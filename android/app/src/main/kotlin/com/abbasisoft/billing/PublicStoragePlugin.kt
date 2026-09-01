package com.abbasisoft.billing

import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

/**
 * حفظ الملفات في **مجلد عام مخصّص للتطبيق** — أسلوب واتساب.
 *
 * لماذا كود أصلي (Kotlin) ولا حزمة Dart جاهزة؟
 * ------------------------------------------------------------------
 * منذ Android 10 (API 29) فُرض «التخزين المحدود» (Scoped Storage)، فلم
 * يبقَ للتطبيق حقّ الكتابة عبر مسارات ملفات عادية في الذاكرة المشتركة،
 * ويرمي النظام `SecurityException`. الطريق المعتمد رسمياً هو `MediaStore`
 * عبر `ContentResolver`، ولا تُغلّفه أي حزمة Dart بشكل يسمح باختيار
 * **مجلد فرعي داخل Documents**، لذا نكتبه بأنفسنا.
 *
 * المرجع: developer.android.com/training/data-storage/shared/media
 *
 * ملاحظة مهمة: على API 29+ **لا تُطلب أي صلاحية تخزين** لإنشاء ملفات
 * جديدة يملكها التطبيق نفسه. الصلاحية تُطلب فقط على API ≤ 28.
 */
object PublicStoragePlugin {

    const val CHANNEL = "com.abbasisoft.billing/public_storage"

    /** اسم المجلد الأساسي — باسم التطبيق بالعربية. */
    private const val FOLDER_AR = "فواتير الكهرباء"

    /** اسم بديل لاتيني، يُستخدم فقط إن رفض النظام الاسم العربي. */
    private const val FOLDER_LATIN = "Electricity Billing"

    fun handle(context: Context, call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "saveFile" -> saveFile(context, call, result)
            "folderLabel" -> result.success("Documents/$FOLDER_AR")
            "needsLegacyPermission" ->
                result.success(Build.VERSION.SDK_INT <= Build.VERSION_CODES.P)
            else -> result.notImplemented()
        }
    }

    private fun saveFile(
        context: Context,
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val fileName = call.argument<String>("fileName")
        val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
        val bytes = call.argument<ByteArray>("bytes")
        val subDir = call.argument<String>("subDir") // مجلد فرعي اختياري

        if (fileName.isNullOrBlank() || bytes == null) {
            result.error("BAD_ARGS", "اسم الملف أو محتواه غير صالح", null)
            return
        }

        // محاولة بالاسم العربي، ثم اللاتيني إن فشل.
        for (folder in listOf(FOLDER_AR, FOLDER_LATIN)) {
            val path = if (subDir.isNullOrBlank()) folder else "$folder/$subDir"
            try {
                val saved = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    writeViaMediaStore(context, fileName, mimeType, bytes, path)
                } else {
                    writeViaLegacyFile(fileName, bytes, path)
                }
                if (saved != null) {
                    result.success(saved)
                    return
                }
            } catch (e: Exception) {
                // نُكمل إلى الاسم البديل، وإن فشل الاثنان نُبلّغ بالخطأ.
                if (folder == FOLDER_LATIN) {
                    result.error("SAVE_FAILED", e.message ?: "تعذّر الحفظ", null)
                    return
                }
            }
        }
        result.error("SAVE_FAILED", "تعذّر إنشاء المجلد أو كتابة الملف", null)
    }

    /**
     * المسار المعتمد على API 29+ — لا صلاحيات، والملف يبقى بعد إزالة
     * التطبيق، ويظهر لكل تطبيقات إدارة الملفات.
     *
     * `IS_PENDING = 1` يمنع القارئين الآخرين من رؤية ملف نصف مكتوب،
     * ثم نصفّره بعد إتمام الكتابة.
     */
    private fun writeViaMediaStore(
        context: Context,
        fileName: String,
        mimeType: String,
        bytes: ByteArray,
        relativeSubPath: String,
    ): String? {
        val resolver = context.contentResolver
        val collection = MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        val relativePath = "${Environment.DIRECTORY_DOCUMENTS}/$relativeSubPath/"

        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }

        val uri = resolver.insert(collection, values) ?: return null
        try {
            resolver.openOutputStream(uri)?.use { it.write(bytes) }
                ?: throw IllegalStateException("تعذّر فتح مجرى الكتابة")
        } catch (e: Exception) {
            resolver.delete(uri, null, null)
            throw e
        }

        values.clear()
        values.put(MediaStore.MediaColumns.IS_PENDING, 0)
        resolver.update(uri, values, null, null)

        // الاسم الفعلي قد يختلف إن كان هناك ملف بنفس الاسم (يُلحق النظام «(1)»).
        var actual = fileName
        resolver.query(
            uri,
            arrayOf(MediaStore.MediaColumns.DISPLAY_NAME),
            null, null, null,
        )?.use { c -> if (c.moveToFirst()) actual = c.getString(0) ?: fileName }

        return "$relativePath$actual"
    }

    /** المسار القديم على API ≤ 28 — يحتاج `WRITE_EXTERNAL_STORAGE`. */
    @Suppress("DEPRECATION")
    private fun writeViaLegacyFile(
        fileName: String,
        bytes: ByteArray,
        relativeSubPath: String,
    ): String? {
        val base = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_DOCUMENTS,
        )
        val dir = File(base, relativeSubPath)
        if (!dir.exists() && !dir.mkdirs()) return null

        var target = File(dir, fileName)
        if (target.exists()) {
            val dot = fileName.lastIndexOf('.')
            val stem = if (dot > 0) fileName.substring(0, dot) else fileName
            val ext = if (dot > 0) fileName.substring(dot) else ""
            var i = 1
            while (target.exists() && i < 500) {
                target = File(dir, "$stem ($i)$ext")
                i++
            }
        }
        FileOutputStream(target).use { it.write(bytes) }
        return "${Environment.DIRECTORY_DOCUMENTS}/$relativeSubPath/${target.name}"
    }
}
