/// أدوات تنسيق الأرقام — مطابقة تمامًا لـ
/// `num.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })`
/// المستخدمة في نسخة الويب.
library;

/// تنسيق رقم بفواصل آلاف وخانتين عشريتين: 12345.6 -> "12,345.60"
String fmt(num value) {
  final negative = value < 0;
  final abs = value.abs();
  final fixed = abs.toStringAsFixed(2);
  final dot = fixed.indexOf('.');
  final intPart = fixed.substring(0, dot);
  final decPart = fixed.substring(dot + 1);

  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  return '${negative ? '-' : ''}$buf.$decPart';
}

/// تنسيق رقم صحيح بفواصل آلاف بدون خانات عشرية: 12345 -> "12,345"
String fmtInt(num value) {
  final negative = value < 0;
  final intPart = value.abs().round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  return '${negative ? '-' : ''}$buf';
}

/// تحويل نص المستخدم إلى رقم (يقبل الأرقام العربية والفواصل)
double parseNum(String? input) {
  if (input == null) return 0;
  const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
  final sb = StringBuffer();
  for (final ch in input.trim().split('')) {
    final ai = arabicDigits.indexOf(ch);
    if (ai >= 0) {
      sb.write(ai);
    } else if (ch == ',' || ch == '٬' || ch == ' ') {
      // تجاهل فواصل الآلاف
    } else if (ch == '٫') {
      sb.write('.');
    } else {
      sb.write(ch);
    }
  }
  return double.tryParse(sb.toString()) ?? 0;
}

/// تاريخ اليوم بصيغة الويب: yyyy/MM/dd
String todayStamp() {
  final n = DateTime.now();
  return '${n.year}/${_p(n.month)}/${_p(n.day)}';
}

/// تنسيق تاريخ من ميلي ثانية إلى yyyy/MM/dd
String stampFromMillis(int millis) {
  final d = DateTime.fromMillisecondsSinceEpoch(millis);
  return '${d.year}/${_p(d.month)}/${_p(d.day)}';
}

String _p(int v) => v.toString().padLeft(2, '0');

/// توحيد صيغة التاريخ المدخل (يستبدل "-" بـ "/") كما في نسخة الويب
String normalizeDate(String input) => input.trim().replaceAll('-', '/');

/// ═══ أسماء الملفات ═══════════════════════════════════════════════════
///
/// يُنقّي نصاً ليصلح كاسم ملف على Android/Windows/Linux.
///
/// المحارف الممنوعة في أنظمة الملفات: `\ / : * ? " < > |` إضافةً إلى
/// محارف التحكّم. كما نمنع النقطة في آخر الاسم لأن Windows يحذفها،
/// ونضغط الفراغات المتكررة كي لا يخرج اسم مشوّه.
String safeFileStem(String raw) {
  const forbidden = r'\/:*?"<>|';
  final sb = StringBuffer();
  for (final ch in raw.trim().split('')) {
    final code = ch.codeUnitAt(0);
    if (code < 32 || forbidden.contains(ch)) {
      sb.write(' ');
    } else {
      sb.write(ch);
    }
  }
  var out = sb.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  while (out.endsWith('.')) {
    out = out.substring(0, out.length - 1).trim();
  }
  // حدّ عملي لطول الاسم: أنظمة الملفات تحدّ الاسم بـ 255 بايت، والحرف
  // العربي بايتان في UTF-8، فنقتصر على 80 حرفاً ليتبقّى متّسع للتاريخ
  // واللاحقة.
  if (out.length > 80) out = out.substring(0, 80).trim();
  return out.isEmpty ? 'ملف' : out;
}

/// اسم ملف الفاتورة = **اسم المشترك + التاريخ**، كما طلب المستخدم.
///
/// مثال: `عبدالله محمد الشامي - 2026-01-15.pdf`
/// وعند إضافة رقم الفاتورة: `عبدالله محمد الشامي - 2026-01-15 - 0731.pdf`
String invoiceFileName({
  required String subscriberName,
  DateTime? date,
  String? invoiceNumber,
  String extension = 'pdf',
}) {
  final d = date ?? DateTime.now();
  final stamp = '${d.year}-${_p(d.month)}-${_p(d.day)}';
  final name = safeFileStem(subscriberName);
  final suffix = (invoiceNumber == null || invoiceNumber.trim().isEmpty)
      ? ''
      : ' - ${safeFileStem(invoiceNumber)}';
  return '$name - $stamp$suffix.$extension';
}

/// اسم ملف النسخة الاحتياطية: `نسخة احتياطية - 2026-01-15 - 2130.json`
///
/// أُضيفت الساعة والدقيقة لأن المستخدم قد يُصدّر أكثر من نسخة في اليوم
/// نفسه، فلا تتزاحم الأسماء ولا يُلحق النظام «(1)».
String backupFileName({DateTime? date}) {
  final d = date ?? DateTime.now();
  final day = '${d.year}-${_p(d.month)}-${_p(d.day)}';
  final time = '${_p(d.hour)}${_p(d.minute)}';
  return 'نسخة احتياطية - $day - $time.json';
}
