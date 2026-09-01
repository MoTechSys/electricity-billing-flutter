import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables.dart';
import '../../core/providers.dart';
import '../../core/widgets/app_shell.dart';
import '../../core/widgets/labeled_field.dart';
import '../../core/widgets/luxe_button.dart';
import '../../core/widgets/luxe_card.dart';

class SubscribersScreen extends ConsumerWidget {
  const SubscribersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(subscribersProvider);

    return AppShell(
      title: 'المشتركون',
      currentRoute: '/subscribers',
      onNavigate: (r) => context.go(r),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: SearchBarField(
                    hint: 'ابحث بالاسم أو رقم المشترك أو العداد',
                    onChanged: (v) => ref
                        .read(subscriberQueryProvider.notifier)
                        .state = v,
                  ),
                ),
                const SizedBox(width: 10),
                LuxeButton(
                  label: 'إضافة',
                  icon: Icons.person_add_alt_1_rounded,
                  variant: LuxeVariant.gold,
                  compact: true,
                  onPressed: () => context.push('/subscribers/new'),
                ),
              ],
            ),
          ),
          Expanded(
            child: list.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ: $e')),
              data: (rows) {
                if (rows.isEmpty) {
                  return EmptyState(
                    icon: Icons.groups_rounded,
                    title: 'لا يوجد مشتركون',
                    subtitle: 'أضف أول مشترك للبدء في إصدار الفواتير.',
                    action: LuxeButton(
                      label: 'إضافة مشترك',
                      icon: Icons.person_add_alt_1_rounded,
                      variant: LuxeVariant.gold,
                      onPressed: () => context.push('/subscribers/new'),
                    ),
                  );
                }
                return ListView.separated(
                  padding:
                      const EdgeInsets.fromLTRB(14, 4, 14, 0) + kBottomNavPadding,
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _SubscriberTile(row: rows[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriberTile extends ConsumerWidget {
  const _SubscriberTile({required this.row});

  final SubscriberRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = row.status == SubscriberStatus.active;

    return LuxeCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: active
                    ? [
                        AppColors.statGreen.withValues(alpha: 0.22),
                        AppColors.statGreen.withValues(alpha: 0.08),
                      ]
                    : [
                        AppColors.textMuted.withValues(alpha: 0.20),
                        AppColors.textMuted.withValues(alpha: 0.07),
                      ],
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 22,
              color: active ? AppColors.statGreen : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.subscriberName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    StatusPill(
                      text: active ? 'نشط' : 'غير نشط',
                      color: active ? AppColors.statGreen : AppColors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 12,
                  runSpacing: 3,
                  children: [
                    if (row.subscriberNumber.isNotEmpty)
                      _meta(Icons.tag_rounded, row.subscriberNumber),
                    if (row.meterNumber.isNotEmpty)
                      _meta(Icons.speed_rounded, row.meterNumber),
                    if (row.cabinName.isNotEmpty)
                      _meta(Icons.electrical_services_rounded, row.cabinName),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.textMuted,
            ),
            onSelected: (v) => _handle(context, ref, v),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'invoice',
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_rounded,
                        size: 18, color: AppColors.btnBlue1),
                    SizedBox(width: 8),
                    Text('إصدار فاتورة'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      active ? Icons.block_rounded : Icons.check_circle_rounded,
                      size: 18,
                      color: active ? AppColors.statOrange : AppColors.statGreen,
                    ),
                    const SizedBox(width: 8),
                    Text(active ? 'تعطيل' : 'تنشيط'),
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
    );
  }

  Widget _meta(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: AppColors.textMuted),
      const SizedBox(width: 3),
      Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final repo = ref.read(repositoryProvider);
    switch (action) {
      case 'invoice':
        context.go('/invoices/new?subscriber=${row.id}');
      case 'toggle':
        await repo.updateSubscriberStatus(
          row.id,
          row.status == SubscriberStatus.active
              ? SubscriberStatus.inactive
              : SubscriberStatus.active,
        );
      case 'delete':
        final count = await repo.countInvoicesOf(row.id);
        if (!context.mounted) return;
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('حذف المشترك'),
            content: Text(
              count > 0
                  ? 'سيتم حذف المشترك «${row.subscriberName}» و $count فاتورة مرتبطة به. لا يمكن التراجع.'
                  : 'سيتم حذف المشترك «${row.subscriberName}». لا يمكن التراجع.',
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
        if (ok == true) await repo.deleteSubscriber(row.id);
    }
  }
}
