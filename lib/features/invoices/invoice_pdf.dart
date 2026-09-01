import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/database/app_database.dart';
import '../../core/database/billing_repository.dart';
import '../../core/utils/formatters.dart';

/// ════════════════════════════════════════════════════════════════════
///  مولّد فاتورة PDF — نسخة مطابقة 100% لتصميم الويب.
///
///  كل القياسات محوّلة حرفياً من CSS الأصلي:
///     1px (CSS @96dpi) = 0.75pt   |   1mm = 72/25.4 pt
///  لا يُعدّل أي رقم هنا إلا إذا تغيّر التصميم الأصلي.
/// ════════════════════════════════════════════════════════════════════

double _px(double v) => v * 0.75; // px -> pt
double _mm(double v) => v * 72 / 25.4; // mm -> pt

class _C {
  // الألوان — من CSS
  static const black = PdfColors.black;
  static const white = PdfColors.white;
  static const titleNavy = PdfColor.fromInt(0xFF0E10B3); // .title / .note
  static const amountBlue = PdfColor.fromInt(0xFF1F9CF0); // td.amount-due
  static const headBg = PdfColor.fromInt(0xFFFCD5B4); // thead th background
}

class InvoiceFonts {
  const InvoiceFonts(this.regular, this.bold);
  final pw.Font regular;
  final pw.Font bold;
}

InvoiceFonts? _cachedFonts;
Uint8List? _cachedLogo;

/// تحميل الخطوط والشعار مرة واحدة فقط.
Future<InvoiceFonts> loadInvoiceFonts() async {
  if (_cachedFonts != null) return _cachedFonts!;
  final reg = await rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf');
  final bold = await rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf');
  _cachedFonts = InvoiceFonts(pw.Font.ttf(reg), pw.Font.ttf(bold));
  return _cachedFonts!;
}

Future<Uint8List> loadInvoiceLogo() async {
  if (_cachedLogo != null) return _cachedLogo!;
  final data = await rootBundle.load('assets/images/logo.png');
  _cachedLogo = data.buffer.asUint8List();
  return _cachedLogo!;
}

/// رقم الفاتورة المعروض: إزالة البادئة INV-YYYY-MM-
String invoiceDisplayNumber(String invoiceNumber) {
  final stripped = invoiceNumber.replaceFirst(
    RegExp(r'^INV-\d{4}-\d{2}-'),
    '',
  );
  return stripped.isEmpty ? invoiceNumber : stripped;
}

/// بناء مستند الفاتورة كاملاً (A4 أفقي 297×210mm، صفحة واحدة).
Future<Uint8List> buildInvoicePdf({
  required InvoiceRow invoice,
  required SubscriberRow subscriber,
  required Map<String, String> settings,
}) async {
  final fonts = await loadInvoiceFonts();
  final logoBytes = await loadInvoiceLogo();
  final logo = pw.MemoryImage(logoBytes);

  final company1 =
      settings[SettingKeys.companyName] ??
      SettingKeys.defaults[SettingKeys.companyName]!;
  final company2 =
      settings[SettingKeys.companySubtitle] ??
      SettingKeys.defaults[SettingKeys.companySubtitle]!;
  final title =
      settings[SettingKeys.invoiceTitle] ??
      SettingKeys.defaults[SettingKeys.invoiceTitle]!;
  final footerNote =
      settings[SettingKeys.footerNote] ??
      SettingKeys.defaults[SettingKeys.footerNote]!;

  final invDisplay = invoiceDisplayNumber(invoice.invoiceNumber);

  final doc = pw.Document(
    title: 'فاتورة $invDisplay',
    author: 'العباسي سوفت',
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(
        _mm(297),
        _mm(210),
        marginAll: 0,
      ),
      theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
      build: (context) => pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        // .invoice { padding:12mm 18mm; display:flex; flex-direction:column; }
        child: pw.Container(
          width: _mm(297),
          height: _mm(210),
          color: _C.white,
          padding: pw.EdgeInsets.symmetric(
            vertical: _mm(12),
            horizontal: _mm(18),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            mainAxisSize: pw.MainAxisSize.max,
            children: [
              _header(fonts, logo, company1, company2),
              _title(fonts, title),
              _info(fonts, invoice, subscriber, invDisplay),
              _billTable(fonts, invoice),
              _written(fonts, invoice.netDueWords),
              pw.Spacer(), // .bottom-bar { margin-top:auto; }
              _footer(fonts, footerNote),
            ],
          ),
        ),
      ),
    ),
  );

  return Uint8List.fromList(await doc.save());
}

