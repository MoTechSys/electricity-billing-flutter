import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/database/app_database.dart';
import '../../core/database/billing_repository.dart';

/// ════════════════════════════════════════════════════════════════════
///  مولّد فاتورة PDF — مطابق للفاتورة الورقية الأصلية.
///
///  كل رقم هنا مستخرج بالقياس البكسلي من الفاتورة الأصلية، لا بالتقدير.
///  التقرير الكامل: `docs/INVOICE_FORENSICS.md`
///
///  ── المعايرة ──────────────────────────────────────────────────────
///  الصورة المرجعية: 1024×522 px.
///  إثبات عدم التشويه: الشعار قرص، وقياسه 70×70 px بالضبط (نسبة 1.0000)
///    ⇒ المقياس موحّد في المحورين.
///  إثبات عرض الصفحة: عرض الجدول 937 px يملأ عرض المحتوى على A4 أفقي
///    بهوامش 12.7mm  ⇒  1024 × 271.6 / 937 = 296.82mm ≈ 297mm (خطأ 0.06%)
///    ⇒ المعامل  K = 297 / 1024 mm/px
///
///  ⚠️ التخطيط الرأسي مُثبَّت بالإحداثيات المطلقة (Stack) لا بالتدفّق،
///     لأن التدفّق يُراكم أخطاء ارتفاع السطر الخاصة بالخط.
///     أي تعديل يجب أن يُتبع بتشغيل  `test/pdf_render_probe.dart`
///     ثم قياس الناتج ضد الأصل.
/// ════════════════════════════════════════════════════════════════════

/// مليمتر ← نقطة (pt)
double _mm(double v) => v * 72 / 25.4;

/// ── مقاس الصفحة ──────────────────────────────────────────────────
/// العرض يبقى 297mm (A4 أفقي) — ثابت ومُثبَت بالقياس.
/// أما **الارتفاع** فيُشتق من نسبة الفاتورة الأصلية نفسها (1024×522 px)
/// لا من 210mm، لأن المستخدم طلب إزالة **المسافة السفلية** الزائدة
/// وجعل حجم الصفحة مطابقاً لفاتورته (المسافات الجانبية لم تُمسّ).
///   الارتفاع = 297 × (522 / 1024) = 151.4mm
/// ويُضاف هامش سفلي صغير (`_kBottomPadRefPx`) أسفل الشريط السفلي
/// لأن الأصل مقصوص عند الحبر تماماً فلا يترك متنفّساً للطابعة.
const double _kPageWmm = 297;
const double _kBottomPadRefPx = 14;

/// ارتفاع الصفحة **مشتقّ من التخطيط** لا رقماً ثابتاً: آخر عنصر هو
/// الشريط السفلي `_Y.bottomBar`، ويُضاف إليه متنفّس الطابعة. فإذا زادت
/// الفوارق الرأسية لمنع التداخل نما الارتفاع تلقائياً ولم يُقطع شيء،
/// وإن نقصت انضغطت المسافة السفلية فلا يبقى فراغ ميت.
/// العرض ‎297mm‎ والمسافات الجانبية لم تُمسّ (طلب المستخدم السابق:
/// «فقط المسافة السفلية، مش المسافة الجانبية»).
final double _kPageHmm =
    _kPageWmm * (_Y.bottomBar + _kBottomPadRefPx) / 1024;

/// بكسل مرجعي (من الأصل، 1024px عرضاً) ← نقطة (pt)
const double _kRefPxToPt = 297 / 1024 * 72 / 25.4; // ≈ 0.822205
double _r(double refPx) => refPx * _kRefPxToPt;

/// ── الإحداثيات الرأسية المطلقة (بكسل مرجعي) ─────────────────────────
/// مقيسة من الأصل: كل قيمة هي موضع الحبر أو الخط الفعلي.
/// ⚠️ الأرقام أدناه مقيسة من الأصل، لكن الفوارق بعدها **مشتقّة** لا ثابتة:
///    كل موضع = الذي قبله + فارق. وبذلك إذا زيد فارقٌ لمنع التداخل انزاح
///    ما بعده تلقائياً ولم يتراكب شيء. طلب المستخدم: «عادي ولو كبرت
///    الفاتورة قليلاً، المهم لا أريد تداخل الخطوط مع بعض».
class _Y {
  static const headerTop = 10.0; // إطار الترويسة، أعلى
  static const headerBottom = 91.0; // إطار الترويسة، أسفل
  static const titleInkTop = 126.0; // أعلى حبر العنوان
  static const titleInkBottom = 148.0; // أسفل حبر العنوان

