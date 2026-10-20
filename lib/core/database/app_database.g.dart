// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settingKeyMeta = const VerificationMeta(
    'settingKey',
  );
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
    'setting_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settingValueMeta = const VerificationMeta(
    'settingValue',
  );
  @override
  late final GeneratedColumn<String> settingValue = GeneratedColumn<String>(
    'setting_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [settingKey, settingValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('setting_key')) {
      context.handle(
        _settingKeyMeta,
        settingKey.isAcceptableOrUnknown(data['setting_key']!, _settingKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('setting_value')) {
      context.handle(
        _settingValueMeta,
        settingValue.isAcceptableOrUnknown(
          data['setting_value']!,
          _settingValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settingValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settingKey};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      settingKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_key'],
      )!,
      settingValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String settingKey;
  final String settingValue;
  const AppSetting({required this.settingKey, required this.settingValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['setting_key'] = Variable<String>(settingKey);
    map['setting_value'] = Variable<String>(settingValue);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      settingKey: Value(settingKey),
      settingValue: Value(settingValue),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      settingKey: serializer.fromJson<String>(json['settingKey']),
      settingValue: serializer.fromJson<String>(json['settingValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settingKey': serializer.toJson<String>(settingKey),
      'settingValue': serializer.toJson<String>(settingValue),
    };
  }

  AppSetting copyWith({String? settingKey, String? settingValue}) => AppSetting(
    settingKey: settingKey ?? this.settingKey,
    settingValue: settingValue ?? this.settingValue,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      settingKey: data.settingKey.present
          ? data.settingKey.value
          : this.settingKey,
      settingValue: data.settingValue.present
          ? data.settingValue.value
          : this.settingValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(settingKey, settingValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.settingKey == this.settingKey &&
          other.settingValue == this.settingValue);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> settingKey;
  final Value<String> settingValue;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.settingKey = const Value.absent(),
    this.settingValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String settingKey,
    required String settingValue,
    this.rowid = const Value.absent(),
  }) : settingKey = Value(settingKey),
       settingValue = Value(settingValue);
  static Insertable<AppSetting> custom({
    Expression<String>? settingKey,
    Expression<String>? settingValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (settingKey != null) 'setting_key': settingKey,
      if (settingValue != null) 'setting_value': settingValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? settingKey,
    Value<String>? settingValue,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (settingValue.present) {
      map['setting_value'] = Variable<String>(settingValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomeSourcesTable extends IncomeSources
    with TableInfo<$IncomeSourcesTable, IncomeSourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomeSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduleJsonMeta = const VerificationMeta(
    'scheduleJson',
  );
  @override
  late final GeneratedColumn<String> scheduleJson = GeneratedColumn<String>(
    'schedule_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frozenThroughMeta = const VerificationMeta(
    'frozenThrough',
  );
  @override
  late final GeneratedColumn<String> frozenThrough = GeneratedColumn<String>(
    'frozen_through',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    amountMinor,
    currencyCode,
    scheduleJson,
    startDate,
    endDate,
    frozenThrough,
    createdAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'income_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncomeSourceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('schedule_json')) {
      context.handle(
        _scheduleJsonMeta,
        scheduleJson.isAcceptableOrUnknown(
          data['schedule_json']!,
          _scheduleJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleJsonMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('frozen_through')) {
      context.handle(
        _frozenThroughMeta,
        frozenThrough.isAcceptableOrUnknown(
          data['frozen_through']!,
          _frozenThroughMeta,
        ),
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
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IncomeSourceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncomeSourceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      scheduleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_json'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
      frozenThrough: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frozen_through'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $IncomeSourcesTable createAlias(String alias) {
    return $IncomeSourcesTable(attachedDatabase, alias);
  }
}

class IncomeSourceRow extends DataClass implements Insertable<IncomeSourceRow> {
  final String id;
  final String name;

  /// `IncomeType.name`.
  final String type;
  final int amountMinor;
  final String currencyCode;

  /// Versioned JSON, see IncomeScheduleCodec.
  final String scheduleJson;
  final String startDate;
  final String? endDate;

  /// History up to and including this day lives in income_entries.
  final String? frozenThrough;
  final DateTime createdAt;
  final DateTime? archivedAt;
  const IncomeSourceRow({
    required this.id,
    required this.name,
    required this.type,
    required this.amountMinor,
    required this.currencyCode,
    required this.scheduleJson,
    required this.startDate,
    this.endDate,
    this.frozenThrough,
    required this.createdAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['schedule_json'] = Variable<String>(scheduleJson);
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    if (!nullToAbsent || frozenThrough != null) {
      map['frozen_through'] = Variable<String>(frozenThrough);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  IncomeSourcesCompanion toCompanion(bool nullToAbsent) {
    return IncomeSourcesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      scheduleJson: Value(scheduleJson),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      frozenThrough: frozenThrough == null && nullToAbsent
          ? const Value.absent()
          : Value(frozenThrough),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory IncomeSourceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncomeSourceRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      scheduleJson: serializer.fromJson<String>(json['scheduleJson']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      frozenThrough: serializer.fromJson<String?>(json['frozenThrough']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'scheduleJson': serializer.toJson<String>(scheduleJson),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'frozenThrough': serializer.toJson<String?>(frozenThrough),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  IncomeSourceRow copyWith({
    String? id,
    String? name,
    String? type,
    int? amountMinor,
    String? currencyCode,
    String? scheduleJson,
    String? startDate,
    Value<String?> endDate = const Value.absent(),
    Value<String?> frozenThrough = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => IncomeSourceRow(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    scheduleJson: scheduleJson ?? this.scheduleJson,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    frozenThrough: frozenThrough.present
        ? frozenThrough.value
        : this.frozenThrough,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  IncomeSourceRow copyWithCompanion(IncomeSourcesCompanion data) {
    return IncomeSourceRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      scheduleJson: data.scheduleJson.present
          ? data.scheduleJson.value
          : this.scheduleJson,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      frozenThrough: data.frozenThrough.present
          ? data.frozenThrough.value
          : this.frozenThrough,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncomeSourceRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('scheduleJson: $scheduleJson, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('frozenThrough: $frozenThrough, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    amountMinor,
    currencyCode,
    scheduleJson,
    startDate,
    endDate,
    frozenThrough,
    createdAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncomeSourceRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.scheduleJson == this.scheduleJson &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.frozenThrough == this.frozenThrough &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt);
}

class IncomeSourcesCompanion extends UpdateCompanion<IncomeSourceRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<String> scheduleJson;
  final Value<String> startDate;
  final Value<String?> endDate;
  final Value<String?> frozenThrough;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const IncomeSourcesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.scheduleJson = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.frozenThrough = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomeSourcesCompanion.insert({
    required String id,
    required String name,
    required String type,
    required int amountMinor,
    required String currencyCode,
    required String scheduleJson,
    required String startDate,
    this.endDate = const Value.absent(),
    this.frozenThrough = const Value.absent(),
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode),
       scheduleJson = Value(scheduleJson),
       startDate = Value(startDate),
       createdAt = Value(createdAt);
  static Insertable<IncomeSourceRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? scheduleJson,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<String>? frozenThrough,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (scheduleJson != null) 'schedule_json': scheduleJson,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (frozenThrough != null) 'frozen_through': frozenThrough,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomeSourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<String>? scheduleJson,
    Value<String>? startDate,
    Value<String?>? endDate,
    Value<String?>? frozenThrough,
    Value<DateTime>? createdAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return IncomeSourcesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      scheduleJson: scheduleJson ?? this.scheduleJson,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      frozenThrough: frozenThrough ?? this.frozenThrough,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (scheduleJson.present) {
      map['schedule_json'] = Variable<String>(scheduleJson.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (frozenThrough.present) {
      map['frozen_through'] = Variable<String>(frozenThrough.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomeSourcesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('scheduleJson: $scheduleJson, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('frozenThrough: $frozenThrough, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomeEntriesTable extends IncomeEntries
    with TableInfo<$IncomeEntriesTable, IncomeEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomeEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES income_sources (id)',
    ),
  );
  static const VerificationMeta _originalDateMeta = const VerificationMeta(
    'originalDate',
  );
  @override
  late final GeneratedColumn<String> originalDate = GeneratedColumn<String>(
    'original_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualDateMeta = const VerificationMeta(
    'actualDate',
  );
  @override
  late final GeneratedColumn<String> actualDate = GeneratedColumn<String>(
    'actual_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    originalDate,
    actualDate,
    status,
    amountMinor,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'income_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncomeEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('original_date')) {
      context.handle(
        _originalDateMeta,
        originalDate.isAcceptableOrUnknown(
          data['original_date']!,
          _originalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalDateMeta);
    }
    if (data.containsKey('actual_date')) {
      context.handle(
        _actualDateMeta,
        actualDate.isAcceptableOrUnknown(data['actual_date']!, _actualDateMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sourceId, originalDate},
  ];
  @override
  IncomeEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncomeEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      originalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_date'],
      )!,
      actualDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actual_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IncomeEntriesTable createAlias(String alias) {
    return $IncomeEntriesTable(attachedDatabase, alias);
  }
}

class IncomeEntryRow extends DataClass implements Insertable<IncomeEntryRow> {
  final String id;
  final String sourceId;

  /// The date the schedule produced for the payment this row replaces.
  final String originalDate;

  /// The date the payment is paid, when it is pinned (frozen history or a
  /// date the user changed). Null: the date is computed from the schedule.
  final String? actualDate;

  /// `IncomeEntryStatus.name`: received or skipped.
  final String status;
  final int amountMinor;
  final DateTime createdAt;
  const IncomeEntryRow({
    required this.id,
    required this.sourceId,
    required this.originalDate,
    this.actualDate,
    required this.status,
    required this.amountMinor,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['original_date'] = Variable<String>(originalDate);
    if (!nullToAbsent || actualDate != null) {
      map['actual_date'] = Variable<String>(actualDate);
    }
    map['status'] = Variable<String>(status);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IncomeEntriesCompanion toCompanion(bool nullToAbsent) {
    return IncomeEntriesCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      originalDate: Value(originalDate),
      actualDate: actualDate == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDate),
      status: Value(status),
      amountMinor: Value(amountMinor),
      createdAt: Value(createdAt),
    );
  }

  factory IncomeEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncomeEntryRow(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      originalDate: serializer.fromJson<String>(json['originalDate']),
      actualDate: serializer.fromJson<String?>(json['actualDate']),
      status: serializer.fromJson<String>(json['status']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'originalDate': serializer.toJson<String>(originalDate),
      'actualDate': serializer.toJson<String?>(actualDate),
      'status': serializer.toJson<String>(status),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  IncomeEntryRow copyWith({
    String? id,
    String? sourceId,
    String? originalDate,
    Value<String?> actualDate = const Value.absent(),
    String? status,
    int? amountMinor,
    DateTime? createdAt,
  }) => IncomeEntryRow(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    originalDate: originalDate ?? this.originalDate,
    actualDate: actualDate.present ? actualDate.value : this.actualDate,
    status: status ?? this.status,
    amountMinor: amountMinor ?? this.amountMinor,
    createdAt: createdAt ?? this.createdAt,
  );
  IncomeEntryRow copyWithCompanion(IncomeEntriesCompanion data) {
    return IncomeEntryRow(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      originalDate: data.originalDate.present
          ? data.originalDate.value
          : this.originalDate,
      actualDate: data.actualDate.present
          ? data.actualDate.value
          : this.actualDate,
      status: data.status.present ? data.status.value : this.status,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncomeEntryRow(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('originalDate: $originalDate, ')
          ..write('actualDate: $actualDate, ')
          ..write('status: $status, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    originalDate,
    actualDate,
    status,
    amountMinor,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncomeEntryRow &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.originalDate == this.originalDate &&
          other.actualDate == this.actualDate &&
          other.status == this.status &&
          other.amountMinor == this.amountMinor &&
          other.createdAt == this.createdAt);
}

class IncomeEntriesCompanion extends UpdateCompanion<IncomeEntryRow> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<String> originalDate;
  final Value<String?> actualDate;
  final Value<String> status;
  final Value<int> amountMinor;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const IncomeEntriesCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.originalDate = const Value.absent(),
    this.actualDate = const Value.absent(),
    this.status = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomeEntriesCompanion.insert({
    required String id,
    required String sourceId,
    required String originalDate,
    this.actualDate = const Value.absent(),
    required String status,
    required int amountMinor,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceId = Value(sourceId),
       originalDate = Value(originalDate),
       status = Value(status),
       amountMinor = Value(amountMinor),
       createdAt = Value(createdAt);
  static Insertable<IncomeEntryRow> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? originalDate,
    Expression<String>? actualDate,
    Expression<String>? status,
    Expression<int>? amountMinor,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (originalDate != null) 'original_date': originalDate,
      if (actualDate != null) 'actual_date': actualDate,
      if (status != null) 'status': status,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomeEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceId,
    Value<String>? originalDate,
    Value<String?>? actualDate,
    Value<String>? status,
    Value<int>? amountMinor,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return IncomeEntriesCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      originalDate: originalDate ?? this.originalDate,
      actualDate: actualDate ?? this.actualDate,
      status: status ?? this.status,
      amountMinor: amountMinor ?? this.amountMinor,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (originalDate.present) {
      map['original_date'] = Variable<String>(originalDate.value);
    }
    if (actualDate.present) {
      map['actual_date'] = Variable<String>(actualDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomeEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('originalDate: $originalDate, ')
          ..write('actualDate: $actualDate, ')
          ..write('status: $status, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BalanceAnchorsTable extends BalanceAnchors
    with TableInfo<$BalanceAnchorsTable, BalanceAnchorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BalanceAnchorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anchorDateMeta = const VerificationMeta(
    'anchorDate',
  );
  @override
  late final GeneratedColumn<String> anchorDate = GeneratedColumn<String>(
    'anchor_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMinorMeta = const VerificationMeta(
    'balanceMinor',
  );
  @override
  late final GeneratedColumn<int> balanceMinor = GeneratedColumn<int>(
    'balance_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    anchorDate,
    balanceMinor,
    currencyCode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'balance_anchors';
  @override
  VerificationContext validateIntegrity(
    Insertable<BalanceAnchorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('anchor_date')) {
      context.handle(
        _anchorDateMeta,
        anchorDate.isAcceptableOrUnknown(data['anchor_date']!, _anchorDateMeta),
      );
    } else if (isInserting) {
      context.missing(_anchorDateMeta);
    }
    if (data.containsKey('balance_minor')) {
      context.handle(
        _balanceMinorMeta,
        balanceMinor.isAcceptableOrUnknown(
          data['balance_minor']!,
          _balanceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balanceMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {anchorDate, currencyCode},
  ];
  @override
  BalanceAnchorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BalanceAnchorRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      anchorDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anchor_date'],
      )!,
      balanceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BalanceAnchorsTable createAlias(String alias) {
    return $BalanceAnchorsTable(attachedDatabase, alias);
  }
}

class BalanceAnchorRow extends DataClass
    implements Insertable<BalanceAnchorRow> {
  final String id;

  /// The balance is the one at the END of this day.
  final String anchorDate;
  final int balanceMinor;
  final String currencyCode;
  final DateTime createdAt;
  const BalanceAnchorRow({
    required this.id,
    required this.anchorDate,
    required this.balanceMinor,
    required this.currencyCode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['anchor_date'] = Variable<String>(anchorDate);
    map['balance_minor'] = Variable<int>(balanceMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BalanceAnchorsCompanion toCompanion(bool nullToAbsent) {
    return BalanceAnchorsCompanion(
      id: Value(id),
      anchorDate: Value(anchorDate),
      balanceMinor: Value(balanceMinor),
      currencyCode: Value(currencyCode),
      createdAt: Value(createdAt),
    );
  }

  factory BalanceAnchorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BalanceAnchorRow(
      id: serializer.fromJson<String>(json['id']),
      anchorDate: serializer.fromJson<String>(json['anchorDate']),
      balanceMinor: serializer.fromJson<int>(json['balanceMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'anchorDate': serializer.toJson<String>(anchorDate),
      'balanceMinor': serializer.toJson<int>(balanceMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BalanceAnchorRow copyWith({
    String? id,
    String? anchorDate,
    int? balanceMinor,
    String? currencyCode,
    DateTime? createdAt,
  }) => BalanceAnchorRow(
    id: id ?? this.id,
    anchorDate: anchorDate ?? this.anchorDate,
    balanceMinor: balanceMinor ?? this.balanceMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    createdAt: createdAt ?? this.createdAt,
  );
  BalanceAnchorRow copyWithCompanion(BalanceAnchorsCompanion data) {
    return BalanceAnchorRow(
      id: data.id.present ? data.id.value : this.id,
      anchorDate: data.anchorDate.present
          ? data.anchorDate.value
          : this.anchorDate,
      balanceMinor: data.balanceMinor.present
          ? data.balanceMinor.value
          : this.balanceMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BalanceAnchorRow(')
          ..write('id: $id, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('balanceMinor: $balanceMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, anchorDate, balanceMinor, currencyCode, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BalanceAnchorRow &&
          other.id == this.id &&
          other.anchorDate == this.anchorDate &&
          other.balanceMinor == this.balanceMinor &&
          other.currencyCode == this.currencyCode &&
          other.createdAt == this.createdAt);
}

class BalanceAnchorsCompanion extends UpdateCompanion<BalanceAnchorRow> {
  final Value<String> id;
  final Value<String> anchorDate;
  final Value<int> balanceMinor;
  final Value<String> currencyCode;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BalanceAnchorsCompanion({
    this.id = const Value.absent(),
    this.anchorDate = const Value.absent(),
    this.balanceMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BalanceAnchorsCompanion.insert({
    required String id,
    required String anchorDate,
    required int balanceMinor,
    required String currencyCode,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       anchorDate = Value(anchorDate),
       balanceMinor = Value(balanceMinor),
       currencyCode = Value(currencyCode),
       createdAt = Value(createdAt);
  static Insertable<BalanceAnchorRow> custom({
    Expression<String>? id,
    Expression<String>? anchorDate,
    Expression<int>? balanceMinor,
    Expression<String>? currencyCode,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (anchorDate != null) 'anchor_date': anchorDate,
      if (balanceMinor != null) 'balance_minor': balanceMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BalanceAnchorsCompanion copyWith({
    Value<String>? id,
    Value<String>? anchorDate,
    Value<int>? balanceMinor,
    Value<String>? currencyCode,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BalanceAnchorsCompanion(
      id: id ?? this.id,
      anchorDate: anchorDate ?? this.anchorDate,
      balanceMinor: balanceMinor ?? this.balanceMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (anchorDate.present) {
      map['anchor_date'] = Variable<String>(anchorDate.value);
    }
    if (balanceMinor.present) {
      map['balance_minor'] = Variable<int>(balanceMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BalanceAnchorsCompanion(')
          ..write('id: $id, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('balanceMinor: $balanceMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryKeyMeta = const VerificationMeta(
    'categoryKey',
  );
  @override
  late final GeneratedColumn<String> categoryKey = GeneratedColumn<String>(
    'category_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [id, categoryKey, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_key')) {
      context.handle(
        _categoryKeyMeta,
        categoryKey.isAcceptableOrUnknown(
          data['category_key']!,
          _categoryKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryKeyMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {categoryKey},
  ];
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_key'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  /// Built-in categories: equal to [categoryKey]. User categories (Phase 5):
  /// a UUID.
  final String id;

  /// Stable key; the display name of a built-in category comes from the ARB
  /// files by this key. (Not called `key`, which is an SQL keyword.)
  final String categoryKey;
  final int sortOrder;
  final DateTime createdAt;
  const CategoryRow({
    required this.id,
    required this.categoryKey,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_key'] = Variable<String>(categoryKey);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      categoryKey: Value(categoryKey),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      categoryKey: serializer.fromJson<String>(json['categoryKey']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryKey': serializer.toJson<String>(categoryKey),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? categoryKey,
    int? sortOrder,
    DateTime? createdAt,
  }) => CategoryRow(
    id: id ?? this.id,
    categoryKey: categoryKey ?? this.categoryKey,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      categoryKey: data.categoryKey.present
          ? data.categoryKey.value
          : this.categoryKey,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryKey, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.categoryKey == this.categoryKey &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> categoryKey;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.categoryKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String categoryKey,
    required int sortOrder,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryKey = Value(categoryKey),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? categoryKey,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryKey != null) 'category_key': categoryKey,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryKey,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      categoryKey: categoryKey ?? this.categoryKey,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryKey.present) {
      map['category_key'] = Variable<String>(categoryKey.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportsTable extends Imports with TableInfo<$ImportsTable, ImportRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileCountMeta = const VerificationMeta(
    'fileCount',
  );
  @override
  late final GeneratedColumn<int> fileCount = GeneratedColumn<int>(
    'file_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedCountMeta = const VerificationMeta(
    'importedCount',
  );
  @override
  late final GeneratedColumn<int> importedCount = GeneratedColumn<int>(
    'imported_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _duplicateCountMeta = const VerificationMeta(
    'duplicateCount',
  );
  @override
  late final GeneratedColumn<int> duplicateCount = GeneratedColumn<int>(
    'duplicate_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _failedCountMeta = const VerificationMeta(
    'failedCount',
  );
  @override
  late final GeneratedColumn<int> failedCount = GeneratedColumn<int>(
    'failed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    importedAt,
    source,
    fileCount,
    importedCount,
    duplicateCount,
    failedCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imports';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('file_count')) {
      context.handle(
        _fileCountMeta,
        fileCount.isAcceptableOrUnknown(data['file_count']!, _fileCountMeta),
      );
    } else if (isInserting) {
      context.missing(_fileCountMeta);
    }
    if (data.containsKey('imported_count')) {
      context.handle(
        _importedCountMeta,
        importedCount.isAcceptableOrUnknown(
          data['imported_count']!,
          _importedCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_importedCountMeta);
    }
    if (data.containsKey('duplicate_count')) {
      context.handle(
        _duplicateCountMeta,
        duplicateCount.isAcceptableOrUnknown(
          data['duplicate_count']!,
          _duplicateCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_duplicateCountMeta);
    }
    if (data.containsKey('failed_count')) {
      context.handle(
        _failedCountMeta,
        failedCount.isAcceptableOrUnknown(
          data['failed_count']!,
          _failedCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_failedCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fileCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_count'],
      )!,
      importedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}imported_count'],
      )!,
      duplicateCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duplicate_count'],
      )!,
      failedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_count'],
      )!,
    );
  }

  @override
  $ImportsTable createAlias(String alias) {
    return $ImportsTable(attachedDatabase, alias);
  }
}

class ImportRow extends DataClass implements Insertable<ImportRow> {
  final String id;
  final DateTime importedAt;

  /// Where the batch came from. `file_picker` for now.
  final String source;

  /// Files picked. Skipped files (not JSON) are
  /// `file_count - imported - duplicate - failed`.
  final int fileCount;
  final int importedCount;
  final int duplicateCount;
  final int failedCount;
  const ImportRow({
    required this.id,
    required this.importedAt,
    required this.source,
    required this.fileCount,
    required this.importedCount,
    required this.duplicateCount,
    required this.failedCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['imported_at'] = Variable<DateTime>(importedAt);
    map['source'] = Variable<String>(source);
    map['file_count'] = Variable<int>(fileCount);
    map['imported_count'] = Variable<int>(importedCount);
    map['duplicate_count'] = Variable<int>(duplicateCount);
    map['failed_count'] = Variable<int>(failedCount);
    return map;
  }

  ImportsCompanion toCompanion(bool nullToAbsent) {
    return ImportsCompanion(
      id: Value(id),
      importedAt: Value(importedAt),
      source: Value(source),
      fileCount: Value(fileCount),
      importedCount: Value(importedCount),
      duplicateCount: Value(duplicateCount),
      failedCount: Value(failedCount),
    );
  }

  factory ImportRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportRow(
      id: serializer.fromJson<String>(json['id']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      source: serializer.fromJson<String>(json['source']),
      fileCount: serializer.fromJson<int>(json['fileCount']),
      importedCount: serializer.fromJson<int>(json['importedCount']),
      duplicateCount: serializer.fromJson<int>(json['duplicateCount']),
      failedCount: serializer.fromJson<int>(json['failedCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'source': serializer.toJson<String>(source),
      'fileCount': serializer.toJson<int>(fileCount),
      'importedCount': serializer.toJson<int>(importedCount),
      'duplicateCount': serializer.toJson<int>(duplicateCount),
      'failedCount': serializer.toJson<int>(failedCount),
    };
  }

  ImportRow copyWith({
    String? id,
    DateTime? importedAt,
    String? source,
    int? fileCount,
    int? importedCount,
    int? duplicateCount,
    int? failedCount,
  }) => ImportRow(
    id: id ?? this.id,
    importedAt: importedAt ?? this.importedAt,
    source: source ?? this.source,
    fileCount: fileCount ?? this.fileCount,
    importedCount: importedCount ?? this.importedCount,
    duplicateCount: duplicateCount ?? this.duplicateCount,
    failedCount: failedCount ?? this.failedCount,
  );
  ImportRow copyWithCompanion(ImportsCompanion data) {
    return ImportRow(
      id: data.id.present ? data.id.value : this.id,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      source: data.source.present ? data.source.value : this.source,
      fileCount: data.fileCount.present ? data.fileCount.value : this.fileCount,
      importedCount: data.importedCount.present
          ? data.importedCount.value
          : this.importedCount,
      duplicateCount: data.duplicateCount.present
          ? data.duplicateCount.value
          : this.duplicateCount,
      failedCount: data.failedCount.present
          ? data.failedCount.value
          : this.failedCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportRow(')
          ..write('id: $id, ')
          ..write('importedAt: $importedAt, ')
          ..write('source: $source, ')
          ..write('fileCount: $fileCount, ')
          ..write('importedCount: $importedCount, ')
          ..write('duplicateCount: $duplicateCount, ')
          ..write('failedCount: $failedCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    importedAt,
    source,
    fileCount,
    importedCount,
    duplicateCount,
    failedCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportRow &&
          other.id == this.id &&
          other.importedAt == this.importedAt &&
          other.source == this.source &&
          other.fileCount == this.fileCount &&
          other.importedCount == this.importedCount &&
          other.duplicateCount == this.duplicateCount &&
          other.failedCount == this.failedCount);
}

class ImportsCompanion extends UpdateCompanion<ImportRow> {
  final Value<String> id;
  final Value<DateTime> importedAt;
  final Value<String> source;
  final Value<int> fileCount;
  final Value<int> importedCount;
  final Value<int> duplicateCount;
  final Value<int> failedCount;
  final Value<int> rowid;
  const ImportsCompanion({
    this.id = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.fileCount = const Value.absent(),
    this.importedCount = const Value.absent(),
    this.duplicateCount = const Value.absent(),
    this.failedCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportsCompanion.insert({
    required String id,
    required DateTime importedAt,
    required String source,
    required int fileCount,
    required int importedCount,
    required int duplicateCount,
    required int failedCount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       importedAt = Value(importedAt),
       source = Value(source),
       fileCount = Value(fileCount),
       importedCount = Value(importedCount),
       duplicateCount = Value(duplicateCount),
       failedCount = Value(failedCount);
  static Insertable<ImportRow> custom({
    Expression<String>? id,
    Expression<DateTime>? importedAt,
    Expression<String>? source,
    Expression<int>? fileCount,
    Expression<int>? importedCount,
    Expression<int>? duplicateCount,
    Expression<int>? failedCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (importedAt != null) 'imported_at': importedAt,
      if (source != null) 'source': source,
      if (fileCount != null) 'file_count': fileCount,
      if (importedCount != null) 'imported_count': importedCount,
      if (duplicateCount != null) 'duplicate_count': duplicateCount,
      if (failedCount != null) 'failed_count': failedCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? importedAt,
    Value<String>? source,
    Value<int>? fileCount,
    Value<int>? importedCount,
    Value<int>? duplicateCount,
    Value<int>? failedCount,
    Value<int>? rowid,
  }) {
    return ImportsCompanion(
      id: id ?? this.id,
      importedAt: importedAt ?? this.importedAt,
      source: source ?? this.source,
      fileCount: fileCount ?? this.fileCount,
      importedCount: importedCount ?? this.importedCount,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      failedCount: failedCount ?? this.failedCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fileCount.present) {
      map['file_count'] = Variable<int>(fileCount.value);
    }
    if (importedCount.present) {
      map['imported_count'] = Variable<int>(importedCount.value);
    }
    if (duplicateCount.present) {
      map['duplicate_count'] = Variable<int>(duplicateCount.value);
    }
    if (failedCount.present) {
      map['failed_count'] = Variable<int>(failedCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportsCompanion(')
          ..write('id: $id, ')
          ..write('importedAt: $importedAt, ')
          ..write('source: $source, ')
          ..write('fileCount: $fileCount, ')
          ..write('importedCount: $importedCount, ')
          ..write('duplicateCount: $duplicateCount, ')
          ..write('failedCount: $failedCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, DocumentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _importIdMeta = const VerificationMeta(
    'importId',
  );
  @override
  late final GeneratedColumn<String> importId = GeneratedColumn<String>(
    'import_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES imports (id)',
    ),
  );
  static const VerificationMeta _sourceFileNameMeta = const VerificationMeta(
    'sourceFileName',
  );
  @override
  late final GeneratedColumn<String> sourceFileName = GeneratedColumn<String>(
    'source_file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ocrTextMeta = const VerificationMeta(
    'ocrText',
  );
  @override
  late final GeneratedColumn<String> ocrText = GeneratedColumn<String>(
    'ocr_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _documentTypeMeta = const VerificationMeta(
    'documentType',
  );
  @override
  late final GeneratedColumn<String> documentType = GeneratedColumn<String>(
    'document_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _pdfNameMeta = const VerificationMeta(
    'pdfName',
  );
  @override
  late final GeneratedColumn<String> pdfName = GeneratedColumn<String>(
    'pdf_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageNamesMeta = const VerificationMeta(
    'imageNames',
  );
  @override
  late final GeneratedColumn<String> imageNames = GeneratedColumn<String>(
    'image_names',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wasLegacyMeta = const VerificationMeta(
    'wasLegacy',
  );
  @override
  late final GeneratedColumn<bool> wasLegacy = GeneratedColumn<bool>(
    'was_legacy',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_legacy" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    importId,
    sourceFileName,
    createdAtUtc,
    ocrText,
    language,
    documentType,
    pdfName,
    imageNames,
    schemaVersion,
    wasLegacy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('import_id')) {
      context.handle(
        _importIdMeta,
        importId.isAcceptableOrUnknown(data['import_id']!, _importIdMeta),
      );
    } else if (isInserting) {
      context.missing(_importIdMeta);
    }
    if (data.containsKey('source_file_name')) {
      context.handle(
        _sourceFileNameMeta,
        sourceFileName.isAcceptableOrUnknown(
          data['source_file_name']!,
          _sourceFileNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceFileNameMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('ocr_text')) {
      context.handle(
        _ocrTextMeta,
        ocrText.isAcceptableOrUnknown(data['ocr_text']!, _ocrTextMeta),
      );
    } else if (isInserting) {
      context.missing(_ocrTextMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('document_type')) {
      context.handle(
        _documentTypeMeta,
        documentType.isAcceptableOrUnknown(
          data['document_type']!,
          _documentTypeMeta,
        ),
      );
    }
    if (data.containsKey('pdf_name')) {
      context.handle(
        _pdfNameMeta,
        pdfName.isAcceptableOrUnknown(data['pdf_name']!, _pdfNameMeta),
      );
    }
    if (data.containsKey('image_names')) {
      context.handle(
        _imageNamesMeta,
        imageNames.isAcceptableOrUnknown(data['image_names']!, _imageNamesMeta),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('was_legacy')) {
      context.handle(
        _wasLegacyMeta,
        wasLegacy.isAcceptableOrUnknown(data['was_legacy']!, _wasLegacyMeta),
      );
    } else if (isInserting) {
      context.missing(_wasLegacyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      importId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_id'],
      )!,
      sourceFileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_file_name'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      ocrText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_text'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
      documentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_type'],
      )!,
      pdfName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pdf_name'],
      ),
      imageNames: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_names'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      wasLegacy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_legacy'],
      )!,
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }
}

class DocumentRow extends DataClass implements Insertable<DocumentRow> {
  final String id;

  /// The `documentId` of the Scan JSON: the duplicate key.
  final String documentId;
  final String importId;

  /// The JSON file the document came from.
  final String sourceFileName;

  /// The `createdAt` instant, UTC.
  final DateTime createdAtUtc;
  final String ocrText;

  /// BCP-47 tag, or null when the file did not say.
  final String? language;

  /// `DocumentType.name`. No constraint: a value written by a newer version
  /// of the app must not make the row unreadable (it reads as `unknown`).
  final String documentType;

  /// File names (labels, never paths), cut to their last segment.
  final String? pdfName;

  /// A JSON array of strings.
  final String imageNames;

  /// The `schemaVersion` of the file; 1 for a legacy file.
  final int schemaVersion;
  final bool wasLegacy;
  const DocumentRow({
    required this.id,
    required this.documentId,
    required this.importId,
    required this.sourceFileName,
    required this.createdAtUtc,
    required this.ocrText,
    this.language,
    required this.documentType,
    this.pdfName,
    required this.imageNames,
    required this.schemaVersion,
    required this.wasLegacy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    map['import_id'] = Variable<String>(importId);
    map['source_file_name'] = Variable<String>(sourceFileName);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['ocr_text'] = Variable<String>(ocrText);
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    map['document_type'] = Variable<String>(documentType);
    if (!nullToAbsent || pdfName != null) {
      map['pdf_name'] = Variable<String>(pdfName);
    }
    map['image_names'] = Variable<String>(imageNames);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['was_legacy'] = Variable<bool>(wasLegacy);
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      documentId: Value(documentId),
      importId: Value(importId),
      sourceFileName: Value(sourceFileName),
      createdAtUtc: Value(createdAtUtc),
      ocrText: Value(ocrText),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      documentType: Value(documentType),
      pdfName: pdfName == null && nullToAbsent
          ? const Value.absent()
          : Value(pdfName),
      imageNames: Value(imageNames),
      schemaVersion: Value(schemaVersion),
      wasLegacy: Value(wasLegacy),
    );
  }

  factory DocumentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentRow(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      importId: serializer.fromJson<String>(json['importId']),
      sourceFileName: serializer.fromJson<String>(json['sourceFileName']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      ocrText: serializer.fromJson<String>(json['ocrText']),
      language: serializer.fromJson<String?>(json['language']),
      documentType: serializer.fromJson<String>(json['documentType']),
      pdfName: serializer.fromJson<String?>(json['pdfName']),
      imageNames: serializer.fromJson<String>(json['imageNames']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      wasLegacy: serializer.fromJson<bool>(json['wasLegacy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'importId': serializer.toJson<String>(importId),
      'sourceFileName': serializer.toJson<String>(sourceFileName),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'ocrText': serializer.toJson<String>(ocrText),
      'language': serializer.toJson<String?>(language),
      'documentType': serializer.toJson<String>(documentType),
      'pdfName': serializer.toJson<String?>(pdfName),
      'imageNames': serializer.toJson<String>(imageNames),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'wasLegacy': serializer.toJson<bool>(wasLegacy),
    };
  }

  DocumentRow copyWith({
    String? id,
    String? documentId,
    String? importId,
    String? sourceFileName,
    DateTime? createdAtUtc,
    String? ocrText,
    Value<String?> language = const Value.absent(),
    String? documentType,
    Value<String?> pdfName = const Value.absent(),
    String? imageNames,
    int? schemaVersion,
    bool? wasLegacy,
  }) => DocumentRow(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    importId: importId ?? this.importId,
    sourceFileName: sourceFileName ?? this.sourceFileName,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    ocrText: ocrText ?? this.ocrText,
    language: language.present ? language.value : this.language,
    documentType: documentType ?? this.documentType,
    pdfName: pdfName.present ? pdfName.value : this.pdfName,
    imageNames: imageNames ?? this.imageNames,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    wasLegacy: wasLegacy ?? this.wasLegacy,
  );
  DocumentRow copyWithCompanion(DocumentsCompanion data) {
    return DocumentRow(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      importId: data.importId.present ? data.importId.value : this.importId,
      sourceFileName: data.sourceFileName.present
          ? data.sourceFileName.value
          : this.sourceFileName,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      ocrText: data.ocrText.present ? data.ocrText.value : this.ocrText,
      language: data.language.present ? data.language.value : this.language,
      documentType: data.documentType.present
          ? data.documentType.value
          : this.documentType,
      pdfName: data.pdfName.present ? data.pdfName.value : this.pdfName,
      imageNames: data.imageNames.present
          ? data.imageNames.value
          : this.imageNames,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      wasLegacy: data.wasLegacy.present ? data.wasLegacy.value : this.wasLegacy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRow(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('importId: $importId, ')
          ..write('sourceFileName: $sourceFileName, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('ocrText: $ocrText, ')
          ..write('language: $language, ')
          ..write('documentType: $documentType, ')
          ..write('pdfName: $pdfName, ')
          ..write('imageNames: $imageNames, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('wasLegacy: $wasLegacy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    importId,
    sourceFileName,
    createdAtUtc,
    ocrText,
    language,
    documentType,
    pdfName,
    imageNames,
    schemaVersion,
    wasLegacy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentRow &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.importId == this.importId &&
          other.sourceFileName == this.sourceFileName &&
          other.createdAtUtc == this.createdAtUtc &&
          other.ocrText == this.ocrText &&
          other.language == this.language &&
          other.documentType == this.documentType &&
          other.pdfName == this.pdfName &&
          other.imageNames == this.imageNames &&
          other.schemaVersion == this.schemaVersion &&
          other.wasLegacy == this.wasLegacy);
}

class DocumentsCompanion extends UpdateCompanion<DocumentRow> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<String> importId;
  final Value<String> sourceFileName;
  final Value<DateTime> createdAtUtc;
  final Value<String> ocrText;
  final Value<String?> language;
  final Value<String> documentType;
  final Value<String?> pdfName;
  final Value<String> imageNames;
  final Value<int> schemaVersion;
  final Value<bool> wasLegacy;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.importId = const Value.absent(),
    this.sourceFileName = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.language = const Value.absent(),
    this.documentType = const Value.absent(),
    this.pdfName = const Value.absent(),
    this.imageNames = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.wasLegacy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    required String documentId,
    required String importId,
    required String sourceFileName,
    required DateTime createdAtUtc,
    required String ocrText,
    this.language = const Value.absent(),
    this.documentType = const Value.absent(),
    this.pdfName = const Value.absent(),
    this.imageNames = const Value.absent(),
    required int schemaVersion,
    required bool wasLegacy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId),
       importId = Value(importId),
       sourceFileName = Value(sourceFileName),
       createdAtUtc = Value(createdAtUtc),
       ocrText = Value(ocrText),
       schemaVersion = Value(schemaVersion),
       wasLegacy = Value(wasLegacy);
  static Insertable<DocumentRow> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<String>? importId,
    Expression<String>? sourceFileName,
    Expression<DateTime>? createdAtUtc,
    Expression<String>? ocrText,
    Expression<String>? language,
    Expression<String>? documentType,
    Expression<String>? pdfName,
    Expression<String>? imageNames,
    Expression<int>? schemaVersion,
    Expression<bool>? wasLegacy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (importId != null) 'import_id': importId,
      if (sourceFileName != null) 'source_file_name': sourceFileName,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (ocrText != null) 'ocr_text': ocrText,
      if (language != null) 'language': language,
      if (documentType != null) 'document_type': documentType,
      if (pdfName != null) 'pdf_name': pdfName,
      if (imageNames != null) 'image_names': imageNames,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (wasLegacy != null) 'was_legacy': wasLegacy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith({
    Value<String>? id,
    Value<String>? documentId,
    Value<String>? importId,
    Value<String>? sourceFileName,
    Value<DateTime>? createdAtUtc,
    Value<String>? ocrText,
    Value<String?>? language,
    Value<String>? documentType,
    Value<String?>? pdfName,
    Value<String>? imageNames,
    Value<int>? schemaVersion,
    Value<bool>? wasLegacy,
    Value<int>? rowid,
  }) {
    return DocumentsCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      importId: importId ?? this.importId,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      ocrText: ocrText ?? this.ocrText,
      language: language ?? this.language,
      documentType: documentType ?? this.documentType,
      pdfName: pdfName ?? this.pdfName,
      imageNames: imageNames ?? this.imageNames,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      wasLegacy: wasLegacy ?? this.wasLegacy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (importId.present) {
      map['import_id'] = Variable<String>(importId.value);
    }
    if (sourceFileName.present) {
      map['source_file_name'] = Variable<String>(sourceFileName.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (ocrText.present) {
      map['ocr_text'] = Variable<String>(ocrText.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (documentType.present) {
      map['document_type'] = Variable<String>(documentType.value);
    }
    if (pdfName.present) {
      map['pdf_name'] = Variable<String>(pdfName.value);
    }
    if (imageNames.present) {
      map['image_names'] = Variable<String>(imageNames.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (wasLegacy.present) {
      map['was_legacy'] = Variable<bool>(wasLegacy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('importId: $importId, ')
          ..write('sourceFileName: $sourceFileName, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('ocrText: $ocrText, ')
          ..write('language: $language, ')
          ..write('documentType: $documentType, ')
          ..write('pdfName: $pdfName, ')
          ..write('imageNames: $imageNames, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('wasLegacy: $wasLegacy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses
    with TableInfo<$ExpensesTable, ExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _expenseDateMeta = const VerificationMeta(
    'expenseDate',
  );
  @override
  late final GeneratedColumn<String> expenseDate = GeneratedColumn<String>(
    'expense_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalAmountMinorMeta =
      const VerificationMeta('originalAmountMinor');
  @override
  late final GeneratedColumn<int> originalAmountMinor = GeneratedColumn<int>(
    'original_amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalCurrencyCodeMeta =
      const VerificationMeta('originalCurrencyCode');
  @override
  late final GeneratedColumn<String> originalCurrencyCode =
      GeneratedColumn<String>(
        'original_currency_code',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _taxAmountMinorMeta = const VerificationMeta(
    'taxAmountMinor',
  );
  @override
  late final GeneratedColumn<int> taxAmountMinor = GeneratedColumn<int>(
    'tax_amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE SET NULL',
    ),
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
    description,
    categoryId,
    expenseDate,
    currencyCode,
    amountMinor,
    originalAmountMinor,
    originalCurrencyCode,
    taxAmountMinor,
    documentId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('expense_date')) {
      context.handle(
        _expenseDateMeta,
        expenseDate.isAcceptableOrUnknown(
          data['expense_date']!,
          _expenseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expenseDateMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('original_amount_minor')) {
      context.handle(
        _originalAmountMinorMeta,
        originalAmountMinor.isAcceptableOrUnknown(
          data['original_amount_minor']!,
          _originalAmountMinorMeta,
        ),
      );
    }
    if (data.containsKey('original_currency_code')) {
      context.handle(
        _originalCurrencyCodeMeta,
        originalCurrencyCode.isAcceptableOrUnknown(
          data['original_currency_code']!,
          _originalCurrencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('tax_amount_minor')) {
      context.handle(
        _taxAmountMinorMeta,
        taxAmountMinor.isAcceptableOrUnknown(
          data['tax_amount_minor']!,
          _taxAmountMinorMeta,
        ),
      );
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
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
  ExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      expenseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_date'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      ),
      originalAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_amount_minor'],
      ),
      originalCurrencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_currency_code'],
      ),
      taxAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_amount_minor'],
      ),
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
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
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class ExpenseRow extends DataClass implements Insertable<ExpenseRow> {
  final String id;
  final String? description;
  final String categoryId;

  /// Calendar day, `yyyy-MM-dd`.
  final String expenseDate;

  /// Currency of the account that was charged. Always set, also when the
  /// expense is pending.
  final String currencyCode;

  /// What left the user's pocket, in [currencyCode]. Null: the expense is
  /// pending ("awaiting amount") and counts nowhere.
  final int? amountMinor;

  /// Informational: the amount and currency on the receipt (24.50 GBP).
  final int? originalAmountMinor;
  final String? originalCurrencyCode;

  /// Informational: the part of [amountMinor] that is VAT/taxes. Added to no
  /// sum.
  final int? taxAmountMinor;

  /// The scanned document this expense was made from (Phase 3), or null.
  /// Deleting the document keeps the expense and clears the link.
  final String? documentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ExpenseRow({
    required this.id,
    this.description,
    required this.categoryId,
    required this.expenseDate,
    required this.currencyCode,
    this.amountMinor,
    this.originalAmountMinor,
    this.originalCurrencyCode,
    this.taxAmountMinor,
    this.documentId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['category_id'] = Variable<String>(categoryId);
    map['expense_date'] = Variable<String>(expenseDate);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || amountMinor != null) {
      map['amount_minor'] = Variable<int>(amountMinor);
    }
    if (!nullToAbsent || originalAmountMinor != null) {
      map['original_amount_minor'] = Variable<int>(originalAmountMinor);
    }
    if (!nullToAbsent || originalCurrencyCode != null) {
      map['original_currency_code'] = Variable<String>(originalCurrencyCode);
    }
    if (!nullToAbsent || taxAmountMinor != null) {
      map['tax_amount_minor'] = Variable<int>(taxAmountMinor);
    }
    if (!nullToAbsent || documentId != null) {
      map['document_id'] = Variable<String>(documentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      categoryId: Value(categoryId),
      expenseDate: Value(expenseDate),
      currencyCode: Value(currencyCode),
      amountMinor: amountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(amountMinor),
      originalAmountMinor: originalAmountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(originalAmountMinor),
      originalCurrencyCode: originalCurrencyCode == null && nullToAbsent
          ? const Value.absent()
          : Value(originalCurrencyCode),
      taxAmountMinor: taxAmountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(taxAmountMinor),
      documentId: documentId == null && nullToAbsent
          ? const Value.absent()
          : Value(documentId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      description: serializer.fromJson<String?>(json['description']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      expenseDate: serializer.fromJson<String>(json['expenseDate']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      amountMinor: serializer.fromJson<int?>(json['amountMinor']),
      originalAmountMinor: serializer.fromJson<int?>(
        json['originalAmountMinor'],
      ),
      originalCurrencyCode: serializer.fromJson<String?>(
        json['originalCurrencyCode'],
      ),
      taxAmountMinor: serializer.fromJson<int?>(json['taxAmountMinor']),
      documentId: serializer.fromJson<String?>(json['documentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'description': serializer.toJson<String?>(description),
      'categoryId': serializer.toJson<String>(categoryId),
      'expenseDate': serializer.toJson<String>(expenseDate),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'amountMinor': serializer.toJson<int?>(amountMinor),
      'originalAmountMinor': serializer.toJson<int?>(originalAmountMinor),
      'originalCurrencyCode': serializer.toJson<String?>(originalCurrencyCode),
      'taxAmountMinor': serializer.toJson<int?>(taxAmountMinor),
      'documentId': serializer.toJson<String?>(documentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ExpenseRow copyWith({
    String? id,
    Value<String?> description = const Value.absent(),
    String? categoryId,
    String? expenseDate,
    String? currencyCode,
    Value<int?> amountMinor = const Value.absent(),
    Value<int?> originalAmountMinor = const Value.absent(),
    Value<String?> originalCurrencyCode = const Value.absent(),
    Value<int?> taxAmountMinor = const Value.absent(),
    Value<String?> documentId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ExpenseRow(
    id: id ?? this.id,
    description: description.present ? description.value : this.description,
    categoryId: categoryId ?? this.categoryId,
    expenseDate: expenseDate ?? this.expenseDate,
    currencyCode: currencyCode ?? this.currencyCode,
    amountMinor: amountMinor.present ? amountMinor.value : this.amountMinor,
    originalAmountMinor: originalAmountMinor.present
        ? originalAmountMinor.value
        : this.originalAmountMinor,
    originalCurrencyCode: originalCurrencyCode.present
        ? originalCurrencyCode.value
        : this.originalCurrencyCode,
    taxAmountMinor: taxAmountMinor.present
        ? taxAmountMinor.value
        : this.taxAmountMinor,
    documentId: documentId.present ? documentId.value : this.documentId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ExpenseRow copyWithCompanion(ExpensesCompanion data) {
    return ExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      description: data.description.present
          ? data.description.value
          : this.description,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      expenseDate: data.expenseDate.present
          ? data.expenseDate.value
          : this.expenseDate,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      originalAmountMinor: data.originalAmountMinor.present
          ? data.originalAmountMinor.value
          : this.originalAmountMinor,
      originalCurrencyCode: data.originalCurrencyCode.present
          ? data.originalCurrencyCode.value
          : this.originalCurrencyCode,
      taxAmountMinor: data.taxAmountMinor.present
          ? data.taxAmountMinor.value
          : this.taxAmountMinor,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRow(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('originalAmountMinor: $originalAmountMinor, ')
          ..write('originalCurrencyCode: $originalCurrencyCode, ')
          ..write('taxAmountMinor: $taxAmountMinor, ')
          ..write('documentId: $documentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    description,
    categoryId,
    expenseDate,
    currencyCode,
    amountMinor,
    originalAmountMinor,
    originalCurrencyCode,
    taxAmountMinor,
    documentId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseRow &&
          other.id == this.id &&
          other.description == this.description &&
          other.categoryId == this.categoryId &&
          other.expenseDate == this.expenseDate &&
          other.currencyCode == this.currencyCode &&
          other.amountMinor == this.amountMinor &&
          other.originalAmountMinor == this.originalAmountMinor &&
          other.originalCurrencyCode == this.originalCurrencyCode &&
          other.taxAmountMinor == this.taxAmountMinor &&
          other.documentId == this.documentId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExpensesCompanion extends UpdateCompanion<ExpenseRow> {
  final Value<String> id;
  final Value<String?> description;
  final Value<String> categoryId;
  final Value<String> expenseDate;
  final Value<String> currencyCode;
  final Value<int?> amountMinor;
  final Value<int?> originalAmountMinor;
  final Value<String?> originalCurrencyCode;
  final Value<int?> taxAmountMinor;
  final Value<String?> documentId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.originalAmountMinor = const Value.absent(),
    this.originalCurrencyCode = const Value.absent(),
    this.taxAmountMinor = const Value.absent(),
    this.documentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    this.description = const Value.absent(),
    required String categoryId,
    required String expenseDate,
    required String currencyCode,
    this.amountMinor = const Value.absent(),
    this.originalAmountMinor = const Value.absent(),
    this.originalCurrencyCode = const Value.absent(),
    this.taxAmountMinor = const Value.absent(),
    this.documentId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       expenseDate = Value(expenseDate),
       currencyCode = Value(currencyCode),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ExpenseRow> custom({
    Expression<String>? id,
    Expression<String>? description,
    Expression<String>? categoryId,
    Expression<String>? expenseDate,
    Expression<String>? currencyCode,
    Expression<int>? amountMinor,
    Expression<int>? originalAmountMinor,
    Expression<String>? originalCurrencyCode,
    Expression<int>? taxAmountMinor,
    Expression<String>? documentId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (originalAmountMinor != null)
        'original_amount_minor': originalAmountMinor,
      if (originalCurrencyCode != null)
        'original_currency_code': originalCurrencyCode,
      if (taxAmountMinor != null) 'tax_amount_minor': taxAmountMinor,
      if (documentId != null) 'document_id': documentId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String?>? description,
    Value<String>? categoryId,
    Value<String>? expenseDate,
    Value<String>? currencyCode,
    Value<int?>? amountMinor,
    Value<int?>? originalAmountMinor,
    Value<String?>? originalCurrencyCode,
    Value<int?>? taxAmountMinor,
    Value<String?>? documentId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      expenseDate: expenseDate ?? this.expenseDate,
      currencyCode: currencyCode ?? this.currencyCode,
      amountMinor: amountMinor ?? this.amountMinor,
      originalAmountMinor: originalAmountMinor ?? this.originalAmountMinor,
      originalCurrencyCode: originalCurrencyCode ?? this.originalCurrencyCode,
      taxAmountMinor: taxAmountMinor ?? this.taxAmountMinor,
      documentId: documentId ?? this.documentId,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (expenseDate.present) {
      map['expense_date'] = Variable<String>(expenseDate.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (originalAmountMinor.present) {
      map['original_amount_minor'] = Variable<int>(originalAmountMinor.value);
    }
    if (originalCurrencyCode.present) {
      map['original_currency_code'] = Variable<String>(
        originalCurrencyCode.value,
      );
    }
    if (taxAmountMinor.present) {
      map['tax_amount_minor'] = Variable<int>(taxAmountMinor.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
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
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('originalAmountMinor: $originalAmountMinor, ')
          ..write('originalCurrencyCode: $originalCurrencyCode, ')
          ..write('taxAmountMinor: $taxAmountMinor, ')
          ..write('documentId: $documentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $IncomeSourcesTable incomeSources = $IncomeSourcesTable(this);
  late final $IncomeEntriesTable incomeEntries = $IncomeEntriesTable(this);
  late final $BalanceAnchorsTable balanceAnchors = $BalanceAnchorsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ImportsTable imports = $ImportsTable(this);
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettings,
    incomeSources,
    incomeEntries,
    balanceAnchors,
    categories,
    imports,
    documents,
    expenses,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expenses', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String settingKey,
      required String settingValue,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> settingKey,
      Value<String> settingValue,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> settingKey = const Value.absent(),
                Value<String> settingValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                settingKey: settingKey,
                settingValue: settingValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String settingKey,
                required String settingValue,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                settingKey: settingKey,
                settingValue: settingValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$IncomeSourcesTableCreateCompanionBuilder =
    IncomeSourcesCompanion Function({
      required String id,
      required String name,
      required String type,
      required int amountMinor,
      required String currencyCode,
      required String scheduleJson,
      required String startDate,
      Value<String?> endDate,
      Value<String?> frozenThrough,
      required DateTime createdAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$IncomeSourcesTableUpdateCompanionBuilder =
    IncomeSourcesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<String> scheduleJson,
      Value<String> startDate,
      Value<String?> endDate,
      Value<String?> frozenThrough,
      Value<DateTime> createdAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$IncomeSourcesTableReferences
    extends
        BaseReferences<_$AppDatabase, $IncomeSourcesTable, IncomeSourceRow> {
  $$IncomeSourcesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$IncomeEntriesTable, List<IncomeEntryRow>>
  _incomeEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.incomeEntries,
    aliasName: 'income_sources__id__income_entries__source_id',
  );

  $$IncomeEntriesTableProcessedTableManager get incomeEntriesRefs {
    final manager = $$IncomeEntriesTableTableManager(
      $_db,
      $_db.incomeEntries,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_incomeEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IncomeSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $IncomeSourcesTable> {
  $$IncomeSourcesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleJson => $composableBuilder(
    column: $table.scheduleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frozenThrough => $composableBuilder(
    column: $table.frozenThrough,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> incomeEntriesRefs(
    Expression<bool> Function($$IncomeEntriesTableFilterComposer f) f,
  ) {
    final $$IncomeEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incomeEntries,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomeEntriesTableFilterComposer(
            $db: $db,
            $table: $db.incomeEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IncomeSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomeSourcesTable> {
  $$IncomeSourcesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleJson => $composableBuilder(
    column: $table.scheduleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frozenThrough => $composableBuilder(
    column: $table.frozenThrough,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IncomeSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomeSourcesTable> {
  $$IncomeSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleJson => $composableBuilder(
    column: $table.scheduleJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get frozenThrough => $composableBuilder(
    column: $table.frozenThrough,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> incomeEntriesRefs<T extends Object>(
    Expression<T> Function($$IncomeEntriesTableAnnotationComposer a) f,
  ) {
    final $$IncomeEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incomeEntries,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomeEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.incomeEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IncomeSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncomeSourcesTable,
          IncomeSourceRow,
          $$IncomeSourcesTableFilterComposer,
          $$IncomeSourcesTableOrderingComposer,
          $$IncomeSourcesTableAnnotationComposer,
          $$IncomeSourcesTableCreateCompanionBuilder,
          $$IncomeSourcesTableUpdateCompanionBuilder,
          (IncomeSourceRow, $$IncomeSourcesTableReferences),
          IncomeSourceRow,
          PrefetchHooks Function({bool incomeEntriesRefs})
        > {
  $$IncomeSourcesTableTableManager(_$AppDatabase db, $IncomeSourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomeSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomeSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomeSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> scheduleJson = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<String?> frozenThrough = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomeSourcesCompanion(
                id: id,
                name: name,
                type: type,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                scheduleJson: scheduleJson,
                startDate: startDate,
                endDate: endDate,
                frozenThrough: frozenThrough,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required int amountMinor,
                required String currencyCode,
                required String scheduleJson,
                required String startDate,
                Value<String?> endDate = const Value.absent(),
                Value<String?> frozenThrough = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomeSourcesCompanion.insert(
                id: id,
                name: name,
                type: type,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                scheduleJson: scheduleJson,
                startDate: startDate,
                endDate: endDate,
                frozenThrough: frozenThrough,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IncomeSourcesTable, IncomeSourceRow>(table),
                  $$IncomeSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({incomeEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (incomeEntriesRefs) db.incomeEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (incomeEntriesRefs)
                    await $_getPrefetchedData<
                      IncomeSourceRow,
                      $IncomeSourcesTable,
                      IncomeEntryRow
                    >(
                      currentTable: table,
                      referencedTable: $$IncomeSourcesTableReferences
                          ._incomeEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$IncomeSourcesTableReferences(
                            db,
                            table,
                            p0,
                          ).incomeEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sourceId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$IncomeSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncomeSourcesTable,
      IncomeSourceRow,
      $$IncomeSourcesTableFilterComposer,
      $$IncomeSourcesTableOrderingComposer,
      $$IncomeSourcesTableAnnotationComposer,
      $$IncomeSourcesTableCreateCompanionBuilder,
      $$IncomeSourcesTableUpdateCompanionBuilder,
      (IncomeSourceRow, $$IncomeSourcesTableReferences),
      IncomeSourceRow,
      PrefetchHooks Function({bool incomeEntriesRefs})
    >;
typedef $$IncomeEntriesTableCreateCompanionBuilder =
    IncomeEntriesCompanion Function({
      required String id,
      required String sourceId,
      required String originalDate,
      Value<String?> actualDate,
      required String status,
      required int amountMinor,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$IncomeEntriesTableUpdateCompanionBuilder =
    IncomeEntriesCompanion Function({
      Value<String> id,
      Value<String> sourceId,
      Value<String> originalDate,
      Value<String?> actualDate,
      Value<String> status,
      Value<int> amountMinor,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$IncomeEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $IncomeEntriesTable, IncomeEntryRow> {
  $$IncomeEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IncomeSourcesTable _sourceIdTable(_$AppDatabase db) => db
      .incomeSources
      .createAlias('income_entries__source_id__income_sources__id');

  $$IncomeSourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$IncomeSourcesTableTableManager(
      $_db,
      $_db.incomeSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IncomeEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $IncomeEntriesTable> {
  $$IncomeEntriesTableFilterComposer({
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

  ColumnFilters<String> get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$IncomeSourcesTableFilterComposer get sourceId {
    final $$IncomeSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.incomeSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomeSourcesTableFilterComposer(
            $db: $db,
            $table: $db.incomeSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomeEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomeEntriesTable> {
  $$IncomeEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$IncomeSourcesTableOrderingComposer get sourceId {
    final $$IncomeSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.incomeSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomeSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.incomeSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomeEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomeEntriesTable> {
  $$IncomeEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalDate => $composableBuilder(
    column: $table.originalDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actualDate => $composableBuilder(
    column: $table.actualDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$IncomeSourcesTableAnnotationComposer get sourceId {
    final $$IncomeSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.incomeSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomeSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.incomeSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomeEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncomeEntriesTable,
          IncomeEntryRow,
          $$IncomeEntriesTableFilterComposer,
          $$IncomeEntriesTableOrderingComposer,
          $$IncomeEntriesTableAnnotationComposer,
          $$IncomeEntriesTableCreateCompanionBuilder,
          $$IncomeEntriesTableUpdateCompanionBuilder,
          (IncomeEntryRow, $$IncomeEntriesTableReferences),
          IncomeEntryRow,
          PrefetchHooks Function({bool sourceId})
        > {
  $$IncomeEntriesTableTableManager(_$AppDatabase db, $IncomeEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomeEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomeEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomeEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> originalDate = const Value.absent(),
                Value<String?> actualDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomeEntriesCompanion(
                id: id,
                sourceId: sourceId,
                originalDate: originalDate,
                actualDate: actualDate,
                status: status,
                amountMinor: amountMinor,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceId,
                required String originalDate,
                Value<String?> actualDate = const Value.absent(),
                required String status,
                required int amountMinor,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => IncomeEntriesCompanion.insert(
                id: id,
                sourceId: sourceId,
                originalDate: originalDate,
                actualDate: actualDate,
                status: status,
                amountMinor: amountMinor,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IncomeEntriesTable, IncomeEntryRow>(table),
                  $$IncomeEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false}) {
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
                    if (sourceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sourceId,
                                referencedTable: $$IncomeEntriesTableReferences
                                    ._sourceIdTable(db),
                                referencedColumn: $$IncomeEntriesTableReferences
                                    ._sourceIdTable(db)
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

typedef $$IncomeEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncomeEntriesTable,
      IncomeEntryRow,
      $$IncomeEntriesTableFilterComposer,
      $$IncomeEntriesTableOrderingComposer,
      $$IncomeEntriesTableAnnotationComposer,
      $$IncomeEntriesTableCreateCompanionBuilder,
      $$IncomeEntriesTableUpdateCompanionBuilder,
      (IncomeEntryRow, $$IncomeEntriesTableReferences),
      IncomeEntryRow,
      PrefetchHooks Function({bool sourceId})
    >;
typedef $$BalanceAnchorsTableCreateCompanionBuilder =
    BalanceAnchorsCompanion Function({
      required String id,
      required String anchorDate,
      required int balanceMinor,
      required String currencyCode,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BalanceAnchorsTableUpdateCompanionBuilder =
    BalanceAnchorsCompanion Function({
      Value<String> id,
      Value<String> anchorDate,
      Value<int> balanceMinor,
      Value<String> currencyCode,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BalanceAnchorsTableFilterComposer
    extends Composer<_$AppDatabase, $BalanceAnchorsTable> {
  $$BalanceAnchorsTableFilterComposer({
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

  ColumnFilters<String> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BalanceAnchorsTableOrderingComposer
    extends Composer<_$AppDatabase, $BalanceAnchorsTable> {
  $$BalanceAnchorsTableOrderingComposer({
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

  ColumnOrderings<String> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BalanceAnchorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BalanceAnchorsTable> {
  $$BalanceAnchorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BalanceAnchorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BalanceAnchorsTable,
          BalanceAnchorRow,
          $$BalanceAnchorsTableFilterComposer,
          $$BalanceAnchorsTableOrderingComposer,
          $$BalanceAnchorsTableAnnotationComposer,
          $$BalanceAnchorsTableCreateCompanionBuilder,
          $$BalanceAnchorsTableUpdateCompanionBuilder,
          (
            BalanceAnchorRow,
            BaseReferences<
              _$AppDatabase,
              $BalanceAnchorsTable,
              BalanceAnchorRow
            >,
          ),
          BalanceAnchorRow,
          PrefetchHooks Function()
        > {
  $$BalanceAnchorsTableTableManager(
    _$AppDatabase db,
    $BalanceAnchorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BalanceAnchorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BalanceAnchorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BalanceAnchorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> anchorDate = const Value.absent(),
                Value<int> balanceMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BalanceAnchorsCompanion(
                id: id,
                anchorDate: anchorDate,
                balanceMinor: balanceMinor,
                currencyCode: currencyCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String anchorDate,
                required int balanceMinor,
                required String currencyCode,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BalanceAnchorsCompanion.insert(
                id: id,
                anchorDate: anchorDate,
                balanceMinor: balanceMinor,
                currencyCode: currencyCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BalanceAnchorsTable, BalanceAnchorRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BalanceAnchorsTable,
                    BalanceAnchorRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BalanceAnchorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BalanceAnchorsTable,
      BalanceAnchorRow,
      $$BalanceAnchorsTableFilterComposer,
      $$BalanceAnchorsTableOrderingComposer,
      $$BalanceAnchorsTableAnnotationComposer,
      $$BalanceAnchorsTableCreateCompanionBuilder,
      $$BalanceAnchorsTableUpdateCompanionBuilder,
      (
        BalanceAnchorRow,
        BaseReferences<_$AppDatabase, $BalanceAnchorsTable, BalanceAnchorRow>,
      ),
      BalanceAnchorRow,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String categoryKey,
      required int sortOrder,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> categoryKey,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExpensesTable, List<ExpenseRow>>
  _expensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'categories__id__expenses__category_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryKey => $composableBuilder(
    column: $table.categoryKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({bool expensesRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryKey = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                categoryKey: categoryKey,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryKey,
                required int sortOrder,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                categoryKey: categoryKey,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (expensesRefs) db.expenses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedData<
                      CategoryRow,
                      $CategoriesTable,
                      ExpenseRow
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._expensesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).expensesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({bool expensesRefs})
    >;
typedef $$ImportsTableCreateCompanionBuilder =
    ImportsCompanion Function({
      required String id,
      required DateTime importedAt,
      required String source,
      required int fileCount,
      required int importedCount,
      required int duplicateCount,
      required int failedCount,
      Value<int> rowid,
    });
typedef $$ImportsTableUpdateCompanionBuilder =
    ImportsCompanion Function({
      Value<String> id,
      Value<DateTime> importedAt,
      Value<String> source,
      Value<int> fileCount,
      Value<int> importedCount,
      Value<int> duplicateCount,
      Value<int> failedCount,
      Value<int> rowid,
    });

final class $$ImportsTableReferences
    extends BaseReferences<_$AppDatabase, $ImportsTable, ImportRow> {
  $$ImportsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DocumentsTable, List<DocumentRow>>
  _documentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.documents,
    aliasName: 'imports__id__documents__import_id',
  );

  $$DocumentsTableProcessedTableManager get documentsRefs {
    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.importId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImportsTableFilterComposer
    extends Composer<_$AppDatabase, $ImportsTable> {
  $$ImportsTableFilterComposer({
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

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileCount => $composableBuilder(
    column: $table.fileCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importedCount => $composableBuilder(
    column: $table.importedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duplicateCount => $composableBuilder(
    column: $table.duplicateCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> documentsRefs(
    Expression<bool> Function($$DocumentsTableFilterComposer f) f,
  ) {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.importId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImportsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportsTable> {
  $$ImportsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileCount => $composableBuilder(
    column: $table.fileCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importedCount => $composableBuilder(
    column: $table.importedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duplicateCount => $composableBuilder(
    column: $table.duplicateCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportsTable> {
  $$ImportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get fileCount =>
      $composableBuilder(column: $table.fileCount, builder: (column) => column);

  GeneratedColumn<int> get importedCount => $composableBuilder(
    column: $table.importedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get duplicateCount => $composableBuilder(
    column: $table.duplicateCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => column,
  );

  Expression<T> documentsRefs<T extends Object>(
    Expression<T> Function($$DocumentsTableAnnotationComposer a) f,
  ) {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.importId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportsTable,
          ImportRow,
          $$ImportsTableFilterComposer,
          $$ImportsTableOrderingComposer,
          $$ImportsTableAnnotationComposer,
          $$ImportsTableCreateCompanionBuilder,
          $$ImportsTableUpdateCompanionBuilder,
          (ImportRow, $$ImportsTableReferences),
          ImportRow,
          PrefetchHooks Function({bool documentsRefs})
        > {
  $$ImportsTableTableManager(_$AppDatabase db, $ImportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> fileCount = const Value.absent(),
                Value<int> importedCount = const Value.absent(),
                Value<int> duplicateCount = const Value.absent(),
                Value<int> failedCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportsCompanion(
                id: id,
                importedAt: importedAt,
                source: source,
                fileCount: fileCount,
                importedCount: importedCount,
                duplicateCount: duplicateCount,
                failedCount: failedCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime importedAt,
                required String source,
                required int fileCount,
                required int importedCount,
                required int duplicateCount,
                required int failedCount,
                Value<int> rowid = const Value.absent(),
              }) => ImportsCompanion.insert(
                id: id,
                importedAt: importedAt,
                source: source,
                fileCount: fileCount,
                importedCount: importedCount,
                duplicateCount: duplicateCount,
                failedCount: failedCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImportsTable, ImportRow>(table),
                  $$ImportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (documentsRefs) db.documents],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (documentsRefs)
                    await $_getPrefetchedData<
                      ImportRow,
                      $ImportsTable,
                      DocumentRow
                    >(
                      currentTable: table,
                      referencedTable: $$ImportsTableReferences
                          ._documentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ImportsTableReferences(db, table, p0).documentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.importId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ImportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportsTable,
      ImportRow,
      $$ImportsTableFilterComposer,
      $$ImportsTableOrderingComposer,
      $$ImportsTableAnnotationComposer,
      $$ImportsTableCreateCompanionBuilder,
      $$ImportsTableUpdateCompanionBuilder,
      (ImportRow, $$ImportsTableReferences),
      ImportRow,
      PrefetchHooks Function({bool documentsRefs})
    >;
typedef $$DocumentsTableCreateCompanionBuilder =
    DocumentsCompanion Function({
      required String id,
      required String documentId,
      required String importId,
      required String sourceFileName,
      required DateTime createdAtUtc,
      required String ocrText,
      Value<String?> language,
      Value<String> documentType,
      Value<String?> pdfName,
      Value<String> imageNames,
      required int schemaVersion,
      required bool wasLegacy,
      Value<int> rowid,
    });
typedef $$DocumentsTableUpdateCompanionBuilder =
    DocumentsCompanion Function({
      Value<String> id,
      Value<String> documentId,
      Value<String> importId,
      Value<String> sourceFileName,
      Value<DateTime> createdAtUtc,
      Value<String> ocrText,
      Value<String?> language,
      Value<String> documentType,
      Value<String?> pdfName,
      Value<String> imageNames,
      Value<int> schemaVersion,
      Value<bool> wasLegacy,
      Value<int> rowid,
    });

final class $$DocumentsTableReferences
    extends BaseReferences<_$AppDatabase, $DocumentsTable, DocumentRow> {
  $$DocumentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ImportsTable _importIdTable(_$AppDatabase db) =>
      db.imports.createAlias('documents__import_id__imports__id');

  $$ImportsTableProcessedTableManager get importId {
    final $_column = $_itemColumn<String>('import_id')!;

    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<ExpenseRow>>
  _expensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'documents__id__expenses__document_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer({
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

  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFileName => $composableBuilder(
    column: $table.sourceFileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pdfName => $composableBuilder(
    column: $table.pdfName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageNames => $composableBuilder(
    column: $table.imageNames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasLegacy => $composableBuilder(
    column: $table.wasLegacy,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportsTableFilterComposer get importId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer({
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

  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFileName => $composableBuilder(
    column: $table.sourceFileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pdfName => $composableBuilder(
    column: $table.pdfName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageNames => $composableBuilder(
    column: $table.imageNames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasLegacy => $composableBuilder(
    column: $table.wasLegacy,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportsTableOrderingComposer get importId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceFileName => $composableBuilder(
    column: $table.sourceFileName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ocrText =>
      $composableBuilder(column: $table.ocrText, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pdfName =>
      $composableBuilder(column: $table.pdfName, builder: (column) => column);

  GeneratedColumn<String> get imageNames => $composableBuilder(
    column: $table.imageNames,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasLegacy =>
      $composableBuilder(column: $table.wasLegacy, builder: (column) => column);

  $$ImportsTableAnnotationComposer get importId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentsTable,
          DocumentRow,
          $$DocumentsTableFilterComposer,
          $$DocumentsTableOrderingComposer,
          $$DocumentsTableAnnotationComposer,
          $$DocumentsTableCreateCompanionBuilder,
          $$DocumentsTableUpdateCompanionBuilder,
          (DocumentRow, $$DocumentsTableReferences),
          DocumentRow,
          PrefetchHooks Function({bool importId, bool expensesRefs})
        > {
  $$DocumentsTableTableManager(_$AppDatabase db, $DocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> importId = const Value.absent(),
                Value<String> sourceFileName = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<String> ocrText = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String> documentType = const Value.absent(),
                Value<String?> pdfName = const Value.absent(),
                Value<String> imageNames = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<bool> wasLegacy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion(
                id: id,
                documentId: documentId,
                importId: importId,
                sourceFileName: sourceFileName,
                createdAtUtc: createdAtUtc,
                ocrText: ocrText,
                language: language,
                documentType: documentType,
                pdfName: pdfName,
                imageNames: imageNames,
                schemaVersion: schemaVersion,
                wasLegacy: wasLegacy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String documentId,
                required String importId,
                required String sourceFileName,
                required DateTime createdAtUtc,
                required String ocrText,
                Value<String?> language = const Value.absent(),
                Value<String> documentType = const Value.absent(),
                Value<String?> pdfName = const Value.absent(),
                Value<String> imageNames = const Value.absent(),
                required int schemaVersion,
                required bool wasLegacy,
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion.insert(
                id: id,
                documentId: documentId,
                importId: importId,
                sourceFileName: sourceFileName,
                createdAtUtc: createdAtUtc,
                ocrText: ocrText,
                language: language,
                documentType: documentType,
                pdfName: pdfName,
                imageNames: imageNames,
                schemaVersion: schemaVersion,
                wasLegacy: wasLegacy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentsTable, DocumentRow>(table),
                  $$DocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({importId = false, expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (expensesRefs) db.expenses],
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
                    if (importId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.importId,
                                referencedTable: $$DocumentsTableReferences
                                    ._importIdTable(db),
                                referencedColumn: $$DocumentsTableReferences
                                    ._importIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedData<
                      DocumentRow,
                      $DocumentsTable,
                      ExpenseRow
                    >(
                      currentTable: table,
                      referencedTable: $$DocumentsTableReferences
                          ._expensesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DocumentsTableReferences(
                            db,
                            table,
                            p0,
                          ).expensesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.documentId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentsTable,
      DocumentRow,
      $$DocumentsTableFilterComposer,
      $$DocumentsTableOrderingComposer,
      $$DocumentsTableAnnotationComposer,
      $$DocumentsTableCreateCompanionBuilder,
      $$DocumentsTableUpdateCompanionBuilder,
      (DocumentRow, $$DocumentsTableReferences),
      DocumentRow,
      PrefetchHooks Function({bool importId, bool expensesRefs})
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      required String id,
      Value<String?> description,
      required String categoryId,
      required String expenseDate,
      required String currencyCode,
      Value<int?> amountMinor,
      Value<int?> originalAmountMinor,
      Value<String?> originalCurrencyCode,
      Value<int?> taxAmountMinor,
      Value<String?> documentId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<String> id,
      Value<String?> description,
      Value<String> categoryId,
      Value<String> expenseDate,
      Value<String> currencyCode,
      Value<int?> amountMinor,
      Value<int?> originalAmountMinor,
      Value<String?> originalCurrencyCode,
      Value<int?> taxAmountMinor,
      Value<String?> documentId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, ExpenseRow> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('expenses__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias('expenses__document_id__documents__id');

  $$DocumentsTableProcessedTableManager? get documentId {
    final $_column = $_itemColumn<String>('document_id');
    if ($_column == null) return null;
    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalCurrencyCode => $composableBuilder(
    column: $table.originalCurrencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxAmountMinor => $composableBuilder(
    column: $table.taxAmountMinor,
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

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalCurrencyCode => $composableBuilder(
    column: $table.originalCurrencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxAmountMinor => $composableBuilder(
    column: $table.taxAmountMinor,
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

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalCurrencyCode => $composableBuilder(
    column: $table.originalCurrencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taxAmountMinor => $composableBuilder(
    column: $table.taxAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          ExpenseRow,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (ExpenseRow, $$ExpensesTableReferences),
          ExpenseRow,
          PrefetchHooks Function({bool categoryId, bool documentId})
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> expenseDate = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int?> amountMinor = const Value.absent(),
                Value<int?> originalAmountMinor = const Value.absent(),
                Value<String?> originalCurrencyCode = const Value.absent(),
                Value<int?> taxAmountMinor = const Value.absent(),
                Value<String?> documentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                description: description,
                categoryId: categoryId,
                expenseDate: expenseDate,
                currencyCode: currencyCode,
                amountMinor: amountMinor,
                originalAmountMinor: originalAmountMinor,
                originalCurrencyCode: originalCurrencyCode,
                taxAmountMinor: taxAmountMinor,
                documentId: documentId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> description = const Value.absent(),
                required String categoryId,
                required String expenseDate,
                required String currencyCode,
                Value<int?> amountMinor = const Value.absent(),
                Value<int?> originalAmountMinor = const Value.absent(),
                Value<String?> originalCurrencyCode = const Value.absent(),
                Value<int?> taxAmountMinor = const Value.absent(),
                Value<String?> documentId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                description: description,
                categoryId: categoryId,
                expenseDate: expenseDate,
                currencyCode: currencyCode,
                amountMinor: amountMinor,
                originalAmountMinor: originalAmountMinor,
                originalCurrencyCode: originalCurrencyCode,
                taxAmountMinor: taxAmountMinor,
                documentId: documentId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTable, ExpenseRow>(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false, documentId = false}) {
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
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$ExpensesTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$ExpensesTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable: $$ExpensesTableReferences
                                    ._documentIdTable(db),
                                referencedColumn: $$ExpensesTableReferences
                                    ._documentIdTable(db)
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

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      ExpenseRow,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (ExpenseRow, $$ExpensesTableReferences),
      ExpenseRow,
      PrefetchHooks Function({bool categoryId, bool documentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$IncomeSourcesTableTableManager get incomeSources =>
      $$IncomeSourcesTableTableManager(_db, _db.incomeSources);
  $$IncomeEntriesTableTableManager get incomeEntries =>
      $$IncomeEntriesTableTableManager(_db, _db.incomeEntries);
  $$BalanceAnchorsTableTableManager get balanceAnchors =>
      $$BalanceAnchorsTableTableManager(_db, _db.balanceAnchors);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ImportsTableTableManager get imports =>
      $$ImportsTableTableManager(_db, _db.imports);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
}
