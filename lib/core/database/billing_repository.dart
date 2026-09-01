import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables.dart';

/// المفاتيح والقيم الافتراضية للإعدادات — مطابقة لنسخة الويب.
class SettingKeys {
  static const companyName = 'company_name';
  static const companySubtitle = 'company_subtitle';
  static const invoiceTitle = 'invoice_title';
  static const footerNote = 'footer_note';
  static const defaultUnitPrice = 'default_unit_price';
  static const currency = 'currency';

  static const defaults = <String, String>{
    companyName: 'شركة العباسي',
    companySubtitle: 'لتوليد الطاقة الكهربائية',
    invoiceTitle: 'فاتورة استهلاك كهرباء',
    footerNote: 'ملاحظة: المحطة غير مسؤولة عن تسليم أي مبلغ بدون سند رسمي',
    defaultUnitPrice: '220',
    currency: 'ريال',
  };
}

/// إحصائيات لوحة التحكم.
class DashboardStats {
  const DashboardStats({
    this.subscribers = 0,
    this.activeSubscribers = 0,
    this.invoices = 0,
    this.issued = 0,
    this.drafts = 0,
    this.revenue = 0,
    this.daily = const [],
  });

  final int subscribers;
  final int activeSubscribers;
  final int invoices;
  final int issued;
  final int drafts;
  final double revenue;

  /// مجاميع آخر 7 أيام (الأقدم أولاً).
  final List<DailyTotal> daily;
}

class DailyTotal {
  const DailyTotal(this.date, this.total);
  final DateTime date;
  final double total;

  String get label => '${date.month}/${date.day}';
}

/// سطر أرشيف الفاتورة مع بيانات المشترك.
class InvoiceWithSubscriber {
  const InvoiceWithSubscriber(this.invoice, this.subscriber);
  final InvoiceRow invoice;
  final SubscriberRow? subscriber;

  String get subscriberName => subscriber?.subscriberName ?? 'محذوف';
  String get subscriberNumber => subscriber?.subscriberNumber ?? '';
}

/// نتيجة استيراد نسخة احتياطية.
class ImportResult {
  const ImportResult(this.subscribers, this.invoices, this.settings);
  final int subscribers;
  final int invoices;
  final int settings;
}

/// طبقة الوصول للبيانات — كل الاستعلامات تتم في SQL (لا فلترة في الذاكرة).
class BillingRepository {
  BillingRepository(this._db);

  final AppDatabase _db;

  static final _rand = Random();

  /// معرّف فريد بنفس صيغة نسخة الويب (للتوافق مع النسخ الاحتياطية).
  static String generateId() {
    final ts = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final rnd = List.generate(
      7,
      (_) => 'abcdefghijklmnopqrstuvwxyz0123456789'[_rand.nextInt(36)],
    ).join();
    return 'id_${ts}_$rnd';
  }

  // ------------------------------------------------------------------
  // المشتركون
  // ------------------------------------------------------------------

  /// بحث مفهرس في SQL (اسم / رقم مشترك / رقم عداد).
  Stream<List<SubscriberRow>> watchSubscribers({String query = ''}) {
    final q = query.trim();
    final select = _db.select(_db.subscribers)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (q.isNotEmpty) {
      final like = '%$q%';
      select.where(
        (t) =>
            t.subscriberName.like(like) |
            t.subscriberNumber.like(like) |
            t.meterNumber.like(like),
      );
    }
    return select.watch();
  }

  Future<SubscriberRow?> getSubscriber(String id) =>
      (_db.select(_db.subscribers)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<SubscriberRow>> searchSubscribers(String query,
      {int limit = 30}) {
    final q = query.trim();
    final select = _db.select(_db.subscribers)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);
    if (q.isNotEmpty) {
      final like = '%$q%';
      select.where(
        (t) =>
            t.subscriberName.like(like) |
            t.subscriberNumber.like(like) |
            t.meterNumber.like(like),
      );
    }
    return select.get();
  }

