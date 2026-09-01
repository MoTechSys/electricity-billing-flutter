import 'package:drift/drift.dart';

import 'connection/connection.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// قاعدة بيانات التطبيق — SQLite محلية بالكامل على الجهاز.
@DriftDatabase(tables: [Subscribers, Invoices, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

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
