import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'database/billing_repository.dart';

/// قاعدة البيانات (تُحقن في main بعد التهيئة).
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden');
});

final repositoryProvider = Provider<BillingRepository>(
  (ref) => BillingRepository(ref.watch(databaseProvider)),
);

// ---------------------------------------------------------------------------
// الإعدادات
// ---------------------------------------------------------------------------

final settingsProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(repositoryProvider).watchSettings(),
);

/// قيمة إعداد واحدة مع الرجوع للافتراضي.
String settingOf(Map<String, String>? map, String key) =>
    map?[key] ?? SettingKeys.defaults[key] ?? '';

// ---------------------------------------------------------------------------
// لوحة التحكم
// ---------------------------------------------------------------------------

final statsProvider = StreamProvider<DashboardStats>(
  (ref) => ref.watch(repositoryProvider).watchStats(),
);

// ---------------------------------------------------------------------------
// المشتركون
// ---------------------------------------------------------------------------

final subscriberQueryProvider = StateProvider<String>((_) => '');

final subscribersProvider = StreamProvider<List<SubscriberRow>>((ref) {
  final q = ref.watch(subscriberQueryProvider);
  return ref.watch(repositoryProvider).watchSubscribers(query: q);
});

final subscriberByIdProvider = FutureProvider.family<SubscriberRow?, String>((
  ref,
  id,
) {
  return ref.watch(repositoryProvider).getSubscriber(id);
});

// ---------------------------------------------------------------------------
// الفواتير
// ---------------------------------------------------------------------------

final invoiceQueryProvider = StateProvider<String>((_) => '');
final invoiceStatusFilterProvider = StateProvider<String?>((_) => null);

final invoicesProvider = StreamProvider<List<InvoiceWithSubscriber>>((ref) {
  final q = ref.watch(invoiceQueryProvider);
  final status = ref.watch(invoiceStatusFilterProvider);
  return ref.watch(repositoryProvider).watchInvoices(query: q, status: status);
});

/// فاتورة + مشتركها (لشاشة المعاينة والطباعة).
final invoiceDetailProvider =
    FutureProvider.family<InvoiceWithSubscriber?, String>((ref, id) async {
      final repo = ref.watch(repositoryProvider);
      final inv = await repo.getInvoice(id);
      if (inv == null) return null;
      final sub = await repo.getSubscriber(inv.subscriberId);
      return InvoiceWithSubscriber(inv, sub);
    });
