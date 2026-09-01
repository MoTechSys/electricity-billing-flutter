import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme.dart';
import '../../core/app_info.dart';
import '../../core/providers.dart';
import '../../core/services/public_storage.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/luxe_button.dart';
import '../settings/settings_screen.dart' show FolderHint;
import 'invoice_pdf.dart';

/// معاينة الفاتورة — نفس تصميم الويب حرفيًا (A4 أفقي 297×210mm)
/// مع أزرار محسّنة: مشاركة PDF / حفظ PDF / طباعة.
class InvoicePreviewScreen extends ConsumerStatefulWidget {
  const InvoicePreviewScreen({super.key, required this.invoiceId});

  final String invoiceId;

  @override
  ConsumerState<InvoicePreviewScreen> createState() =>
      _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends ConsumerState<InvoicePreviewScreen> {
  String _busy = '';
  Uint8List? _cached;

  Future<Uint8List> _generate() async {
    if (_cached != null) return _cached!;
    final detail = await ref.read(
      invoiceDetailProvider(widget.invoiceId).future,
    );
    if (detail == null || detail.subscriber == null) {
      throw Exception('الفاتورة غير موجودة');
    }
    final settings = await ref.read(repositoryProvider).loadSettings();
    _cached = await buildInvoicePdf(
      invoice: detail.invoice,
      subscriber: detail.subscriber!,
      settings: settings,
    );
    return _cached!;
  }

  Future<void> _share(String fileName) async {
    setState(() => _busy = 'share');
    try {
      final bytes = await _generate();
      if (kIsWeb) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes, flush: true);
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'application/pdf')],
            title: fileName,
          ),
        );
      }
    } catch (e) {
      _snack('تعذّر إنشاء الـ PDF للمشاركة.');
    } finally {
      if (mounted) setState(() => _busy = '');
    }
  }

  /// حفط الفاتورة في **مجلد عام باسم التطبيق** — أسلوب واتساب:
  /// `Documents/فواتير الكهرباء/الفواتير/<اسم المشترك> - <التاريخ>.pdf`
  ///
  /// الملف يبقى في الجهاز حتى لو أُزيل التطبيق، ويراه مدير الملفات
  /// والتطبيقات الأخرى، بخلاف السلوك السابق الذي كان يكتب في مجلد
  /// خاص لا يراه المستخدم أبداً.
  Future<void> _save(String fileName) async {
    setState(() => _busy = 'pdf');
    try {
      final bytes = await _generate();

      if (kIsWeb) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
        return;
      }

      final outcome = await PublicStorage.save(
        fileName: fileName,
        bytes: bytes,
        mimeType: 'application/pdf',
        subDir: AppInfo.invoicesSubDir,
      );

      if (!mounted) return;
      if (outcome.ok) {
        _showSaved(outcome.path);
      } else if (outcome.denied) {
        await _showPermissionSheet();
      } else {
        // بديل أخير كي لا يفقد المستخدم الفاتورة: مجلد التطبيق الخاص.
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes, flush: true);
        if (mounted) _snack('تم الحفط داخل التطبيق: ${file.path}');
      }
    } catch (e) {
      _snack('تعذّر إنشاء الـ PDF.');
    } finally {
      if (mounted) setState(() => _busy = '');
    }
  }

  void _showSaved(String path) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'تم حفط الفاتورة في المجلد',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(path, style: const TextStyle(fontSize: 11.5)),
          ],
        ),
      ),
    );
  }

  Future<void> _showPermissionSheet() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('صلاحية الوصول إلى الملفات'),
        content: const Text(
          'لحفط الفاتورة في مجلد يمكنك الوصول إليه من مدير الملفات، '
          'يحتاج التطبيق صلاحية الوصول إلى الملفات. لن تُقرأ أي ملفات أخرى.',
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

  Future<void> _print(String fileName) async {
    setState(() => _busy = 'print');
    try {
      final bytes = await _generate();
      await Printing.layoutPdf(
        onLayout: (_) => bytes,
        name: fileName,
        format: PdfPageFormat(297 * 72 / 25.4, 210 * 72 / 25.4),
      );
    } catch (e) {
      _snack('تعذّرت الطباعة.');
    } finally {
      if (mounted) setState(() => _busy = '');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(invoiceDetailProvider(widget.invoiceId));

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        title: const Text('معاينة الفاتورة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go('/invoices/archive'),
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$e', textAlign: TextAlign.center),
          ),
        ),
        data: (d) {
          if (d == null || d.subscriber == null) {
            return const Center(
              child: Text(
                'الفاتورة غير موجودة',
                style: TextStyle(
                  color: AppColors.btnRed2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }
          final display = invoiceDisplayNumber(d.invoice.invoiceNumber);

          // ── اسم الملف = **اسم المشترك + التاريخ** ────────────────────
          // كما طلب المستخدم صراحةً. أُضيف رقم الفاتورة في النهاية كي
          // لا تتزاحم فاتورتان لنفس المشترك في اليوم نفسه.
          // التاريخ المستخدم هو تاريخ **إصدار الفاتورة** لا تاريخ اليوم،
          // فيبقى الاسم ثابتاً لو أُعيد الحفظ لاحقاً.
          final fileName = invoiceFileName(
            subscriberName: d.subscriber!.subscriberName,
            date: d.invoice.issuedAt ?? d.invoice.createdAt,
            invoiceNumber: display,
          );

          return Column(
            children: [
              // شريط الأزرار المحسّن
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: LuxeButton(
                            label: 'مشاركة PDF',
                            icon: Icons.ios_share_rounded,
                            variant: LuxeVariant.success,
                            expanded: true,
                            compact: true,
                            loading: _busy == 'share',
                            onPressed: _busy.isEmpty
                                ? () => _share(fileName)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LuxeButton(
                            label: 'حفظ في المجلد',
                            icon: Icons.folder_special_rounded,
                            variant: LuxeVariant.blue,
                            expanded: true,
                            compact: true,
                            loading: _busy == 'pdf',
                            onPressed: _busy.isEmpty
                                ? () => _save(fileName)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LuxeButton(
                            label: 'طباعة',
                            icon: Icons.print_rounded,
                            variant: LuxeVariant.gold,
                            expanded: true,
                            compact: true,
                            loading: _busy == 'print',
                            onPressed: _busy.isEmpty
                                ? () => _print(fileName)
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // يرى المستخدم **أين** سيُحفظ الملف وبأي اسم، قبل الضغط.
                    const FolderHint(subDir: AppInfo.invoicesSubDir),
                    const SizedBox(height: 6),
                    Text(
                      'اسم الملف: $fileName',
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              // المعاينة — الفاتورة الفعلية بلا أي تعديل
              Expanded(
                child: PdfPreview(
                  build: (_) => _generate(),
                  pdfFileName: fileName,
                  useActions: false,
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  allowPrinting: false,
                  allowSharing: false,
                  initialPageFormat: PdfPageFormat(
                    297 * 72 / 25.4,
                    210 * 72 / 25.4,
                  ),
                  scrollViewDecoration: const BoxDecoration(
                    color: Color(0xFFE8E8E8),
                  ),
                  pdfPreviewPageDecoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 24,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  loadingWidget: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
