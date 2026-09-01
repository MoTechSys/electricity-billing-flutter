// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SubscribersTable extends Subscribers
    with TableInfo<$SubscribersTable, SubscriberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscribersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subscriberNumberMeta = const VerificationMeta(
    'subscriberNumber',
  );
  @override
  late final GeneratedColumn<String> subscriberNumber = GeneratedColumn<String>(
    'subscriber_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _subscriberNameMeta = const VerificationMeta(
    'subscriberName',
  );
  @override
  late final GeneratedColumn<String> subscriberName = GeneratedColumn<String>(
    'subscriber_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meterNumberMeta = const VerificationMeta(
    'meterNumber',
  );
  @override
  late final GeneratedColumn<String> meterNumber = GeneratedColumn<String>(
    'meter_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _routeNumberMeta = const VerificationMeta(
    'routeNumber',
  );
  @override
  late final GeneratedColumn<String> routeNumber = GeneratedColumn<String>(
    'route_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cabinNameMeta = const VerificationMeta(
    'cabinName',
  );
  @override
  late final GeneratedColumn<String> cabinName = GeneratedColumn<String>(
    'cabin_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _locationNameMeta = const VerificationMeta(
    'locationName',
  );
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
    'location_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SubscriberStatus.active),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subscriberNumber,
    subscriberName,
    meterNumber,
    routeNumber,
    cabinName,
    locationName,
    phone,
    status,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscribers';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubscriberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subscriber_number')) {
      context.handle(
        _subscriberNumberMeta,
        subscriberNumber.isAcceptableOrUnknown(
          data['subscriber_number']!,
          _subscriberNumberMeta,
        ),
      );
    }
    if (data.containsKey('subscriber_name')) {
      context.handle(
        _subscriberNameMeta,
        subscriberName.isAcceptableOrUnknown(
          data['subscriber_name']!,
          _subscriberNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscriberNameMeta);
    }
    if (data.containsKey('meter_number')) {
      context.handle(
        _meterNumberMeta,
        meterNumber.isAcceptableOrUnknown(
          data['meter_number']!,
          _meterNumberMeta,
        ),
      );
    }
    if (data.containsKey('route_number')) {
      context.handle(
        _routeNumberMeta,
        routeNumber.isAcceptableOrUnknown(
          data['route_number']!,
          _routeNumberMeta,
        ),
      );
    }
    if (data.containsKey('cabin_name')) {
      context.handle(
        _cabinNameMeta,
        cabinName.isAcceptableOrUnknown(data['cabin_name']!, _cabinNameMeta),
      );
    }
    if (data.containsKey('location_name')) {
      context.handle(
        _locationNameMeta,
        locationName.isAcceptableOrUnknown(
          data['location_name']!,
          _locationNameMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubscriberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      subscriberNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscriber_number'],
      )!,
      subscriberName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscriber_name'],
      )!,
      meterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meter_number'],
      )!,
      routeNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_number'],
      )!,
      cabinName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cabin_name'],
      )!,
      locationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SubscribersTable createAlias(String alias) {
    return $SubscribersTable(attachedDatabase, alias);
  }
}