  /// إزاحة كتلة البيانات للأسفل: التسطير نزل بمقدار
  /// `_kTitleUnderlineGap`، فلو بقيت الكتلة في موضعها لامست التسطير.
  static const infoShift = 10.0;
  static const infoRow1 = 160.0 + infoShift; // أعلى حبر صف البيانات 1

  /// خطوة الأسطر: الأصل ‎29.5px‎؛ رُفعت إلى ‎33px‎ لأن المحارف المرتفعة
  /// في سطر كانت تلامس النازلة من السطر الذي يعلوه.
  static const infoStep = 33.0;
  static const infoRow2 = infoRow1 + infoStep;
  static const infoRow3 = infoRow2 + infoStep;

  static const ruleAboveTable = infoRow3 + 42.0; // الخط السميك فوق الجدول
  static const tableTop = ruleAboveTable + 9.0; // أعلى إطار الجدول
  static const tableHeadBottom = tableTop + 38.0; // فاصل الرأس/الجسم
  static const tableBottom = tableHeadBottom + 44.0; // أسفل إطار الجدول
  static const writtenInk = tableBottom + 19.0; // أعلى حبر سطر «كتابةً»

  /// خط التذييل — وهو **الخط الذي تحت «المبلغ المستحق كتابةً»**.
  /// طلب المستخدم: «الخط اللي تحت المبلغ المستحق نزّله قليلاً».
  /// الفارق في الأصل ‎26px‎ ← ‎38px‎ (نزول ‎12px‎).
  static const footerRule = writtenInk + 38.0;
  static const footerInk = footerRule + 18.0; // أعلى حبر نص التذييل
  static const bottomBar = footerInk + 50.0; // الشريط السفلي
}

/// فراغ التسطير تحت أدنى حبر العنوان (بكسل مرجعي).
/// طلب المستخدم أن يكون الخط **تحت** النص لا في وسطه.
///
/// القيمة مقيسة لا مقدَّرة: بفراغ ‎7px‎ وقع التسطير عند ‎y158‎ في حين أن
/// نازلات «ء» و«ه» في «كهرباء» تمتد إلى ‎y164‎، فكان الخط يقطعها. رُفع
/// الفراغ إلى ‎14px‎ فنزل التسطير أسفل آخر بكسل حبر بهامش واضح.
const double _kTitleUnderlineGap = 14.0;

/// ── الإحداثيات الأفقية المطلقة (بكسل مرجعي) ─────────────────────────
class _X {
  static const headerLeft = 23.0; // إطار الترويسة
  static const headerRight = 1000.0;
  static const logoCenter = 510.5; // مركز الشعار (x 477..544 للقرص)

  /// حافة يمين حبر اسم الشركة — مقيسة: كلا السطرين ينتهيان عند x=992
  static const companyTextRight = 992.0;

  static const ruleLeft = 32.0; // الخط السميك فوق الجدول
  static const ruleRight = 991.0;

  static const tableLeft = 45.0; // إطار الجدول
  static const tableRight = 982.0;

  // ── كتلة البيانات — مقيسة حرفياً من الأصل ─────────────────
  // الترتيب من اليمين: [الملصق] ثم [:] ثم [القيمة]

  // العمود الأيمن: الملصق ينتهي x=974، النقطتان x=850..860،
  //              القيمة تنتهي يميناً عند x=843 وتتمدد يساراً
  static const infoRLabelRight = 976.0;
  static const infoRColonRight = 861.0;
  static const infoRValueRight = 843.0;
  static const infoRValueLeft = 470.0; // حد التمدد (منتصف الصفحة)

  /// أقصى عرض لملصق العمود الأيمن — أوسع حبر مقيس 88px + هامش
  static const infoRLabelW = 104.0;

  // العمود الأيسر: الملصق ينتهي x=297، النقطتان x=221..229،
  //               القيمة تنتهي يميناً عند x=196 وتتمدد يساراً
  static const infoLLabelRight = 299.0;
  static const infoLColonRight = 230.0;
  static const infoLValueRight = 196.0;
  static const infoLValueLeft = 44.0; // حد التمدد (هامش الجدول)

