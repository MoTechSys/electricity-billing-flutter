import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/database/billing_repository.dart';
import '../../core/database/tables.dart';
import '../../core/providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_shell.dart';
import '../../core/widgets/labeled_field.dart';
import '../../core/widgets/luxe_button.dart';
import '../../core/widgets/luxe_card.dart';
import 'invoice_pdf.dart';

const _statusMeta = <String, (String, Color)>{
  InvoiceStatus.issued: ('صادرة', AppColors.statGreen),
  InvoiceStatus.draft: ('مسودة', AppColors.statYellow),
  InvoiceStatus.cancelled: ('ملغاة', AppColors.btnRed2),
};

class InvoiceArchiveScreen extends ConsumerWidget {
  const InvoiceArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(invoicesProvider);
    final filter = ref.watch(invoiceStatusFilterProvider);

    return AppShell(
      title: 'أرشيف الفواتير',
      currentRoute: '/invoices/archive',
      onNavigate: (r) => context.go(r),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: SearchBarField(
              hint: 'ابحث برقم الفاتورة أو اسم المشترك',
              onChanged: (v) =>
                  ref.read(invoiceQueryProvider.notifier).state = v,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                _chip(ref, 'الكل', null, filter),
                const SizedBox(width: 8),
                _chip(ref, 'صادرة', InvoiceStatus.issued, filter),
                const SizedBox(width: 8),
                _chip(ref, 'مسودة', InvoiceStatus.draft, filter),
                const SizedBox(width: 8),
                _chip(ref, 'ملغاة', InvoiceStatus.cancelled, filter),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: list.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ: $e')),
              data: (rows) {
                if (rows.isEmpty) {
                  return EmptyState(
                    icon: Icons.inventory_2_rounded,
                    title: 'لا توجد فواتير',
                    subtitle: 'أصدر أول فاتورة لتظهر هنا.',
                    action: LuxeButton(
                      label: 'فاتورة جديدة',
                      icon: Icons.add_circle_outline_rounded,
                      onPressed: () => context.go('/invoices/new'),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 0) +
                      kBottomNavPadding,
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _InvoiceTile(item: rows[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(WidgetRef ref, String label, String? value, String? current) {
    final active = current == value;
    return GestureDetector(
      onTap: () =>
          ref.read(invoiceStatusFilterProvider.notifier).state = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [AppColors.navy2, AppColors.navy],
                )
              : null,
          color: active ? null : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppColors.navy : const Color(0xFFDDE3EE),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _InvoiceTile extends ConsumerWidget {
  const _InvoiceTile({required this.item});

  final InvoiceWithSubscriber item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inv = item.invoice;
    final meta = _statusMeta[inv.status] ?? ('—', AppColors.textMuted);

    return LuxeCard(
      onTap: () => context.push('/invoices/${inv.id}/print'),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${invoiceDisplayNumber(inv.invoiceNumber)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(text: meta.$1, color: meta.$2),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onSelected: (v) => _handle(context, ref, v),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'open',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_rounded,
                            size: 18, color: AppColors.btnBlue1),
                        SizedBox(width: 8),
                        Text('عرض / طباعة'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.btnRed2),
                        SizedBox(width: 8),
                        Text('حذف'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.subscriberName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.date_range_rounded,
                  size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'من ${inv.periodFrom} حتى ${inv.periodTo}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${fmt(inv.netDue)} ${inv.currency}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.invoiceBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    switch (action) {
      case 'open':
        context.push('/invoices/${item.invoice.id}/print');
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('حذف الفاتورة'),
            content: Text(
              'سيتم حذف الفاتورة #${invoiceDisplayNumber(item.invoice.invoiceNumber)} نهائيًا.',
              style: const TextStyle(height: 1.6),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'حذف',
                  style: TextStyle(
                    color: AppColors.btnRed2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );
        if (ok == true) {
          await ref.read(repositoryProvider).deleteInvoice(item.invoice.id);
        }
    }
  }
}
