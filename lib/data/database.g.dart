// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BatchRecordsTable extends BatchRecords
    with TableInfo<$BatchRecordsTable, BatchRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNumberMeta = const VerificationMeta(
    'displayNumber',
  );
  @override
  late final GeneratedColumn<int> displayNumber = GeneratedColumn<int>(
    'display_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeNameMeta = const VerificationMeta(
    'recipeName',
  );
  @override
  late final GeneratedColumn<String> recipeName = GeneratedColumn<String>(
    'recipe_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fermentationStartMeta = const VerificationMeta(
    'fermentationStart',
  );
  @override
  late final GeneratedColumn<DateTime> fermentationStart =
      GeneratedColumn<DateTime>(
        'fermentation_start',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fermentationConfirmMeta =
      const VerificationMeta('fermentationConfirm');
  @override
  late final GeneratedColumn<DateTime> fermentationConfirm =
      GeneratedColumn<DateTime>(
        'fermentation_confirm',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _boilingStartMeta = const VerificationMeta(
    'boilingStart',
  );
  @override
  late final GeneratedColumn<DateTime> boilingStart = GeneratedColumn<DateTime>(
    'boiling_start',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boilingConfirmMeta = const VerificationMeta(
    'boilingConfirm',
  );
  @override
  late final GeneratedColumn<DateTime> boilingConfirm =
      GeneratedColumn<DateTime>(
        'boiling_confirm',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _steamingStartMeta = const VerificationMeta(
    'steamingStart',
  );
  @override
  late final GeneratedColumn<DateTime> steamingStart =
      GeneratedColumn<DateTime>(
        'steaming_start',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _steamingConfirmMeta = const VerificationMeta(
    'steamingConfirm',
  );
  @override
  late final GeneratedColumn<DateTime> steamingConfirm =
      GeneratedColumn<DateTime>(
        'steaming_confirm',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _simmeringStartMeta = const VerificationMeta(
    'simmeringStart',
  );
  @override
  late final GeneratedColumn<DateTime> simmeringStart =
      GeneratedColumn<DateTime>(
        'simmering_start',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _uncoverConfirmMeta = const VerificationMeta(
    'uncoverConfirm',
  );
  @override
  late final GeneratedColumn<DateTime> uncoverConfirm =
      GeneratedColumn<DateTime>(
        'uncover_confirm',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fermentationActualMinutesMeta =
      const VerificationMeta('fermentationActualMinutes');
  @override
  late final GeneratedColumn<int> fermentationActualMinutes =
      GeneratedColumn<int>(
        'fermentation_actual_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fermentationResultMeta =
      const VerificationMeta('fermentationResult');
  @override
  late final GeneratedColumn<String> fermentationResult =
      GeneratedColumn<String>(
        'fermentation_result',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lowConfidenceMeta = const VerificationMeta(
    'lowConfidence',
  );
  @override
  late final GeneratedColumn<bool> lowConfidence = GeneratedColumn<bool>(
    'low_confidence',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("low_confidence" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _simmeringIntervalMinutesMeta =
      const VerificationMeta('simmeringIntervalMinutes');
  @override
  late final GeneratedColumn<int> simmeringIntervalMinutes =
      GeneratedColumn<int>(
        'simmering_interval_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _humidityMeta = const VerificationMeta(
    'humidity',
  );
  @override
  late final GeneratedColumn<int> humidity = GeneratedColumn<int>(
    'humidity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherSourceMeta = const VerificationMeta(
    'weatherSource',
  );
  @override
  late final GeneratedColumn<String> weatherSource = GeneratedColumn<String>(
    'weather_source',
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
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adjustmentMinutesMeta = const VerificationMeta(
    'adjustmentMinutes',
  );
  @override
  late final GeneratedColumn<int> adjustmentMinutes = GeneratedColumn<int>(
    'adjustment_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _positionLabelMeta = const VerificationMeta(
    'positionLabel',
  );
  @override
  late final GeneratedColumn<String> positionLabel = GeneratedColumn<String>(
    'position_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boilingReminderDelaySecondsMeta =
      const VerificationMeta('boilingReminderDelaySeconds');
  @override
  late final GeneratedColumn<int> boilingReminderDelaySeconds =
      GeneratedColumn<int>(
        'boiling_reminder_delay_seconds',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _steamingReminderDelaySecondsMeta =
      const VerificationMeta('steamingReminderDelaySeconds');
  @override
  late final GeneratedColumn<int> steamingReminderDelaySeconds =
      GeneratedColumn<int>(
        'steaming_reminder_delay_seconds',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _extensionsLogMeta = const VerificationMeta(
    'extensionsLog',
  );
  @override
  late final GeneratedColumn<String> extensionsLog = GeneratedColumn<String>(
    'extensions_log',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayNumber,
    recipeId,
    recipeName,
    fermentationStart,
    fermentationConfirm,
    boilingStart,
    boilingConfirm,
    steamingStart,
    steamingConfirm,
    simmeringStart,
    uncoverConfirm,
    fermentationActualMinutes,
    fermentationResult,
    lowConfidence,
    simmeringIntervalMinutes,
    temperature,
    humidity,
    weatherSource,
    createdAt,
    season,
    adjustmentMinutes,
    status,
    positionLabel,
    boilingReminderDelaySeconds,
    steamingReminderDelaySeconds,
    extensionsLog,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batch_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<BatchRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_number')) {
      context.handle(
        _displayNumberMeta,
        displayNumber.isAcceptableOrUnknown(
          data['display_number']!,
          _displayNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNumberMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('recipe_name')) {
      context.handle(
        _recipeNameMeta,
        recipeName.isAcceptableOrUnknown(data['recipe_name']!, _recipeNameMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeNameMeta);
    }
    if (data.containsKey('fermentation_start')) {
      context.handle(
        _fermentationStartMeta,
        fermentationStart.isAcceptableOrUnknown(
          data['fermentation_start']!,
          _fermentationStartMeta,
        ),
      );
    }
    if (data.containsKey('fermentation_confirm')) {
      context.handle(
        _fermentationConfirmMeta,
        fermentationConfirm.isAcceptableOrUnknown(
          data['fermentation_confirm']!,
          _fermentationConfirmMeta,
        ),
      );
    }
    if (data.containsKey('boiling_start')) {
      context.handle(
        _boilingStartMeta,
        boilingStart.isAcceptableOrUnknown(
          data['boiling_start']!,
          _boilingStartMeta,
        ),
      );
    }
    if (data.containsKey('boiling_confirm')) {
      context.handle(
        _boilingConfirmMeta,
        boilingConfirm.isAcceptableOrUnknown(
          data['boiling_confirm']!,
          _boilingConfirmMeta,
        ),
      );
    }
    if (data.containsKey('steaming_start')) {
      context.handle(
        _steamingStartMeta,
        steamingStart.isAcceptableOrUnknown(
          data['steaming_start']!,
          _steamingStartMeta,
        ),
      );
    }
    if (data.containsKey('steaming_confirm')) {
      context.handle(
        _steamingConfirmMeta,
        steamingConfirm.isAcceptableOrUnknown(
          data['steaming_confirm']!,
          _steamingConfirmMeta,
        ),
      );
    }
    if (data.containsKey('simmering_start')) {
      context.handle(
        _simmeringStartMeta,
        simmeringStart.isAcceptableOrUnknown(
          data['simmering_start']!,
          _simmeringStartMeta,
        ),
      );
    }
    if (data.containsKey('uncover_confirm')) {
      context.handle(
        _uncoverConfirmMeta,
        uncoverConfirm.isAcceptableOrUnknown(
          data['uncover_confirm']!,
          _uncoverConfirmMeta,
        ),
      );
    }
    if (data.containsKey('fermentation_actual_minutes')) {
      context.handle(
        _fermentationActualMinutesMeta,
        fermentationActualMinutes.isAcceptableOrUnknown(
          data['fermentation_actual_minutes']!,
          _fermentationActualMinutesMeta,
        ),
      );
    }
    if (data.containsKey('fermentation_result')) {
      context.handle(
        _fermentationResultMeta,
        fermentationResult.isAcceptableOrUnknown(
          data['fermentation_result']!,
          _fermentationResultMeta,
        ),
      );
    }
    if (data.containsKey('low_confidence')) {
      context.handle(
        _lowConfidenceMeta,
        lowConfidence.isAcceptableOrUnknown(
          data['low_confidence']!,
          _lowConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('simmering_interval_minutes')) {
      context.handle(
        _simmeringIntervalMinutesMeta,
        simmeringIntervalMinutes.isAcceptableOrUnknown(
          data['simmering_interval_minutes']!,
          _simmeringIntervalMinutesMeta,
        ),
      );
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    }
    if (data.containsKey('humidity')) {
      context.handle(
        _humidityMeta,
        humidity.isAcceptableOrUnknown(data['humidity']!, _humidityMeta),
      );
    }
    if (data.containsKey('weather_source')) {
      context.handle(
        _weatherSourceMeta,
        weatherSource.isAcceptableOrUnknown(
          data['weather_source']!,
          _weatherSourceMeta,
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
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('adjustment_minutes')) {
      context.handle(
        _adjustmentMinutesMeta,
        adjustmentMinutes.isAcceptableOrUnknown(
          data['adjustment_minutes']!,
          _adjustmentMinutesMeta,
        ),
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
    if (data.containsKey('position_label')) {
      context.handle(
        _positionLabelMeta,
        positionLabel.isAcceptableOrUnknown(
          data['position_label']!,
          _positionLabelMeta,
        ),
      );
    }
    if (data.containsKey('boiling_reminder_delay_seconds')) {
      context.handle(
        _boilingReminderDelaySecondsMeta,
        boilingReminderDelaySeconds.isAcceptableOrUnknown(
          data['boiling_reminder_delay_seconds']!,
          _boilingReminderDelaySecondsMeta,
        ),
      );
    }
    if (data.containsKey('steaming_reminder_delay_seconds')) {
      context.handle(
        _steamingReminderDelaySecondsMeta,
        steamingReminderDelaySeconds.isAcceptableOrUnknown(
          data['steaming_reminder_delay_seconds']!,
          _steamingReminderDelaySecondsMeta,
        ),
      );
    }
    if (data.containsKey('extensions_log')) {
      context.handle(
        _extensionsLogMeta,
        extensionsLog.isAcceptableOrUnknown(
          data['extensions_log']!,
          _extensionsLogMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BatchRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatchRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_number'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      recipeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_name'],
      )!,
      fermentationStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fermentation_start'],
      ),
      fermentationConfirm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fermentation_confirm'],
      ),
      boilingStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}boiling_start'],
      ),
      boilingConfirm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}boiling_confirm'],
      ),
      steamingStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}steaming_start'],
      ),
      steamingConfirm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}steaming_confirm'],
      ),
      simmeringStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}simmering_start'],
      ),
      uncoverConfirm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}uncover_confirm'],
      ),
      fermentationActualMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fermentation_actual_minutes'],
      ),
      fermentationResult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fermentation_result'],
      ),
      lowConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}low_confidence'],
      )!,
      simmeringIntervalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}simmering_interval_minutes'],
      ),
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature'],
      ),
      humidity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}humidity'],
      ),
      weatherSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather_source'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season'],
      )!,
      adjustmentMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}adjustment_minutes'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      positionLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position_label'],
      ),
      boilingReminderDelaySeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}boiling_reminder_delay_seconds'],
      ),
      steamingReminderDelaySeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steaming_reminder_delay_seconds'],
      ),
      extensionsLog: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extensions_log'],
      ),
    );
  }

  @override
  $BatchRecordsTable createAlias(String alias) {
    return $BatchRecordsTable(attachedDatabase, alias);
  }
}