  /// أقصى عرض لملصق العمود الأيسر — أوسع حبر مقيس 66px + هامش
  static const infoLLabelW = 80.0;

  static const writtenRight = 972.0; // سطر «كتابةً» محاذى لليمين

  static const footerNoteRight = 983.0; // ملاحظة التذييل (يمين)
  static const footerAccountsLeft = 131.0; // «الحسابات» (يسار)
}

class _C {
  static const black = PdfColors.black;
  static const white = PdfColors.white;

  /// أزرق العنوان + تسطيره + ملاحظة التذييل.
  /// مستخرج من ملف Word الأصلي الذي أرسله المستخدم (`bill.docx`):
  /// `word/document.xml` يحتوي `<w:color w:val="0000FF"/>` في **31 موضعاً**
  /// دون أي لون آخر، أي أن كل الأزرق في الفاتورة لون واحد.
  static const titleNavy = PdfColor.fromInt(0xFF0000FF);

  /// أزرق قيمة المبلغ المستحق — **نفس** أزرق العنوان.
  /// طلب المستخدم: «المبلغ المستحق خلّه أزرق نفس لون فاتورة استهلاك
  /// كهرباء»، ويؤكده الأصل: كلاهما `0000FF`.
  static const amountBlue = titleNavy;

  /// خلفية رأس الجدول الخوخية — مقيس من الأصل RGB(252,213,180)
  static const headBg = PdfColor.fromInt(0xFFFCD5B4);
}

/// ── أحجام الخطوط (pt) — محلولة عددياً من عرض الحبر في الأصل ──────────
/// ── أحجام الخط (pt) ────────────────────────────────────────────────
/// مضروبة في `_kFontBoost` بناءً على طلب المستخدم: «كبّر حجم الخط».
/// النِسب بين الأحجام محفوظة كما في الفاتورة الأصلية، والزيادة موحّدة
/// حتى لا يختلّ التوازن البصري بين العناصر.
const double _kFontBoost = 1.16;

class _F {
  static const companyLine = 18.3 * _kFontBoost; // اسم الشركة (سطران)
  static const title = 21.1 * _kFontBoost; // «فاتورة استهلاك كهرباء»
  static const info = 16.4 * _kFontBoost; // صفوف البيانات
  /// رؤوس الجدول — تكبيرها مقيَّد بعرض الخلايا الثابت المقيس من الأصل.
  /// أضيق خلية «مدفوع خلال الفترة» = 129px، وحبر الأصل 117px (فراغ 9%).
  /// بتكبير 1.16 يصبح الحبر 126px (فراغ 2%) فيلامس الحدود ⇒ نُقلّل إلى 1.07.
  static const tableHead = 14.6 * 1.07; // رؤوس الجدول
  static const tableValue = 16.9 * _kFontBoost; // قيم الجدول
  static const amountDue = 16.6 * _kFontBoost; // المبلغ المستحق (أزرق)
  static const written = 15.6 * _kFontBoost; // سطر «كتابةً»
  static const footer = 14.6 * _kFontBoost; // ملاحظة التذييل
  static const accounts = 15.0 * _kFontBoost; // «الحسابات»
}

/// ── سماكات الخطوط ──────────────────────────────────────────────────
class _W {
  static final headerBox = _r(1.6);
  static final ruleAboveTable = _r(3); // مقيس y 261..263
  static final tableBorder = _r(1.2);
  static final titleUnderline = _r(2.6); // مقيس y 149..151
  static final footerRule = _r(2); // مقيس y 390..391
  static final bottomBar = _r(2); // مقيس y 458..459
}

class InvoiceFonts {
  const InvoiceFonts(this.regular, this.bold, this.latinFallback);
  final pw.Font regular;
  final pw.Font bold;

  /// خطوط احتياطية للمحارف اللاتينية والترقيم (Tinos، متوافق مع Times).
  /// تُبقى كشبكة أمان فقط؛ Amiri يغطّي `-` و `/` و `—` والأرقام بنفسه.
  final List<pw.Font> latinFallback;
}

InvoiceFonts? _cachedFonts;
Uint8List? _cachedLogo;

