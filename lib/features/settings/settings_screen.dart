import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme.dart';
import '../../core/app_info.dart';
import '../../core/database/billing_repository.dart';
import '../../core/providers.dart';
import '../../core/services/public_storage.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_shell.dart';
import '../../core/widgets/labeled_field.dart';
import '../../core/widgets/luxe_button.dart';
import '../../core/widgets/luxe_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _company = TextEditingController();
  final _subtitle = TextEditingController();
  final _title = TextEditingController();
  final _footer = TextEditingController();
  final _price = TextEditingController();
  final _currency = TextEditingController();

  bool _loaded = false;
  bool _saving = false;
  String _busy = '';

  @override
  void dispose() {
    for (final c in [_company, _subtitle, _title, _footer, _price, _currency]) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrate(Map<String, String> s) {
    if (_loaded) return;
    _company.text = s[SettingKeys.companyName] ?? '';
    _subtitle.text = s[SettingKeys.companySubtitle] ?? '';
    _title.text = s[SettingKeys.invoiceTitle] ?? '';
    _footer.text = s[SettingKeys.footerNote] ?? '';
    _price.text = s[SettingKeys.defaultUnitPrice] ?? '';
    _currency.text = s[SettingKeys.currency] ?? '';
    _loaded = true;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(repositoryProvider).saveSettings({
      SettingKeys.companyName: _company.text.trim(),
      SettingKeys.companySubtitle: _subtitle.text.trim(),
      SettingKeys.invoiceTitle: _title.text.trim(),
      SettingKeys.footerNote: _footer.text.trim(),
      SettingKeys.defaultUnitPrice: _price.text.trim(),
      SettingKeys.currency: _currency.text.trim(),
    });
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ الإعدادات')));
  }

  /// تصدير النسخة الاحتياطية إلى **مجلد عام مخصّص** (أسلوب واتساب):
  /// `Documents/فواتير الكهرباء/النسخ الاحتياطي/`.
  ///
  /// يطلب الصلاحية أولاً إن كان النظام يحتاجها (Android ≤ 9 فقط)، وإن رفض
  /// المستخدم أوضحنا له السبب مع زر يفتح إعدادات التطبيق.
  Future<void> _exportToFolder() async {
    setState(() => _busy = 'folder');
    try {
      final json = await ref.read(repositoryProvider).exportJson();
      final name = backupFileName();
      final bytes = Uint8List.fromList(utf8.encode(json));

      final outcome = await PublicStorage.save(
        fileName: name,
        bytes: bytes,
        mimeType: 'application/json',
        subDir: AppInfo.backupsSubDir,
      );

      if (!mounted) return;
      if (outcome.ok) {
        _showSaved(outcome.path);
      } else if (outcome.denied) {
        await _showPermissionSheet();
      } else {
        _snack('تعذّر الحفظ في المجلد: ${outcome.message}');
      }
    } catch (e) {
      _snack('تعذّر تصدير النسخة الاحتياطية');
    } finally {
      if (mounted) setState(() => _busy = '');
    }
  }

  /// نافذة توضيحية عند رفض الصلاحية.
  Future<void> _showPermissionSheet() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('صلاحية الوصول إلى الملفات'),
        content: const Text(
          'لحفظ الملف في مجلد يمكنك الوصول إليه من مدير الملفات، يحتاج '
          'التطبيق صلاحية الوصول إلى الملفات. لن تُقرأ أي ملفات أخرى، '
          'والصلاحية تُستخدم للكتابة فقط.',
          style: TextStyle(height: 1.8),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لاحقًا'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              PublicStorage.openSettings();
            },
            child: const Text(
              'فتح الإعدادات',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  void _showSaved(String path) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'تم الحفظ في المجلد',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(path, style: const TextStyle(fontSize: 11.5)),
          ],
        ),
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _busy = 'export');
    try {
      final json = await ref.read(repositoryProvider).exportJson();
      final name = backupFileName();

      if (kIsWeb) {
        // على الويب: نعرض الملف للنسخ
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('النسخة الاحتياطية'),
            content: SizedBox(
              width: 420,
              child: SelectableText(
                json.length > 4000 ? '${json.substring(0, 4000)}…' : json,
                style: const TextStyle(fontSize: 11),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        );
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$name');
        await file.writeAsString(json, flush: true);
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'application/json')],
            title: 'نسخة احتياطية',
          ),
        );
      }
    } catch (e) {
      _snack('تعذّر تصدير النسخة الاحتياطية');
    } finally {
      if (mounted) setState(() => _busy = '');
    }
  }

  Future<void> _import() async {
    setState(() => _busy = 'import');
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) {
        if (mounted) setState(() => _busy = '');
        return;
      }
      final f = picked.files.first;
      final content = f.bytes != null
          ? utf8.decode(f.bytes!)
          : await File(f.path!).readAsString();

      final result = await ref.read(repositoryProvider).importJson(content);
      _loaded = false;
      if (!mounted) return;
      _snack(
        'تم الاستيراد: ${result.subscribers} مشترك، ${result.invoices} فاتورة',
      );
    } catch (e) {
      _snack('ملف غير صالح أو تالف');
    } finally {
      if (mounted) setState(() => _busy = '');
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء الترخيص'),
        content: const Text(
          'سيُطلب منك إدخال رمز الترخيص مرة أخرى عند فتح التطبيق. البيانات لن تُحذف.',
          style: TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'تأكيد',
              style: TextStyle(
                color: AppColors.btnRed2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_licensed', false);
    if (!mounted) return;
    context.go('/license');
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return AppShell(
      title: 'الإعدادات',
      currentRoute: '/settings',
      onNavigate: (r) => context.go(r),
      child: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (s) {
          _hydrate(s);
          return ListView(
            padding:
                const EdgeInsets.fromLTRB(14, 16, 14, 0) + kBottomNavPadding,
            children: [
              LuxeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(title: 'بيانات الفاتورة', emoji: '🧾'),
                    LabeledField(label: 'اسم الشركة', controller: _company),
                    const SizedBox(height: 12),
                    LabeledField(label: 'وصف الشركة', controller: _subtitle),
                    const SizedBox(height: 12),
                    LabeledField(label: 'عنوان الفاتورة', controller: _title),
                    const SizedBox(height: 12),
                    LabeledField(
                      label: 'ملاحظة أسفل الفاتورة',
                      controller: _footer,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: LabeledField(
                            label: 'سعر الوحدة الافتراضي',
                            controller: _price,
                            numeric: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: LabeledField(
                            label: 'العملة',
                            controller: _currency,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LuxeButton(
                      label: 'حفظ الإعدادات',
                      icon: Icons.save_rounded,
                      variant: LuxeVariant.blue,
                      expanded: true,
                      loading: _saving,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              LuxeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(title: 'النسخ الاحتياطي', emoji: '💾'),
                    const Text(
                      'كل البيانات محفوظة داخل جهازك فقط. صدّر نسخة احتياطية بشكل دوري لحفظها في مكان آمن.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const FolderHint(subDir: AppInfo.backupsSubDir),
                    const SizedBox(height: 14),
                    if (PublicStorage.isSupported) ...[
                      LuxeButton(
                        label: 'حفظ نسخة في مجلد التطبيق',
                        icon: Icons.folder_special_rounded,
                        variant: LuxeVariant.success,
                        expanded: true,
                        loading: _busy == 'folder',
                        onPressed: _busy.isEmpty ? _exportToFolder : null,
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: LuxeButton(
                            label: 'مشاركة نسخة',
                            icon: Icons.upload_file_rounded,
                            variant: LuxeVariant.blue,
                            expanded: true,
                            loading: _busy == 'export',
                            onPressed: _busy.isEmpty ? _export : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: LuxeButton(
                            label: 'استيراد نسخة',
                            icon: Icons.download_for_offline_rounded,
                            variant: LuxeVariant.gold,
                            expanded: true,
                            loading: _busy == 'import',
                            onPressed: _busy.isEmpty ? _import : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              LuxeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(title: 'الترخيص', emoji: '🔐'),
                    LuxeButton(
                      label: 'إلغاء الترخيص',
                      icon: Icons.logout_rounded,
                      variant: LuxeVariant.danger,
                      expanded: true,
                      onPressed: _logout,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              LuxeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(title: 'عن التطبيق', emoji: 'ℹ️'),
                    LuxeButton(
                      label: 'المطوّر والتواصل',
                      icon: Icons.support_agent_rounded,
                      variant: LuxeVariant.ghost,
                      expanded: true,
                      onPressed: () => context.go(AppInfo.aboutRoute),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 54,
                    height: 54,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppInfo.developer,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    AppInfo.versionLabel,
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// شريحة تُبيّن للمستخدم **أين** ستُحفظ ملفاته بالضبط.
///
/// جُعلت عامة (لا تبدأ بشرطة سفلية) لأن شاشة معاينة الفاتورة تستخدمها
/// أيضاً، فلا يتكرّر النص ولا يتناقض بين الشاشتين.
class FolderHint extends StatelessWidget {
  const FolderHint({super.key, required this.subDir});

  final String subDir;

  @override
  Widget build(BuildContext context) {
    if (!PublicStorage.isSupported) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.folder_rounded, size: 18, color: AppColors.goldDark),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'مكان الحفظ على جهازك',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppInfo.publicFolderLabel}/$subDir',
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
