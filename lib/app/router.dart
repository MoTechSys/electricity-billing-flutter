import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        builder: (_, __) => SplashScreen(licensed: licensed),
      ),
      GoRoute(path: '/license', builder: (_, __) => const LicenseScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(
        path: '/subscribers',
        builder: (_, __) => const SubscribersScreen(),
      ),
      GoRoute(
        path: '/subscribers/new',
        builder: (_, __) => const SubscriberFormScreen(),
      ),
      GoRoute(
        path: '/invoices/new',
        builder: (context, state) => InvoiceFormScreen(
          presetSubscriberId: state.uri.queryParameters['subscriber'],
        ),
      ),
      GoRoute(
        path: '/invoices/archive',
        builder: (_, __) => const InvoiceArchiveScreen(),
      ),
      GoRoute(
        path: '/invoices/:id/print',
        builder: (context, state) =>
            InvoicePreviewScreen(invoiceId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('صفحة غير موجودة: ${state.uri}')),
    ),
  );
}