/// تحميل الخطوط والشعار مرة واحدة فقط.
///
/// الخط الأساسي: **Amiri** — خط نَسخي طباعي كلاسيكي، الأنسب للفواتير
/// والمستندات الرسمية (تماماً كما طلب المستخدم: «نوع خط يتناسب مع الفواتير»).
///
/// لماذا Amiri وليس غيره؟  تدقيق التغطية بـ fontTools:
///   • Amiri            : PFB 140 ✅، ترقيم لاتيني كامل ✅، أرقام 10/10 ✅
///   • Noto Naskh       : PFB 141 ✅ لكن `-` `/` `—` مفقودة ❌
///   • Scheherazade New : PFB 1  ❌ ⇒ مرفوض تقنياً
/// ومُقلّص بـ fontTools ليقتصر على العربي + اللاتيني + الترقيم.
Future<InvoiceFonts> loadInvoiceFonts() async {
  if (_cachedFonts != null) return _cachedFonts!;
  final reg = await rootBundle.load('assets/fonts/AmiriInvoice-Regular.ttf');
  final bold = await rootBundle.load('assets/fonts/AmiriInvoice-Bold.ttf');
  final latinReg = await rootBundle.load('assets/fonts/TinosLatin-Regular.ttf');
  final latinBold = await rootBundle.load('assets/fonts/TinosLatin-Bold.ttf');
  _cachedFonts = InvoiceFonts(pw.Font.ttf(reg), pw.Font.ttf(bold), [
    pw.Font.ttf(latinBold),
    pw.Font.ttf(latinReg),
  ]);
  return _cachedFonts!;
}

Future<Uint8List> loadInvoiceLogo() async {
  if (_cachedLogo != null) return _cachedLogo!;
  final data = await rootBundle.load('assets/images/logo.png');
  _cachedLogo = data.buffer.asUint8List();
  return _cachedLogo!;
}

/// تنسيق رقم داخل الفاتورة المطبوعة — **بلا فواصل ألوف** وبخانتين عشريتين.
///
/// مقيس من الأصل: «319451.00» و «1372.00» — لا توجد فواصل.
/// ملاحظة: `fmt()` في `formatters.dart` يبقى كما هو لأنه مطابق
/// لنسخة الويب ويُستخدم في واجهة التطبيق.
String _pdfNum(num v) => v.toStringAsFixed(2);

/// توحيد صيغة التاريخ للطباعة: yyyy/M/dd كما في الأصل («2026/5/01»).
String _pdfDate(String raw) {
  final s = raw.trim();
  final m = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$').firstMatch(s);
  if (m == null) return s.replaceAll('-', '/');
  final month = int.parse(m.group(2)!); // بلا تصفير بادئة — كما في الأصل
  final day = m.group(3)!.padLeft(2, '0');
  return '${m.group(1)}/$month/$day';
}

/// رقم الفاتورة المعروض: إزالة البادئة INV-YYYY-MM-
String invoiceDisplayNumber(String invoiceNumber) {
  final stripped = invoiceNumber.replaceFirst(RegExp(r'^INV-\d{4}-\d{2}-'), '');
  return stripped.isEmpty ? invoiceNumber : stripped;
}

/// اسم ملف الفاتورة: «اسم العميل + التاريخ» — كما طلب المستخدم.
String invoiceFileName({
  required String subscriberName,
  required DateTime date,
}) {
  final safe = subscriberName
      .replaceAll(RegExp(r'[\\/:*?"<>|\n\r\t]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  final base = safe.isEmpty ? 'فاتورة' : safe;
  return '$base - $y-$m-$d.pdf';
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
    author: 'م. معين العباسي',
    creator: 'فواتير الكهرباء',
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(_mm(_kPageWmm), _mm(_kPageHmm), marginAll: 0),
      theme: pw.ThemeData.withFont(
        base: fonts.regular,
        bold: fonts.bold,
        fontFallback: fonts.latinFallback,
      ),
      build: (context) => pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Container(
          width: _mm(_kPageWmm),
          height: _mm(_kPageHmm),
          color: _C.white,
          // ── تخطيط بإحداثيات مطلقة: كل عنصر عند موضعه المقيس بالضبط ──
          child: pw.Stack(
            children: [
              _headerBox(fonts, logo, company1, company2),
              _titleBlock(fonts, title),
              _infoBlock(fonts, invoice, subscriber, invDisplay),
              _ruleAboveTable(),
              _billTable(fonts, invoice),
              _writtenLine(fonts, invoice.netDueWords),
              _footerRule(),
              _footerText(fonts, footerNote),
              _bottomBar(),
            ],
          ),
        ),
      ),
    ),
  );

  return Uint8List.fromList(await doc.save());
}