class BatchRecord extends DataClass implements Insertable<BatchRecord> {
  final String id;
  final int displayNumber;
  final String recipeId;
  final String recipeName;
  final DateTime? fermentationStart;
  final DateTime? fermentationConfirm;
  final DateTime? boilingStart;
  final DateTime? boilingConfirm;
  final DateTime? steamingStart;
  final DateTime? steamingConfirm;
  final DateTime? simmeringStart;
  final DateTime? uncoverConfirm;
  final int? fermentationActualMinutes;
  final String? fermentationResult;
  final bool lowConfidence;
  final int? simmeringIntervalMinutes;
  final double? temperature;
  final int? humidity;
  final String? weatherSource;
  final DateTime createdAt;
  final String season;
  final int adjustmentMinutes;
  final String status;
  final String? positionLabel;
  final int? boilingReminderDelaySeconds;
  final int? steamingReminderDelaySeconds;
  final String? extensionsLog;
  const BatchRecord({
    required this.id,
    required this.displayNumber,
    required this.recipeId,
    required this.recipeName,
    this.fermentationStart,
    this.fermentationConfirm,
    this.boilingStart,
    this.boilingConfirm,
    this.steamingStart,
    this.steamingConfirm,
    this.simmeringStart,
    this.uncoverConfirm,
    this.fermentationActualMinutes,
    this.fermentationResult,
    required this.lowConfidence,
    this.simmeringIntervalMinutes,
    this.temperature,
    this.humidity,
    this.weatherSource,
    required this.createdAt,
    required this.season,
    required this.adjustmentMinutes,
    required this.status,
    this.positionLabel,
    this.boilingReminderDelaySeconds,
    this.steamingReminderDelaySeconds,
    this.extensionsLog,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_number'] = Variable<int>(displayNumber);
    map['recipe_id'] = Variable<String>(recipeId);
    map['recipe_name'] = Variable<String>(recipeName);
    if (!nullToAbsent || fermentationStart != null) {
      map['fermentation_start'] = Variable<DateTime>(fermentationStart);
    }
    if (!nullToAbsent || fermentationConfirm != null) {
      map['fermentation_confirm'] = Variable<DateTime>(fermentationConfirm);
    }
    if (!nullToAbsent || boilingStart != null) {
      map['boiling_start'] = Variable<DateTime>(boilingStart);
    }
    if (!nullToAbsent || boilingConfirm != null) {
      map['boiling_confirm'] = Variable<DateTime>(boilingConfirm);
    }
    if (!nullToAbsent || steamingStart != null) {
      map['steaming_start'] = Variable<DateTime>(steamingStart);
    }
    if (!nullToAbsent || steamingConfirm != null) {
      map['steaming_confirm'] = Variable<DateTime>(steamingConfirm);
    }
    if (!nullToAbsent || simmeringStart != null) {
      map['simmering_start'] = Variable<DateTime>(simmeringStart);
    }
    if (!nullToAbsent || uncoverConfirm != null) {
      map['uncover_confirm'] = Variable<DateTime>(uncoverConfirm);
    }
    if (!nullToAbsent || fermentationActualMinutes != null) {
      map['fermentation_actual_minutes'] = Variable<int>(
        fermentationActualMinutes,
      );
    }
    if (!nullToAbsent || fermentationResult != null) {
      map['fermentation_result'] = Variable<String>(fermentationResult);
    }
    map['low_confidence'] = Variable<bool>(lowConfidence);
    if (!nullToAbsent || simmeringIntervalMinutes != null) {
      map['simmering_interval_minutes'] = Variable<int>(
        simmeringIntervalMinutes,
      );
    }
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<double>(temperature);
    }
    if (!nullToAbsent || humidity != null) {
      map['humidity'] = Variable<int>(humidity);
    }
    if (!nullToAbsent || weatherSource != null) {
      map['weather_source'] = Variable<String>(weatherSource);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['season'] = Variable<String>(season);
    map['adjustment_minutes'] = Variable<int>(adjustmentMinutes);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || positionLabel != null) {
      map['position_label'] = Variable<String>(positionLabel);
    }
    if (!nullToAbsent || boilingReminderDelaySeconds != null) {
      map['boiling_reminder_delay_seconds'] = Variable<int>(
        boilingReminderDelaySeconds,
      );
    }
    if (!nullToAbsent || steamingReminderDelaySeconds != null) {
      map['steaming_reminder_delay_seconds'] = Variable<int>(
        steamingReminderDelaySeconds,
      );
    }
    if (!nullToAbsent || extensionsLog != null) {
      map['extensions_log'] = Variable<String>(extensionsLog);
    }
    return map;
  }

