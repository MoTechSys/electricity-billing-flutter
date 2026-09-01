/// تحويل الأرقام إلى كلمات عربية.
/// منقول بدقة من نسخة الويب لضمان تطابق نص الفاتورة حرفياً.
library;

const _ones = <String>[
  '',
  'واحد',
  'اثنان',
  'ثلاثة',
  'أربعة',
  'خمسة',
  'ستة',
  'سبعة',
  'ثمانية',
  'تسعة',
  'عشرة',
  'أحد عشر',
  'اثنا عشر',
  'ثلاثة عشر',
  'أربعة عشر',
  'خمسة عشر',
  'ستة عشر',
  'سبعة عشر',
  'ثمانية عشر',
  'تسعة عشر',
];

const _tens = <String>[
  '',
  '',
  'عشرون',
  'ثلاثون',
  'أربعون',
  'خمسون',
  'ستون',
  'سبعون',
  'ثمانون',
  'تسعون',
];

const _hundreds = <String>[
  '',
  'مائة',
  'مائتان',
  'ثلاثمائة',
  'أربعمائة',
  'خمسمائة',
  'ستمائة',
  'سبعمائة',
  'ثمانمائة',
  'تسعمائة',
];

const _groupNames = <String>['', 'ألف', 'مليون', 'مليار'];
const _groupNamesPlural = <String>['', 'آلاف', 'ملايين', 'مليارات'];
const _groupNamesDual = <String>['', 'ألفان', 'مليونان', 'ملياران'];

String _convertGroup(int num) {
  if (num == 0) return '';

  final h = num ~/ 100;
  final remainder = num % 100;
  final t = remainder ~/ 10;
  final o = remainder % 10;

  var result = '';
  if (h > 0) result = _hundreds[h];

  if (remainder > 0) {
    if (result.isNotEmpty) result += ' و';
    if (remainder < 20) {
      result += _ones[remainder];
    } else {
      if (o > 0) result += '${_ones[o]} و';
      result += _tens[t];
    }
  }

  return result;
}

/// يعيد المبلغ بالحروف العربية متبوعاً بالعملة و«فقط لا غير».
String numberToArabicWords(num value, {String currency = 'ريال'}) {
  if (value == 0) return 'صفر $currency فقط لا غير';

  final isNegative = value < 0;
  final abs = value.abs();
  final intPart = abs.floor();

  if (intPart == 0) return 'صفر $currency فقط لا غير';

  // تقسيم إلى مجموعات ثلاثية
  final groups = <int>[];
  var temp = intPart;
  while (temp > 0) {
    groups.add(temp % 1000);
    temp = temp ~/ 1000;
  }

  final parts = <String>[];
  for (var i = groups.length - 1; i >= 0; i--) {
    final g = groups[i];
    if (g == 0) continue;

    if (i == 0) {
      parts.add(_convertGroup(g));
    } else if (g == 1) {
      parts.add(_groupNames[i]);
    } else if (g == 2) {
      parts.add(_groupNamesDual[i]);
    } else if (g >= 3 && g <= 10) {
      parts.add('${_convertGroup(g)} ${_groupNamesPlural[i]}');
    } else {
      parts.add('${_convertGroup(g)} ${_groupNames[i]}اً');
    }
  }

  var result = parts.join(' و');
  if (isNegative) result = 'سالب $result';

  return '$result $currency فقط لا غير';
}