class SubscriberRow extends DataClass implements Insertable<SubscriberRow> {
  final String id;
  final String subscriberNumber;
  final String subscriberName;
  final String meterNumber;
  final String routeNumber;
  final String cabinName;
  final String locationName;
  final String phone;
  final String status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SubscriberRow({
    required this.id,
    required this.subscriberNumber,
    required this.subscriberName,
    required this.meterNumber,
    required this.routeNumber,
    required this.cabinName,
    required this.locationName,
    required this.phone,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subscriber_number'] = Variable<String>(subscriberNumber);
    map['subscriber_name'] = Variable<String>(subscriberName);
    map['meter_number'] = Variable<String>(meterNumber);
    map['route_number'] = Variable<String>(routeNumber);
    map['cabin_name'] = Variable<String>(cabinName);
    map['location_name'] = Variable<String>(locationName);
    map['phone'] = Variable<String>(phone);
    map['status'] = Variable<String>(status);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SubscribersCompanion toCompanion(bool nullToAbsent) {
    return SubscribersCompanion(
      id: Value(id),
      subscriberNumber: Value(subscriberNumber),
      subscriberName: Value(subscriberName),
      meterNumber: Value(meterNumber),
      routeNumber: Value(routeNumber),
      cabinName: Value(cabinName),
      locationName: Value(locationName),
      phone: Value(phone),
      status: Value(status),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SubscriberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriberRow(
      id: serializer.fromJson<String>(json['id']),
      subscriberNumber: serializer.fromJson<String>(json['subscriberNumber']),
      subscriberName: serializer.fromJson<String>(json['subscriberName']),
      meterNumber: serializer.fromJson<String>(json['meterNumber']),
      routeNumber: serializer.fromJson<String>(json['routeNumber']),
      cabinName: serializer.fromJson<String>(json['cabinName']),
      locationName: serializer.fromJson<String>(json['locationName']),
      phone: serializer.fromJson<String>(json['phone']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subscriberNumber': serializer.toJson<String>(subscriberNumber),
      'subscriberName': serializer.toJson<String>(subscriberName),
      'meterNumber': serializer.toJson<String>(meterNumber),
      'routeNumber': serializer.toJson<String>(routeNumber),
      'cabinName': serializer.toJson<String>(cabinName),
      'locationName': serializer.toJson<String>(locationName),
      'phone': serializer.toJson<String>(phone),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SubscriberRow copyWith({
    String? id,
    String? subscriberNumber,
    String? subscriberName,
    String? meterNumber,
    String? routeNumber,
    String? cabinName,
    String? locationName,
    String? phone,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SubscriberRow(
    id: id ?? this.id,
    subscriberNumber: subscriberNumber ?? this.subscriberNumber,
    subscriberName: subscriberName ?? this.subscriberName,
    meterNumber: meterNumber ?? this.meterNumber,
    routeNumber: routeNumber ?? this.routeNumber,
    cabinName: cabinName ?? this.cabinName,
    locationName: locationName ?? this.locationName,
    phone: phone ?? this.phone,
    status: status ?? this.status,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SubscriberRow copyWithCompanion(SubscribersCompanion data) {
    return SubscriberRow(
      id: data.id.present ? data.id.value : this.id,
      subscriberNumber: data.subscriberNumber.present
          ? data.subscriberNumber.value
          : this.subscriberNumber,
      subscriberName: data.subscriberName.present
          ? data.subscriberName.value
          : this.subscriberName,
      meterNumber: data.meterNumber.present
          ? data.meterNumber.value
          : this.meterNumber,
      routeNumber: data.routeNumber.present
          ? data.routeNumber.value
          : this.routeNumber,
      cabinName: data.cabinName.present ? data.cabinName.value : this.cabinName,
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
      phone: data.phone.present ? data.phone.value : this.phone,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriberRow(')
          ..write('id: $id, ')
          ..write('subscriberNumber: $subscriberNumber, ')
          ..write('subscriberName: $subscriberName, ')
          ..write('meterNumber: $meterNumber, ')
          ..write('routeNumber: $routeNumber, ')
          ..write('cabinName: $cabinName, ')
          ..write('locationName: $locationName, ')
          ..write('phone: $phone, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subscriberNumber,
    subscriberName,
    meterNumber,
    routeNumber,
    cabinName,
    locationName,
    phone,
    status,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriberRow &&
          other.id == this.id &&
          other.subscriberNumber == this.subscriberNumber &&
          other.subscriberName == this.subscriberName &&
          other.meterNumber == this.meterNumber &&
          other.routeNumber == this.routeNumber &&
          other.cabinName == this.cabinName &&
          other.locationName == this.locationName &&
          other.phone == this.phone &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SubscribersCompanion extends UpdateCompanion<SubscriberRow> {
  final Value<String> id;
  final Value<String> subscriberNumber;
  final Value<String> subscriberName;
  final Value<String> meterNumber;
  final Value<String> routeNumber;
  final Value<String> cabinName;
  final Value<String> locationName;
  final Value<String> phone;
  final Value<String> status;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SubscribersCompanion({
    this.id = const Value.absent(),
    this.subscriberNumber = const Value.absent(),
    this.subscriberName = const Value.absent(),
    this.meterNumber = const Value.absent(),
    this.routeNumber = const Value.absent(),
    this.cabinName = const Value.absent(),
    this.locationName = const Value.absent(),
    this.phone = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscribersCompanion.insert({
    required String id,
    this.subscriberNumber = const Value.absent(),
    required String subscriberName,
    this.meterNumber = const Value.absent(),
    this.routeNumber = const Value.absent(),
    this.cabinName = const Value.absent(),
    this.locationName = const Value.absent(),
    this.phone = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       subscriberName = Value(subscriberName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SubscriberRow> custom({
    Expression<String>? id,
    Expression<String>? subscriberNumber,
    Expression<String>? subscriberName,
    Expression<String>? meterNumber,
    Expression<String>? routeNumber,
    Expression<String>? cabinName,
    Expression<String>? locationName,
    Expression<String>? phone,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subscriberNumber != null) 'subscriber_number': subscriberNumber,
      if (subscriberName != null) 'subscriber_name': subscriberName,
      if (meterNumber != null) 'meter_number': meterNumber,
      if (routeNumber != null) 'route_number': routeNumber,
      if (cabinName != null) 'cabin_name': cabinName,
      if (locationName != null) 'location_name': locationName,
      if (phone != null) 'phone': phone,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscribersCompanion copyWith({
    Value<String>? id,
    Value<String>? subscriberNumber,
    Value<String>? subscriberName,
    Value<String>? meterNumber,
    Value<String>? routeNumber,
    Value<String>? cabinName,
    Value<String>? locationName,
    Value<String>? phone,
    Value<String>? status,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SubscribersCompanion(
      id: id ?? this.id,
      subscriberNumber: subscriberNumber ?? this.subscriberNumber,
      subscriberName: subscriberName ?? this.subscriberName,
      meterNumber: meterNumber ?? this.meterNumber,
      routeNumber: routeNumber ?? this.routeNumber,
      cabinName: cabinName ?? this.cabinName,
      locationName: locationName ?? this.locationName,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subscriberNumber.present) {
      map['subscriber_number'] = Variable<String>(subscriberNumber.value);
    }
    if (subscriberName.present) {
      map['subscriber_name'] = Variable<String>(subscriberName.value);
    }
    if (meterNumber.present) {
      map['meter_number'] = Variable<String>(meterNumber.value);
    }
    if (routeNumber.present) {
      map['route_number'] = Variable<String>(routeNumber.value);
    }
    if (cabinName.present) {
      map['cabin_name'] = Variable<String>(cabinName.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscribersCompanion(')
          ..write('id: $id, ')
          ..write('subscriberNumber: $subscriberNumber, ')
          ..write('subscriberName: $subscriberName, ')
          ..write('meterNumber: $meterNumber, ')
          ..write('routeNumber: $routeNumber, ')
          ..write('cabinName: $cabinName, ')
          ..write('locationName: $locationName, ')
          ..write('phone: $phone, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices
    with TableInfo<$InvoicesTable, InvoiceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta(
    'invoiceNumber',
  );
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleNumberMeta = const VerificationMeta(
    'cycleNumber',
  );
  @override
  late final GeneratedColumn<String> cycleNumber = GeneratedColumn<String>(
    'cycle_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _subscriberIdMeta = const VerificationMeta(
    'subscriberId',
  );
  @override
  late final GeneratedColumn<String> subscriberId = GeneratedColumn<String>(
    'subscriber_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subscribers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _periodFromMeta = const VerificationMeta(
    'periodFrom',
  );
  @override
  late final GeneratedColumn<String> periodFrom = GeneratedColumn<String>(
    'period_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodToMeta = const VerificationMeta(
    'periodTo',
  );
  @override
  late final GeneratedColumn<String> periodTo = GeneratedColumn<String>(
    'period_to',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousReadingMeta = const VerificationMeta(
    'previousReading',
  );
  @override
  late final GeneratedColumn<double> previousReading = GeneratedColumn<double>(
    'previous_reading',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentReadingMeta = const VerificationMeta(
    'currentReading',
  );
  @override
  late final GeneratedColumn<double> currentReading = GeneratedColumn<double>(
    'current_reading',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _consumptionKwhMeta = const VerificationMeta(
    'consumptionKwh',
  );
  @override
  late final GeneratedColumn<double> consumptionKwh = GeneratedColumn<double>(
    'consumption_kwh',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _baseValueMeta = const VerificationMeta(
    'baseValue',
  );
  @override
  late final GeneratedColumn<double> baseValue = GeneratedColumn<double>(
    'base_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _servicesAmountMeta = const VerificationMeta(
    'servicesAmount',
  );
  @override
  late final GeneratedColumn<double> servicesAmount = GeneratedColumn<double>(
    'services_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _arrearsAmountMeta = const VerificationMeta(
    'arrearsAmount',
  );
  @override
  late final GeneratedColumn<double> arrearsAmount = GeneratedColumn<double>(
    'arrears_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paidDuringPeriodMeta = const VerificationMeta(
    'paidDuringPeriod',
  );
  @override
  late final GeneratedColumn<double> paidDuringPeriod = GeneratedColumn<double>(
    'paid_during_period',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _grossAmountMeta = const VerificationMeta(
    'grossAmount',
  );
  @override
  late final GeneratedColumn<double> grossAmount = GeneratedColumn<double>(
    'gross_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _netDueMeta = const VerificationMeta('netDue');
  @override
  late final GeneratedColumn<double> netDue = GeneratedColumn<double>(
    'net_due',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _netDueWordsMeta = const VerificationMeta(
    'netDueWords',
  );
  @override
  late final GeneratedColumn<String> netDueWords = GeneratedColumn<String>(
    'net_due_words',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ريال'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(InvoiceStatus.draft),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _issuedAtMeta = const VerificationMeta(
    'issuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> issuedAt = GeneratedColumn<DateTime>(
    'issued_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceNumber,
    cycleNumber,
    subscriberId,
    periodFrom,
    periodTo,
    previousReading,
    currentReading,
    consumptionKwh,
    unitPrice,
    baseValue,
    servicesAmount,
    arrearsAmount,
    paidDuringPeriod,
    grossAmount,
    netDue,
    netDueWords,
    currency,
    status,
    notes,
    issuedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(
          data['invoice_number']!,
          _invoiceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('cycle_number')) {
      context.handle(
        _cycleNumberMeta,
        cycleNumber.isAcceptableOrUnknown(
          data['cycle_number']!,
          _cycleNumberMeta,
        ),
      );
    }
    if (data.containsKey('subscriber_id')) {
      context.handle(
        _subscriberIdMeta,
        subscriberId.isAcceptableOrUnknown(
          data['subscriber_id']!,
          _subscriberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscriberIdMeta);
    }
    if (data.containsKey('period_from')) {
      context.handle(
        _periodFromMeta,
        periodFrom.isAcceptableOrUnknown(data['period_from']!, _periodFromMeta),
      );
    } else if (isInserting) {
      context.missing(_periodFromMeta);
    }
    if (data.containsKey('period_to')) {
      context.handle(
        _periodToMeta,
        periodTo.isAcceptableOrUnknown(data['period_to']!, _periodToMeta),
      );
    } else if (isInserting) {
      context.missing(_periodToMeta);
    }
    if (data.containsKey('previous_reading')) {
      context.handle(
        _previousReadingMeta,
        previousReading.isAcceptableOrUnknown(
          data['previous_reading']!,
          _previousReadingMeta,
        ),
      );
    }
    if (data.containsKey('current_reading')) {
      context.handle(
        _currentReadingMeta,
        currentReading.isAcceptableOrUnknown(
          data['current_reading']!,
          _currentReadingMeta,
        ),
      );
    }
    if (data.containsKey('consumption_kwh')) {
      context.handle(
        _consumptionKwhMeta,
        consumptionKwh.isAcceptableOrUnknown(
          data['consumption_kwh']!,
          _consumptionKwhMeta,
        ),
      );
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    }
    if (data.containsKey('base_value')) {
      context.handle(
        _baseValueMeta,
        baseValue.isAcceptableOrUnknown(data['base_value']!, _baseValueMeta),
      );
    }
    if (data.containsKey('services_amount')) {
      context.handle(
        _servicesAmountMeta,
        servicesAmount.isAcceptableOrUnknown(
          data['services_amount']!,
          _servicesAmountMeta,
        ),
      );
    }
    if (data.containsKey('arrears_amount')) {
      context.handle(
        _arrearsAmountMeta,
        arrearsAmount.isAcceptableOrUnknown(
          data['arrears_amount']!,
          _arrearsAmountMeta,
        ),
      );
    }
    if (data.containsKey('paid_during_period')) {
      context.handle(
        _paidDuringPeriodMeta,
        paidDuringPeriod.isAcceptableOrUnknown(
          data['paid_during_period']!,
          _paidDuringPeriodMeta,
        ),
      );
    }
    if (data.containsKey('gross_amount')) {
      context.handle(
        _grossAmountMeta,
        grossAmount.isAcceptableOrUnknown(
          data['gross_amount']!,
          _grossAmountMeta,
        ),
      );
    }
    if (data.containsKey('net_due')) {
      context.handle(
        _netDueMeta,
        netDue.isAcceptableOrUnknown(data['net_due']!, _netDueMeta),
      );
    }
    if (data.containsKey('net_due_words')) {
      context.handle(
        _netDueWordsMeta,
        netDueWords.isAcceptableOrUnknown(
          data['net_due_words']!,
          _netDueWordsMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('issued_at')) {
      context.handle(
        _issuedAtMeta,
        issuedAt.isAcceptableOrUnknown(data['issued_at']!, _issuedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      invoiceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_number'],
      )!,
      cycleNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle_number'],
      )!,
      subscriberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscriber_id'],
      )!,
      periodFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_from'],
      )!,
      periodTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_to'],
      )!,
      previousReading: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}previous_reading'],
      )!,
      currentReading: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_reading'],
      )!,
      consumptionKwh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}consumption_kwh'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      baseValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_value'],
      )!,
      servicesAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}services_amount'],
      )!,
      arrearsAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}arrears_amount'],
      )!,
      paidDuringPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}paid_during_period'],
      )!,
      grossAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gross_amount'],
      )!,
      netDue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}net_due'],
      )!,
      netDueWords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}net_due_words'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      issuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}issued_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class InvoiceRow extends DataClass implements Insertable<InvoiceRow> {
  final String id;
  final String invoiceNumber;
  final String cycleNumber;
  final String subscriberId;
  final String periodFrom;
  final String periodTo;
  final double previousReading;
  final double currentReading;
  final double consumptionKwh;
  final double unitPrice;
  final double baseValue;
  final double servicesAmount;
  final double arrearsAmount;
  final double paidDuringPeriod;
  final double grossAmount;
  final double netDue;
  final String netDueWords;
  final String currency;
  final String status;
  final String notes;
  final DateTime? issuedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const InvoiceRow({
    required this.id,
    required this.invoiceNumber,
    required this.cycleNumber,
    required this.subscriberId,
    required this.periodFrom,
    required this.periodTo,
    required this.previousReading,
    required this.currentReading,
    required this.consumptionKwh,
    required this.unitPrice,
    required this.baseValue,
    required this.servicesAmount,
    required this.arrearsAmount,
    required this.paidDuringPeriod,
    required this.grossAmount,
    required this.netDue,
    required this.netDueWords,
    required this.currency,
    required this.status,
    required this.notes,
    this.issuedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    map['cycle_number'] = Variable<String>(cycleNumber);
    map['subscriber_id'] = Variable<String>(subscriberId);
    map['period_from'] = Variable<String>(periodFrom);
    map['period_to'] = Variable<String>(periodTo);
    map['previous_reading'] = Variable<double>(previousReading);
    map['current_reading'] = Variable<double>(currentReading);
    map['consumption_kwh'] = Variable<double>(consumptionKwh);
    map['unit_price'] = Variable<double>(unitPrice);
    map['base_value'] = Variable<double>(baseValue);
    map['services_amount'] = Variable<double>(servicesAmount);
    map['arrears_amount'] = Variable<double>(arrearsAmount);
    map['paid_during_period'] = Variable<double>(paidDuringPeriod);
    map['gross_amount'] = Variable<double>(grossAmount);
    map['net_due'] = Variable<double>(netDue);
    map['net_due_words'] = Variable<String>(netDueWords);
    map['currency'] = Variable<String>(currency);
    map['status'] = Variable<String>(status);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || issuedAt != null) {
      map['issued_at'] = Variable<DateTime>(issuedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      invoiceNumber: Value(invoiceNumber),
      cycleNumber: Value(cycleNumber),
      subscriberId: Value(subscriberId),
      periodFrom: Value(periodFrom),
      periodTo: Value(periodTo),
      previousReading: Value(previousReading),
      currentReading: Value(currentReading),
      consumptionKwh: Value(consumptionKwh),
      unitPrice: Value(unitPrice),
      baseValue: Value(baseValue),
      servicesAmount: Value(servicesAmount),
      arrearsAmount: Value(arrearsAmount),
      paidDuringPeriod: Value(paidDuringPeriod),
      grossAmount: Value(grossAmount),
      netDue: Value(netDue),
      netDueWords: Value(netDueWords),
      currency: Value(currency),
      status: Value(status),
      notes: Value(notes),
      issuedAt: issuedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(issuedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory InvoiceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceRow(
      id: serializer.fromJson<String>(json['id']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      cycleNumber: serializer.fromJson<String>(json['cycleNumber']),
      subscriberId: serializer.fromJson<String>(json['subscriberId']),
      periodFrom: serializer.fromJson<String>(json['periodFrom']),
      periodTo: serializer.fromJson<String>(json['periodTo']),
      previousReading: serializer.fromJson<double>(json['previousReading']),
      currentReading: serializer.fromJson<double>(json['currentReading']),
      consumptionKwh: serializer.fromJson<double>(json['consumptionKwh']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      baseValue: serializer.fromJson<double>(json['baseValue']),
      servicesAmount: serializer.fromJson<double>(json['servicesAmount']),
      arrearsAmount: serializer.fromJson<double>(json['arrearsAmount']),
      paidDuringPeriod: serializer.fromJson<double>(json['paidDuringPeriod']),
      grossAmount: serializer.fromJson<double>(json['grossAmount']),
      netDue: serializer.fromJson<double>(json['netDue']),
      netDueWords: serializer.fromJson<String>(json['netDueWords']),
      currency: serializer.fromJson<String>(json['currency']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String>(json['notes']),
      issuedAt: serializer.fromJson<DateTime?>(json['issuedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'cycleNumber': serializer.toJson<String>(cycleNumber),
      'subscriberId': serializer.toJson<String>(subscriberId),
      'periodFrom': serializer.toJson<String>(periodFrom),
      'periodTo': serializer.toJson<String>(periodTo),
      'previousReading': serializer.toJson<double>(previousReading),
      'currentReading': serializer.toJson<double>(currentReading),
      'consumptionKwh': serializer.toJson<double>(consumptionKwh),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'baseValue': serializer.toJson<double>(baseValue),
      'servicesAmount': serializer.toJson<double>(servicesAmount),
      'arrearsAmount': serializer.toJson<double>(arrearsAmount),
      'paidDuringPeriod': serializer.toJson<double>(paidDuringPeriod),
      'grossAmount': serializer.toJson<double>(grossAmount),
      'netDue': serializer.toJson<double>(netDue),
      'netDueWords': serializer.toJson<String>(netDueWords),
      'currency': serializer.toJson<String>(currency),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String>(notes),
      'issuedAt': serializer.toJson<DateTime?>(issuedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  InvoiceRow copyWith({
    String? id,
    String? invoiceNumber,
    String? cycleNumber,
    String? subscriberId,
    String? periodFrom,
    String? periodTo,
    double? previousReading,
    double? currentReading,
    double? consumptionKwh,
    double? unitPrice,
    double? baseValue,
    double? servicesAmount,
    double? arrearsAmount,
    double? paidDuringPeriod,
    double? grossAmount,
    double? netDue,
    String? netDueWords,
    String? currency,
    String? status,
    String? notes,
    Value<DateTime?> issuedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => InvoiceRow(
    id: id ?? this.id,
    invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    cycleNumber: cycleNumber ?? this.cycleNumber,
    subscriberId: subscriberId ?? this.subscriberId,
    periodFrom: periodFrom ?? this.periodFrom,
    periodTo: periodTo ?? this.periodTo,
    previousReading: previousReading ?? this.previousReading,
    currentReading: currentReading ?? this.currentReading,
    consumptionKwh: consumptionKwh ?? this.consumptionKwh,
    unitPrice: unitPrice ?? this.unitPrice,
    baseValue: baseValue ?? this.baseValue,
    servicesAmount: servicesAmount ?? this.servicesAmount,
    arrearsAmount: arrearsAmount ?? this.arrearsAmount,
    paidDuringPeriod: paidDuringPeriod ?? this.paidDuringPeriod,
    grossAmount: grossAmount ?? this.grossAmount,
    netDue: netDue ?? this.netDue,
    netDueWords: netDueWords ?? this.netDueWords,
    currency: currency ?? this.currency,
    status: status ?? this.status,
    notes: notes ?? this.notes,
    issuedAt: issuedAt.present ? issuedAt.value : this.issuedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  InvoiceRow copyWithCompanion(InvoicesCompanion data) {
    return InvoiceRow(
      id: data.id.present ? data.id.value : this.id,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      cycleNumber: data.cycleNumber.present
          ? data.cycleNumber.value
          : this.cycleNumber,
      subscriberId: data.subscriberId.present
          ? data.subscriberId.value
          : this.subscriberId,
      periodFrom: data.periodFrom.present
          ? data.periodFrom.value
          : this.periodFrom,
      periodTo: data.periodTo.present ? data.periodTo.value : this.periodTo,
      previousReading: data.previousReading.present
          ? data.previousReading.value
          : this.previousReading,
      currentReading: data.currentReading.present
          ? data.currentReading.value
          : this.currentReading,
      consumptionKwh: data.consumptionKwh.present
          ? data.consumptionKwh.value
          : this.consumptionKwh,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      baseValue: data.baseValue.present ? data.baseValue.value : this.baseValue,
      servicesAmount: data.servicesAmount.present
          ? data.servicesAmount.value
          : this.servicesAmount,
      arrearsAmount: data.arrearsAmount.present
          ? data.arrearsAmount.value
          : this.arrearsAmount,
      paidDuringPeriod: data.paidDuringPeriod.present
          ? data.paidDuringPeriod.value
          : this.paidDuringPeriod,
      grossAmount: data.grossAmount.present
          ? data.grossAmount.value
          : this.grossAmount,
      netDue: data.netDue.present ? data.netDue.value : this.netDue,
      netDueWords: data.netDueWords.present
          ? data.netDueWords.value
          : this.netDueWords,
      currency: data.currency.present ? data.currency.value : this.currency,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      issuedAt: data.issuedAt.present ? data.issuedAt.value : this.issuedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceRow(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('cycleNumber: $cycleNumber, ')
          ..write('subscriberId: $subscriberId, ')
          ..write('periodFrom: $periodFrom, ')
          ..write('periodTo: $periodTo, ')
          ..write('previousReading: $previousReading, ')
          ..write('currentReading: $currentReading, ')
          ..write('consumptionKwh: $consumptionKwh, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('baseValue: $baseValue, ')
          ..write('servicesAmount: $servicesAmount, ')
          ..write('arrearsAmount: $arrearsAmount, ')
          ..write('paidDuringPeriod: $paidDuringPeriod, ')
          ..write('grossAmount: $grossAmount, ')
          ..write('netDue: $netDue, ')
          ..write('netDueWords: $netDueWords, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    invoiceNumber,
    cycleNumber,
    subscriberId,
    periodFrom,
    periodTo,
    previousReading,
    currentReading,
    consumptionKwh,
    unitPrice,
    baseValue,
    servicesAmount,
    arrearsAmount,
    paidDuringPeriod,
    grossAmount,
    netDue,
    netDueWords,
    currency,
    status,
    notes,
    issuedAt,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceRow &&
          other.id == this.id &&
          other.invoiceNumber == this.invoiceNumber &&
          other.cycleNumber == this.cycleNumber &&
          other.subscriberId == this.subscriberId &&
          other.periodFrom == this.periodFrom &&
          other.periodTo == this.periodTo &&
          other.previousReading == this.previousReading &&
          other.currentReading == this.currentReading &&
          other.consumptionKwh == this.consumptionKwh &&
          other.unitPrice == this.unitPrice &&
          other.baseValue == this.baseValue &&
          other.servicesAmount == this.servicesAmount &&
          other.arrearsAmount == this.arrearsAmount &&
          other.paidDuringPeriod == this.paidDuringPeriod &&
          other.grossAmount == this.grossAmount &&
          other.netDue == this.netDue &&
          other.netDueWords == this.netDueWords &&
          other.currency == this.currency &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.issuedAt == this.issuedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InvoicesCompanion extends UpdateCompanion<InvoiceRow> {
  final Value<String> id;
  final Value<String> invoiceNumber;
  final Value<String> cycleNumber;
  final Value<String> subscriberId;
  final Value<String> periodFrom;
  final Value<String> periodTo;
  final Value<double> previousReading;
  final Value<double> currentReading;
  final Value<double> consumptionKwh;
  final Value<double> unitPrice;
  final Value<double> baseValue;
  final Value<double> servicesAmount;
  final Value<double> arrearsAmount;
  final Value<double> paidDuringPeriod;
  final Value<double> grossAmount;
  final Value<double> netDue;
  final Value<String> netDueWords;
  final Value<String> currency;
  final Value<String> status;
  final Value<String> notes;
  final Value<DateTime?> issuedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.cycleNumber = const Value.absent(),
    this.subscriberId = const Value.absent(),
    this.periodFrom = const Value.absent(),
    this.periodTo = const Value.absent(),
    this.previousReading = const Value.absent(),
    this.currentReading = const Value.absent(),
    this.consumptionKwh = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.baseValue = const Value.absent(),
    this.servicesAmount = const Value.absent(),
    this.arrearsAmount = const Value.absent(),
    this.paidDuringPeriod = const Value.absent(),
    this.grossAmount = const Value.absent(),
    this.netDue = const Value.absent(),
    this.netDueWords = const Value.absent(),
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicesCompanion.insert({
    required String id,
    required String invoiceNumber,
    this.cycleNumber = const Value.absent(),
    required String subscriberId,
    required String periodFrom,
    required String periodTo,
    this.previousReading = const Value.absent(),
    this.currentReading = const Value.absent(),
    this.consumptionKwh = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.baseValue = const Value.absent(),
    this.servicesAmount = const Value.absent(),
    this.arrearsAmount = const Value.absent(),
    this.paidDuringPeriod = const Value.absent(),
    this.grossAmount = const Value.absent(),
    this.netDue = const Value.absent(),
    this.netDueWords = const Value.absent(),
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.issuedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       invoiceNumber = Value(invoiceNumber),
       subscriberId = Value(subscriberId),
       periodFrom = Value(periodFrom),
       periodTo = Value(periodTo),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<InvoiceRow> custom({
    Expression<String>? id,
    Expression<String>? invoiceNumber,
    Expression<String>? cycleNumber,
    Expression<String>? subscriberId,
    Expression<String>? periodFrom,
    Expression<String>? periodTo,
    Expression<double>? previousReading,
    Expression<double>? currentReading,
    Expression<double>? consumptionKwh,
    Expression<double>? unitPrice,
    Expression<double>? baseValue,
    Expression<double>? servicesAmount,
    Expression<double>? arrearsAmount,
    Expression<double>? paidDuringPeriod,
    Expression<double>? grossAmount,
    Expression<double>? netDue,
    Expression<String>? netDueWords,
    Expression<String>? currency,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? issuedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (cycleNumber != null) 'cycle_number': cycleNumber,
      if (subscriberId != null) 'subscriber_id': subscriberId,
      if (periodFrom != null) 'period_from': periodFrom,
      if (periodTo != null) 'period_to': periodTo,
      if (previousReading != null) 'previous_reading': previousReading,
      if (currentReading != null) 'current_reading': currentReading,
      if (consumptionKwh != null) 'consumption_kwh': consumptionKwh,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (baseValue != null) 'base_value': baseValue,
      if (servicesAmount != null) 'services_amount': servicesAmount,
      if (arrearsAmount != null) 'arrears_amount': arrearsAmount,
      if (paidDuringPeriod != null) 'paid_during_period': paidDuringPeriod,
      if (grossAmount != null) 'gross_amount': grossAmount,
      if (netDue != null) 'net_due': netDue,
      if (netDueWords != null) 'net_due_words': netDueWords,
      if (currency != null) 'currency': currency,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicesCompanion copyWith({
    Value<String>? id,
    Value<String>? invoiceNumber,
    Value<String>? cycleNumber,
    Value<String>? subscriberId,
    Value<String>? periodFrom,
    Value<String>? periodTo,
    Value<double>? previousReading,
    Value<double>? currentReading,
    Value<double>? consumptionKwh,
    Value<double>? unitPrice,
    Value<double>? baseValue,
    Value<double>? servicesAmount,
    Value<double>? arrearsAmount,
    Value<double>? paidDuringPeriod,
    Value<double>? grossAmount,
    Value<double>? netDue,
    Value<String>? netDueWords,
    Value<String>? currency,
    Value<String>? status,
    Value<String>? notes,
    Value<DateTime?>? issuedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return InvoicesCompanion(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      cycleNumber: cycleNumber ?? this.cycleNumber,
      subscriberId: subscriberId ?? this.subscriberId,
      periodFrom: periodFrom ?? this.periodFrom,
      periodTo: periodTo ?? this.periodTo,
      previousReading: previousReading ?? this.previousReading,
      currentReading: currentReading ?? this.currentReading,
      consumptionKwh: consumptionKwh ?? this.consumptionKwh,
      unitPrice: unitPrice ?? this.unitPrice,
      baseValue: baseValue ?? this.baseValue,
      servicesAmount: servicesAmount ?? this.servicesAmount,
      arrearsAmount: arrearsAmount ?? this.arrearsAmount,
      paidDuringPeriod: paidDuringPeriod ?? this.paidDuringPeriod,
      grossAmount: grossAmount ?? this.grossAmount,
      netDue: netDue ?? this.netDue,
      netDueWords: netDueWords ?? this.netDueWords,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      issuedAt: issuedAt ?? this.issuedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (cycleNumber.present) {
      map['cycle_number'] = Variable<String>(cycleNumber.value);
    }
    if (subscriberId.present) {
      map['subscriber_id'] = Variable<String>(subscriberId.value);
    }
    if (periodFrom.present) {
      map['period_from'] = Variable<String>(periodFrom.value);
    }
    if (periodTo.present) {
      map['period_to'] = Variable<String>(periodTo.value);
    }
    if (previousReading.present) {
      map['previous_reading'] = Variable<double>(previousReading.value);
    }
    if (currentReading.present) {
      map['current_reading'] = Variable<double>(currentReading.value);
    }
    if (consumptionKwh.present) {
      map['consumption_kwh'] = Variable<double>(consumptionKwh.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (baseValue.present) {
      map['base_value'] = Variable<double>(baseValue.value);
    }
    if (servicesAmount.present) {
      map['services_amount'] = Variable<double>(servicesAmount.value);
    }
    if (arrearsAmount.present) {
      map['arrears_amount'] = Variable<double>(arrearsAmount.value);
    }
    if (paidDuringPeriod.present) {
      map['paid_during_period'] = Variable<double>(paidDuringPeriod.value);
    }
    if (grossAmount.present) {
      map['gross_amount'] = Variable<double>(grossAmount.value);
    }
    if (netDue.present) {
      map['net_due'] = Variable<double>(netDue.value);
    }
    if (netDueWords.present) {
      map['net_due_words'] = Variable<String>(netDueWords.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (issuedAt.present) {
      map['issued_at'] = Variable<DateTime>(issuedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('cycleNumber: $cycleNumber, ')
          ..write('subscriberId: $subscriberId, ')
          ..write('periodFrom: $periodFrom, ')
          ..write('periodTo: $periodTo, ')
          ..write('previousReading: $previousReading, ')
          ..write('currentReading: $currentReading, ')
          ..write('consumptionKwh: $consumptionKwh, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('baseValue: $baseValue, ')
          ..write('servicesAmount: $servicesAmount, ')
          ..write('arrearsAmount: $arrearsAmount, ')
          ..write('paidDuringPeriod: $paidDuringPeriod, ')
          ..write('grossAmount: $grossAmount, ')
          ..write('netDue: $netDue, ')
          ..write('netDueWords: $netDueWords, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubscribersTable subscribers = $SubscribersTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    subscribers,
    invoices,
    settings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'subscribers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('invoices', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SubscribersTableCreateCompanionBuilder =
    SubscribersCompanion Function({
      required String id,
      Value<String> subscriberNumber,
      required String subscriberName,
      Value<String> meterNumber,
      Value<String> routeNumber,
      Value<String> cabinName,
      Value<String> locationName,
      Value<String> phone,
      Value<String> status,
      Value<String> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SubscribersTableUpdateCompanionBuilder =
    SubscribersCompanion Function({
      Value<String> id,
      Value<String> subscriberNumber,
      Value<String> subscriberName,
      Value<String> meterNumber,
      Value<String> routeNumber,
      Value<String> cabinName,
      Value<String> locationName,
      Value<String> phone,
      Value<String> status,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SubscribersTableReferences
    extends BaseReferences<_$AppDatabase, $SubscribersTable, SubscriberRow> {
  $$SubscribersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InvoicesTable, List<InvoiceRow>>
  _invoicesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.invoices,
    aliasName: $_aliasNameGenerator(
      db.subscribers.id,
      db.invoices.subscriberId,
    ),
  );

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.subscriberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubscribersTableFilterComposer
    extends Composer<_$AppDatabase, $SubscribersTable> {
  $$SubscribersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subscriberNumber => $composableBuilder(
    column: $table.subscriberNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subscriberName => $composableBuilder(
    column: $table.subscriberName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meterNumber => $composableBuilder(
    column: $table.meterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeNumber => $composableBuilder(
    column: $table.routeNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cabinName => $composableBuilder(
    column: $table.cabinName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> invoicesRefs(
    Expression<bool> Function($$InvoicesTableFilterComposer f) f,
  ) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.subscriberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubscribersTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscribersTable> {
  $$SubscribersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscriberNumber => $composableBuilder(
    column: $table.subscriberNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscriberName => $composableBuilder(
    column: $table.subscriberName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meterNumber => $composableBuilder(
    column: $table.meterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeNumber => $composableBuilder(
    column: $table.routeNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cabinName => $composableBuilder(
    column: $table.cabinName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubscribersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscribersTable> {
  $$SubscribersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subscriberNumber => $composableBuilder(
    column: $table.subscriberNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subscriberName => $composableBuilder(
    column: $table.subscriberName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meterNumber => $composableBuilder(
    column: $table.meterNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routeNumber => $composableBuilder(
    column: $table.routeNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cabinName =>
      $composableBuilder(column: $table.cabinName, builder: (column) => column);

  GeneratedColumn<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> invoicesRefs<T extends Object>(
    Expression<T> Function($$InvoicesTableAnnotationComposer a) f,
  ) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.subscriberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubscribersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscribersTable,
          SubscriberRow,
          $$SubscribersTableFilterComposer,
          $$SubscribersTableOrderingComposer,
          $$SubscribersTableAnnotationComposer,
          $$SubscribersTableCreateCompanionBuilder,
          $$SubscribersTableUpdateCompanionBuilder,
          (SubscriberRow, $$SubscribersTableReferences),
          SubscriberRow,
          PrefetchHooks Function({bool invoicesRefs})
        > {
  $$SubscribersTableTableManager(_$AppDatabase db, $SubscribersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscribersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscribersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscribersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> subscriberNumber = const Value.absent(),
                Value<String> subscriberName = const Value.absent(),
                Value<String> meterNumber = const Value.absent(),
                Value<String> routeNumber = const Value.absent(),
                Value<String> cabinName = const Value.absent(),
                Value<String> locationName = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubscribersCompanion(
                id: id,
                subscriberNumber: subscriberNumber,
                subscriberName: subscriberName,
                meterNumber: meterNumber,
                routeNumber: routeNumber,
                cabinName: cabinName,
                locationName: locationName,
                phone: phone,
                status: status,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> subscriberNumber = const Value.absent(),
                required String subscriberName,
                Value<String> meterNumber = const Value.absent(),
                Value<String> routeNumber = const Value.absent(),
                Value<String> cabinName = const Value.absent(),
                Value<String> locationName = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SubscribersCompanion.insert(
                id: id,
                subscriberNumber: subscriberNumber,
                subscriberName: subscriberName,
                meterNumber: meterNumber,
                routeNumber: routeNumber,
                cabinName: cabinName,
                locationName: locationName,
                phone: phone,
                status: status,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubscribersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({invoicesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (invoicesRefs) db.invoices],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoicesRefs)
                    await $_getPrefetchedData<
                      SubscriberRow,
                      $SubscribersTable,
                      InvoiceRow
                    >(
                      currentTable: table,
                      referencedTable: $$SubscribersTableReferences
                          ._invoicesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SubscribersTableReferences(
                            db,
                            table,
                            p0,
                          ).invoicesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.subscriberId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SubscribersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscribersTable,
      SubscriberRow,
      $$SubscribersTableFilterComposer,
      $$SubscribersTableOrderingComposer,
      $$SubscribersTableAnnotationComposer,
      $$SubscribersTableCreateCompanionBuilder,
      $$SubscribersTableUpdateCompanionBuilder,
      (SubscriberRow, $$SubscribersTableReferences),
      SubscriberRow,
      PrefetchHooks Function({bool invoicesRefs})
    >;
typedef $$InvoicesTableCreateCompanionBuilder =
    InvoicesCompanion Function({
      required String id,
      required String invoiceNumber,
      Value<String> cycleNumber,
      required String subscriberId,
      required String periodFrom,
      required String periodTo,
      Value<double> previousReading,
      Value<double> currentReading,
      Value<double> consumptionKwh,
      Value<double> unitPrice,
      Value<double> baseValue,
      Value<double> servicesAmount,
      Value<double> arrearsAmount,
      Value<double> paidDuringPeriod,
      Value<double> grossAmount,
      Value<double> netDue,
      Value<String> netDueWords,
      Value<String> currency,
      Value<String> status,
      Value<String> notes,
      Value<DateTime?> issuedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$InvoicesTableUpdateCompanionBuilder =
    InvoicesCompanion Function({
      Value<String> id,
      Value<String> invoiceNumber,
      Value<String> cycleNumber,
      Value<String> subscriberId,
      Value<String> periodFrom,
      Value<String> periodTo,
      Value<double> previousReading,
      Value<double> currentReading,
      Value<double> consumptionKwh,
      Value<double> unitPrice,
      Value<double> baseValue,
      Value<double> servicesAmount,
      Value<double> arrearsAmount,
      Value<double> paidDuringPeriod,
      Value<double> grossAmount,
      Value<double> netDue,
      Value<String> netDueWords,
      Value<String> currency,
      Value<String> status,
      Value<String> notes,
      Value<DateTime?> issuedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$InvoicesTableReferences
    extends BaseReferences<_$AppDatabase, $InvoicesTable, InvoiceRow> {
  $$InvoicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SubscribersTable _subscriberIdTable(_$AppDatabase db) =>
      db.subscribers.createAlias(
        $_aliasNameGenerator(db.invoices.subscriberId, db.subscribers.id),
      );

  $$SubscribersTableProcessedTableManager get subscriberId {
    final $_column = $_itemColumn<String>('subscriber_id')!;

    final manager = $$SubscribersTableTableManager(
      $_db,
      $_db.subscribers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subscriberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycleNumber => $composableBuilder(
    column: $table.cycleNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodFrom => $composableBuilder(
    column: $table.periodFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodTo => $composableBuilder(
    column: $table.periodTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get previousReading => $composableBuilder(
    column: $table.previousReading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentReading => $composableBuilder(
    column: $table.currentReading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get consumptionKwh => $composableBuilder(
    column: $table.consumptionKwh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baseValue => $composableBuilder(
    column: $table.baseValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servicesAmount => $composableBuilder(
    column: $table.servicesAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get arrearsAmount => $composableBuilder(
    column: $table.arrearsAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get paidDuringPeriod => $composableBuilder(
    column: $table.paidDuringPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grossAmount => $composableBuilder(
    column: $table.grossAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get netDue => $composableBuilder(
    column: $table.netDue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get netDueWords => $composableBuilder(
    column: $table.netDueWords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SubscribersTableFilterComposer get subscriberId {
    final $$SubscribersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriberId,
      referencedTable: $db.subscribers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscribersTableFilterComposer(
            $db: $db,
            $table: $db.subscribers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycleNumber => $composableBuilder(
    column: $table.cycleNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodFrom => $composableBuilder(
    column: $table.periodFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodTo => $composableBuilder(
    column: $table.periodTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get previousReading => $composableBuilder(
    column: $table.previousReading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentReading => $composableBuilder(
    column: $table.currentReading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get consumptionKwh => $composableBuilder(
    column: $table.consumptionKwh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baseValue => $composableBuilder(
    column: $table.baseValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servicesAmount => $composableBuilder(
    column: $table.servicesAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get arrearsAmount => $composableBuilder(
    column: $table.arrearsAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get paidDuringPeriod => $composableBuilder(
    column: $table.paidDuringPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grossAmount => $composableBuilder(
    column: $table.grossAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get netDue => $composableBuilder(
    column: $table.netDue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get netDueWords => $composableBuilder(
    column: $table.netDueWords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubscribersTableOrderingComposer get subscriberId {
    final $$SubscribersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriberId,
      referencedTable: $db.subscribers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscribersTableOrderingComposer(
            $db: $db,
            $table: $db.subscribers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cycleNumber => $composableBuilder(
    column: $table.cycleNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get periodFrom => $composableBuilder(
    column: $table.periodFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get periodTo =>
      $composableBuilder(column: $table.periodTo, builder: (column) => column);

  GeneratedColumn<double> get previousReading => $composableBuilder(
    column: $table.previousReading,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentReading => $composableBuilder(
    column: $table.currentReading,
    builder: (column) => column,
  );

  GeneratedColumn<double> get consumptionKwh => $composableBuilder(
    column: $table.consumptionKwh,
    builder: (column) => column,
  );

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get baseValue =>
      $composableBuilder(column: $table.baseValue, builder: (column) => column);

  GeneratedColumn<double> get servicesAmount => $composableBuilder(
    column: $table.servicesAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get arrearsAmount => $composableBuilder(
    column: $table.arrearsAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get paidDuringPeriod => $composableBuilder(
    column: $table.paidDuringPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<double> get grossAmount => $composableBuilder(
    column: $table.grossAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get netDue =>
      $composableBuilder(column: $table.netDue, builder: (column) => column);

  GeneratedColumn<String> get netDueWords => $composableBuilder(
    column: $table.netDueWords,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get issuedAt =>
      $composableBuilder(column: $table.issuedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SubscribersTableAnnotationComposer get subscriberId {
    final $$SubscribersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriberId,
      referencedTable: $db.subscribers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscribersTableAnnotationComposer(
            $db: $db,
            $table: $db.subscribers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoicesTable,
          InvoiceRow,
          $$InvoicesTableFilterComposer,
          $$InvoicesTableOrderingComposer,
          $$InvoicesTableAnnotationComposer,
          $$InvoicesTableCreateCompanionBuilder,
          $$InvoicesTableUpdateCompanionBuilder,
          (InvoiceRow, $$InvoicesTableReferences),
          InvoiceRow,
          PrefetchHooks Function({bool subscriberId})
        > {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> invoiceNumber = const Value.absent(),
                Value<String> cycleNumber = const Value.absent(),
                Value<String> subscriberId = const Value.absent(),
                Value<String> periodFrom = const Value.absent(),
                Value<String> periodTo = const Value.absent(),
                Value<double> previousReading = const Value.absent(),
                Value<double> currentReading = const Value.absent(),
                Value<double> consumptionKwh = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> baseValue = const Value.absent(),
                Value<double> servicesAmount = const Value.absent(),
                Value<double> arrearsAmount = const Value.absent(),
                Value<double> paidDuringPeriod = const Value.absent(),
                Value<double> grossAmount = const Value.absent(),
                Value<double> netDue = const Value.absent(),
                Value<String> netDueWords = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime?> issuedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicesCompanion(
                id: id,
                invoiceNumber: invoiceNumber,
                cycleNumber: cycleNumber,
                subscriberId: subscriberId,
                periodFrom: periodFrom,
                periodTo: periodTo,
                previousReading: previousReading,
                currentReading: currentReading,
                consumptionKwh: consumptionKwh,
                unitPrice: unitPrice,
                baseValue: baseValue,
                servicesAmount: servicesAmount,
                arrearsAmount: arrearsAmount,
                paidDuringPeriod: paidDuringPeriod,
                grossAmount: grossAmount,
                netDue: netDue,
                netDueWords: netDueWords,
                currency: currency,
                status: status,
                notes: notes,
                issuedAt: issuedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String invoiceNumber,
                Value<String> cycleNumber = const Value.absent(),
                required String subscriberId,
                required String periodFrom,
                required String periodTo,
                Value<double> previousReading = const Value.absent(),
                Value<double> currentReading = const Value.absent(),
                Value<double> consumptionKwh = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> baseValue = const Value.absent(),
                Value<double> servicesAmount = const Value.absent(),
                Value<double> arrearsAmount = const Value.absent(),
                Value<double> paidDuringPeriod = const Value.absent(),
                Value<double> grossAmount = const Value.absent(),
                Value<double> netDue = const Value.absent(),
                Value<String> netDueWords = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime?> issuedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => InvoicesCompanion.insert(
                id: id,
                invoiceNumber: invoiceNumber,
                cycleNumber: cycleNumber,
                subscriberId: subscriberId,
                periodFrom: periodFrom,
                periodTo: periodTo,
                previousReading: previousReading,
                currentReading: currentReading,
                consumptionKwh: consumptionKwh,
                unitPrice: unitPrice,
                baseValue: baseValue,
                servicesAmount: servicesAmount,
                arrearsAmount: arrearsAmount,
                paidDuringPeriod: paidDuringPeriod,
                grossAmount: grossAmount,
                netDue: netDue,
                netDueWords: netDueWords,
                currency: currency,
                status: status,
                notes: notes,
                issuedAt: issuedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvoicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({subscriberId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (subscriberId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.subscriberId,
                                referencedTable: $$InvoicesTableReferences
                                    ._subscriberIdTable(db),
                                referencedColumn: $$InvoicesTableReferences
                                    ._subscriberIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoicesTable,
      InvoiceRow,
      $$InvoicesTableFilterComposer,
      $$InvoicesTableOrderingComposer,
      $$InvoicesTableAnnotationComposer,
      $$InvoicesTableCreateCompanionBuilder,
      $$InvoicesTableUpdateCompanionBuilder,
      (InvoiceRow, $$InvoicesTableReferences),
      InvoiceRow,
      PrefetchHooks Function({bool subscriberId})
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubscribersTableTableManager get subscribers =>
      $$SubscribersTableTableManager(_db, _db.subscribers);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