// ───────────────────────────────────────────────────────────────────
// صندوق الترويسة — مقيس: y 10..91 (h=81)، x 23..1000
// الشعار: القرص البرتقالي 70px، مركزه x=510.5
//         القرص يمثل 0.8008 من إطار PNG ⇒ الإطار = 87.4px
// ───────────────────────────────────────────────────────────────────
pw.Widget _headerBox(
  InvoiceFonts f,
  pw.MemoryImage logo,
  String company1,
  String company2,
) {
  const boxW = _X.headerRight - _X.headerLeft; // 977
  const logoBox = 87.4;

  // مقيس من الأصل: السطر1 حبره y 23..47، السطر2 y 51..72 ⇒ الخطوة 28px.
  // كلا السطرين محاذيان لحافة يمنى واحدة عند x = 992.
  const lineStep = 28.0;
  const line1Ink = 23.0;
  const line2Ink = 51.0;

  final style = pw.TextStyle(
    font: f.bold,
    fontBold: f.bold,
    fontFallback: f.latinFallback,
    fontSize: _F.companyLine,
    height: 1.0, // الخطوة تُدار بالإحداثيات لا بارتفاع السطر
  );

  /// سطر واحد من اسم الشركة، مثبَّت بحافته اليمنى المقيسة (x=992).
  pw.Widget companyLine(String text, double inkTop) => pw.Positioned(
    top: _r(inkTop - _Y.headerTop - 5),
    right: _r(_X.headerRight - _X.companyTextRight),
    child: pw.SizedBox(
      width: _r(_X.companyTextRight - _X.headerLeft - logoBox - 30),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.right,
        maxLines: 1,
        textDirection: pw.TextDirection.rtl,
        style: style,
      ),
    ),
  );

  assert(line2Ink - line1Ink == lineStep);

  return pw.Positioned(
    top: _r(_Y.headerTop),
    right: _r(_kRefW - _X.headerRight),
    child: pw.Container(
      width: _r(boxW),
      height: _r(_Y.headerBottom - _Y.headerTop),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _C.black, width: _W.headerBox),
        borderRadius: pw.BorderRadius.circular(_r(12)),
      ),
      child: pw.Stack(
        children: [
          // اسم الشركة — سطران، حافة يمنى موحّدة عند x=992
          companyLine(company1, line1Ink),
          companyLine(company2, line2Ink),
          // الشعار — مركزه المقيس x=510.5 داخل إطار يبدأ عند x=23
          pw.Positioned(
            top: _r((_Y.headerBottom - _Y.headerTop - logoBox) / 2 - 1),
            left: _r(_X.logoCenter - logoBox / 2 - _X.headerLeft),
            child: pw.SizedBox(
              width: _r(logoBox),
              height: _r(logoBox),
              child: pw.Image(logo, fit: pw.BoxFit.contain),
            ),
          ),
        ],
      ),
    ),
  );
}

// ───────────────────────────────────────────────────────────────────
// العنوان + تسطيره الكحلي
// مقيس: الحبر y 126..148، التسطير y 149..151 (3px)، x 412..612 (200px)
// ───────────────────────────────────────────────────────────────────
pw.Widget _titleBlock(InvoiceFonts f, String title) {
  const inkH = _Y.titleInkBottom - _Y.titleInkTop; // 22
  return pw.Positioned(
    top: _r(_Y.titleInkTop - 3), // تعويض الحافة العلوية لصندوق النص
    left: 0,
    right: 0,
    child: pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.SizedBox(
          height: _r(inkH + 6),
          child: pw.Center(
            child: pw.Text(
              title,
              textAlign: pw.TextAlign.center,
              maxLines: 1,
              style: pw.TextStyle(
                font: f.bold,
                fontBold: f.bold,
                fontFallback: f.latinFallback,
                fontSize: _F.title,
                color: _C.titleNavy,
              ),
            ),
          ),
        ),
        // ── التسطير: تحت النص لا في وسطه ──
        // طلب المستخدم: «لا أريده يستبعد، نزّله تحت وليس وسط النص».
        // كان الصندوق أعلاه بارتفاع `inkH + 6` فقط، وهو لا يستوعب
        // نازلات المحارف (ء / ه / ـل)، فيلامس الخط أسفل الحبر ويبدو
        // شاطباً للنص. الحل: فراغ صريح يفصل الخط عن أدنى نقطة حبر.
        pw.SizedBox(height: _r(_kTitleUnderlineGap)),
        // التسطير بعرض الحبر تماماً (200px) لا بعرض الصفحة
        pw.Container(
          width: _r(200),
          height: _W.titleUnderline,
          color: _C.titleNavy,
        ),
      ],
    ),
  );
}

