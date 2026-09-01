<div dir="rtl">

# التخزين العام والصلاحيات

> كيف يحفظ التطبيق الفواتير والنسخ الاحتياطية في **مجلد عام يراه
> المستخدم**، على أسلوب واتساب، وكيف يتعامل مع الصلاحيات بذكاء.

---

## 1. المشكلة

المطلوب من صاحب النظام كان واضحاً في بندين:

> «زر النسخ الاحتياطي يطلب صلاحية الملفات ويكون له **مجلد مخصّص** مثل
> واتساب.»
> «حفظ الفاتورة في **مجلد رئيسي عام باسم التطبيق**، واسم الملف = اسم
> العميل + التاريخ.»

السلوك السابق كان يكتب الملفات في
`getApplicationDocumentsDirectory()` — وهو مجلد **خاص** داخل
`/data/data/<package>/`، **لا يراه المستخدم ولا مدير الملفات**، ويُحذف
مع إزالة التطبيق. فكان المستخدم يضغط «حفظ» ثم لا يجد شيئاً.

---

## 2. القيد التقني: التخزين المحدود (Scoped Storage)

منذ **Android 10 (API 29)** فُرض التخزين المحدود:

* لا يستطيع التطبيق الكتابة عبر **مسارات ملفات عادية** في الذاكرة
  المشتركة — يرمي النظام `SecurityException`.
* الطريق المعتمد رسمياً هو **`MediaStore`** عبر `ContentResolver`.
* الملفات المكتوبة عبر `MediaStore` **تبقى بعد إزالة التطبيق** وتظهر
  لكل التطبيقات.

