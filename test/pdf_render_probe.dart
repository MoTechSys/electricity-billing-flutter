// أداة قياس داخلية — تُنتج فاتورة نموذجية إلى /tmp/probe/out.pdf
// لتُقاس بكسلياً ضد الفاتورة المرجعية. ليست اختباراً وظيفياً.
import 'dart:io';

import 'package:motech_billing/core/database/app_database.dart';
import 'package:motech_billing/core/database/billing_repository.dart';
import 'package:motech_billing/features/invoices/invoice_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('render probe invoice', () async {
    final now = DateTime(2026, 1, 1);

    final invoice = InvoiceRow(
      id: 'probe',
      invoiceNumber: 'INV-2026-01-0731',
      cycleNumber: '7',
      subscriberId: 'sub',
      periodFrom: '2025-11-01',
      periodTo: '2025-11-30',
      previousReading: 12340,
      currentReading: 13120,
      consumptionKwh: 780,
      unitPrice: 250,
      baseValue: 195000,
      servicesAmount: 0,
      arrearsAmount: 0,
      paidDuringPeriod: 0,
      grossAmount: 195000,
      netDue: 195000,
      netDueWords: 'مائة وخمسة وتسعون ألف ريال يمني فقط لا غير',
      currency: 'ريال',
      status: 'issued',
      notes: '',
      createdAt: now,
      updatedAt: now,
    );

    final subscriber = SubscriberRow(
      id: 'sub',
      subscriberNumber: '10254',
      subscriberName: 'عبدالله محمد الشامي',
      meterNumber: '884213',
      routeNumber: '7',
      cabinName: 'الكبينة الشرقية',
      locationName: 'حي النصر',
      phone: '',
      status: 'active',
      notes: '',
      createdAt: now,
      updatedAt: now,
    );

    final bytes = await buildInvoicePdf(
      invoice: invoice,
      subscriber: subscriber,
      settings: SettingKeys.defaults,
    );

    Directory('/tmp/probe').createSync(recursive: true);
    File('/tmp/probe/out.pdf').writeAsBytesSync(bytes);
    // ignore: avoid_print
    print('WROTE ${bytes.length} bytes');
  });
}
