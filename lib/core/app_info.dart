/// ثوابت هوية التطبيق والمطوّر — **مصدر واحد للحقيقة**.
///
/// كل نص يظهر للمستخدم عن المطوّر أو التواصل أو الإصدار يُقرأ من هنا
/// حصراً، فلا يتكرّر النص في عدّة ملفات ولا يُنسى تحديث أحدها.
library;

class AppInfo {
  AppInfo._();

  /// اسم التطبيق كما يظهر للمستخدم.
  static const appName = 'فواتير الكهرباء';

  /// معرّف حزمة أندرويد.
  static const packageId = 'com.abbasisoft.billing';

  /// الإصدار — يجب أن يوافق `version` في `pubspec.yaml`.
  static const version = '1.1.0';
  static const versionLabel = 'الإصدار $version';

  /// اسم المطوّر — كما طلبه المستخدم حرفياً.
  static const developer = 'تطوير م. معين العباسي';

  /// رقم التواصل بصيغة E.164 (بدون «+» لرابط wa.me).
  static const phoneE164 = '+967770941666';
  static const whatsappDisplay = '+967 770 941 666';

  /// رابط واتساب الرسمي. `wa.me` يعمل مع تطبيق واتساب والويب معاً،
  /// ولا يحتاج الرقم أن يكون في جهات الاتصال.
  static const whatsappUrl = 'https://wa.me/967770941666';

  /// الموقع الإلكتروني.
  static const websiteUrl = 'https://alabbasi.uk';
  static const websiteDisplay = 'alabbasi.uk';

  /// وصف المجلد العام الذي تُحفظ فيه الملفات — لعرضه في الواجهة.
  static const publicFolderLabel = 'Documents/فواتير الكهرباء';

  /// المجلدات الفرعية داخل المجلد العام.
  static const invoicesSubDir = 'الفواتير';
  static const backupsSubDir = 'النسخ الاحتياطي';

  /// مسار صفحة المطوّر في المُوجِّه.
  static const aboutRoute = '/about';
}