// ───────────────────────────────────────────────────────────────────
// .header — grid 1fr auto 1fr، حدود 1px، radius 10px، padding 14px 22px
// ───────────────────────────────────────────────────────────────────
pw.Widget _header(
  InvoiceFonts f,
  pw.MemoryImage logo,
  String company1,
  String company2,
) {
  return pw.Container(
    margin: pw.EdgeInsets.only(bottom: _px(10)),
    padding: pw.EdgeInsets.symmetric(
      vertical: _px(14),
      horizontal: _px(22),
    ),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _C.black, width: _px(1)),
      borderRadius: pw.BorderRadius.circular(_px(10)),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // 1fr — .company-name { text-align:right; font-weight:800; 19px; lh 1.45 }
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                company1,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  font: f.bold,
                  fontBold: f.bold,
                  fontSize: _px(19),
                  height: 1.45,
                ),
              ),
              pw.Text(
                company2,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  font: f.bold,
                  fontBold: f.bold,
                  fontSize: _px(19),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: _px(20)), // gap
        // auto — .logo { 80px x 80px }
        pw.SizedBox(
          width: _px(80),
          height: _px(80),
          child: pw.Image(logo, fit: pw.BoxFit.contain),
        ),
        pw.SizedBox(width: _px(20)), // gap
        // 1fr — خلية فارغة
        pw.Expanded(child: pw.SizedBox()),
      ],
    ),
  );
}

// ───────────────────────────────────────────────────────────────────
// .title { center; #0e10b3; 800; 26px; margin:4px 0 14px }
// ───────────────────────────────────────────────────────────────────
pw.Widget _title(InvoiceFonts f, String title) {
  return pw.Container(
    margin: pw.EdgeInsets.only(top: _px(4), bottom: _px(14)),
    width: double.infinity,
    child: pw.Text(
      title,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        font: f.bold,
        fontBold: f.bold,
        fontSize: _px(26),
        color: _C.titleNavy,
      ),
    ),
  );
}

// ───────────────────────────────────────────────────────────────────
// .info { grid 1.7fr 1fr; gap 8px 30px; margin-bottom 14px; 15px/600;
//         padding 0 6px }  .row { grid 100px 10px 1fr }
// ───────────────────────────────────────────────────────────────────
pw.Widget _info(
  InvoiceFonts f,
  InvoiceRow inv,
  SubscriberRow sub,
  String invDisplay,
) {
  final namePieces = StringBuffer(sub.subscriberName);
  if (sub.cabinName.isNotEmpty) namePieces.write(' — ${sub.cabinName}');
  if (sub.subscriberNumber.isNotEmpty) {
    namePieces.write(' / ${sub.subscriberNumber}');
  }

  final right = <List<String>>[
    ['رقم الفاتورة', invDisplay],
    ['اسم المشترك', namePieces.toString()],
    ['الفترة', 'من ${inv.periodFrom} حتى ${inv.periodTo}'],
  ];
  final left = <List<String>>[
    ['رقم الدورة', inv.cycleNumber.isNotEmpty ? inv.cycleNumber : sub.routeNumber],
    ['رقم العداد', sub.meterNumber],
    ['الكبينة', sub.cabinName],
  ];

  pw.Widget col(List<List<String>> rows) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      for (var i = 0; i < rows.length; i++) ...[
        if (i > 0) pw.SizedBox(height: _px(8)), // row-gap
        _infoRow(f, rows[i][0], rows[i][1]),
      ],
    ],
  );

  return pw.Container(
    margin: pw.EdgeInsets.only(bottom: _px(14)),
    padding: pw.EdgeInsets.symmetric(horizontal: _px(6)),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(flex: 17, child: col(right)), // 1.7fr
        pw.SizedBox(width: _px(30)), // column-gap
        pw.Expanded(flex: 10, child: col(left)), // 1fr
      ],
    ),
  );
}

pw.Widget _infoRow(InvoiceFonts f, String label, String value) {
  final labelStyle = pw.TextStyle(
    font: f.bold,
    fontBold: f.bold,
    fontSize: _px(15),
  );
  final valueStyle = pw.TextStyle(
    font: f.regular,
    fontBold: f.bold,
    fontSize: _px(15),
  );
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(
        width: _px(100),
        child: pw.Text(label, style: labelStyle),
      ),
      pw.SizedBox(
        width: _px(10),
        child: pw.Text(':', style: labelStyle),
      ),
      pw.Expanded(
        child: pw.Text(value, style: valueStyle, maxLines: 1),
      ),
    ],
  );
}

