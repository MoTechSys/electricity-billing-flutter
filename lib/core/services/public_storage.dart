import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// نتيجة محاولة الحفظ في مجلد عام.
class SaveOutcome {
  const SaveOutcome._({
    required this.ok,
    required this.path,
    required this.message,
    required this.denied,
  });

  /// نجح الحفظ في المجلد العام.
  factory SaveOutcome.saved(String path) =>
      SaveOutcome._(ok: true, path: path, message: '', denied: false);

  /// رفض المستخدم الصلاحية.
  factory SaveOutcome.permissionDenied(String message) =>
      SaveOutcome._(ok: false, path: '', message: message, denied: true);

  /// فشل لسبب آخر.
  factory SaveOutcome.failed(String message) =>
      SaveOutcome._(ok: false, path: '', message: message, denied: false);

  final bool ok;
  final String path;
  final String message;
  final bool denied;
}

/// حفظ الملفات في **مجلد عام باسم التطبيق** — على غرار واتساب.
///
/// كيف يعمل؟
/// -------------------------------------------------------------------
/// * على Android 10 (API 29) وما بعده: يُكتب الملف عبر `MediaStore`
///   داخل `Documents/فواتير الكهرباء/…`. **لا صلاحية مطلوبة** لأن
///   التطبيق هو مُنشئ الملف، والملف يبقى بعد إزالة التطبيق ويظهر في
///   كل تطبيقات إدارة الملفات.
/// * على Android 9 (API ≤ 28): لا يوجد `MediaStore` للمستندات، فيُكتب
///   الملف بمسار عادي، وهذا **يحتاج صلاحية** `WRITE_EXTERNAL_STORAGE`
///   فنطلبها من المستخدم أولاً.
/// * على الويب / منصات أخرى: لا يوجد مجلد عام، فنُرجع فشلاً ليتولّى
///   المُستدعي البديل (مشاركة / تنزيل عبر المتصفح).
class PublicStorage {
  PublicStorage._();

  static const _channel = MethodChannel(
    'com.abbasisoft.billing/public_storage',
  );

  /// هل المنصة تدعم الحفظ في مجلد عام أصلاً؟
  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  /// وصف المجلد لعرضه للمستخدم، مثل «Documents/فواتير الكهرباء».
  static Future<String> folderLabel() async {
    if (!isSupported) return 'مجلد المستندات';
    try {
      return await _channel.invokeMethod<String>('folderLabel') ??
          'Documents/فواتير الكهرباء';
    } on PlatformException {
      return 'Documents/فواتير الكهرباء';
    }
  }

  /// هل نسخة النظام الحالية تحتاج صلاحية تخزين تقليدية؟
  static Future<bool> _needsLegacyPermission() async {
    try {
      return await _channel.invokeMethod<bool>('needsLegacyPermission') ??
          false;
    } on PlatformException {
      return false;
    }
  }

  /// يطلب صلاحية التخزين **فقط** إن كان النظام يحتاجها فعلاً.
  ///
  /// نتفادى إزعاج مستخدمي Android 10+ بنافذة صلاحية لا لزوم لها؛
  /// وهذا هو السلوك الصحيح المعتمد وليس مجرد تحسين شكلي.
  static Future<bool> ensurePermission() async {
    if (!isSupported) return false;
    if (!await _needsLegacyPermission()) return true;

    final status = await Permission.storage.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) return false;

    final asked = await Permission.storage.request();
    return asked.isGranted;
  }

  /// يفتح إعدادات التطبيق ليمنح المستخدم الصلاحية يدوياً بعد رفض دائم.
  static Future<void> openSettings() => openAppSettings();

  /// يحفظ [bytes] باسم [fileName] داخل المجلد العام للتطبيق.
  ///
  /// [subDir] مجلد فرعي اختياري داخل مجلد التطبيق، مثل «الفواتير» أو
  /// «النسخ الاحتياطي»، فيبقى المجلد الأساسي مرتّباً.
  static Future<SaveOutcome> save({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? subDir,
  }) async {
    if (!isSupported) {
      // بديل آمن على المنصات الأخرى: مجلد مستندات التطبيق الخاص.
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes, flush: true);
        return SaveOutcome.saved(file.path);
      } catch (e) {
        return SaveOutcome.failed('تعذّر الحفظ على هذه المنصة');
      }
    }

    if (!await ensurePermission()) {
      return SaveOutcome.permissionDenied(
        'يحتاج التطبيق صلاحية الوصول إلى الملفات لحفظ الملف في مجلد عام.',
      );
    }

    try {
      final path = await _channel.invokeMethod<String>('saveFile', {
        'fileName': fileName,
        'mimeType': mimeType,
        'bytes': bytes,
        'subDir': subDir,
      });
      if (path == null || path.isEmpty) {
        return SaveOutcome.failed('تعذّر تحديد مسار الحفظ');
      }
      return SaveOutcome.saved(path);
    } on PlatformException catch (e) {
      return SaveOutcome.failed(e.message ?? 'تعذّر حفظ الملف');
    }
  }
}
