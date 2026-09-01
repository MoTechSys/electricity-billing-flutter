import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/providers.dart';
import '../../core/widgets/labeled_field.dart';
import '../../core/widgets/luxe_button.dart';
import '../../core/widgets/luxe_card.dart';

class SubscriberFormScreen extends ConsumerStatefulWidget {
  const SubscriberFormScreen({super.key});

  @override
  ConsumerState<SubscriberFormScreen> createState() =>
      _SubscriberFormScreenState();
}

class _SubscriberFormScreenState extends ConsumerState<SubscriberFormScreen> {
  final _number = TextEditingController();
  final _name = TextEditingController();
  final _meter = TextEditingController();
  final _route = TextEditingController();
  final _cabin = TextEditingController();
  final _location = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();

  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [
      _number,
      _name,
      _meter,
      _route,
      _cabin,
      _location,
      _phone,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _error = null;
      _busy = true;
    });

    final number = _number.text.trim();
    final name = _name.text.trim();
    final meter = _meter.text.trim();

    if (number.isEmpty || name.isEmpty || meter.isEmpty) {
      setState(() {
        _error = 'يرجى تعبئة الحقول الأساسية';
        _busy = false;
      });
      return;
    }

    final repo = ref.read(repositoryProvider);

    // فحص التكرار
    final existing = await repo.searchSubscribers(number, limit: 200);
    if (existing.any((s) => s.subscriberNumber == number)) {
      setState(() {
        _error = 'رقم المشترك موجود مسبقاً';
        _busy = false;
      });
      return;
    }
    final byMeter = await repo.searchSubscribers(meter, limit: 200);
    if (byMeter.any((s) => s.meterNumber == meter)) {
      setState(() {
        _error = 'رقم العداد موجود مسبقاً';
        _busy = false;
      });
      return;
    }

    await repo.insertSubscriber(
      subscriberName: name,
      subscriberNumber: number,
      meterNumber: meter,
      routeNumber: _route.text.trim(),
      cabinName: _cabin.text.trim(),
      locationName: _location.text.trim(),
      phone: _phone.text.trim(),
      notes: _notes.text.trim(),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ المشترك بنجاح')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة مشترك جديد')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          LuxeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'بيانات المشترك', emoji: '👤'),
                LabeledField(
                  label: 'رقم المشترك',
                  controller: _number,
                  required: true,
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'اسم المشترك',
                  controller: _name,
                  required: true,
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'رقم العداد',
                  controller: _meter,
                  required: true,
                ),
                const SizedBox(height: 12),
                LabeledField(label: 'رقم خط السير', controller: _route),
                const SizedBox(height: 12),
                LabeledField(label: 'الكبينة', controller: _cabin),
                const SizedBox(height: 12),
                LabeledField(label: 'الموقع / العنوان', controller: _location),
                const SizedBox(height: 12),
                LabeledField(label: 'الهاتف', controller: _phone),
                const SizedBox(height: 12),
                LabeledField(label: 'ملاحظات', controller: _notes, maxLines: 3),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.btnRed1.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.btnRed1.withValues(alpha: 0.3),
                ),
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
                      _error!,
                      style: const TextStyle(
                        color: AppColors.btnRed3,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LuxeButton(
                  label: 'حفظ المشترك',
                  icon: Icons.save_rounded,
                  variant: LuxeVariant.blue,
                  expanded: true,
                  loading: _busy,
                  onPressed: _save,
                ),
              ),
              const SizedBox(width: 10),
              LuxeButton(
                label: 'إلغاء',
                variant: LuxeVariant.ghost,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