  Future<String> insertSubscriber({
    required String subscriberName,
    String subscriberNumber = '',
    String meterNumber = '',
    String routeNumber = '',
    String cabinName = '',
    String locationName = '',
    String phone = '',
    String notes = '',
  }) async {
    final now = DateTime.now();
    final id = generateId();
    await _db.into(_db.subscribers).insert(
          SubscribersCompanion.insert(
            id: id,
            subscriberName: subscriberName,
            subscriberNumber: Value(subscriberNumber),
            meterNumber: Value(meterNumber),
            routeNumber: Value(routeNumber),
            cabinName: Value(cabinName),
            locationName: Value(locationName),
            phone: Value(phone),
            notes: Value(notes),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> updateSubscriberStatus(String id, String status) {
    return (_db.update(_db.subscribers)..where((t) => t.id.equals(id))).write(
      SubscribersCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// حذف المشترك — الفواتير تُحذف تلقائياً (ON DELETE CASCADE).
  Future<void> deleteSubscriber(String id) {
    return (_db.delete(_db.subscribers)..where((t) => t.id.equals(id))).go();
  }

  Future<int> countInvoicesOf(String subscriberId) async {
    final expr = _db.invoices.id.count();
    final row = await (_db.selectOnly(_db.invoices)
          ..addColumns([expr])
          ..where(_db.invoices.subscriberId.equals(subscriberId)))
        .getSingle();
    return row.read(expr) ?? 0;
  }

  // ------------------------------------------------------------------
  // الفواتير
  // ------------------------------------------------------------------

  Future<InvoiceRow?> getInvoice(String id) =>
      (_db.select(_db.invoices)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// آخر قراءة حالية للمشترك (لتعبئة القراءة السابقة تلقائياً).
  Future<double?> lastReadingOf(String subscriberId) async {
    final row = await (_db.select(_db.invoices)
          ..where((t) => t.subscriberId.equals(subscriberId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
    return row?.currentReading;
  }

  /// أرشيف الفواتير مع بيانات المشترك — join في SQL.
  Stream<List<InvoiceWithSubscriber>> watchInvoices({
    String query = '',
    String? status,
  }) {
    final q = query.trim();
    final select = _db.select(_db.invoices).join([
      leftOuterJoin(
        _db.subscribers,
        _db.subscribers.id.equalsExp(_db.invoices.subscriberId),
      ),
    ])
      ..orderBy([OrderingTerm.desc(_db.invoices.createdAt)]);

    if (status != null && status.isNotEmpty) {
      select.where(_db.invoices.status.equals(status));
    }
    if (q.isNotEmpty) {
      final like = '%$q%';
      select.where(
        _db.invoices.invoiceNumber.like(like) |
            _db.subscribers.subscriberName.like(like) |
            _db.subscribers.subscriberNumber.like(like),
      );
    }

    return select.watch().map(
          (rows) => rows
              .map(
                (r) => InvoiceWithSubscriber(
                  r.readTable(_db.invoices),
                  r.readTableOrNull(_db.subscribers),
                ),
              )
              .toList(),
        );
  }

  Future<String> insertInvoice(InvoicesCompanion companion) async {
    await _db.into(_db.invoices).insert(companion);
    return companion.id.value;
  }

  Future<void> deleteInvoice(String id) {
    return (_db.delete(_db.invoices)..where((t) => t.id.equals(id))).go();
  }

  /// رقم فاتورة تسلسلي داخل الشهر — INV-YYYY-MM-NNNN
  Future<String> nextInvoiceNumber() async {
    final now = DateTime.now();
    final prefix =
        'INV-${now.year}-${now.month.toString().padLeft(2, '0')}-';
    final last = await (_db.select(_db.invoices)
          ..where((t) => t.invoiceNumber.like('$prefix%'))
          ..orderBy([(t) => OrderingTerm.desc(t.invoiceNumber)])
          ..limit(1))
        .getSingleOrNull();
    final seq = last == null
        ? 1
        : (int.tryParse(last.invoiceNumber.substring(prefix.length)) ?? 0) + 1;
    return '$prefix${seq.toString().padLeft(4, '0')}';
  }

  // ------------------------------------------------------------------
  // لوحة التحكم
  // ------------------------------------------------------------------

  Stream<DashboardStats> watchStats() {
    // نراقب التغييرات على الجدولين ونعيد الحساب عبر استعلامات مجمّعة.
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {_db.subscribers, _db.invoices},
        )
        .watch()
        .asyncMap((_) => _computeStats());
  }

  Future<DashboardStats> _computeStats() async {
    Future<int> countOf(String sql) async {
      final row = await _db.customSelect(sql).getSingle();
      return row.read<int>('c');
    }

    final subscribers = await countOf('SELECT COUNT(*) AS c FROM subscribers');
    final active = await countOf(
      "SELECT COUNT(*) AS c FROM subscribers WHERE status = 'active'",
    );
    final invoices = await countOf('SELECT COUNT(*) AS c FROM invoices');
    final issued = await countOf(
      "SELECT COUNT(*) AS c FROM invoices WHERE status = 'issued'",
    );
    final drafts = await countOf(
      "SELECT COUNT(*) AS c FROM invoices WHERE status = 'draft'",
    );

    final revenueRow = await _db
        .customSelect(
          "SELECT COALESCE(SUM(net_due), 0) AS s FROM invoices WHERE status = 'issued'",
        )
        .getSingle();
    final revenue = revenueRow.read<double>('s');

    // مجاميع آخر 7 أيام
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));
    final rows = await (_db.select(_db.invoices)
          ..where(
            (t) =>
                t.status.equals(InvoiceStatus.issued) &
                t.createdAt.isBiggerOrEqualValue(start),
          ))
        .get();

    final buckets = <DateTime, double>{
      for (var i = 0; i < 7; i++) start.add(Duration(days: i)): 0,
    };
    for (final inv in rows) {
      final key = DateTime(
        inv.createdAt.year,
        inv.createdAt.month,
        inv.createdAt.day,
      );
      if (buckets.containsKey(key)) {
        buckets[key] = buckets[key]! + inv.netDue;
      }
    }

    return DashboardStats(
      subscribers: subscribers,
      activeSubscribers: active,
      invoices: invoices,
      issued: issued,
      drafts: drafts,
      revenue: revenue,
      daily: buckets.entries.map((e) => DailyTotal(e.key, e.value)).toList(),
    );
  }

  // ------------------------------------------------------------------
  // الإعدادات
  // ------------------------------------------------------------------

  Future<Map<String, String>> loadSettings() async {
    final rows = await _db.select(_db.settings).get();
    final map = Map<String, String>.from(SettingKeys.defaults);
    for (final r in rows) {
      map[r.key] = r.value;
    }
    return map;
  }

  Stream<Map<String, String>> watchSettings() {
    return _db.select(_db.settings).watch().map((rows) {
      final map = Map<String, String>.from(SettingKeys.defaults);
      for (final r in rows) {
        map[r.key] = r.value;
      }
      return map;
    });
  }

  Future<void> saveSettings(Map<String, String> values) async {
    await _db.batch((b) {
      for (final e in values.entries) {
        b.insert(
          _db.settings,
          SettingRow(key: e.key, value: e.value),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ------------------------------------------------------------------
  // النسخ الاحتياطي — نفس صيغة نسخة الويب (motech-billing v1)
  // ------------------------------------------------------------------

  static const _backupApp = 'motech-billing';
  static const _backupVersion = 1;

  String _iso(DateTime d) => d.toUtc().toIso8601String();

  DateTime _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) {
      return DateTime.tryParse(v)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }

  double _num(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0;
  }

  Future<String> exportJson() async {
    final subs = await _db.select(_db.subscribers).get();
    final invs = await _db.select(_db.invoices).get();
    final sets = await _db.select(_db.settings).get();

    final payload = {
      'app': _backupApp,
      'version': _backupVersion,
      'exportedAt': _iso(DateTime.now()),
      'data': {
        'subscribers': subs
            .map(
              (s) => {
                'id': s.id,
                'subscriberNumber': s.subscriberNumber,
                'subscriberName': s.subscriberName,
                'meterNumber': s.meterNumber,
                'routeNumber': s.routeNumber,
                'cabinName': s.cabinName,
                'locationName': s.locationName,
                'phone': s.phone,
                'status': s.status,
                'notes': s.notes,
                'createdAt': _iso(s.createdAt),
                'updatedAt': _iso(s.updatedAt),
              },
            )
            .toList(),
        'invoices': invs
            .map(
              (i) => {
                'id': i.id,
                'invoiceNumber': i.invoiceNumber,
                'cycleNumber': i.cycleNumber,
                'subscriberId': i.subscriberId,
                'periodFrom': i.periodFrom,
                'periodTo': i.periodTo,
                'previousReading': i.previousReading,
                'currentReading': i.currentReading,
                'consumptionKwh': i.consumptionKwh,
                'unitPrice': i.unitPrice,
                'baseValue': i.baseValue,
                'servicesAmount': i.servicesAmount,
                'arrearsAmount': i.arrearsAmount,
                'paidDuringPeriod': i.paidDuringPeriod,
                'grossAmount': i.grossAmount,
                'netDue': i.netDue,
                'netDueWords': i.netDueWords,
                'currency': i.currency,
                'status': i.status,
                'notes': i.notes,
                'issuedAt': i.issuedAt == null ? null : _iso(i.issuedAt!),
                'createdAt': _iso(i.createdAt),
                'updatedAt': _iso(i.updatedAt),
              },
            )
            .toList(),
        'settings': sets.map((s) => {'key': s.key, 'value': s.value}).toList(),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<ImportResult> importJson(String json) async {
    final parsed = jsonDecode(json);
    if (parsed is! Map || parsed['app'] != _backupApp) {
      throw const FormatException('ملف غير صالح');
    }
    final data = (parsed['data'] as Map?) ?? const {};
    final subs = (data['subscribers'] as List?) ?? const [];
    final invs = (data['invoices'] as List?) ?? const [];
    final sets = (data['settings'] as List?) ?? const [];

    await _db.transaction(() async {
      await _db.batch((b) {
        for (final raw in subs) {
          final m = raw as Map;
          b.insert(
            _db.subscribers,
            SubscriberRow(
              id: '${m['id']}',
              subscriberNumber: '${m['subscriberNumber'] ?? ''}',
              subscriberName: '${m['subscriberName'] ?? ''}',
              meterNumber: '${m['meterNumber'] ?? ''}',
              routeNumber: '${m['routeNumber'] ?? ''}',
              cabinName: '${m['cabinName'] ?? ''}',
              locationName: '${m['locationName'] ?? ''}',
              phone: '${m['phone'] ?? ''}',
              status: '${m['status'] ?? SubscriberStatus.active}',
              notes: '${m['notes'] ?? ''}',
              createdAt: _parseDate(m['createdAt']),
              updatedAt: _parseDate(m['updatedAt']),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });

      await _db.batch((b) {
        for (final raw in invs) {
          final m = raw as Map;
          b.insert(
            _db.invoices,
            InvoiceRow(
              id: '${m['id']}',
              invoiceNumber: '${m['invoiceNumber'] ?? ''}',
              cycleNumber: '${m['cycleNumber'] ?? ''}',
              subscriberId: '${m['subscriberId']}',
              periodFrom: '${m['periodFrom'] ?? ''}',
              periodTo: '${m['periodTo'] ?? ''}',
              previousReading: _num(m['previousReading']),
              currentReading: _num(m['currentReading']),
              consumptionKwh: _num(m['consumptionKwh']),
              unitPrice: _num(m['unitPrice']),
              baseValue: _num(m['baseValue']),
              servicesAmount: _num(m['servicesAmount']),
              arrearsAmount: _num(m['arrearsAmount']),
              paidDuringPeriod: _num(m['paidDuringPeriod']),
              grossAmount: _num(m['grossAmount']),
              netDue: _num(m['netDue']),
              netDueWords: '${m['netDueWords'] ?? ''}',
              currency: '${m['currency'] ?? 'ريال'}',
              status: '${m['status'] ?? InvoiceStatus.draft}',
              notes: '${m['notes'] ?? ''}',
              issuedAt:
                  m['issuedAt'] == null ? null : _parseDate(m['issuedAt']),
              createdAt: _parseDate(m['createdAt']),
              updatedAt: _parseDate(m['updatedAt']),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });

      await _db.batch((b) {
        for (final raw in sets) {
          final m = raw as Map;
          b.insert(
            _db.settings,
            SettingRow(key: '${m['key']}', value: '${m['value'] ?? ''}'),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    });

    return ImportResult(subs.length, invs.length, sets.length);
  }
}
