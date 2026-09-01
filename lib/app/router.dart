import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_info.dart';
import '../features/about/about_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/invoices/invoice_archive_screen.dart';
import '../features/invoices/invoice_form_screen.dart';
import '../features/invoices/invoice_preview_screen.dart';
import '../features/onboarding/license_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/subscribers/subscriber_form_screen.dart';
import '../features/subscribers/subscribers_screen.dart';

GoRouter buildRouter({required bool licensed}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => SplashScreen(licensed: licensed),
      ),
      GoRoute(path: '/license', builder: (_, _) => const LicenseScreen()),
      GoRoute(path: '/dashboard', builder: (_, _) => const DashboardScreen()),
      GoRoute(
        path: '/subscribers',
        builder: (_, _) => const SubscribersScreen(),
      ),
      GoRoute(
        path: '/subscribers/new',
        builder: (_, _) => const SubscriberFormScreen(),
      ),
      GoRoute(
        path: '/invoices/new',
        builder: (context, state) => InvoiceFormScreen(
          presetSubscriberId: state.uri.queryParameters['subscriber'],
        ),
      ),
      GoRoute(
        path: '/invoices/archive',
        builder: (_, _) => const InvoiceArchiveScreen(),
      ),
      GoRoute(
        path: '/invoices/:id/print',
        builder: (context, state) =>
            InvoicePreviewScreen(invoiceId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: AppInfo.aboutRoute, builder: (_, _) => const AboutScreen()),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('صفحة غير موجودة: ${state.uri}'))),
  );
}
