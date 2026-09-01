import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/database/app_database.dart';
import 'core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final prefs = await SharedPreferences.getInstance();
  final licensed = prefs.getBool('app_licensed') ?? false;

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MotechBillingApp(licensed: licensed),
    ),
  );
}

class MotechBillingApp extends StatefulWidget {
  const MotechBillingApp({super.key, required this.licensed});

  final bool licensed;

  @override
  State<MotechBillingApp> createState() => _MotechBillingAppState();
}

class _MotechBillingAppState extends State<MotechBillingApp> {
  late final _router = buildRouter(licensed: widget.licensed);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'فواتير الكهرباء',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: MediaQuery.withNoTextScaling(child: child!),
      ),
    );
  }
}