// ───────────────────────────────────────────────────────────────────
// كتلة البيانات — عمودان، 3 صفوف عند y 160 / 190 / 219 (الخطوة ≈ 29.5)
// العمود الأيمن: الملصق ينتهي x=974، النقطتان x=860، القيمة تبدأ x=826
// العمود الأيسر: الملصق ينتهي x=297، النقطتان x=226، القيمة تبدأ x=195
// ───────────────────────────────────────────────────────────────────
pw.Widget _infoBlock(
  InvoiceFonts f,
  InvoiceRow inv,
  SubscriberRow sub,
  String invDisplay,
) {
  final right = <List<String>>[
    ['رقم الفاتورة', invDisplay],
    ['اسم المشترك', sub.subscriberName],
    [
      'الفترة',
      'من ${_pdfDate(inv.periodFrom)} حتى ${_pdfDate(inv.periodTo)}',
    ],
  ];
  final left = <List<String>>[
    [
      'رقم الدورة',
      inv.cycleNumber.isNotEmpty ? inv.cycleNumber : sub.routeNumber,
    ],
    ['رقم العداد', sub.meterNumber],
    ['الكبينة', sub.cabinName.isNotEmpty ? sub.cabinName : sub.locationName],
  ];

  const ys = [_Y.infoRow1, _Y.infoRow2, _Y.infoRow3];

  return pw.Stack(
    children: [
      for (var i = 0; i < 3; i++) ...[
        // العمود الأيمن
        _infoCell(
          f,
          label: right[i][0],
          value: right[i][1],
          y: ys[i],
          labelRight: _X.infoRLabelRight,
          labelWidth: _X.infoRLabelW,
          colonRight: _X.infoRColonRight,
          valueRight: _X.infoRValueRight,
          valueLeft: _X.infoRValueLeft,
        ),
        // العمود الأيسر
        _infoCell(
          f,
          label: left[i][0],
          value: left[i][1],
          y: ys[i],
          labelRight: _X.infoLLabelRight,
          labelWidth: _X.infoLLabelW,
          colonRight: _X.infoLColonRight,
          valueRight: _X.infoLValueRight,
          valueLeft: _X.infoLValueLeft,
        ),
      ],
    ],
  );
}

/// خلية بيانات واحدة، بإحداثيات مطلقة.
///
/// البنية المقيسة من الأصل (من اليمين إلى اليسار):
///   [الملصق  ← محاذى لليمين عند labelRight]
///   [النقطتان ← موضع ثابت، حافتها اليمنى colonRight]
///   [القيمة   ← محاذاة لليمين عند valueRight، تتمدد يساراً حتى valueLeft]
///
/// كل جزء له صندوقه المستقل، فلا يُقصّ أحدها الآخر.
pw.Widget _infoCell(
  InvoiceFonts f, {
  required String label,
  required String value,
  required double y,
  required double labelRight,
  required double labelWidth,
  required double colonRight,
  required double valueRight,
  required double valueLeft,
}) {
  final style = pw.TextStyle(
    font: f.bold,
    fontBold: f.bold,
    fontFallback: f.latinFallback,
    fontSize: _F.info,
  );

  // تعويض 4px: الحافة العلوية لصندوق النص أعلى من أول بكسل حبر
  final top = _r(y - 4);

  /// نص محاذى لحافته اليمنى، يتمدد يساراً بحرية دون قصّ.
  pw.Widget rightAligned(String text, double rightEdge, double maxLeft) =>
      pw.Positioned(
        top: top,
        right: _r(_kRefW - rightEdge),
        child: pw.SizedBox(
          width: _r(rightEdge - maxLeft),
          child: pw.Text(
            text,
            textAlign: pw.TextAlign.right,
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
            textDirection: pw.TextDirection.rtl,
            style: style,
          ),
        ),
      );

  return pw.Stack(
    children: [
      // الملصق — عرضه مستقل عن موقع النقطتين، فلا يُقصّ.
      // (أوسع حبر مقيس من الأصل 88px يميناً و 66px يساراً)
      rightAligned(label, labelRight, labelRight - labelWidth),
      // النقطتان — موضع ثابت مقيس
      rightAligned(':', colonRight, colonRight - 14),
      // القيمة — تتمدد يساراً
      rightAligned(value, valueRight, valueLeft),
    ],
  );
}

