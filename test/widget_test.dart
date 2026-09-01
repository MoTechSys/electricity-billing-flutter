import 'package:flutter_test/flutter_test.dart';

import 'package:motech_billing/core/utils/arabic_number_words.dart';
import 'package:motech_billing/core/utils/formatters.dart';
import 'package:motech_billing/core/utils/invoice_calculator.dart';

void main() {
  group('تنسيق الأرقام — مطابق لنسخة الويب', () {
    test('فواصل الآلاف وخانتان عشريتان', () {
      expect(fmt(12345.6), '12,345.60');
      expect(fmt(0), '0.00');
      expect(fmt(1000000), '1,000,000.00');
    });
  });

  group('حسابات الفاتورة', () {
    test('المعادلات الأساسية', () {
      final r = calculateInvoice(
        previousReading: 100,
        currentReading: 150,
        unitPrice: 220,
        servicesAmount: 500,
        arrearsAmount: 300,
        paidDuringPeriod: 800,
      );
      expect(r.consumptionKwh, 50);
      expect(r.baseValue, 11000);
      expect(r.grossAmount, 11800);
      expect(r.netDue, 11000);
    });
  });

  group('الأرقام إلى كلمات عربية', () {
    test('صفر', () {
      expect(numberToArabicWords(0), 'صفر ريال فقط لا غير');
    });
    test('ينتهي بـ فقط لا غير', () {
      expect(numberToArabicWords(11000).endsWith('ريال فقط لا غير'), isTrue);
    });
  });

  // ═══ أسماء الملفات ═══════════════════════════════════════════════
  //
  // هذه الاختبارات تحمي **قابلية الحفظ على الجهاز**: أي محرف ممنوع في
  // نظام الملفات يجعل الحفظ يفشل بصمت، ولن يلاحظ المستخدم إلا بعد أن
  // يفقد فاتورةً. لذا نُثبّت العقد باختبارات.
  group('تنقية أسماء الملفات', () {
    test('يزيل المحارف الممنوعة في أنظمة الملفات', () {
      expect(safeFileStem(r'أحمد/محمد\علي'), 'أحمد محمد علي');
      expect(safeFileStem('عبدالله: الشامي'), 'عبدالله الشامي');
      expect(safeFileStem('اسم *?"<>| غريب'), 'اسم غريب');
    });

    test('يضغط الفراغات المتكررة ويحذف الأطراف', () {
      expect(safeFileStem('  علي     أحمد  '), 'علي أحمد');
    });

    test('يحذف النقطة الأخيرة — لأن ويندوز يحذفها فيتغيّر الاسم', () {
      expect(safeFileStem('اسم...'), 'اسم');
    });

    test('لا يُخرج اسمًا فارغًا أبدًا', () {
      expect(safeFileStem('   '), 'ملف');
      expect(safeFileStem('///'), 'ملف');
    });

    test('يحدّ الطول كي لا يتجاوز حدّ نظام الملفات', () {
      final long = 'م' * 300;
      expect(safeFileStem(long).length, lessThanOrEqualTo(80));
    });
  });

  group('اسم ملف الفاتورة', () {
    final date = DateTime(2026, 1, 5);

    test('اسم المشترك + التاريخ — كما طلب المستخدم', () {
      expect(
        invoiceFileName(subscriberName: 'عبدالله محمد الشامي', date: date),
        'عبدالله محمد الشامي - 2026-01-05.pdf',
      );
    });

    test('يُلحق رقم الفاتورة عند تمريره', () {
      expect(
        invoiceFileName(
          subscriberName: 'علي أحمد',
          date: date,
          invoiceNumber: '0731',
        ),
        'علي أحمد - 2026-01-05 - 0731.pdf',
      );
    });

    test('لا يحتوي أي محرف ممنوع مهما كان اسم المشترك', () {
      final name = invoiceFileName(
        subscriberName: r'أ/ب\ج:د*ه?و"ز<ح>ط|ي',
        date: date,
      );
      for (final ch in r'\/:*?"<>|'.split('')) {
        expect(name.contains(ch), isFalse, reason: 'وجد المحرف الممنوع $ch');
      }
    });

    test('يصفّر الشهر واليوم بخانتين', () {
      expect(
        invoiceFileName(
          subscriberName: 'س',
          date: DateTime(2026, 12, 31),
        ),
        'س - 2026-12-31.pdf',
      );
    });
  });

  group('اسم ملف النسخة الاحتياطية', () {
    test('يشمل التاريخ والوقت كي لا تتزاحم نسخ اليوم نفسه', () {
      final a = backupFileName(date: DateTime(2026, 1, 5, 9, 7));
      final b = backupFileName(date: DateTime(2026, 1, 5, 21, 30));
      expect(a, 'نسخة احتياطية - 2026-01-05 - 0907.json');
      expect(b, 'نسخة احتياطية - 2026-01-05 - 2130.json');
      expect(a == b, isFalse);
    });
  });
}
