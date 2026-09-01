import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/database/billing_repository.dart';
import '../../core/providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_shell.dart';
import '../../core/widgets/luxe_button.dart';
import '../../core/widgets/luxe_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final settings = ref.watch(settingsProvider).value;
    final currency = settingOf(settings, SettingKeys.currency);

    return AppShell(
      currentRoute: '/dashboard',
      onNavigate: (r) => context.go(r),
      child: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBox(message: '$e', onRetry: () => ref.invalidate(statsProvider)),
        data: (s) => ListView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 0) + kBottomNavPadding,
          children: [
            _Greeting(currency: currency, revenue: s.revenue),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth >= 620 ? 3 : 2;
                return GridView.count(
                  crossAxisCount: cols,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    StatCard(
                      label: 'إجمالي المشتركين',
                      value: fmtInt(s.subscribers),
                      icon: Icons.groups_rounded,
                      color: AppColors.statBlue,
                      onTap: () => context.go('/subscribers'),
                    ),
                    StatCard(
                      label: 'المشتركون النشطون',
                      value: fmtInt(s.activeSubscribers),
                      icon: Icons.how_to_reg_rounded,
                      color: AppColors.statGreen,
                      onTap: () => context.go('/subscribers'),
                    ),
                    StatCard(
                      label: 'إجمالي الفواتير',
                      value: fmtInt(s.invoices),
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.statPurple,
                      onTap: () => context.go('/invoices/archive'),
                    ),
                    StatCard(
                      label: 'فواتير صادرة',
                      value: fmtInt(s.issued),
                      icon: Icons.task_alt_rounded,
                      color: AppColors.statOrange,
                      onTap: () => context.go('/invoices/archive'),
                    ),
                    StatCard(
                      label: 'مسودات',
                      value: fmtInt(s.drafts),
                      icon: Icons.edit_note_rounded,
                      color: AppColors.statYellow,
                      onTap: () => context.go('/invoices/archive'),
                    ),
                    StatCard(
                      label: 'إجمالي المستحقات',
                      value: fmt(s.revenue),
                      icon: Icons.payments_rounded,
                      color: AppColors.statEmerald,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _RevenueChart(daily: s.daily),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LuxeButton(
                    label: 'فاتورة جديدة',
                    icon: Icons.add_circle_outline_rounded,
                    variant: LuxeVariant.blue,
                    expanded: true,
                    onPressed: () => context.go('/invoices/new'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: LuxeButton(
                    label: 'مشترك جديد',
                    icon: Icons.person_add_alt_1_rounded,
                    variant: LuxeVariant.gold,
                    expanded: true,
                    onPressed: () => context.push('/subscribers/new'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.currency, required this.revenue});

  final String currency;
  final double revenue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.8, -1),
          end: Alignment(0.8, 1),
          colors: [AppColors.navy2, AppColors.navy],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.32)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330F1B3D),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إجمالي المستحقات',
                  style: TextStyle(
                    color: AppColors.goldLight.withValues(alpha: 0.9),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        fmt(revenue),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currency,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [AppColors.goldLight, AppColors.goldDark],
              ),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Color(0xFF2A2102),
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  const _RevenueChart({required this.daily});

  final List<DailyTotal> daily;

  @override
  Widget build(BuildContext context) {
    final maxY = daily.fold<double>(0, (m, d) => d.total > m ? d.total : m);
    final safeMax = maxY <= 0 ? 100.0 : maxY * 1.25;

    return LuxeCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'المستحقات — آخر 7 أيام', emoji: '📈'),
          SizedBox(
            height: 168,
            child: BarChart(
              BarChartData(
                maxY: safeMax,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.navy,
                    getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                      fmt(rod.toY),
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        fontFamily: kFontFamily,
                      ),
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: safeMax / 4,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFE6EAF2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= daily.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            daily[i].label,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < daily.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: daily[i].total,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppColors.navy, AppColors.statBlue],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 46, color: AppColors.btnRed2),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 18),
            LuxeButton(
              label: 'إعادة المحاولة',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