/// عرض الصورة المرجعية بالبكسل — أساس التحويل من «حافة يمنى» إلى `right`.
const double _kRefW = 1024;

// ───────────────────────────────────────────────────────────────────
// الخط السميك فوق الجدول — مقيس y 261..263 (3px)، x 32..991
// وهو أعرض من الجدول نفسه (x 45..982).
// ───────────────────────────────────────────────────────────────────
pw.Widget _ruleAboveTable() => pw.Positioned(
  top: _r(_Y.ruleAboveTable),
  right: _r(_kRefW - _X.ruleRight),
  child: pw.Container(
    width: _r(_X.ruleRight - _X.ruleLeft),
    height: _W.ruleAboveTable,
    color: _C.black,
  ),
);

// ───────────────────────────────────────────────────────────────────
// جدول الفاتورة — 8 أعمدة، x 45..982 (عرض 937px)
// الخطوط الرأسية المقيسة: 45, 233, 368, 451, 515, 641, 755, 868, 982
// الرأس y 270..306 (36px)، الجسم y 306..347 (41px)
// ملاحظة: pw.Table لا يحترم RTL ⇒ نعكس ترتيب الأعمدة يدوياً.
// ───────────────────────────────────────────────────────────────────
pw.Widget _billTable(InvoiceFonts f, InvoiceRow inv) {
  // ترتيب منطقي (يمين ← يسار) — مطابق للأصل
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

  // عروض الأعمدة بالبكسل المرجعي، مستنتجة من فروق الخطوط الرأسية
  // (يمين ← يسار): 982-868, 868-755, 755-641, 641-515, 515-451, ...
  const widths = <double>[
    114, // القراءة السابقة
    113, // القراءة الحالية
    114, // الاستهلاك
    126, // القيمة
    64, // خدمات
    83, // المتأخرات
    135, // مدفوع خلال الفترة
    188, // المبلغ المستحق
  ];

  // مقيس من الأصل: القيم بخانتين عشريتين وبلا فواصل ألوف،
  // و«خدمات» و«المتأخرات» تُكتبان «0» مجردة عند الصفر.
  final values = <String>[
    _pdfNum(inv.previousReading),
    _pdfNum(inv.currentReading),
    _pdfNum(inv.consumptionKwh),
    _pdfNum(inv.baseValue),
    inv.servicesAmount == 0 ? '0' : _pdfNum(inv.servicesAmount),
    inv.arrearsAmount == 0 ? '0' : _pdfNum(inv.arrearsAmount),
    inv.paidDuringPeriod == 0 ? '' : _pdfNum(inv.paidDuringPeriod),
    _pdfNum(inv.netDue),
  ];

  final vHeaders = headers.reversed.toList();
  final vValues = values.reversed.toList();
  final vWidths = widths.reversed.toList();

  final side = pw.BorderSide(color: _C.black, width: _W.tableBorder);

  return pw.Positioned(
    top: _r(_Y.tableTop),
    right: _r(_kRefW - _X.tableRight),
    child: pw.SizedBox(
      width: _r(_X.tableRight - _X.tableLeft),
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
          for (var i = 0; i < vWidths.length; i++)
            i: pw.FixedColumnWidth(_r(vWidths[i])),
        },
        children: [
          // رأس الجدول
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: _C.headBg),
            children: [
              for (final h in vHeaders)
                pw.Container(
                  height: _r(_Y.tableHeadBottom - _Y.tableTop),
                  padding: pw.EdgeInsets.symmetric(horizontal: _r(2)),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    h,
                    textAlign: pw.TextAlign.center,
                    textDirection: pw.TextDirection.rtl,
                    maxLines: 1,
                    style: pw.TextStyle(
                      font: f.bold,
                      fontBold: f.bold,
                      fontFallback: f.latinFallback,
                      fontSize: _F.tableHead,
                    ),
                  ),
                ),
            ],
          ),
          // جسم الجدول
          pw.TableRow(
            children: [
              for (var i = 0; i < vValues.length; i++)
                pw.Container(
                  height: _r(_Y.tableBottom - _Y.tableHeadBottom),
                  padding: pw.EdgeInsets.symmetric(horizontal: _r(2)),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    vValues[i],
                    textAlign: pw.TextAlign.center,
                    textDirection: pw.TextDirection.ltr,
                    maxLines: 1,
                    style: i == 0
                        // بعد العكس: العمود 0 = «المبلغ المستحق»
                        ? pw.TextStyle(
                            font: f.bold,
                            fontBold: f.bold,
                            fontFallback: f.latinFallback,
                            fontSize: _F.amountDue,
                            color: _C.amountBlue,
                          )
                        : pw.TextStyle(
                            font: f.bold,
                            fontBold: f.bold,
                            fontFallback: f.latinFallback,
                            fontSize: _F.tableValue,
                          ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ───────────────────────────────────────────────────────────────────
// سطر «المبلغ المستحق كتابةً» — مقيس: الحبر y 364..382، x 391..972
// ───────────────────────────────────────────────────────────────────
pw.Widget _writtenLine(InvoiceFonts f, String words) {
  final style = pw.TextStyle(
    font: f.bold,
    fontBold: f.bold,
    fontFallback: f.latinFallback,
    fontSize: _F.written,
  );
  return pw.Positioned(
    top: _r(_Y.writtenInk - 4),
    right: _r(_kRefW - _X.writtenRight),
    child: pw.SizedBox(
      width: _r(_X.writtenRight - _X.tableLeft),
      child: pw.RichText(
        textDirection: pw.TextDirection.rtl,
        textAlign: pw.TextAlign.right,
        maxLines: 1,
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: 'المبلغ المستحق كتابةً هو :- ', style: style),
            pw.TextSpan(text: words, style: style),
          ],
        ),
      ),
    ),
  );
}

// ───────────────────────────────────────────────────────────────────
// خط التذييل العلوي — مقيس y 390..391 (2px)، x 32..991
// ───────────────────────────────────────────────────────────────────
pw.Widget _footerRule() => pw.Positioned(
  top: _r(_Y.footerRule),
  right: _r(_kRefW - _X.ruleRight),
  child: pw.Container(
    width: _r(_X.ruleRight - _X.ruleLeft),
    height: _W.footerRule,
    color: _C.black,
  ),
);

// ───────────────────────────────────────────────────────────────────
// نص التذييل — مقيس: الحبر y 408..428
// «الحسابات» يسار عند x 131..188، والملاحظة يمين حتى x=983
// ───────────────────────────────────────────────────────────────────
pw.Widget _footerText(InvoiceFonts f, String note) => pw.Positioned(
  top: _r(_Y.footerInk - 5),
  right: _r(_kRefW - _X.footerNoteRight),
  child: pw.SizedBox(
    width: _r(_X.footerNoteRight - _X.footerAccountsLeft),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          note,
          maxLines: 1,
          textDirection: pw.TextDirection.rtl,
          style: pw.TextStyle(
            font: f.bold,
            fontBold: f.bold,
            fontFallback: f.latinFallback,
            fontSize: _F.footer,
            color: _C.titleNavy,
          ),
        ),
        pw.Text(
          'الحسابات',
          maxLines: 1,
          textDirection: pw.TextDirection.rtl,
          style: pw.TextStyle(
            font: f.bold,
            fontBold: f.bold,
            fontFallback: f.latinFallback,
            fontSize: _F.accounts,
          ),
        ),
      ],
    ),
  ),
);

// ───────────────────────────────────────────────────────────────────
// الشريط السفلي — مقيس y 458..459 (2px)، x 33..991
// ───────────────────────────────────────────────────────────────────
pw.Widget _bottomBar() => pw.Positioned(
  top: _r(_Y.bottomBar),
  right: _r(_kRefW - _X.ruleRight),
  child: pw.Container(
    width: _r(_X.ruleRight - _X.ruleLeft),
    height: _W.bottomBar,
    color: _C.black,
  ),
);
