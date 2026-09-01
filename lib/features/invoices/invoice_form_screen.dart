import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/database/billing_repository.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables.dart';
import '../../core/providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/invoice_calculator.dart';
import '../../core/widgets/labeled_field.dart';
import '../../core/widgets/luxe_button.dart';
import '../../core/widgets/luxe_card.dart';

class InvoiceFormScreen extends ConsumerStatefulWidget {
  const InvoiceFormScreen({super.key, this.presetSubscriberId});

  final String? presetSubscriberId;

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  final _search = TextEditingController();
  final _cycle = TextEditingController();
  final _periodFrom = TextEditingController();
  final _periodTo = TextEditingController();
  final _prev = TextEditingController();
  final _curr = TextEditingController();
  final _price = TextEditingController(text: '220');
  final _services = TextEditingController(text: '0');
  final _arrears = TextEditingController(text: '0');
  final _paid = TextEditingController(text: '0');
  final _notes = TextEditingController();

  SubscriberRow? _selected;
  List<SubscriberRow> _options = const [];
  bool _showDropdown = false;
  bool _showAdvanced = false;
  String _lastReadingNote = '';
  String? _error;
  bool _busy = false;
  String _currency = 'ريال';

  InvoiceCalculation? _calc;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [
      _search,
      _cycle,
      _periodFrom,
      _periodTo,
      _prev,
      _curr,
      _price,
      _services,
      _arrears,
      _paid,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final repo = ref.read(repositoryProvider);
    final settings = await repo.loadSettings();
    final subs = await repo.searchSubscribers('', limit: 20);
    if (!mounted) return;
    setState(() {
      _price.text = settings[SettingKeys.defaultUnitPrice] ?? '220';
      _currency = settings[SettingKeys.currency] ?? 'ريال';
      _options = subs;
      _periodTo.text = todayStamp();
    });

    if (widget.presetSubscriberId != null) {
      final sub = await repo.getSubscriber(widget.presetSubscriberId!);
      if (sub != null && mounted) await _select(sub);
    }
  }

  Future<void> _refreshOptions(String query) async {
    final subs = await ref
        .read(repositoryProvider)
        .searchSubscribers(query, limit: 20);
    if (mounted) setState(() => _options = subs);
  }

  Future<void> _select(SubscriberRow sub) async {
    final last = await ref.read(repositoryProvider).lastReadingOf(sub.id);
    if (!mounted) return;
    setState(() {
      _selected = sub;
      _showDropdown = false;
      _search.clear();
      if (last != null) {
        _prev.text = fmtInt(last);
        _lastReadingNote =
            'تم جلب القراءة السابقة (${fmtInt(last)}) تلقائياً من آخر فاتورة';
      } else {
        _prev.clear();
        _lastReadingNote = 'لا توجد فواتير سابقة — أدخل القراءة السابقة يدوياً';
      }
      if (_cycle.text.trim().isEmpty) _cycle.text = sub.routeNumber;
    });
    _scheduleCalc();
  }

