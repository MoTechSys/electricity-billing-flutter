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