// ───────────────────────────────────────────────────────────────────
// table.bill — 8 أعمدة، borders 1px، height 36px، thead #fcd5b4
// ملاحظة: pdf's Table لا يحترم RTL، لذا نعكس ترتيب الأعمدة يدوياً
//         ليظهر «القراءة السابقة» على يمين الجدول تماماً كالويب.
// ───────────────────────────────────────────────────────────────────
pw.Widget _billTable(InvoiceFonts f, InvoiceRow inv) {
  // ترتيب منطقي (يمين ← يسار) كما في HTML
  const headers = <String>[
    'القراءة السابقة',
    'القراءة الحالية',
    'الاستهلاك',
    'القيمة',
    'خدمات',
    'المتأخرات',
    'مدفوع خلال الفترة',
    'المبلغ المستحق',
  ];
  // colgroup widths
  const widths = <double>[11.5, 11.5, 11.5, 14, 8, 8, 14, 14];

  final values = <String>[
    fmt(inv.previousReading),
    fmt(inv.currentReading),
    fmt(inv.consumptionKwh),
    fmt(inv.baseValue),
    inv.servicesAmount == 0 ? '0' : fmt(inv.servicesAmount),
    inv.arrearsAmount == 0 ? '0' : fmt(inv.arrearsAmount),
    inv.paidDuringPeriod == 0 ? '' : fmt(inv.paidDuringPeriod),
    fmt(inv.netDue),
  ];

  // العكس للعرض (Table يرسم من اليسار)
  final vHeaders = headers.reversed.toList();
  final vValues = values.reversed.toList();
  final vWidths = widths.reversed.toList();

  final side = pw.BorderSide(color: _C.black, width: _px(1));
  final cellPadding = pw.EdgeInsets.symmetric(
    vertical: _px(9),
    horizontal: _px(4),
  );
  final rowHeight = _px(36);

  return pw.Container(
    margin: pw.EdgeInsets.only(bottom: _px(10)),
    child: pw.Table(
      border: pw.TableBorder(
        top: side,
        bottom: side,
        left: side,
        right: side,
        horizontalInside: side,
        verticalInside: side,
      ),
      columnWidths: {
        for (var i = 0; i < vWidths.length; i++) i: pw.FlexColumnWidth(vWidths[i]),
      },
      children: [
        // thead
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _C.headBg),
          children: [
            for (final h in vHeaders)
              pw.Container(
                height: rowHeight,
                padding: cellPadding,
                alignment: pw.Alignment.center,
                child: pw.Text(
                  h,
                  textAlign: pw.TextAlign.center,
                  textDirection: pw.TextDirection.rtl,
                  style: pw.TextStyle(
                    font: f.bold,
                    fontBold: f.bold,
                    fontSize: _px(14),
                  ),
                ),
              ),
          ],
        ),
        // tbody
        pw.TableRow(
          children: [
            for (var i = 0; i < vValues.length; i++)
              pw.Container(
                height: rowHeight,
                padding: cellPadding,
                alignment: pw.Alignment.center,
                child: pw.Text(
                  vValues[i],
                  textAlign: pw.TextAlign.center,
                  // أرقام لاتينية: LTR لضمان الترتيب الصحيح
                  textDirection: pw.TextDirection.ltr,
                  style: i == 0
                      // العمود الأول بعد العكس = «المبلغ المستحق» (td.amount-due)
                      ? pw.TextStyle(
                          font: f.bold,
                          fontBold: f.bold,
                          fontSize: _px(17),
                          color: _C.amountBlue,
                        )
                      : pw.TextStyle(
                          font: f.regular,
                          fontBold: f.bold,
                          fontSize: _px(15),
                        ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

// ───────────────────────────────────────────────────────────────────
// .written { 15px/600; margin:10px 4px 14px; lh 1.6 }  .lbl { 700 }
// ───────────────────────────────────────────────────────────────────
pw.Widget _written(InvoiceFonts f, String words) {
  return pw.Container(
    margin: pw.EdgeInsets.only(
      top: _px(10),
      bottom: _px(14),
      left: _px(4),
      right: _px(4),
    ),
    width: double.infinity,
    child: pw.RichText(
      textDirection: pw.TextDirection.rtl,
      textAlign: pw.TextAlign.right,
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: 'المبلغ المستحق كتابةً هو :- ',
            style: pw.TextStyle(
              font: f.bold,
              fontBold: f.bold,
              fontSize: _px(15),
              height: 1.6,
            ),
          ),
          pw.TextSpan(
            text: words,
            style: pw.TextStyle(
              font: f.regular,
              fontBold: f.bold,
              fontSize: _px(15),
              height: 1.6,
            ),
          ),
        ],
      ),
    ),
  );
}

// ───────────────────────────────────────────────────────────────────
// .footer-line { border-top 1.5px; margin-top 6px; padding 12px/6px;
//                space-between }  +  .bottom-bar { border-bottom 2px }
// ───────────────────────────────────────────────────────────────────
pw.Widget _footer(InvoiceFonts f, String note) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      pw.Container(
        margin: pw.EdgeInsets.only(top: _px(6)),
        padding: pw.EdgeInsets.only(top: _px(12), bottom: _px(6)),
        decoration: pw.BoxDecoration(
          border: pw.Border(
            top: pw.BorderSide(color: _C.black, width: _px(1.5)),
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              child: pw.Text(
                note,
                style: pw.TextStyle(
                  font: f.bold,
                  fontBold: f.bold,
                  fontSize: _px(14),
                  color: _C.titleNavy,
                ),
              ),
            ),
            pw.SizedBox(width: _px(16)),
            pw.Text(
              'الحسابات',
              style: pw.TextStyle(
                font: f.bold,
                fontBold: f.bold,
                fontSize: _px(15),
              ),
            ),
          ],
        ),
      ),
      // .bottom-bar
      pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: _C.black, width: _px(2)),
          ),
        ),
      ),
    ],
  );
}