  void _scheduleCalc() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _recalc);
  }

  void _recalc() {
    final prev = parseNum(_prev.text);
    final curr = parseNum(_curr.text);
    final price = parseNum(_price.text);

    if (curr >= prev && price > 0 && _curr.text.trim().isNotEmpty) {
      final r = calculateInvoice(
        previousReading: prev,
        currentReading: curr,
        unitPrice: price,
        servicesAmount: parseNum(_services.text),
        arrearsAmount: parseNum(_arrears.text),
        paidDuringPeriod: parseNum(_paid.text),
        currency: _currency,
      );
      if (mounted) setState(() => _calc = r);
    } else {
      if (mounted) setState(() => _calc = null);
    }
  }

  Future<void> _pickDate(TextEditingController target) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(
        () => target.text =
            '${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}',
      );
    }
  }

  Future<void> _submit(bool issue) async {
    if (_selected == null) {
      setState(() => _error = 'يرجى اختيار مشترك');
      return;
    }
    if (_periodFrom.text.trim().isEmpty || _periodTo.text.trim().isEmpty) {
      setState(() => _error = 'يرجى تحديد الفترة');
      return;
    }
    if (_prev.text.trim().isEmpty || _curr.text.trim().isEmpty) {
      setState(() => _error = 'يرجى إدخال القراءات');
      return;
    }

    final prev = parseNum(_prev.text);
    final curr = parseNum(_curr.text);
    if (curr < prev) {
      setState(() => _error = 'القراءة الحالية أقل من السابقة');
      return;
    }

    setState(() {
      _error = null;
      _busy = true;
    });

    final repo = ref.read(repositoryProvider);
    final price = parseNum(_price.text);
    final services = parseNum(_services.text);
    final arrears = parseNum(_arrears.text);
    final paid = parseNum(_paid.text);

    final r = calculateInvoice(
      previousReading: prev,
      currentReading: curr,
      unitPrice: price,
      servicesAmount: services,
      arrearsAmount: arrears,
      paidDuringPeriod: paid,
      currency: _currency,
    );

    final now = DateTime.now();
    final id = BillingRepository.generateId();
    final number = await repo.nextInvoiceNumber();

    await repo.insertInvoice(
      InvoicesCompanion.insert(
        id: id,
        invoiceNumber: number,
        cycleNumber: Value(_cycle.text.trim()),
        subscriberId: _selected!.id,
        periodFrom: normalizeDate(_periodFrom.text),
        periodTo: normalizeDate(_periodTo.text),
        previousReading: Value(prev),
        currentReading: Value(curr),
        consumptionKwh: Value(r.consumptionKwh),
        unitPrice: Value(price),
        baseValue: Value(r.baseValue),
        servicesAmount: Value(services),
        arrearsAmount: Value(arrears),
        paidDuringPeriod: Value(paid),
        grossAmount: Value(r.grossAmount),
        netDue: Value(r.netDue),
        netDueWords: Value(r.netDueWords),
        currency: Value(_currency),
        status: Value(issue ? InvoiceStatus.issued : InvoiceStatus.draft),
        notes: Value(_notes.text.trim()),
        issuedAt: Value(issue ? now : null),
        createdAt: now,
        updatedAt: now,
      ),
    );

    if (!mounted) return;
    setState(() => _busy = false);

    if (issue) {
      context.push('/invoices/$id/print');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ المسودة بنجاح')));
      context.go('/invoices/archive');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إصدار فاتورة جديدة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/dashboard'),
        ),
      ),
      body: GestureDetector(
        onTap: () => setState(() => _showDropdown = false),
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            _subscriberSection(),
            const SizedBox(height: 14),
            _invoiceDataSection(),
            const SizedBox(height: 14),
            if (_calc != null) _resultsSection(_calc!),
            if (_error != null) ...[
              const SizedBox(height: 12),
              _errorBox(_error!),
            ],
            const SizedBox(height: 16),
            LuxeButton(
              label: 'إصدار الفاتورة',
              icon: Icons.receipt_long_rounded,
              variant: LuxeVariant.blue,
              expanded: true,
              loading: _busy,
              onPressed: () => _submit(true),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: LuxeButton(
                    label: 'حفظ كمسودة',
                    icon: Icons.save_outlined,
                    variant: LuxeVariant.gold,
                    expanded: true,
                    onPressed: _busy ? null : () => _submit(false),
                  ),
                ),
                const SizedBox(width: 10),
                LuxeButton(
                  label: 'إلغاء',
                  variant: LuxeVariant.ghost,
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go('/dashboard'),
                ),
              ],
            ),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }

  // ── القسم 1: بيانات المشترك ──────────────────────────────────────
  Widget _subscriberSection() {
    return LuxeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'بيانات المشترك', emoji: '📋'),
          if (_selected == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _search,
                  onTap: () => setState(() => _showDropdown = true),
                  onChanged: (v) {
                    setState(() => _showDropdown = true);
                    _refreshOptions(v);
                  },
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'اختر العميل: ابحث بالاسم أو الرقم...',
                    prefixIcon: Icon(Icons.person_search_rounded, size: 20),
                  ),
                ),
                if (_showDropdown && _options.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 240),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE1E7F1)),
                      boxShadow: AppShadows.card,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _options.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final s = _options[i];
                        return ListTile(
                          dense: true,
                          onTap: () => _select(s),
                          title: Text(
                            s.subscriberName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            'رقم المشترك: ${s.subscriberNumber} | العداد: ${s.meterNumber}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.btnBlue1.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.btnBlue1.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selected!.subscriberName,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => setState(() {
                          _selected = null;
                          _lastReadingNote = '';
                          _prev.clear();
                        }),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('تغيير'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.btnRed2,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 32),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      _kv('رقم المشترك', _selected!.subscriberNumber),
                      _kv('رقم العداد', _selected!.meterNumber),
                      _kv('خط السير', _selected!.routeNumber),
                      _kv('الكبينة', _selected!.cabinName),
                    ],
                  ),
                ],
              ),
            ),
          if (_lastReadingNote.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AppColors.statGreen,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _lastReadingNote,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.statGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => RichText(
    text: TextSpan(
      style: const TextStyle(fontFamily: kFontFamily, fontSize: 13),
      children: [
        TextSpan(
          text: '$k: ',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        TextSpan(
          text: v.isEmpty ? '—' : v,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );

  // ── القسم 2: بيانات الفاتورة ─────────────────────────────────────
  Widget _invoiceDataSection() {
    return LuxeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'بيانات الفاتورة', emoji: '📊'),
          Row(
            children: [
              Expanded(child: _dateField('الفترة من', _periodFrom)),
              const SizedBox(width: 10),
              Expanded(child: _dateField('الفترة إلى', _periodTo)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LabeledField(
                  label: 'القراءة السابقة',
                  controller: _prev,
                  numeric: true,
                  required: true,
                  onChanged: (_) => _scheduleCalc(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LabeledField(
                  label: 'القراءة الحالية',
                  controller: _curr,
                  numeric: true,
                  required: true,
                  onChanged: (_) => _scheduleCalc(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LabeledField(
                  label: 'سعر الوحدة',
                  controller: _price,
                  numeric: true,
                  required: true,
                  suffix: _currency,
                  onChanged: (_) => _scheduleCalc(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LabeledField(
                  label: 'خدمات',
                  controller: _services,
                  numeric: true,
                  onChanged: (_) => _scheduleCalc(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // إعدادات إضافية قابلة للطي
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 4, bottom: 4),
              initiallyExpanded: _showAdvanced,
              onExpansionChanged: (v) => setState(() => _showAdvanced = v),
              title: const Text(
                '⚙️  إعدادات إضافية',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy2,
                ),
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LabeledField(
                        label: 'رقم الدورة',
                        controller: _cycle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: LabeledField(
                        label: 'المتأخرات',
                        controller: _arrears,
                        numeric: true,
                        onChanged: (_) => _scheduleCalc(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'مدفوع خلال الفترة',
                  controller: _paid,
                  numeric: true,
                  onChanged: (_) => _scheduleCalc(),
                ),
                const SizedBox(height: 12),
                LabeledField(label: 'ملاحظات', controller: _notes, maxLines: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField(String label, TextEditingController c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 6, right: 2),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF44506B),
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: AppColors.btnRed2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      TextField(
        controller: c,
        readOnly: true,
        onTap: () => _pickDate(c),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        decoration: const InputDecoration(
          hintText: 'yyyy/mm/dd',
          suffixIcon: Icon(Icons.calendar_month_rounded, size: 19),
        ),
      ),
    ],
  );

  // ── القسم 3: النتائج المحسوبة ────────────────────────────────────
  Widget _resultsSection(InvoiceCalculation c) {
    return LuxeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'النتائج المحسوبة', emoji: '💰'),
          Row(
            children: [
              Expanded(
                child: ResultTile(
                  label: 'الاستهلاك',
                  value: fmt(c.consumptionKwh),
                  suffix: 'ك.و.س',
                  color: AppColors.statBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ResultTile(
                  label: 'القيمة',
                  value: fmt(c.baseValue),
                  suffix: _currency,
                  color: AppColors.statPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ResultTile(
                  label: 'الإجمالي',
                  value: fmt(c.grossAmount),
                  suffix: _currency,
                  color: AppColors.statOrange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ResultTile(
                  label: 'المبلغ المستحق',
                  value: fmt(c.netDue),
                  suffix: _currency,
                  color: AppColors.invoiceBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.navy.withValues(alpha: 0.12)),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 13,
                  height: 1.7,
                  color: AppColors.textPrimary,
                ),
                children: [
                  const TextSpan(
                    text: 'المبلغ المستحق كتابةً هو :- ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: c.netDueWords,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBox(String message) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.btnRed1.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.btnRed1.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 18,
          color: AppColors.btnRed2,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: AppColors.btnRed3,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}
