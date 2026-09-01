import 'package:drift/drift.dart';

/// يختار المنفّذ المناسب حسب المنصّة:
/// - الجوال/سطح المكتب  → SQLite أصلي (native.dart)
/// - الويب (المعاينة)   → SQLite WASM  (web.dart)
export 'native.dart' if (dart.library.js_interop) 'web.dart';

/// واجهة موحّدة يستدعيها [AppDatabase].
typedef ConnectionOpener = QueryExecutor Function();
