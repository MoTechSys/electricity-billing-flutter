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
}
