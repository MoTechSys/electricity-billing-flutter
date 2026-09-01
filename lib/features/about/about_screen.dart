import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../core/app_info.dart';
import '../../core/widgets/app_shell.dart';
import '../../core/widgets/luxe_card.dart';

/// صفحة المطوّر والتواصل — واتساب + الموقع + معلومات التطبيق.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _open(BuildContext context, Uri uri, String label) async {
    // `LaunchMode.externalApplication` ضروري: بدونه يحاول Android فتح
    // الرابط داخل WebView التطبيق، فلا يُسلّم لواتساب.
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا يوجد تطبيق يفتح $label على هذا الجهاز')),
      );
    }
  }

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم النسخ')));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'المطوّر والتواصل',
      currentRoute: AppInfo.aboutRoute,
      onNavigate: (r) => context.go(r),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 0) + kBottomNavPadding,
        children: [
          // ── ترويسة المطوّر ─────────────────────────────────────────
          LuxeCard(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  // الشعار كما هو تمامًا — لا يتغيّر
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  AppInfo.developer,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 2,
                  width: 90,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x00C9A227),
                        AppColors.gold,
                        Color(0x00C9A227),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'تصميم وبرمجة أنظمة الفواتير والإدارة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── قنوات التواصل ─────────────────────────────────────────
          LuxeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'تواصل معنا', emoji: '📞'),
                _ContactTile(
                  icon: Icons.chat_rounded,
                  color: const Color(0xFF25D366),
                  title: 'واتساب',
                  value: AppInfo.whatsappDisplay,
                  onTap: () =>
                      _open(context, Uri.parse(AppInfo.whatsappUrl), 'واتساب'),
                  onLongPress: () => _copy(context, AppInfo.whatsappDisplay),
                ),
                const SizedBox(height: 10),
                _ContactTile(
                  icon: Icons.language_rounded,
                  color: AppColors.btnBlue1,
                  title: 'الموقع الإلكتروني',
                  value: AppInfo.websiteDisplay,
                  onTap: () =>
                      _open(context, Uri.parse(AppInfo.websiteUrl), 'المتصفح'),
                  onLongPress: () => _copy(context, AppInfo.websiteUrl),
                ),
                const SizedBox(height: 10),
                _ContactTile(
                  icon: Icons.phone_rounded,
                  color: AppColors.gold,
                  title: 'اتصال هاتفي',
                  value: AppInfo.whatsappDisplay,
                  onTap: () => _open(
                    context,
                    Uri.parse('tel:${AppInfo.phoneE164}'),
                    'تطبيق الهاتف',
                  ),
                  onLongPress: () => _copy(context, AppInfo.whatsappDisplay),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اضغط ضغطة طويلة لنسخ أي بيانات تواصل.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── معلومات التطبيق ───────────────────────────────────────
          LuxeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'معلومات التطبيق', emoji: 'ℹ️'),
                const _InfoRow(label: 'اسم التطبيق', value: AppInfo.appName),
                const _InfoRow(label: 'الإصدار', value: AppInfo.versionLabel),
                const _InfoRow(label: 'معرّف الحزمة', value: AppInfo.packageId),
                const _InfoRow(
                  label: 'مكان البيانات',
                  value: 'داخل جهازك فقط — بلا خدمات سحابية',
                ),
                const _InfoRow(
                  label: 'مجلد الحفظ',
                  value: AppInfo.publicFolderLabel,
                  last: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          LuxeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'الخصوصية', emoji: '🔒'),
                const Text(
                  'لا يجمع التطبيق أي بيانات ولا يرسلها إلى أي جهة. '
                  'كل المشتركين والفواتير والإعدادات محفوظة في قاعدة بيانات '
                  'محليّة داخل جهازك، ولا يعمل التطبيق بحاجة إلى إنترنت. '
                  'الملفات التي تُصدّرها (الفواتير والنسخ الاحتياطية) تُكتب '
                  'في مجلد عام تملكه أنت، وتبقى في جهازك حتى لو أزلت التطبيق.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                    height: 1.9,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          const Text(
            AppInfo.developer,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            AppInfo.versionLabel,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, size: 21, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: color.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: last
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
