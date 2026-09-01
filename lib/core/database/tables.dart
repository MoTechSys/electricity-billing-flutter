import 'package:drift/drift.dart';

/// حالة المشترك
class SubscriberStatus {
  static const active = 'active';
  static const inactive = 'inactive';
}

/// حالة الفاتورة
class InvoiceStatus {
  static const draft = 'draft';
  static const issued = 'issued';
  static const cancelled = 'cancelled';
}

/// جدول المشتركين
@DataClassName('SubscriberRow')
class Subscribers extends Table {
  TextColumn get id => text()();
  TextColumn get subscriberNumber => text().withDefault(const Constant(''))();
  TextColumn get subscriberName => text()();
  TextColumn get meterNumber => text().withDefault(const Constant(''))();
  TextColumn get routeNumber => text().withDefault(const Constant(''))();
  TextColumn get cabinName => text().withDefault(const Constant(''))();
  TextColumn get locationName => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get status =>
      text().withDefault(const Constant(SubscriberStatus.active))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// جدول الفواتير
@DataClassName('InvoiceRow')
class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNumber => text()();
  TextColumn get cycleNumber => text().withDefault(const Constant(''))();
  TextColumn get subscriberId =>
      text().references(Subscribers, #id, onDelete: KeyAction.cascade)();
  TextColumn get periodFrom => text()();
  TextColumn get periodTo => text()();
  RealColumn get previousReading => real().withDefault(const Constant(0))();
  RealColumn get currentReading => real().withDefault(const Constant(0))();
  RealColumn get consumptionKwh => real().withDefault(const Constant(0))();
  RealColumn get unitPrice => real().withDefault(const Constant(0))();
  RealColumn get baseValue => real().withDefault(const Constant(0))();
  RealColumn get servicesAmount => real().withDefault(const Constant(0))();
  RealColumn get arrearsAmount => real().withDefault(const Constant(0))();
  RealColumn get paidDuringPeriod => real().withDefault(const Constant(0))();
  RealColumn get grossAmount => real().withDefault(const Constant(0))();
  RealColumn get netDue => real().withDefault(const Constant(0))();
  TextColumn get netDueWords => text().withDefault(const Constant(''))();
  TextColumn get currency => text().withDefault(const Constant('ريال'))();
  TextColumn get status =>
      text().withDefault(const Constant(InvoiceStatus.draft))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get issuedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// جدول الإعدادات (مفتاح/قيمة)
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