المرجع: [developer.android.com/training/data-storage/shared/media](https://developer.android.com/training/data-storage/shared/media)

### لماذا لم تُستخدم حزمة Dart جاهزة؟

لا تُغلّف حزم Dart المتاحة `MediaStore` بشكل يسمح باختيار **مجلد فرعي
مخصّص داخل `Documents`**، وهو جوهر الطلب (مجلد باسم التطبيق). لذلك
كُتبت طبقة أصليّة صغيرة بـ Kotlin عبر `MethodChannel`.

---

## 3. البنية

```
android/app/src/main/kotlin/com/abbasisoft/billing/
├── MainActivity.kt            تسجيل MethodChannel
└── PublicStoragePlugin.kt     الكتابة الفعلية

lib/core/services/public_storage.dart   واجهة Dart + إدارة الصلاحية
lib/core/app_info.dart                  أسماء المجلدات
lib/core/utils/formatters.dart          توليد أسماء الملفات وتنقيتها
```

قناة التواصل: `com.abbasisoft.billing/public_storage`

| الطريقة | الدور |
|---|---|
| `saveFile` | يكتب الملف ويُرجع مساره الفعلي |
| `folderLabel` | وصف المجلد لعرضه في الواجهة |
| `needsLegacyPermission` | هل نسخة النظام تحتاج صلاحية تقليدية؟ |

---

## 4. شجرة المجلدات

```
Documents/
└── فواتير الكهرباء/
    ├── الفواتير/
    │   └── عبدالله محمد الشامي - 2026-01-05 - 0731.pdf
    └── النسخ الاحتياطي/
        └── نسخة احتياطية - 2026-01-05 - 2130.json
```

يجرّب المُلحق الاسم العربي أولاً، وإن رفضه النظام رجع إلى
`Electricity Billing` — حماية من أنظمة ملفات لا تحتمل العربية في أسماء
المجلدات.

---

## 5. مسار الكتابة على API 29+

```kotlin
val collection = MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
val values = ContentValues().apply {
    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
    put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
    put(MediaStore.MediaColumns.RELATIVE_PATH,
        "${Environment.DIRECTORY_DOCUMENTS}/$relativeSubPath/")
    put(MediaStore.MediaColumns.IS_PENDING, 1)   // ← مهم
}
val uri = resolver.insert(collection, values)
resolver.openOutputStream(uri)?.use { it.write(bytes) }
values.clear(); values.put(MediaStore.MediaColumns.IS_PENDING, 0)
resolver.update(uri, values, null, null)
```

**لماذا `IS_PENDING`؟** يمنع التطبيقات الأخرى من رؤية ملف **نصف مكتوب**
لو انقطعت العملية. ويُصفَّر بعد إتمام الكتابة فقط.

**لماذا `MediaStore.Files` وليس `MediaStore.Downloads`؟** لأن المطلوب
مجلد داخل **`Documents`** لا داخل `Download`، و`MediaStore.Files` هو
المجموعة التي تسمح بمسار نسبي حرّ.

**التقاط الاسم الفعلي:** لو وُجد ملف بنفس الاسم يُلحق النظام «(1)»
تلقائياً، فيُستعلَم عن `DISPLAY_NAME` بعد الكتابة كي نُبلّغ المستخدم
بالاسم الحقيقي لا المطلوب.

### مسار API ≤ 28

لا يوجد `MediaStore` للمستندات على تلك النسخ، فيُكتب الملف بمسار عادي
عبر `Environment.getExternalStoragePublicDirectory(DIRECTORY_DOCUMENTS)`
مع توليد اسم بديل يدوياً إن تكرّر.

---

## 6. الصلاحيات — منطق ذكي

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                 android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
                 android:maxSdkVersion="32" />
```

على **API 29+ لا تُطلب أي صلاحية** لأن التطبيق هو مُنشئ الملف. ولذلك
`maxSdkVersion="28"`: فلا يُطالب مستخدمو الأجهزة الحديثة بصلاحية لا
معنى لها.

يُنفّذ هذا في `PublicStorage.ensurePermission()`:

```dart
if (!await _needsLegacyPermission()) return true;   // API 29+ → لا شيء
final status = await Permission.storage.status;
if (status.isGranted) return true;
if (status.isPermanentlyDenied) return false;       // → نافذة الشرح
return (await Permission.storage.request()).isGranted;
```

هذا ليس تحسيناً شكلياً بل **السلوك الصحيح المعتمد**: طلب صلاحية لا
يحتاجها النظام يُقلّل ثقة المستخدم وقد يُرفض عند مراجعة النشر.

### عند الرفض

تُعرض نافذة تشرح **لماذا** نحتاج الصلاحية وتؤكد أنها للكتابة فقط، مع
زرّ يفتح إعدادات التطبيق مباشرةً عبر `openAppSettings()`.

### الاحتياط الأخير

لو فشل الحفظ في المجلد العام لأي سبب، تُكتب الفاتورة في مجلد التطبيق
الخاص ويُبلَّغ المستخدم بمسارها. **لا يفقد المستخدم فاتورته أبداً.**

---

## 7. أسماء الملفات

```dart
invoiceFileName(
  subscriberName: 'عبدالله محمد الشامي',
  date: invoice.issuedAt ?? invoice.createdAt,
  invoiceNumber: '0731',
)
// ⇒ 'عبدالله محمد الشامي - 2026-01-05 - 0731.pdf'
```

* **التاريخ هو تاريخ إصدار الفاتورة** لا تاريخ اليوم، فيبقى الاسم
  ثابتاً لو أُعيد الحفظ بعد شهر.
* **رقم الفاتورة يُلحَق** كي لا تتزاحم فاتورتان لنفس المشترك في اليوم
  نفسه.
* **النسخ الاحتياطية تحمل الساعة والدقيقة** لأن المستخدم قد يُصدّر عدة
  نسخ في اليوم نفسه.

### التنقية — `safeFileStem()`

المحارف الممنوعة في أنظمة الملفات: `\ / : * ? " < > |` إضافةً إلى محارف
التحكّم. وتُحذف النقطة الأخيرة لأن ويندوز يحذفها فيتغيّر الاسم. ويُحدّ
الطول بـ 80 حرفاً (الحرف العربي بايتان في UTF-8، وحدّ نظام الملفات 255
بايتاً).

**هذا محميّ بستّة اختبارات**، لأن محرفاً ممنوعاً واحداً يجعل الحفظ يفشل
بصمت، ولن يلاحظ المستخدم إلا بعد أن يفقد فاتورة.

---

## 8. الواجهة

* **شريحة `FolderHint`** تُبيّن للمستخدم مسار الحفظ **قبل** الضغط، فلا
  يتساءل «أين ذهب الملف؟».
* **اسم الملف معروض** أسفل أزرار المعاينة.
* **إشعار النجاح** يعرض **المسار الفعلي** لست ثوانٍ.
* زر «حفظ في المجلد» يظهر على أندرويد فقط
  (`PublicStorage.isSupported`)، وعلى الويب يُستخدم تنزيل المتصفح.

---

## 9. قابلية رؤية التطبيقات الخارجية

منذ **Android 11 (API 30)** لا يرى التطبيق التطبيقات المثبّتة إلا ما
يُعلن عنه. بدون ذلك يفشل `url_launcher` **بصمت** مع
`canLaunchUrl == false`، فلا يفتح واتساب ولا المتصفح:

```xml
<queries>
    <intent><action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" /></intent>
    <intent><action android:name="android.intent.action.VIEW" />
            <data android:scheme="tel" /></intent>
    <intent><action android:name="android.intent.action.SEND" />
            <data android:mimeType="*/*" /></intent>
</queries>
```

كما يجب استخدام `LaunchMode.externalApplication`، وإلا حاول أندرويد فتح
الرابط داخل WebView التطبيق فلا يُسلَّم لواتساب.

</div>