  BatchRecordsCompanion toCompanion(bool nullToAbsent) {
    return BatchRecordsCompanion(
      id: Value(id),
      displayNumber: Value(displayNumber),
      recipeId: Value(recipeId),
      recipeName: Value(recipeName),
      fermentationStart: fermentationStart == null && nullToAbsent
          ? const Value.absent()
          : Value(fermentationStart),
      fermentationConfirm: fermentationConfirm == null && nullToAbsent
          ? const Value.absent()
          : Value(fermentationConfirm),
      boilingStart: boilingStart == null && nullToAbsent
          ? const Value.absent()
          : Value(boilingStart),
      boilingConfirm: boilingConfirm == null && nullToAbsent
          ? const Value.absent()
          : Value(boilingConfirm),
      steamingStart: steamingStart == null && nullToAbsent
          ? const Value.absent()
          : Value(steamingStart),
      steamingConfirm: steamingConfirm == null && nullToAbsent
          ? const Value.absent()
          : Value(steamingConfirm),
      simmeringStart: simmeringStart == null && nullToAbsent
          ? const Value.absent()
          : Value(simmeringStart),
      uncoverConfirm: uncoverConfirm == null && nullToAbsent
          ? const Value.absent()
          : Value(uncoverConfirm),
      fermentationActualMinutes:
          fermentationActualMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(fermentationActualMinutes),
      fermentationResult: fermentationResult == null && nullToAbsent
          ? const Value.absent()
          : Value(fermentationResult),
      lowConfidence: Value(lowConfidence),
      simmeringIntervalMinutes: simmeringIntervalMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(simmeringIntervalMinutes),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      humidity: humidity == null && nullToAbsent
          ? const Value.absent()
          : Value(humidity),
      weatherSource: weatherSource == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherSource),
      createdAt: Value(createdAt),
      season: Value(season),
      adjustmentMinutes: Value(adjustmentMinutes),
      status: Value(status),
      positionLabel: positionLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(positionLabel),
      boilingReminderDelaySeconds:
          boilingReminderDelaySeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(boilingReminderDelaySeconds),
      steamingReminderDelaySeconds:
          steamingReminderDelaySeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(steamingReminderDelaySeconds),
      extensionsLog: extensionsLog == null && nullToAbsent
          ? const Value.absent()
          : Value(extensionsLog),
    );
  }

  factory BatchRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatchRecord(
      id: serializer.fromJson<String>(json['id']),
      displayNumber: serializer.fromJson<int>(json['displayNumber']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      recipeName: serializer.fromJson<String>(json['recipeName']),
      fermentationStart: serializer.fromJson<DateTime?>(
        json['fermentationStart'],
      ),
      fermentationConfirm: serializer.fromJson<DateTime?>(
        json['fermentationConfirm'],
      ),
      boilingStart: serializer.fromJson<DateTime?>(json['boilingStart']),
      boilingConfirm: serializer.fromJson<DateTime?>(json['boilingConfirm']),
      steamingStart: serializer.fromJson<DateTime?>(json['steamingStart']),
      steamingConfirm: serializer.fromJson<DateTime?>(json['steamingConfirm']),
      simmeringStart: serializer.fromJson<DateTime?>(json['simmeringStart']),
      uncoverConfirm: serializer.fromJson<DateTime?>(json['uncoverConfirm']),
      fermentationActualMinutes: serializer.fromJson<int?>(
        json['fermentationActualMinutes'],
      ),
      fermentationResult: serializer.fromJson<String?>(
        json['fermentationResult'],
      ),
      lowConfidence: serializer.fromJson<bool>(json['lowConfidence']),
      simmeringIntervalMinutes: serializer.fromJson<int?>(
        json['simmeringIntervalMinutes'],
      ),
      temperature: serializer.fromJson<double?>(json['temperature']),
      humidity: serializer.fromJson<int?>(json['humidity']),
      weatherSource: serializer.fromJson<String?>(json['weatherSource']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      season: serializer.fromJson<String>(json['season']),
      adjustmentMinutes: serializer.fromJson<int>(json['adjustmentMinutes']),
      status: serializer.fromJson<String>(json['status']),
      positionLabel: serializer.fromJson<String?>(json['positionLabel']),
      boilingReminderDelaySeconds: serializer.fromJson<int?>(
        json['boilingReminderDelaySeconds'],
      ),
      steamingReminderDelaySeconds: serializer.fromJson<int?>(
        json['steamingReminderDelaySeconds'],
      ),
      extensionsLog: serializer.fromJson<String?>(json['extensionsLog']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayNumber': serializer.toJson<int>(displayNumber),
      'recipeId': serializer.toJson<String>(recipeId),
      'recipeName': serializer.toJson<String>(recipeName),
      'fermentationStart': serializer.toJson<DateTime?>(fermentationStart),
      'fermentationConfirm': serializer.toJson<DateTime?>(fermentationConfirm),
      'boilingStart': serializer.toJson<DateTime?>(boilingStart),
      'boilingConfirm': serializer.toJson<DateTime?>(boilingConfirm),
      'steamingStart': serializer.toJson<DateTime?>(steamingStart),
      'steamingConfirm': serializer.toJson<DateTime?>(steamingConfirm),
      'simmeringStart': serializer.toJson<DateTime?>(simmeringStart),
      'uncoverConfirm': serializer.toJson<DateTime?>(uncoverConfirm),
      'fermentationActualMinutes': serializer.toJson<int?>(
        fermentationActualMinutes,
      ),
      'fermentationResult': serializer.toJson<String?>(fermentationResult),
      'lowConfidence': serializer.toJson<bool>(lowConfidence),
      'simmeringIntervalMinutes': serializer.toJson<int?>(
        simmeringIntervalMinutes,
      ),
      'temperature': serializer.toJson<double?>(temperature),
      'humidity': serializer.toJson<int?>(humidity),
      'weatherSource': serializer.toJson<String?>(weatherSource),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'season': serializer.toJson<String>(season),
      'adjustmentMinutes': serializer.toJson<int>(adjustmentMinutes),
      'status': serializer.toJson<String>(status),
      'positionLabel': serializer.toJson<String?>(positionLabel),
      'boilingReminderDelaySeconds': serializer.toJson<int?>(
        boilingReminderDelaySeconds,
      ),
      'steamingReminderDelaySeconds': serializer.toJson<int?>(
        steamingReminderDelaySeconds,
      ),
      'extensionsLog': serializer.toJson<String?>(extensionsLog),
    };
  }

  BatchRecord copyWith({
    String? id,
    int? displayNumber,
    String? recipeId,
    String? recipeName,
    Value<DateTime?> fermentationStart = const Value.absent(),
    Value<DateTime?> fermentationConfirm = const Value.absent(),
    Value<DateTime?> boilingStart = const Value.absent(),
    Value<DateTime?> boilingConfirm = const Value.absent(),
    Value<DateTime?> steamingStart = const Value.absent(),
    Value<DateTime?> steamingConfirm = const Value.absent(),
    Value<DateTime?> simmeringStart = const Value.absent(),
    Value<DateTime?> uncoverConfirm = const Value.absent(),
    Value<int?> fermentationActualMinutes = const Value.absent(),
    Value<String?> fermentationResult = const Value.absent(),
    bool? lowConfidence,
    Value<int?> simmeringIntervalMinutes = const Value.absent(),
    Value<double?> temperature = const Value.absent(),
    Value<int?> humidity = const Value.absent(),
    Value<String?> weatherSource = const Value.absent(),
    DateTime? createdAt,
    String? season,
    int? adjustmentMinutes,
    String? status,
    Value<String?> positionLabel = const Value.absent(),
    Value<int?> boilingReminderDelaySeconds = const Value.absent(),
    Value<int?> steamingReminderDelaySeconds = const Value.absent(),
    Value<String?> extensionsLog = const Value.absent(),
  }) => BatchRecord(
    id: id ?? this.id,
    displayNumber: displayNumber ?? this.displayNumber,
    recipeId: recipeId ?? this.recipeId,
    recipeName: recipeName ?? this.recipeName,
    fermentationStart: fermentationStart.present
        ? fermentationStart.value
        : this.fermentationStart,
    fermentationConfirm: fermentationConfirm.present
        ? fermentationConfirm.value
        : this.fermentationConfirm,
    boilingStart: boilingStart.present ? boilingStart.value : this.boilingStart,
    boilingConfirm: boilingConfirm.present
        ? boilingConfirm.value
        : this.boilingConfirm,
    steamingStart: steamingStart.present
        ? steamingStart.value
        : this.steamingStart,
    steamingConfirm: steamingConfirm.present
        ? steamingConfirm.value
        : this.steamingConfirm,
    simmeringStart: simmeringStart.present
        ? simmeringStart.value
        : this.simmeringStart,
    uncoverConfirm: uncoverConfirm.present
        ? uncoverConfirm.value
        : this.uncoverConfirm,
    fermentationActualMinutes: fermentationActualMinutes.present
        ? fermentationActualMinutes.value
        : this.fermentationActualMinutes,
    fermentationResult: fermentationResult.present
        ? fermentationResult.value
        : this.fermentationResult,
    lowConfidence: lowConfidence ?? this.lowConfidence,
    simmeringIntervalMinutes: simmeringIntervalMinutes.present
        ? simmeringIntervalMinutes.value
        : this.simmeringIntervalMinutes,
    temperature: temperature.present ? temperature.value : this.temperature,
    humidity: humidity.present ? humidity.value : this.humidity,
    weatherSource: weatherSource.present
        ? weatherSource.value
        : this.weatherSource,
    createdAt: createdAt ?? this.createdAt,
    season: season ?? this.season,
    adjustmentMinutes: adjustmentMinutes ?? this.adjustmentMinutes,
    status: status ?? this.status,
    positionLabel: positionLabel.present
        ? positionLabel.value
        : this.positionLabel,
    boilingReminderDelaySeconds: boilingReminderDelaySeconds.present
        ? boilingReminderDelaySeconds.value
        : this.boilingReminderDelaySeconds,
    steamingReminderDelaySeconds: steamingReminderDelaySeconds.present
        ? steamingReminderDelaySeconds.value
        : this.steamingReminderDelaySeconds,
    extensionsLog: extensionsLog.present
        ? extensionsLog.value
        : this.extensionsLog,
  );
  BatchRecord copyWithCompanion(BatchRecordsCompanion data) {
    return BatchRecord(
      id: data.id.present ? data.id.value : this.id,
      displayNumber: data.displayNumber.present
          ? data.displayNumber.value
          : this.displayNumber,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      recipeName: data.recipeName.present
          ? data.recipeName.value
          : this.recipeName,
      fermentationStart: data.fermentationStart.present
          ? data.fermentationStart.value
          : this.fermentationStart,
      fermentationConfirm: data.fermentationConfirm.present
          ? data.fermentationConfirm.value
          : this.fermentationConfirm,
      boilingStart: data.boilingStart.present
          ? data.boilingStart.value
          : this.boilingStart,
      boilingConfirm: data.boilingConfirm.present
          ? data.boilingConfirm.value
          : this.boilingConfirm,
      steamingStart: data.steamingStart.present
          ? data.steamingStart.value
          : this.steamingStart,
      steamingConfirm: data.steamingConfirm.present
          ? data.steamingConfirm.value
          : this.steamingConfirm,
      simmeringStart: data.simmeringStart.present
          ? data.simmeringStart.value
          : this.simmeringStart,
      uncoverConfirm: data.uncoverConfirm.present
          ? data.uncoverConfirm.value
          : this.uncoverConfirm,
      fermentationActualMinutes: data.fermentationActualMinutes.present
          ? data.fermentationActualMinutes.value
          : this.fermentationActualMinutes,
      fermentationResult: data.fermentationResult.present
          ? data.fermentationResult.value
          : this.fermentationResult,
      lowConfidence: data.lowConfidence.present
          ? data.lowConfidence.value
          : this.lowConfidence,
      simmeringIntervalMinutes: data.simmeringIntervalMinutes.present
          ? data.simmeringIntervalMinutes.value
          : this.simmeringIntervalMinutes,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      humidity: data.humidity.present ? data.humidity.value : this.humidity,
      weatherSource: data.weatherSource.present
          ? data.weatherSource.value
          : this.weatherSource,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      season: data.season.present ? data.season.value : this.season,
      adjustmentMinutes: data.adjustmentMinutes.present
          ? data.adjustmentMinutes.value
          : this.adjustmentMinutes,
      status: data.status.present ? data.status.value : this.status,
      positionLabel: data.positionLabel.present
          ? data.positionLabel.value
          : this.positionLabel,
      boilingReminderDelaySeconds: data.boilingReminderDelaySeconds.present
          ? data.boilingReminderDelaySeconds.value
          : this.boilingReminderDelaySeconds,
      steamingReminderDelaySeconds: data.steamingReminderDelaySeconds.present
          ? data.steamingReminderDelaySeconds.value
          : this.steamingReminderDelaySeconds,
      extensionsLog: data.extensionsLog.present
          ? data.extensionsLog.value
          : this.extensionsLog,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatchRecord(')
          ..write('id: $id, ')
          ..write('displayNumber: $displayNumber, ')
          ..write('recipeId: $recipeId, ')
          ..write('recipeName: $recipeName, ')
          ..write('fermentationStart: $fermentationStart, ')
          ..write('fermentationConfirm: $fermentationConfirm, ')
          ..write('boilingStart: $boilingStart, ')
          ..write('boilingConfirm: $boilingConfirm, ')
          ..write('steamingStart: $steamingStart, ')
          ..write('steamingConfirm: $steamingConfirm, ')
          ..write('simmeringStart: $simmeringStart, ')
          ..write('uncoverConfirm: $uncoverConfirm, ')
          ..write('fermentationActualMinutes: $fermentationActualMinutes, ')
          ..write('fermentationResult: $fermentationResult, ')
          ..write('lowConfidence: $lowConfidence, ')
          ..write('simmeringIntervalMinutes: $simmeringIntervalMinutes, ')
          ..write('temperature: $temperature, ')
          ..write('humidity: $humidity, ')
          ..write('weatherSource: $weatherSource, ')
          ..write('createdAt: $createdAt, ')
          ..write('season: $season, ')
          ..write('adjustmentMinutes: $adjustmentMinutes, ')
          ..write('status: $status, ')
          ..write('positionLabel: $positionLabel, ')
          ..write('boilingReminderDelaySeconds: $boilingReminderDelaySeconds, ')
          ..write(
            'steamingReminderDelaySeconds: $steamingReminderDelaySeconds, ',
          )
          ..write('extensionsLog: $extensionsLog')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    displayNumber,
    recipeId,
    recipeName,
    fermentationStart,
    fermentationConfirm,
    boilingStart,
    boilingConfirm,
    steamingStart,
    steamingConfirm,
    simmeringStart,
    uncoverConfirm,
    fermentationActualMinutes,
    fermentationResult,
    lowConfidence,
    simmeringIntervalMinutes,
    temperature,
    humidity,
    weatherSource,
    createdAt,
    season,
    adjustmentMinutes,
    status,
    positionLabel,
    boilingReminderDelaySeconds,
    steamingReminderDelaySeconds,
    extensionsLog,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatchRecord &&
          other.id == this.id &&
          other.displayNumber == this.displayNumber &&
          other.recipeId == this.recipeId &&
          other.recipeName == this.recipeName &&
          other.fermentationStart == this.fermentationStart &&
          other.fermentationConfirm == this.fermentationConfirm &&
          other.boilingStart == this.boilingStart &&
          other.boilingConfirm == this.boilingConfirm &&
          other.steamingStart == this.steamingStart &&
          other.steamingConfirm == this.steamingConfirm &&
          other.simmeringStart == this.simmeringStart &&
          other.uncoverConfirm == this.uncoverConfirm &&
          other.fermentationActualMinutes == this.fermentationActualMinutes &&
          other.fermentationResult == this.fermentationResult &&
          other.lowConfidence == this.lowConfidence &&
          other.simmeringIntervalMinutes == this.simmeringIntervalMinutes &&
          other.temperature == this.temperature &&
          other.humidity == this.humidity &&
          other.weatherSource == this.weatherSource &&
          other.createdAt == this.createdAt &&
          other.season == this.season &&
          other.adjustmentMinutes == this.adjustmentMinutes &&
          other.status == this.status &&
          other.positionLabel == this.positionLabel &&
          other.boilingReminderDelaySeconds ==
              this.boilingReminderDelaySeconds &&
          other.steamingReminderDelaySeconds ==
              this.steamingReminderDelaySeconds &&
          other.extensionsLog == this.extensionsLog);
}

class BatchRecordsCompanion extends UpdateCompanion<BatchRecord> {
  final Value<String> id;
  final Value<int> displayNumber;
  final Value<String> recipeId;
  final Value<String> recipeName;
  final Value<DateTime?> fermentationStart;
  final Value<DateTime?> fermentationConfirm;
  final Value<DateTime?> boilingStart;
  final Value<DateTime?> boilingConfirm;
  final Value<DateTime?> steamingStart;
  final Value<DateTime?> steamingConfirm;
  final Value<DateTime?> simmeringStart;
  final Value<DateTime?> uncoverConfirm;
  final Value<int?> fermentationActualMinutes;
  final Value<String?> fermentationResult;
  final Value<bool> lowConfidence;
  final Value<int?> simmeringIntervalMinutes;
  final Value<double?> temperature;
  final Value<int?> humidity;
  final Value<String?> weatherSource;
  final Value<DateTime> createdAt;
  final Value<String> season;
  final Value<int> adjustmentMinutes;
  final Value<String> status;
  final Value<String?> positionLabel;
  final Value<int?> boilingReminderDelaySeconds;
  final Value<int?> steamingReminderDelaySeconds;
  final Value<String?> extensionsLog;
  final Value<int> rowid;
  const BatchRecordsCompanion({
    this.id = const Value.absent(),
    this.displayNumber = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.recipeName = const Value.absent(),
    this.fermentationStart = const Value.absent(),
    this.fermentationConfirm = const Value.absent(),
    this.boilingStart = const Value.absent(),
    this.boilingConfirm = const Value.absent(),
    this.steamingStart = const Value.absent(),
    this.steamingConfirm = const Value.absent(),
    this.simmeringStart = const Value.absent(),
    this.uncoverConfirm = const Value.absent(),
    this.fermentationActualMinutes = const Value.absent(),
    this.fermentationResult = const Value.absent(),
    this.lowConfidence = const Value.absent(),
    this.simmeringIntervalMinutes = const Value.absent(),
    this.temperature = const Value.absent(),
    this.humidity = const Value.absent(),
    this.weatherSource = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.season = const Value.absent(),
    this.adjustmentMinutes = const Value.absent(),
    this.status = const Value.absent(),
    this.positionLabel = const Value.absent(),
    this.boilingReminderDelaySeconds = const Value.absent(),
    this.steamingReminderDelaySeconds = const Value.absent(),
    this.extensionsLog = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatchRecordsCompanion.insert({
    required String id,
    required int displayNumber,
    required String recipeId,
    required String recipeName,
    this.fermentationStart = const Value.absent(),
    this.fermentationConfirm = const Value.absent(),
    this.boilingStart = const Value.absent(),
    this.boilingConfirm = const Value.absent(),
    this.steamingStart = const Value.absent(),
    this.steamingConfirm = const Value.absent(),
    this.simmeringStart = const Value.absent(),
    this.uncoverConfirm = const Value.absent(),
    this.fermentationActualMinutes = const Value.absent(),
    this.fermentationResult = const Value.absent(),
    this.lowConfidence = const Value.absent(),
    this.simmeringIntervalMinutes = const Value.absent(),
    this.temperature = const Value.absent(),
    this.humidity = const Value.absent(),
    this.weatherSource = const Value.absent(),
    required DateTime createdAt,
    required String season,
    this.adjustmentMinutes = const Value.absent(),
    required String status,
    this.positionLabel = const Value.absent(),
    this.boilingReminderDelaySeconds = const Value.absent(),
    this.steamingReminderDelaySeconds = const Value.absent(),
    this.extensionsLog = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayNumber = Value(displayNumber),
       recipeId = Value(recipeId),
       recipeName = Value(recipeName),
       createdAt = Value(createdAt),
       season = Value(season),
       status = Value(status);
  static Insertable<BatchRecord> custom({
    Expression<String>? id,
    Expression<int>? displayNumber,
    Expression<String>? recipeId,
    Expression<String>? recipeName,
    Expression<DateTime>? fermentationStart,
    Expression<DateTime>? fermentationConfirm,
    Expression<DateTime>? boilingStart,
    Expression<DateTime>? boilingConfirm,
    Expression<DateTime>? steamingStart,
    Expression<DateTime>? steamingConfirm,
    Expression<DateTime>? simmeringStart,
    Expression<DateTime>? uncoverConfirm,
    Expression<int>? fermentationActualMinutes,
    Expression<String>? fermentationResult,
    Expression<bool>? lowConfidence,
    Expression<int>? simmeringIntervalMinutes,
    Expression<double>? temperature,
    Expression<int>? humidity,
    Expression<String>? weatherSource,
    Expression<DateTime>? createdAt,
    Expression<String>? season,
    Expression<int>? adjustmentMinutes,
    Expression<String>? status,
    Expression<String>? positionLabel,
    Expression<int>? boilingReminderDelaySeconds,
    Expression<int>? steamingReminderDelaySeconds,
    Expression<String>? extensionsLog,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayNumber != null) 'display_number': displayNumber,
      if (recipeId != null) 'recipe_id': recipeId,
      if (recipeName != null) 'recipe_name': recipeName,
      if (fermentationStart != null) 'fermentation_start': fermentationStart,
      if (fermentationConfirm != null)
        'fermentation_confirm': fermentationConfirm,
      if (boilingStart != null) 'boiling_start': boilingStart,
      if (boilingConfirm != null) 'boiling_confirm': boilingConfirm,
      if (steamingStart != null) 'steaming_start': steamingStart,
      if (steamingConfirm != null) 'steaming_confirm': steamingConfirm,
      if (simmeringStart != null) 'simmering_start': simmeringStart,
      if (uncoverConfirm != null) 'uncover_confirm': uncoverConfirm,
      if (fermentationActualMinutes != null)
        'fermentation_actual_minutes': fermentationActualMinutes,
      if (fermentationResult != null) 'fermentation_result': fermentationResult,
      if (lowConfidence != null) 'low_confidence': lowConfidence,
      if (simmeringIntervalMinutes != null)
        'simmering_interval_minutes': simmeringIntervalMinutes,
      if (temperature != null) 'temperature': temperature,
      if (humidity != null) 'humidity': humidity,
      if (weatherSource != null) 'weather_source': weatherSource,
      if (createdAt != null) 'created_at': createdAt,
      if (season != null) 'season': season,
      if (adjustmentMinutes != null) 'adjustment_minutes': adjustmentMinutes,
      if (status != null) 'status': status,
      if (positionLabel != null) 'position_label': positionLabel,
      if (boilingReminderDelaySeconds != null)
        'boiling_reminder_delay_seconds': boilingReminderDelaySeconds,
      if (steamingReminderDelaySeconds != null)
        'steaming_reminder_delay_seconds': steamingReminderDelaySeconds,
      if (extensionsLog != null) 'extensions_log': extensionsLog,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatchRecordsCompanion copyWith({
    Value<String>? id,
    Value<int>? displayNumber,
    Value<String>? recipeId,
    Value<String>? recipeName,
    Value<DateTime?>? fermentationStart,
    Value<DateTime?>? fermentationConfirm,
    Value<DateTime?>? boilingStart,
    Value<DateTime?>? boilingConfirm,
    Value<DateTime?>? steamingStart,
    Value<DateTime?>? steamingConfirm,
    Value<DateTime?>? simmeringStart,
    Value<DateTime?>? uncoverConfirm,
    Value<int?>? fermentationActualMinutes,
    Value<String?>? fermentationResult,
    Value<bool>? lowConfidence,
    Value<int?>? simmeringIntervalMinutes,
    Value<double?>? temperature,
    Value<int?>? humidity,
    Value<String?>? weatherSource,
    Value<DateTime>? createdAt,
    Value<String>? season,
    Value<int>? adjustmentMinutes,
    Value<String>? status,
    Value<String?>? positionLabel,
    Value<int?>? boilingReminderDelaySeconds,
    Value<int?>? steamingReminderDelaySeconds,
    Value<String?>? extensionsLog,
    Value<int>? rowid,
  }) {
    return BatchRecordsCompanion(
      id: id ?? this.id,
      displayNumber: displayNumber ?? this.displayNumber,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      fermentationStart: fermentationStart ?? this.fermentationStart,
      fermentationConfirm: fermentationConfirm ?? this.fermentationConfirm,
      boilingStart: boilingStart ?? this.boilingStart,
      boilingConfirm: boilingConfirm ?? this.boilingConfirm,
      steamingStart: steamingStart ?? this.steamingStart,
      steamingConfirm: steamingConfirm ?? this.steamingConfirm,
      simmeringStart: simmeringStart ?? this.simmeringStart,
      uncoverConfirm: uncoverConfirm ?? this.uncoverConfirm,
      fermentationActualMinutes:
          fermentationActualMinutes ?? this.fermentationActualMinutes,
      fermentationResult: fermentationResult ?? this.fermentationResult,
      lowConfidence: lowConfidence ?? this.lowConfidence,
      simmeringIntervalMinutes:
          simmeringIntervalMinutes ?? this.simmeringIntervalMinutes,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      weatherSource: weatherSource ?? this.weatherSource,
      createdAt: createdAt ?? this.createdAt,
      season: season ?? this.season,
      adjustmentMinutes: adjustmentMinutes ?? this.adjustmentMinutes,
      status: status ?? this.status,
      positionLabel: positionLabel ?? this.positionLabel,
      boilingReminderDelaySeconds:
          boilingReminderDelaySeconds ?? this.boilingReminderDelaySeconds,
      steamingReminderDelaySeconds:
          steamingReminderDelaySeconds ?? this.steamingReminderDelaySeconds,
      extensionsLog: extensionsLog ?? this.extensionsLog,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayNumber.present) {
      map['display_number'] = Variable<int>(displayNumber.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (recipeName.present) {
      map['recipe_name'] = Variable<String>(recipeName.value);
    }
    if (fermentationStart.present) {
      map['fermentation_start'] = Variable<DateTime>(fermentationStart.value);
    }
    if (fermentationConfirm.present) {
      map['fermentation_confirm'] = Variable<DateTime>(
        fermentationConfirm.value,
      );
    }
    if (boilingStart.present) {
      map['boiling_start'] = Variable<DateTime>(boilingStart.value);
    }
    if (boilingConfirm.present) {
      map['boiling_confirm'] = Variable<DateTime>(boilingConfirm.value);
    }
    if (steamingStart.present) {
      map['steaming_start'] = Variable<DateTime>(steamingStart.value);
    }
    if (steamingConfirm.present) {
      map['steaming_confirm'] = Variable<DateTime>(steamingConfirm.value);
    }
    if (simmeringStart.present) {
      map['simmering_start'] = Variable<DateTime>(simmeringStart.value);
    }
    if (uncoverConfirm.present) {
      map['uncover_confirm'] = Variable<DateTime>(uncoverConfirm.value);
    }
    if (fermentationActualMinutes.present) {
      map['fermentation_actual_minutes'] = Variable<int>(
        fermentationActualMinutes.value,
      );
    }
    if (fermentationResult.present) {
      map['fermentation_result'] = Variable<String>(fermentationResult.value);
    }
    if (lowConfidence.present) {
      map['low_confidence'] = Variable<bool>(lowConfidence.value);
    }
    if (simmeringIntervalMinutes.present) {
      map['simmering_interval_minutes'] = Variable<int>(
        simmeringIntervalMinutes.value,
      );
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (humidity.present) {
      map['humidity'] = Variable<int>(humidity.value);
    }
    if (weatherSource.present) {
      map['weather_source'] = Variable<String>(weatherSource.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (adjustmentMinutes.present) {
      map['adjustment_minutes'] = Variable<int>(adjustmentMinutes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (positionLabel.present) {
      map['position_label'] = Variable<String>(positionLabel.value);
    }
    if (boilingReminderDelaySeconds.present) {
      map['boiling_reminder_delay_seconds'] = Variable<int>(
        boilingReminderDelaySeconds.value,
      );
    }
    if (steamingReminderDelaySeconds.present) {
      map['steaming_reminder_delay_seconds'] = Variable<int>(
        steamingReminderDelaySeconds.value,
      );
    }
    if (extensionsLog.present) {
      map['extensions_log'] = Variable<String>(extensionsLog.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchRecordsCompanion(')
          ..write('id: $id, ')
          ..write('displayNumber: $displayNumber, ')
          ..write('recipeId: $recipeId, ')
          ..write('recipeName: $recipeName, ')
          ..write('fermentationStart: $fermentationStart, ')
          ..write('fermentationConfirm: $fermentationConfirm, ')
          ..write('boilingStart: $boilingStart, ')
          ..write('boilingConfirm: $boilingConfirm, ')
          ..write('steamingStart: $steamingStart, ')
          ..write('steamingConfirm: $steamingConfirm, ')
          ..write('simmeringStart: $simmeringStart, ')
          ..write('uncoverConfirm: $uncoverConfirm, ')
          ..write('fermentationActualMinutes: $fermentationActualMinutes, ')
          ..write('fermentationResult: $fermentationResult, ')
          ..write('lowConfidence: $lowConfidence, ')
          ..write('simmeringIntervalMinutes: $simmeringIntervalMinutes, ')
          ..write('temperature: $temperature, ')
          ..write('humidity: $humidity, ')
          ..write('weatherSource: $weatherSource, ')
          ..write('createdAt: $createdAt, ')
          ..write('season: $season, ')
          ..write('adjustmentMinutes: $adjustmentMinutes, ')
          ..write('status: $status, ')
          ..write('positionLabel: $positionLabel, ')
          ..write('boilingReminderDelaySeconds: $boilingReminderDelaySeconds, ')
          ..write(
            'steamingReminderDelaySeconds: $steamingReminderDelaySeconds, ',
          )
          ..write('extensionsLog: $extensionsLog, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeRecordsTable extends RecipeRecords
    with TableInfo<$RecipeRecordsTable, RecipeRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _announcementNameMeta = const VerificationMeta(
    'announcementName',
  );
  @override
  late final GeneratedColumn<String> announcementName = GeneratedColumn<String>(
    'announcement_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepsJsonMeta = const VerificationMeta(
    'stepsJson',
  );
  @override
  late final GeneratedColumn<String> stepsJson = GeneratedColumn<String>(
    'steps_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fermentationRangeMinMeta =
      const VerificationMeta('fermentationRangeMin');
  @override
  late final GeneratedColumn<int> fermentationRangeMin = GeneratedColumn<int>(
    'fermentation_range_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fermentationRangeMaxMeta =
      const VerificationMeta('fermentationRangeMax');
  @override
  late final GeneratedColumn<int> fermentationRangeMax = GeneratedColumn<int>(
    'fermentation_range_max',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPresetMeta = const VerificationMeta(
    'isPreset',
  );
  @override
  late final GeneratedColumn<bool> isPreset = GeneratedColumn<bool>(
    'is_preset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_preset" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    name,
    announcementName,
    stepsJson,
    fermentationRangeMin,
    fermentationRangeMax,
    isPreset,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeRecord> instance, {
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
    if (data.containsKey('announcement_name')) {
      context.handle(
        _announcementNameMeta,
        announcementName.isAcceptableOrUnknown(
          data['announcement_name']!,
          _announcementNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_announcementNameMeta);
    }
    if (data.containsKey('steps_json')) {
      context.handle(
        _stepsJsonMeta,
        stepsJson.isAcceptableOrUnknown(data['steps_json']!, _stepsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_stepsJsonMeta);
    }
    if (data.containsKey('fermentation_range_min')) {
      context.handle(
        _fermentationRangeMinMeta,
        fermentationRangeMin.isAcceptableOrUnknown(
          data['fermentation_range_min']!,
          _fermentationRangeMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fermentationRangeMinMeta);
    }
    if (data.containsKey('fermentation_range_max')) {
      context.handle(
        _fermentationRangeMaxMeta,
        fermentationRangeMax.isAcceptableOrUnknown(
          data['fermentation_range_max']!,
          _fermentationRangeMaxMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fermentationRangeMaxMeta);
    }
    if (data.containsKey('is_preset')) {
      context.handle(
        _isPresetMeta,
        isPreset.isAcceptableOrUnknown(data['is_preset']!, _isPresetMeta),
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
  RecipeRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      announcementName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}announcement_name'],
      )!,
      stepsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}steps_json'],
      )!,
      fermentationRangeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fermentation_range_min'],
      )!,
      fermentationRangeMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fermentation_range_max'],
      )!,
      isPreset: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_preset'],
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
  $RecipeRecordsTable createAlias(String alias) {
    return $RecipeRecordsTable(attachedDatabase, alias);
  }
}

class RecipeRecord extends DataClass implements Insertable<RecipeRecord> {
  final String id;
  final String name;
  final String announcementName;
  final String stepsJson;
  final int fermentationRangeMin;
  final int fermentationRangeMax;
  final bool isPreset;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RecipeRecord({
    required this.id,
    required this.name,
    required this.announcementName,
    required this.stepsJson,
    required this.fermentationRangeMin,
    required this.fermentationRangeMax,
    required this.isPreset,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['announcement_name'] = Variable<String>(announcementName);
    map['steps_json'] = Variable<String>(stepsJson);
    map['fermentation_range_min'] = Variable<int>(fermentationRangeMin);
    map['fermentation_range_max'] = Variable<int>(fermentationRangeMax);
    map['is_preset'] = Variable<bool>(isPreset);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RecipeRecordsCompanion toCompanion(bool nullToAbsent) {
    return RecipeRecordsCompanion(
      id: Value(id),
      name: Value(name),
      announcementName: Value(announcementName),
      stepsJson: Value(stepsJson),
      fermentationRangeMin: Value(fermentationRangeMin),
      fermentationRangeMax: Value(fermentationRangeMax),
      isPreset: Value(isPreset),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RecipeRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      announcementName: serializer.fromJson<String>(json['announcementName']),
      stepsJson: serializer.fromJson<String>(json['stepsJson']),
      fermentationRangeMin: serializer.fromJson<int>(
        json['fermentationRangeMin'],
      ),
      fermentationRangeMax: serializer.fromJson<int>(
        json['fermentationRangeMax'],
      ),
      isPreset: serializer.fromJson<bool>(json['isPreset']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'announcementName': serializer.toJson<String>(announcementName),
      'stepsJson': serializer.toJson<String>(stepsJson),
      'fermentationRangeMin': serializer.toJson<int>(fermentationRangeMin),
      'fermentationRangeMax': serializer.toJson<int>(fermentationRangeMax),
      'isPreset': serializer.toJson<bool>(isPreset),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RecipeRecord copyWith({
    String? id,
    String? name,
    String? announcementName,
    String? stepsJson,
    int? fermentationRangeMin,
    int? fermentationRangeMax,
    bool? isPreset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RecipeRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    announcementName: announcementName ?? this.announcementName,
    stepsJson: stepsJson ?? this.stepsJson,
    fermentationRangeMin: fermentationRangeMin ?? this.fermentationRangeMin,
    fermentationRangeMax: fermentationRangeMax ?? this.fermentationRangeMax,
    isPreset: isPreset ?? this.isPreset,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RecipeRecord copyWithCompanion(RecipeRecordsCompanion data) {
    return RecipeRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      announcementName: data.announcementName.present
          ? data.announcementName.value
          : this.announcementName,
      stepsJson: data.stepsJson.present ? data.stepsJson.value : this.stepsJson,
      fermentationRangeMin: data.fermentationRangeMin.present
          ? data.fermentationRangeMin.value
          : this.fermentationRangeMin,
      fermentationRangeMax: data.fermentationRangeMax.present
          ? data.fermentationRangeMax.value
          : this.fermentationRangeMax,
      isPreset: data.isPreset.present ? data.isPreset.value : this.isPreset,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('announcementName: $announcementName, ')
          ..write('stepsJson: $stepsJson, ')
          ..write('fermentationRangeMin: $fermentationRangeMin, ')
          ..write('fermentationRangeMax: $fermentationRangeMax, ')
          ..write('isPreset: $isPreset, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    announcementName,
    stepsJson,
    fermentationRangeMin,
    fermentationRangeMax,
    isPreset,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.announcementName == this.announcementName &&
          other.stepsJson == this.stepsJson &&
          other.fermentationRangeMin == this.fermentationRangeMin &&
          other.fermentationRangeMax == this.fermentationRangeMax &&
          other.isPreset == this.isPreset &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecipeRecordsCompanion extends UpdateCompanion<RecipeRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> announcementName;
  final Value<String> stepsJson;
  final Value<int> fermentationRangeMin;
  final Value<int> fermentationRangeMax;
  final Value<bool> isPreset;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RecipeRecordsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.announcementName = const Value.absent(),
    this.stepsJson = const Value.absent(),
    this.fermentationRangeMin = const Value.absent(),
    this.fermentationRangeMax = const Value.absent(),
    this.isPreset = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeRecordsCompanion.insert({
    required String id,
    required String name,
    required String announcementName,
    required String stepsJson,
    required int fermentationRangeMin,
    required int fermentationRangeMax,
    this.isPreset = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       announcementName = Value(announcementName),
       stepsJson = Value(stepsJson),
       fermentationRangeMin = Value(fermentationRangeMin),
       fermentationRangeMax = Value(fermentationRangeMax),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RecipeRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? announcementName,
    Expression<String>? stepsJson,
    Expression<int>? fermentationRangeMin,
    Expression<int>? fermentationRangeMax,
    Expression<bool>? isPreset,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (announcementName != null) 'announcement_name': announcementName,
      if (stepsJson != null) 'steps_json': stepsJson,
      if (fermentationRangeMin != null)
        'fermentation_range_min': fermentationRangeMin,
      if (fermentationRangeMax != null)
        'fermentation_range_max': fermentationRangeMax,
      if (isPreset != null) 'is_preset': isPreset,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? announcementName,
    Value<String>? stepsJson,
    Value<int>? fermentationRangeMin,
    Value<int>? fermentationRangeMax,
    Value<bool>? isPreset,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RecipeRecordsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      announcementName: announcementName ?? this.announcementName,
      stepsJson: stepsJson ?? this.stepsJson,
      fermentationRangeMin: fermentationRangeMin ?? this.fermentationRangeMin,
      fermentationRangeMax: fermentationRangeMax ?? this.fermentationRangeMax,
      isPreset: isPreset ?? this.isPreset,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (announcementName.present) {
      map['announcement_name'] = Variable<String>(announcementName.value);
    }
    if (stepsJson.present) {
      map['steps_json'] = Variable<String>(stepsJson.value);
    }
    if (fermentationRangeMin.present) {
      map['fermentation_range_min'] = Variable<int>(fermentationRangeMin.value);
    }
    if (fermentationRangeMax.present) {
      map['fermentation_range_max'] = Variable<int>(fermentationRangeMax.value);
    }
    if (isPreset.present) {
      map['is_preset'] = Variable<bool>(isPreset.value);
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
    return (StringBuffer('RecipeRecordsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('announcementName: $announcementName, ')
          ..write('stepsJson: $stepsJson, ')
          ..write('fermentationRangeMin: $fermentationRangeMin, ')
          ..write('fermentationRangeMax: $fermentationRangeMax, ')
          ..write('isPreset: $isPreset, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitDefaultsTable extends HabitDefaults
    with TableInfo<$HabitDefaultsTable, HabitDefault> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitDefaultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperatureRangeLowMeta =
      const VerificationMeta('temperatureRangeLow');
  @override
  late final GeneratedColumn<int> temperatureRangeLow = GeneratedColumn<int>(
    'temperature_range_low',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperatureRangeHighMeta =
      const VerificationMeta('temperatureRangeHigh');
  @override
  late final GeneratedColumn<int> temperatureRangeHigh = GeneratedColumn<int>(
    'temperature_range_high',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultMinutesMeta = const VerificationMeta(
    'defaultMinutes',
  );
  @override
  late final GeneratedColumn<int> defaultMinutes = GeneratedColumn<int>(
    'default_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consecutiveCountMeta = const VerificationMeta(
    'consecutiveCount',
  );
  @override
  late final GeneratedColumn<int> consecutiveCount = GeneratedColumn<int>(
    'consecutive_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    recipeId,
    temperatureRangeLow,
    temperatureRangeHigh,
    defaultMinutes,
    consecutiveCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_defaults';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitDefault> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('temperature_range_low')) {
      context.handle(
        _temperatureRangeLowMeta,
        temperatureRangeLow.isAcceptableOrUnknown(
          data['temperature_range_low']!,
          _temperatureRangeLowMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperatureRangeLowMeta);
    }
    if (data.containsKey('temperature_range_high')) {
      context.handle(
        _temperatureRangeHighMeta,
        temperatureRangeHigh.isAcceptableOrUnknown(
          data['temperature_range_high']!,
          _temperatureRangeHighMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperatureRangeHighMeta);
    }
    if (data.containsKey('default_minutes')) {
      context.handle(
        _defaultMinutesMeta,
        defaultMinutes.isAcceptableOrUnknown(
          data['default_minutes']!,
          _defaultMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultMinutesMeta);
    }
    if (data.containsKey('consecutive_count')) {
      context.handle(
        _consecutiveCountMeta,
        consecutiveCount.isAcceptableOrUnknown(
          data['consecutive_count']!,
          _consecutiveCountMeta,
        ),
      );
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
  Set<GeneratedColumn> get $primaryKey => {
    recipeId,
    temperatureRangeLow,
    temperatureRangeHigh,
  };
  @override
  HabitDefault map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitDefault(
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      temperatureRangeLow: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temperature_range_low'],
      )!,
      temperatureRangeHigh: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temperature_range_high'],
      )!,
      defaultMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_minutes'],
      )!,
      consecutiveCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consecutive_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HabitDefaultsTable createAlias(String alias) {
    return $HabitDefaultsTable(attachedDatabase, alias);
  }
}

class HabitDefault extends DataClass implements Insertable<HabitDefault> {
  final String recipeId;
  final int temperatureRangeLow;
  final int temperatureRangeHigh;
  final int defaultMinutes;
  final int consecutiveCount;
  final DateTime updatedAt;
  const HabitDefault({
    required this.recipeId,
    required this.temperatureRangeLow,
    required this.temperatureRangeHigh,
    required this.defaultMinutes,
    required this.consecutiveCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recipe_id'] = Variable<String>(recipeId);
    map['temperature_range_low'] = Variable<int>(temperatureRangeLow);
    map['temperature_range_high'] = Variable<int>(temperatureRangeHigh);
    map['default_minutes'] = Variable<int>(defaultMinutes);
    map['consecutive_count'] = Variable<int>(consecutiveCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HabitDefaultsCompanion toCompanion(bool nullToAbsent) {
    return HabitDefaultsCompanion(
      recipeId: Value(recipeId),
      temperatureRangeLow: Value(temperatureRangeLow),
      temperatureRangeHigh: Value(temperatureRangeHigh),
      defaultMinutes: Value(defaultMinutes),
      consecutiveCount: Value(consecutiveCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory HabitDefault.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitDefault(
      recipeId: serializer.fromJson<String>(json['recipeId']),
      temperatureRangeLow: serializer.fromJson<int>(
        json['temperatureRangeLow'],
      ),
      temperatureRangeHigh: serializer.fromJson<int>(
        json['temperatureRangeHigh'],
      ),
      defaultMinutes: serializer.fromJson<int>(json['defaultMinutes']),
      consecutiveCount: serializer.fromJson<int>(json['consecutiveCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recipeId': serializer.toJson<String>(recipeId),
      'temperatureRangeLow': serializer.toJson<int>(temperatureRangeLow),
      'temperatureRangeHigh': serializer.toJson<int>(temperatureRangeHigh),
      'defaultMinutes': serializer.toJson<int>(defaultMinutes),
      'consecutiveCount': serializer.toJson<int>(consecutiveCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HabitDefault copyWith({
    String? recipeId,
    int? temperatureRangeLow,
    int? temperatureRangeHigh,
    int? defaultMinutes,
    int? consecutiveCount,
    DateTime? updatedAt,
  }) => HabitDefault(
    recipeId: recipeId ?? this.recipeId,
    temperatureRangeLow: temperatureRangeLow ?? this.temperatureRangeLow,
    temperatureRangeHigh: temperatureRangeHigh ?? this.temperatureRangeHigh,
    defaultMinutes: defaultMinutes ?? this.defaultMinutes,
    consecutiveCount: consecutiveCount ?? this.consecutiveCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HabitDefault copyWithCompanion(HabitDefaultsCompanion data) {
    return HabitDefault(
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      temperatureRangeLow: data.temperatureRangeLow.present
          ? data.temperatureRangeLow.value
          : this.temperatureRangeLow,
      temperatureRangeHigh: data.temperatureRangeHigh.present
          ? data.temperatureRangeHigh.value
          : this.temperatureRangeHigh,
      defaultMinutes: data.defaultMinutes.present
          ? data.defaultMinutes.value
          : this.defaultMinutes,
      consecutiveCount: data.consecutiveCount.present
          ? data.consecutiveCount.value
          : this.consecutiveCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitDefault(')
          ..write('recipeId: $recipeId, ')
          ..write('temperatureRangeLow: $temperatureRangeLow, ')
          ..write('temperatureRangeHigh: $temperatureRangeHigh, ')
          ..write('defaultMinutes: $defaultMinutes, ')
          ..write('consecutiveCount: $consecutiveCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    recipeId,
    temperatureRangeLow,
    temperatureRangeHigh,
    defaultMinutes,
    consecutiveCount,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitDefault &&
          other.recipeId == this.recipeId &&
          other.temperatureRangeLow == this.temperatureRangeLow &&
          other.temperatureRangeHigh == this.temperatureRangeHigh &&
          other.defaultMinutes == this.defaultMinutes &&
          other.consecutiveCount == this.consecutiveCount &&
          other.updatedAt == this.updatedAt);
}

class HabitDefaultsCompanion extends UpdateCompanion<HabitDefault> {
  final Value<String> recipeId;
  final Value<int> temperatureRangeLow;
  final Value<int> temperatureRangeHigh;
  final Value<int> defaultMinutes;
  final Value<int> consecutiveCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const HabitDefaultsCompanion({
    this.recipeId = const Value.absent(),
    this.temperatureRangeLow = const Value.absent(),
    this.temperatureRangeHigh = const Value.absent(),
    this.defaultMinutes = const Value.absent(),
    this.consecutiveCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitDefaultsCompanion.insert({
    required String recipeId,
    required int temperatureRangeLow,
    required int temperatureRangeHigh,
    required int defaultMinutes,
    this.consecutiveCount = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : recipeId = Value(recipeId),
       temperatureRangeLow = Value(temperatureRangeLow),
       temperatureRangeHigh = Value(temperatureRangeHigh),
       defaultMinutes = Value(defaultMinutes),
       updatedAt = Value(updatedAt);
  static Insertable<HabitDefault> custom({
    Expression<String>? recipeId,
    Expression<int>? temperatureRangeLow,
    Expression<int>? temperatureRangeHigh,
    Expression<int>? defaultMinutes,
    Expression<int>? consecutiveCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recipeId != null) 'recipe_id': recipeId,
      if (temperatureRangeLow != null)
        'temperature_range_low': temperatureRangeLow,
      if (temperatureRangeHigh != null)
        'temperature_range_high': temperatureRangeHigh,
      if (defaultMinutes != null) 'default_minutes': defaultMinutes,
      if (consecutiveCount != null) 'consecutive_count': consecutiveCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitDefaultsCompanion copyWith({
    Value<String>? recipeId,
    Value<int>? temperatureRangeLow,
    Value<int>? temperatureRangeHigh,
    Value<int>? defaultMinutes,
    Value<int>? consecutiveCount,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return HabitDefaultsCompanion(
      recipeId: recipeId ?? this.recipeId,
      temperatureRangeLow: temperatureRangeLow ?? this.temperatureRangeLow,
      temperatureRangeHigh: temperatureRangeHigh ?? this.temperatureRangeHigh,
      defaultMinutes: defaultMinutes ?? this.defaultMinutes,
      consecutiveCount: consecutiveCount ?? this.consecutiveCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (temperatureRangeLow.present) {
      map['temperature_range_low'] = Variable<int>(temperatureRangeLow.value);
    }
    if (temperatureRangeHigh.present) {
      map['temperature_range_high'] = Variable<int>(temperatureRangeHigh.value);
    }
    if (defaultMinutes.present) {
      map['default_minutes'] = Variable<int>(defaultMinutes.value);
    }
    if (consecutiveCount.present) {
      map['consecutive_count'] = Variable<int>(consecutiveCount.value);
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
    return (StringBuffer('HabitDefaultsCompanion(')
          ..write('recipeId: $recipeId, ')
          ..write('temperatureRangeLow: $temperatureRangeLow, ')
          ..write('temperatureRangeHigh: $temperatureRangeHigh, ')
          ..write('defaultMinutes: $defaultMinutes, ')
          ..write('consecutiveCount: $consecutiveCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BatchRecordsTable batchRecords = $BatchRecordsTable(this);
  late final $RecipeRecordsTable recipeRecords = $RecipeRecordsTable(this);
  late final $HabitDefaultsTable habitDefaults = $HabitDefaultsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    batchRecords,
    recipeRecords,
    habitDefaults,
  ];
}

typedef $$BatchRecordsTableCreateCompanionBuilder =
    BatchRecordsCompanion Function({
      required String id,
      required int displayNumber,
      required String recipeId,
      required String recipeName,
      Value<DateTime?> fermentationStart,
      Value<DateTime?> fermentationConfirm,
      Value<DateTime?> boilingStart,
      Value<DateTime?> boilingConfirm,
      Value<DateTime?> steamingStart,
      Value<DateTime?> steamingConfirm,
      Value<DateTime?> simmeringStart,
      Value<DateTime?> uncoverConfirm,
      Value<int?> fermentationActualMinutes,
      Value<String?> fermentationResult,
      Value<bool> lowConfidence,
      Value<int?> simmeringIntervalMinutes,
      Value<double?> temperature,
      Value<int?> humidity,
      Value<String?> weatherSource,
      required DateTime createdAt,
      required String season,
      Value<int> adjustmentMinutes,
      required String status,
      Value<String?> positionLabel,
      Value<int?> boilingReminderDelaySeconds,
      Value<int?> steamingReminderDelaySeconds,
      Value<String?> extensionsLog,
      Value<int> rowid,
    });
typedef $$BatchRecordsTableUpdateCompanionBuilder =
    BatchRecordsCompanion Function({
      Value<String> id,
      Value<int> displayNumber,
      Value<String> recipeId,
      Value<String> recipeName,
      Value<DateTime?> fermentationStart,
      Value<DateTime?> fermentationConfirm,
      Value<DateTime?> boilingStart,
      Value<DateTime?> boilingConfirm,
      Value<DateTime?> steamingStart,
      Value<DateTime?> steamingConfirm,
      Value<DateTime?> simmeringStart,
      Value<DateTime?> uncoverConfirm,
      Value<int?> fermentationActualMinutes,
      Value<String?> fermentationResult,
      Value<bool> lowConfidence,
      Value<int?> simmeringIntervalMinutes,
      Value<double?> temperature,
      Value<int?> humidity,
      Value<String?> weatherSource,
      Value<DateTime> createdAt,
      Value<String> season,
      Value<int> adjustmentMinutes,
      Value<String> status,
      Value<String?> positionLabel,
      Value<int?> boilingReminderDelaySeconds,
      Value<int?> steamingReminderDelaySeconds,
      Value<String?> extensionsLog,
      Value<int> rowid,
    });

class $$BatchRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $BatchRecordsTable> {
  $$BatchRecordsTableFilterComposer({
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

  ColumnFilters<int> get displayNumber => $composableBuilder(
    column: $table.displayNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeName => $composableBuilder(
    column: $table.recipeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fermentationStart => $composableBuilder(
    column: $table.fermentationStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fermentationConfirm => $composableBuilder(
    column: $table.fermentationConfirm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get boilingStart => $composableBuilder(
    column: $table.boilingStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get boilingConfirm => $composableBuilder(
    column: $table.boilingConfirm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get steamingStart => $composableBuilder(
    column: $table.steamingStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get steamingConfirm => $composableBuilder(
    column: $table.steamingConfirm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get simmeringStart => $composableBuilder(
    column: $table.simmeringStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get uncoverConfirm => $composableBuilder(
    column: $table.uncoverConfirm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fermentationActualMinutes => $composableBuilder(
    column: $table.fermentationActualMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fermentationResult => $composableBuilder(
    column: $table.fermentationResult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lowConfidence => $composableBuilder(
    column: $table.lowConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get simmeringIntervalMinutes => $composableBuilder(
    column: $table.simmeringIntervalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get humidity => $composableBuilder(
    column: $table.humidity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherSource => $composableBuilder(
    column: $table.weatherSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get adjustmentMinutes => $composableBuilder(
    column: $table.adjustmentMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get positionLabel => $composableBuilder(
    column: $table.positionLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get boilingReminderDelaySeconds => $composableBuilder(
    column: $table.boilingReminderDelaySeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steamingReminderDelaySeconds => $composableBuilder(
    column: $table.steamingReminderDelaySeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extensionsLog => $composableBuilder(
    column: $table.extensionsLog,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BatchRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $BatchRecordsTable> {
  $$BatchRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get displayNumber => $composableBuilder(
    column: $table.displayNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeName => $composableBuilder(
    column: $table.recipeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fermentationStart => $composableBuilder(
    column: $table.fermentationStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fermentationConfirm => $composableBuilder(
    column: $table.fermentationConfirm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get boilingStart => $composableBuilder(
    column: $table.boilingStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get boilingConfirm => $composableBuilder(
    column: $table.boilingConfirm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get steamingStart => $composableBuilder(
    column: $table.steamingStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get steamingConfirm => $composableBuilder(
    column: $table.steamingConfirm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get simmeringStart => $composableBuilder(
    column: $table.simmeringStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get uncoverConfirm => $composableBuilder(
    column: $table.uncoverConfirm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fermentationActualMinutes => $composableBuilder(
    column: $table.fermentationActualMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fermentationResult => $composableBuilder(
    column: $table.fermentationResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lowConfidence => $composableBuilder(
    column: $table.lowConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get simmeringIntervalMinutes => $composableBuilder(
    column: $table.simmeringIntervalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get humidity => $composableBuilder(
    column: $table.humidity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherSource => $composableBuilder(
    column: $table.weatherSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get adjustmentMinutes => $composableBuilder(
    column: $table.adjustmentMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get positionLabel => $composableBuilder(
    column: $table.positionLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get boilingReminderDelaySeconds => $composableBuilder(
    column: $table.boilingReminderDelaySeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steamingReminderDelaySeconds => $composableBuilder(
    column: $table.steamingReminderDelaySeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extensionsLog => $composableBuilder(
    column: $table.extensionsLog,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BatchRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatchRecordsTable> {
  $$BatchRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get displayNumber => $composableBuilder(
    column: $table.displayNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get recipeName => $composableBuilder(
    column: $table.recipeName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fermentationStart => $composableBuilder(
    column: $table.fermentationStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fermentationConfirm => $composableBuilder(
    column: $table.fermentationConfirm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get boilingStart => $composableBuilder(
    column: $table.boilingStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get boilingConfirm => $composableBuilder(
    column: $table.boilingConfirm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get steamingStart => $composableBuilder(
    column: $table.steamingStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get steamingConfirm => $composableBuilder(
    column: $table.steamingConfirm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get simmeringStart => $composableBuilder(
    column: $table.simmeringStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get uncoverConfirm => $composableBuilder(
    column: $table.uncoverConfirm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fermentationActualMinutes => $composableBuilder(
    column: $table.fermentationActualMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fermentationResult => $composableBuilder(
    column: $table.fermentationResult,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get lowConfidence => $composableBuilder(
    column: $table.lowConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get simmeringIntervalMinutes => $composableBuilder(
    column: $table.simmeringIntervalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<int> get humidity =>
      $composableBuilder(column: $table.humidity, builder: (column) => column);

  GeneratedColumn<String> get weatherSource => $composableBuilder(
    column: $table.weatherSource,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<int> get adjustmentMinutes => $composableBuilder(
    column: $table.adjustmentMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get positionLabel => $composableBuilder(
    column: $table.positionLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get boilingReminderDelaySeconds => $composableBuilder(
    column: $table.boilingReminderDelaySeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get steamingReminderDelaySeconds => $composableBuilder(
    column: $table.steamingReminderDelaySeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extensionsLog => $composableBuilder(
    column: $table.extensionsLog,
    builder: (column) => column,
  );
}

class $$BatchRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BatchRecordsTable,
          BatchRecord,
          $$BatchRecordsTableFilterComposer,
          $$BatchRecordsTableOrderingComposer,
          $$BatchRecordsTableAnnotationComposer,
          $$BatchRecordsTableCreateCompanionBuilder,
          $$BatchRecordsTableUpdateCompanionBuilder,
          (
            BatchRecord,
            BaseReferences<_$AppDatabase, $BatchRecordsTable, BatchRecord>,
          ),
          BatchRecord,
          PrefetchHooks Function()
        > {
  $$BatchRecordsTableTableManager(_$AppDatabase db, $BatchRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatchRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatchRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatchRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> displayNumber = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<String> recipeName = const Value.absent(),
                Value<DateTime?> fermentationStart = const Value.absent(),
                Value<DateTime?> fermentationConfirm = const Value.absent(),
                Value<DateTime?> boilingStart = const Value.absent(),
                Value<DateTime?> boilingConfirm = const Value.absent(),
                Value<DateTime?> steamingStart = const Value.absent(),
                Value<DateTime?> steamingConfirm = const Value.absent(),
                Value<DateTime?> simmeringStart = const Value.absent(),
                Value<DateTime?> uncoverConfirm = const Value.absent(),
                Value<int?> fermentationActualMinutes = const Value.absent(),
                Value<String?> fermentationResult = const Value.absent(),
                Value<bool> lowConfidence = const Value.absent(),
                Value<int?> simmeringIntervalMinutes = const Value.absent(),
                Value<double?> temperature = const Value.absent(),
                Value<int?> humidity = const Value.absent(),
                Value<String?> weatherSource = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<int> adjustmentMinutes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> positionLabel = const Value.absent(),
                Value<int?> boilingReminderDelaySeconds = const Value.absent(),
                Value<int?> steamingReminderDelaySeconds = const Value.absent(),
                Value<String?> extensionsLog = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchRecordsCompanion(
                id: id,
                displayNumber: displayNumber,
                recipeId: recipeId,
                recipeName: recipeName,
                fermentationStart: fermentationStart,
                fermentationConfirm: fermentationConfirm,
                boilingStart: boilingStart,
                boilingConfirm: boilingConfirm,
                steamingStart: steamingStart,
                steamingConfirm: steamingConfirm,
                simmeringStart: simmeringStart,
                uncoverConfirm: uncoverConfirm,
                fermentationActualMinutes: fermentationActualMinutes,
                fermentationResult: fermentationResult,
                lowConfidence: lowConfidence,
                simmeringIntervalMinutes: simmeringIntervalMinutes,
                temperature: temperature,
                humidity: humidity,
                weatherSource: weatherSource,
                createdAt: createdAt,
                season: season,
                adjustmentMinutes: adjustmentMinutes,
                status: status,
                positionLabel: positionLabel,
                boilingReminderDelaySeconds: boilingReminderDelaySeconds,
                steamingReminderDelaySeconds: steamingReminderDelaySeconds,
                extensionsLog: extensionsLog,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int displayNumber,
                required String recipeId,
                required String recipeName,
                Value<DateTime?> fermentationStart = const Value.absent(),
                Value<DateTime?> fermentationConfirm = const Value.absent(),
                Value<DateTime?> boilingStart = const Value.absent(),
                Value<DateTime?> boilingConfirm = const Value.absent(),
                Value<DateTime?> steamingStart = const Value.absent(),
                Value<DateTime?> steamingConfirm = const Value.absent(),
                Value<DateTime?> simmeringStart = const Value.absent(),
                Value<DateTime?> uncoverConfirm = const Value.absent(),
                Value<int?> fermentationActualMinutes = const Value.absent(),
                Value<String?> fermentationResult = const Value.absent(),
                Value<bool> lowConfidence = const Value.absent(),
                Value<int?> simmeringIntervalMinutes = const Value.absent(),
                Value<double?> temperature = const Value.absent(),
                Value<int?> humidity = const Value.absent(),
                Value<String?> weatherSource = const Value.absent(),
                required DateTime createdAt,
                required String season,
                Value<int> adjustmentMinutes = const Value.absent(),
                required String status,
                Value<String?> positionLabel = const Value.absent(),
                Value<int?> boilingReminderDelaySeconds = const Value.absent(),
                Value<int?> steamingReminderDelaySeconds = const Value.absent(),
                Value<String?> extensionsLog = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchRecordsCompanion.insert(
                id: id,
                displayNumber: displayNumber,
                recipeId: recipeId,
                recipeName: recipeName,
                fermentationStart: fermentationStart,
                fermentationConfirm: fermentationConfirm,
                boilingStart: boilingStart,
                boilingConfirm: boilingConfirm,
                steamingStart: steamingStart,
                steamingConfirm: steamingConfirm,
                simmeringStart: simmeringStart,
                uncoverConfirm: uncoverConfirm,
                fermentationActualMinutes: fermentationActualMinutes,
                fermentationResult: fermentationResult,
                lowConfidence: lowConfidence,
                simmeringIntervalMinutes: simmeringIntervalMinutes,
                temperature: temperature,
                humidity: humidity,
                weatherSource: weatherSource,
                createdAt: createdAt,
                season: season,
                adjustmentMinutes: adjustmentMinutes,
                status: status,
                positionLabel: positionLabel,
                boilingReminderDelaySeconds: boilingReminderDelaySeconds,
                steamingReminderDelaySeconds: steamingReminderDelaySeconds,
                extensionsLog: extensionsLog,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BatchRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BatchRecordsTable,
      BatchRecord,
      $$BatchRecordsTableFilterComposer,
      $$BatchRecordsTableOrderingComposer,
      $$BatchRecordsTableAnnotationComposer,
      $$BatchRecordsTableCreateCompanionBuilder,
      $$BatchRecordsTableUpdateCompanionBuilder,
      (
        BatchRecord,
        BaseReferences<_$AppDatabase, $BatchRecordsTable, BatchRecord>,
      ),
      BatchRecord,
      PrefetchHooks Function()
    >;
typedef $$RecipeRecordsTableCreateCompanionBuilder =
    RecipeRecordsCompanion Function({
      required String id,
      required String name,
      required String announcementName,
      required String stepsJson,
      required int fermentationRangeMin,
      required int fermentationRangeMax,
      Value<bool> isPreset,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$RecipeRecordsTableUpdateCompanionBuilder =
    RecipeRecordsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> announcementName,
      Value<String> stepsJson,
      Value<int> fermentationRangeMin,
      Value<int> fermentationRangeMax,
      Value<bool> isPreset,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RecipeRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeRecordsTable> {
  $$RecipeRecordsTableFilterComposer({
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

  ColumnFilters<String> get announcementName => $composableBuilder(
    column: $table.announcementName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepsJson => $composableBuilder(
    column: $table.stepsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fermentationRangeMin => $composableBuilder(
    column: $table.fermentationRangeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fermentationRangeMax => $composableBuilder(
    column: $table.fermentationRangeMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
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
}

class $$RecipeRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeRecordsTable> {
  $$RecipeRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get announcementName => $composableBuilder(
    column: $table.announcementName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepsJson => $composableBuilder(
    column: $table.stepsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fermentationRangeMin => $composableBuilder(
    column: $table.fermentationRangeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fermentationRangeMax => $composableBuilder(
    column: $table.fermentationRangeMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
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

class $$RecipeRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeRecordsTable> {
  $$RecipeRecordsTableAnnotationComposer({
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

  GeneratedColumn<String> get announcementName => $composableBuilder(
    column: $table.announcementName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stepsJson =>
      $composableBuilder(column: $table.stepsJson, builder: (column) => column);

  GeneratedColumn<int> get fermentationRangeMin => $composableBuilder(
    column: $table.fermentationRangeMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fermentationRangeMax => $composableBuilder(
    column: $table.fermentationRangeMax,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPreset =>
      $composableBuilder(column: $table.isPreset, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RecipeRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeRecordsTable,
          RecipeRecord,
          $$RecipeRecordsTableFilterComposer,
          $$RecipeRecordsTableOrderingComposer,
          $$RecipeRecordsTableAnnotationComposer,
          $$RecipeRecordsTableCreateCompanionBuilder,
          $$RecipeRecordsTableUpdateCompanionBuilder,
          (
            RecipeRecord,
            BaseReferences<_$AppDatabase, $RecipeRecordsTable, RecipeRecord>,
          ),
          RecipeRecord,
          PrefetchHooks Function()
        > {
  $$RecipeRecordsTableTableManager(_$AppDatabase db, $RecipeRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> announcementName = const Value.absent(),
                Value<String> stepsJson = const Value.absent(),
                Value<int> fermentationRangeMin = const Value.absent(),
                Value<int> fermentationRangeMax = const Value.absent(),
                Value<bool> isPreset = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeRecordsCompanion(
                id: id,
                name: name,
                announcementName: announcementName,
                stepsJson: stepsJson,
                fermentationRangeMin: fermentationRangeMin,
                fermentationRangeMax: fermentationRangeMax,
                isPreset: isPreset,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String announcementName,
                required String stepsJson,
                required int fermentationRangeMin,
                required int fermentationRangeMax,
                Value<bool> isPreset = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecipeRecordsCompanion.insert(
                id: id,
                name: name,
                announcementName: announcementName,
                stepsJson: stepsJson,
                fermentationRangeMin: fermentationRangeMin,
                fermentationRangeMax: fermentationRangeMax,
                isPreset: isPreset,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipeRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeRecordsTable,
      RecipeRecord,
      $$RecipeRecordsTableFilterComposer,
      $$RecipeRecordsTableOrderingComposer,
      $$RecipeRecordsTableAnnotationComposer,
      $$RecipeRecordsTableCreateCompanionBuilder,
      $$RecipeRecordsTableUpdateCompanionBuilder,
      (
        RecipeRecord,
        BaseReferences<_$AppDatabase, $RecipeRecordsTable, RecipeRecord>,
      ),
      RecipeRecord,
      PrefetchHooks Function()
    >;
typedef $$HabitDefaultsTableCreateCompanionBuilder =
    HabitDefaultsCompanion Function({
      required String recipeId,
      required int temperatureRangeLow,
      required int temperatureRangeHigh,
      required int defaultMinutes,
      Value<int> consecutiveCount,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$HabitDefaultsTableUpdateCompanionBuilder =
    HabitDefaultsCompanion Function({
      Value<String> recipeId,
      Value<int> temperatureRangeLow,
      Value<int> temperatureRangeHigh,
      Value<int> defaultMinutes,
      Value<int> consecutiveCount,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$HabitDefaultsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitDefaultsTable> {
  $$HabitDefaultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temperatureRangeLow => $composableBuilder(
    column: $table.temperatureRangeLow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temperatureRangeHigh => $composableBuilder(
    column: $table.temperatureRangeHigh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultMinutes => $composableBuilder(
    column: $table.defaultMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get consecutiveCount => $composableBuilder(
    column: $table.consecutiveCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitDefaultsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitDefaultsTable> {
  $$HabitDefaultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temperatureRangeLow => $composableBuilder(
    column: $table.temperatureRangeLow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temperatureRangeHigh => $composableBuilder(
    column: $table.temperatureRangeHigh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultMinutes => $composableBuilder(
    column: $table.defaultMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get consecutiveCount => $composableBuilder(
    column: $table.consecutiveCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitDefaultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitDefaultsTable> {
  $$HabitDefaultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<int> get temperatureRangeLow => $composableBuilder(
    column: $table.temperatureRangeLow,
    builder: (column) => column,
  );

  GeneratedColumn<int> get temperatureRangeHigh => $composableBuilder(
    column: $table.temperatureRangeHigh,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultMinutes => $composableBuilder(
    column: $table.defaultMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get consecutiveCount => $composableBuilder(
    column: $table.consecutiveCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HabitDefaultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitDefaultsTable,
          HabitDefault,
          $$HabitDefaultsTableFilterComposer,
          $$HabitDefaultsTableOrderingComposer,
          $$HabitDefaultsTableAnnotationComposer,
          $$HabitDefaultsTableCreateCompanionBuilder,
          $$HabitDefaultsTableUpdateCompanionBuilder,
          (
            HabitDefault,
            BaseReferences<_$AppDatabase, $HabitDefaultsTable, HabitDefault>,
          ),
          HabitDefault,
          PrefetchHooks Function()
        > {
  $$HabitDefaultsTableTableManager(_$AppDatabase db, $HabitDefaultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitDefaultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitDefaultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitDefaultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> recipeId = const Value.absent(),
                Value<int> temperatureRangeLow = const Value.absent(),
                Value<int> temperatureRangeHigh = const Value.absent(),
                Value<int> defaultMinutes = const Value.absent(),
                Value<int> consecutiveCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitDefaultsCompanion(
                recipeId: recipeId,
                temperatureRangeLow: temperatureRangeLow,
                temperatureRangeHigh: temperatureRangeHigh,
                defaultMinutes: defaultMinutes,
                consecutiveCount: consecutiveCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String recipeId,
                required int temperatureRangeLow,
                required int temperatureRangeHigh,
                required int defaultMinutes,
                Value<int> consecutiveCount = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => HabitDefaultsCompanion.insert(
                recipeId: recipeId,
                temperatureRangeLow: temperatureRangeLow,
                temperatureRangeHigh: temperatureRangeHigh,
                defaultMinutes: defaultMinutes,
                consecutiveCount: consecutiveCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitDefaultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitDefaultsTable,
      HabitDefault,
      $$HabitDefaultsTableFilterComposer,
      $$HabitDefaultsTableOrderingComposer,
      $$HabitDefaultsTableAnnotationComposer,
      $$HabitDefaultsTableCreateCompanionBuilder,
      $$HabitDefaultsTableUpdateCompanionBuilder,
      (
        HabitDefault,
        BaseReferences<_$AppDatabase, $HabitDefaultsTable, HabitDefault>,
      ),
      HabitDefault,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BatchRecordsTableTableManager get batchRecords =>
      $$BatchRecordsTableTableManager(_db, _db.batchRecords);
  $$RecipeRecordsTableTableManager get recipeRecords =>
      $$RecipeRecordsTableTableManager(_db, _db.recipeRecords);
  $$HabitDefaultsTableTableManager get habitDefaults =>
      $$HabitDefaultsTableTableManager(_db, _db.habitDefaults);
}
