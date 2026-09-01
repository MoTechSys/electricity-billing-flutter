import 'arabic_number_words.dart';

/// نتيجة حسابات الفاتورة — منقولة حرفيًا من `calculateInvoice` في نسخة الويب.
class InvoiceCalculation {
  const InvoiceCalculation({
    required this.consumptionKwh,
    required this.baseValue,
    required this.grossAmount,
    required this.netDue,
    required this.netDueWords,
  });

  final double consumptionKwh;
  final double baseValue;
  final double grossAmount;
  final double netDue;
  final String netDueWords;

  static const InvoiceCalculation zero = InvoiceCalculation(
    consumptionKwh: 0,
    baseValue: 0,
    grossAmount: 0,
    netDue: 0,
    netDueWords: '',
  );
}

/// نفس المعادلات بالحرف:
/// consumption = current - previous
/// base        = consumption * unitPrice
/// gross       = base + services + arrears
/// net         = gross - paid
InvoiceCalculation calculateInvoice({
  required double previousReading,
  required double currentReading,
  required double unitPrice,
  double servicesAmount = 0,
  double arrearsAmount = 0,
  double paidDuringPeriod = 0,
  String currency = 'ريال',
}) {
  final consumptionKwh = currentReading - previousReading;
  final baseValue = consumptionKwh * unitPrice;
  final grossAmount = baseValue + servicesAmount + arrearsAmount;
  final netDue = grossAmount - paidDuringPeriod;
  return InvoiceCalculation(
    consumptionKwh: consumptionKwh,
    baseValue: baseValue,
    grossAmount: grossAmount,
    netDue: netDue,
    netDueWords: numberToArabicWords(netDue, currency: currency),
  );
}
