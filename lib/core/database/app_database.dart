import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// قاعدة بيانات التطبيق — SQLite محلية بالكامل على الجهاز.
@DriftDatabase(tables: [Subscribers, Invoices, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// للاختبارات: قاعدة بيانات في الذاكرة.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // تفعيل المفاتيح الأجنبية (لازم لحذف الفواتير تلقائياً مع المشترك)
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) {
        await _createIndexes();
      }
    },
    onCreate: (m) async {
      await m.createAll();
    },
  );

  /// فهارس تسريع البحث والفرز مع البيانات الكبيرة.
  Future<void> _createIndexes() async {
    const statements = [
      'CREATE INDEX IF NOT EXISTS idx_sub_created ON subscribers (created_at DESC)',
      'CREATE INDEX IF NOT EXISTS idx_sub_status ON subscribers (status)',
      'CREATE INDEX IF NOT EXISTS idx_sub_number ON subscribers (subscriber_number)',
      'CREATE INDEX IF NOT EXISTS idx_sub_meter ON subscribers (meter_number)',
      'CREATE INDEX IF NOT EXISTS idx_inv_created ON invoices (created_at DESC)',
      'CREATE INDEX IF NOT EXISTS idx_inv_status ON invoices (status)',
      'CREATE INDEX IF NOT EXISTS idx_inv_sub ON invoices (subscriber_id)',
      'CREATE INDEX IF NOT EXISTS idx_inv_number ON invoices (invoice_number)',
    ];
    for (final s in statements) {
      await customStatement(s);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'motech_billing.sqlite'));

    // تحسينات النظام الموصى بها من drift.
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    sqlite3.tempDirectory = (await getTemporaryDirectory()).path;

    return NativeDatabase.createInBackground(file);
  });
}
