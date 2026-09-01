import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// قاعدة بيانات للمعاينة على الويب — SQLite مُصرَّفة إلى WebAssembly
/// وتُخزَّن في IndexedDB داخل المتصفّح.
///
/// تُستخدم فقط في معاينة المتصفّح؛ التطبيق على الجوال يستعمل
/// `native.dart` مع SQLite أصلي.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'motech_billing',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
