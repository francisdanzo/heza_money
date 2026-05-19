// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('expense'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _monthKeyMeta =
      const VerificationMeta('monthKey');
  @override
  late final GeneratedColumn<String> monthKey = GeneratedColumn<String>(
      'month_key', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 7, maxTextLength: 7),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, amount, category, type, note, date, monthKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('month_key')) {
      context.handle(_monthKeyMeta,
          monthKey.isAcceptableOrUnknown(data['month_key']!, _monthKeyMeta));
    } else if (isInserting) {
      context.missing(_monthKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      monthKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}month_key'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final double amount;
  final String category;
  final String type;
  final String? note;
  final DateTime date;
  final String monthKey;
  const Transaction(
      {required this.id,
      required this.amount,
      required this.category,
      required this.type,
      this.note,
      required this.date,
      required this.monthKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    map['category'] = Variable<String>(category);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['date'] = Variable<DateTime>(date);
    map['month_key'] = Variable<String>(monthKey);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      category: Value(category),
      type: Value(type),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      date: Value(date),
      monthKey: Value(monthKey),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      type: serializer.fromJson<String>(json['type']),
      note: serializer.fromJson<String?>(json['note']),
      date: serializer.fromJson<DateTime>(json['date']),
      monthKey: serializer.fromJson<String>(json['monthKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String>(category),
      'type': serializer.toJson<String>(type),
      'note': serializer.toJson<String?>(note),
      'date': serializer.toJson<DateTime>(date),
      'monthKey': serializer.toJson<String>(monthKey),
    };
  }

  Transaction copyWith(
          {int? id,
          double? amount,
          String? category,
          String? type,
          Value<String?> note = const Value.absent(),
          DateTime? date,
          String? monthKey}) =>
      Transaction(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        type: type ?? this.type,
        note: note.present ? note.value : this.note,
        date: date ?? this.date,
        monthKey: monthKey ?? this.monthKey,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      type: data.type.present ? data.type.value : this.type,
      note: data.note.present ? data.note.value : this.note,
      date: data.date.present ? data.date.value : this.date,
      monthKey: data.monthKey.present ? data.monthKey.value : this.monthKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('monthKey: $monthKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, amount, category, type, note, date, monthKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.type == this.type &&
          other.note == this.note &&
          other.date == this.date &&
          other.monthKey == this.monthKey);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<double> amount;
  final Value<String> category;
  final Value<String> type;
  final Value<String?> note;
  final Value<DateTime> date;
  final Value<String> monthKey;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.type = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
    this.monthKey = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    required String category,
    this.type = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime date,
    required String monthKey,
  })  : amount = Value(amount),
        category = Value(category),
        date = Value(date),
        monthKey = Value(monthKey);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<String>? type,
    Expression<String>? note,
    Expression<DateTime>? date,
    Expression<String>? monthKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (type != null) 'type': type,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
      if (monthKey != null) 'month_key': monthKey,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? id,
      Value<double>? amount,
      Value<String>? category,
      Value<String>? type,
      Value<String?>? note,
      Value<DateTime>? date,
      Value<String>? monthKey}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      note: note ?? this.note,
      date: date ?? this.date,
      monthKey: monthKey ?? this.monthKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (monthKey.present) {
      map['month_key'] = Variable<String>(monthKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('monthKey: $monthKey')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _targetAmountMeta =
      const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
      'target_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currentAmountMeta =
      const VerificationMeta('currentAmount');
  @override
  late final GeneratedColumn<double> currentAmount = GeneratedColumn<double>(
      'current_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _deadlineMeta =
      const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
      'deadline', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#1D9E75'));
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        targetAmount,
        currentAmount,
        deadline,
        color,
        icon,
        createdAt,
        isCompleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(Insertable<Goal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
          _targetAmountMeta,
          targetAmount.isAcceptableOrUnknown(
              data['target_amount']!, _targetAmountMeta));
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('current_amount')) {
      context.handle(
          _currentAmountMeta,
          currentAmount.isAcceptableOrUnknown(
              data['current_amount']!, _currentAmountMeta));
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta,
          deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    } else if (isInserting) {
      context.missing(_deadlineMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      targetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_amount'])!,
      currentAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_amount'])!,
      deadline: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final int id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String color;
  final String? icon;
  final DateTime createdAt;
  final bool isCompleted;
  const Goal(
      {required this.id,
      required this.title,
      required this.targetAmount,
      required this.currentAmount,
      required this.deadline,
      required this.color,
      this.icon,
      required this.createdAt,
      required this.isCompleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['target_amount'] = Variable<double>(targetAmount);
    map['current_amount'] = Variable<double>(currentAmount);
    map['deadline'] = Variable<DateTime>(deadline);
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      title: Value(title),
      targetAmount: Value(targetAmount),
      currentAmount: Value(currentAmount),
      deadline: Value(deadline),
      color: Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      createdAt: Value(createdAt),
      isCompleted: Value(isCompleted),
    );
  }

  factory Goal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      currentAmount: serializer.fromJson<double>(json['currentAmount']),
      deadline: serializer.fromJson<DateTime>(json['deadline']),
      color: serializer.fromJson<String>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'currentAmount': serializer.toJson<double>(currentAmount),
      'deadline': serializer.toJson<DateTime>(deadline),
      'color': serializer.toJson<String>(color),
      'icon': serializer.toJson<String?>(icon),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  Goal copyWith(
          {int? id,
          String? title,
          double? targetAmount,
          double? currentAmount,
          DateTime? deadline,
          String? color,
          Value<String?> icon = const Value.absent(),
          DateTime? createdAt,
          bool? isCompleted}) =>
      Goal(
        id: id ?? this.id,
        title: title ?? this.title,
        targetAmount: targetAmount ?? this.targetAmount,
        currentAmount: currentAmount ?? this.currentAmount,
        deadline: deadline ?? this.deadline,
        color: color ?? this.color,
        icon: icon.present ? icon.value : this.icon,
        createdAt: createdAt ?? this.createdAt,
        isCompleted: isCompleted ?? this.isCompleted,
      );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('deadline: $deadline, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, targetAmount, currentAmount,
      deadline, color, icon, createdAt, isCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.title == this.title &&
          other.targetAmount == this.targetAmount &&
          other.currentAmount == this.currentAmount &&
          other.deadline == this.deadline &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.createdAt == this.createdAt &&
          other.isCompleted == this.isCompleted);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<int> id;
  final Value<String> title;
  final Value<double> targetAmount;
  final Value<double> currentAmount;
  final Value<DateTime> deadline;
  final Value<String> color;
  final Value<String?> icon;
  final Value<DateTime> createdAt;
  final Value<bool> isCompleted;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.deadline = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required double targetAmount,
    this.currentAmount = const Value.absent(),
    required DateTime deadline,
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    required DateTime createdAt,
    this.isCompleted = const Value.absent(),
  })  : title = Value(title),
        targetAmount = Value(targetAmount),
        deadline = Value(deadline),
        createdAt = Value(createdAt);
  static Insertable<Goal> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<double>? targetAmount,
    Expression<double>? currentAmount,
    Expression<DateTime>? deadline,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<DateTime>? createdAt,
    Expression<bool>? isCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (deadline != null) 'deadline': deadline,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (createdAt != null) 'created_at': createdAt,
      if (isCompleted != null) 'is_completed': isCompleted,
    });
  }

  GoalsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<double>? targetAmount,
      Value<double>? currentAmount,
      Value<DateTime>? deadline,
      Value<String>? color,
      Value<String?>? icon,
      Value<DateTime>? createdAt,
      Value<bool>? isCompleted}) {
    return GoalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<double>(currentAmount.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('deadline: $deadline, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }
}

class $UserProfileTable extends UserProfile
    with TableInfo<$UserProfileTable, UserProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _monthlySalaryMeta =
      const VerificationMeta('monthlySalary');
  @override
  late final GeneratedColumn<double> monthlySalary = GeneratedColumn<double>(
      'monthly_salary', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(700000.0));
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('BIF'));
  static const VerificationMeta _themeModeMeta =
      const VerificationMeta('themeMode');
  @override
  late final GeneratedColumn<int> themeMode = GeneratedColumn<int>(
      'theme_mode', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
      'notifications_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notifications_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, monthlySalary, currency, themeMode, notificationsEnabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfileData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('monthly_salary')) {
      context.handle(
          _monthlySalaryMeta,
          monthlySalary.isAcceptableOrUnknown(
              data['monthly_salary']!, _monthlySalaryMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(_themeModeMeta,
          themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta));
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
          _notificationsEnabledMeta,
          notificationsEnabled.isAcceptableOrUnknown(
              data['notifications_enabled']!, _notificationsEnabledMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      monthlySalary: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monthly_salary'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      themeMode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}theme_mode'])!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}notifications_enabled'])!,
    );
  }

  @override
  $UserProfileTable createAlias(String alias) {
    return $UserProfileTable(attachedDatabase, alias);
  }
}

class UserProfileData extends DataClass implements Insertable<UserProfileData> {
  final int id;
  final String name;
  final double monthlySalary;
  final String currency;
  final int themeMode;
  final bool notificationsEnabled;
  const UserProfileData(
      {required this.id,
      required this.name,
      required this.monthlySalary,
      required this.currency,
      required this.themeMode,
      required this.notificationsEnabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['monthly_salary'] = Variable<double>(monthlySalary);
    map['currency'] = Variable<String>(currency);
    map['theme_mode'] = Variable<int>(themeMode);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    return map;
  }

  UserProfileCompanion toCompanion(bool nullToAbsent) {
    return UserProfileCompanion(
      id: Value(id),
      name: Value(name),
      monthlySalary: Value(monthlySalary),
      currency: Value(currency),
      themeMode: Value(themeMode),
      notificationsEnabled: Value(notificationsEnabled),
    );
  }

  factory UserProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      monthlySalary: serializer.fromJson<double>(json['monthlySalary']),
      currency: serializer.fromJson<String>(json['currency']),
      themeMode: serializer.fromJson<int>(json['themeMode']),
      notificationsEnabled:
          serializer.fromJson<bool>(json['notificationsEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'monthlySalary': serializer.toJson<double>(monthlySalary),
      'currency': serializer.toJson<String>(currency),
      'themeMode': serializer.toJson<int>(themeMode),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
    };
  }

  UserProfileData copyWith(
          {int? id,
          String? name,
          double? monthlySalary,
          String? currency,
          int? themeMode,
          bool? notificationsEnabled}) =>
      UserProfileData(
        id: id ?? this.id,
        name: name ?? this.name,
        monthlySalary: monthlySalary ?? this.monthlySalary,
        currency: currency ?? this.currency,
        themeMode: themeMode ?? this.themeMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );
  UserProfileData copyWithCompanion(UserProfileCompanion data) {
    return UserProfileData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      monthlySalary: data.monthlySalary.present
          ? data.monthlySalary.value
          : this.monthlySalary,
      currency: data.currency.present ? data.currency.value : this.currency,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('monthlySalary: $monthlySalary, ')
          ..write('currency: $currency, ')
          ..write('themeMode: $themeMode, ')
          ..write('notificationsEnabled: $notificationsEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, monthlySalary, currency, themeMode, notificationsEnabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileData &&
          other.id == this.id &&
          other.name == this.name &&
          other.monthlySalary == this.monthlySalary &&
          other.currency == this.currency &&
          other.themeMode == this.themeMode &&
          other.notificationsEnabled == this.notificationsEnabled);
}

class UserProfileCompanion extends UpdateCompanion<UserProfileData> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> monthlySalary;
  final Value<String> currency;
  final Value<int> themeMode;
  final Value<bool> notificationsEnabled;
  const UserProfileCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.monthlySalary = const Value.absent(),
    this.currency = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
  });
  UserProfileCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.monthlySalary = const Value.absent(),
    this.currency = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
  }) : name = Value(name);
  static Insertable<UserProfileData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? monthlySalary,
    Expression<String>? currency,
    Expression<int>? themeMode,
    Expression<bool>? notificationsEnabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (monthlySalary != null) 'monthly_salary': monthlySalary,
      if (currency != null) 'currency': currency,
      if (themeMode != null) 'theme_mode': themeMode,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
    });
  }

  UserProfileCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? monthlySalary,
      Value<String>? currency,
      Value<int>? themeMode,
      Value<bool>? notificationsEnabled}) {
    return UserProfileCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (monthlySalary.present) {
      map['monthly_salary'] = Variable<double>(monthlySalary.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<int>(themeMode.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('monthlySalary: $monthlySalary, ')
          ..write('currency: $currency, ')
          ..write('themeMode: $themeMode, ')
          ..write('notificationsEnabled: $notificationsEnabled')
          ..write(')'))
        .toString();
  }
}

class $LessonProgressTable extends LessonProgress
    with TableInfo<$LessonProgressTable, LessonProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lessonIdMeta =
      const VerificationMeta('lessonId');
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
      'lesson_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 2, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
      'completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [lessonId, completed, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_progress';
  @override
  VerificationContext validateIntegrity(Insertable<LessonProgressData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lesson_id')) {
      context.handle(_lessonIdMeta,
          lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta));
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lessonId};
  @override
  LessonProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonProgressData(
      lessonId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lesson_id'])!,
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $LessonProgressTable createAlias(String alias) {
    return $LessonProgressTable(attachedDatabase, alias);
  }
}

class LessonProgressData extends DataClass
    implements Insertable<LessonProgressData> {
  final String lessonId;
  final bool completed;
  final DateTime? completedAt;
  const LessonProgressData(
      {required this.lessonId, required this.completed, this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lesson_id'] = Variable<String>(lessonId);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  LessonProgressCompanion toCompanion(bool nullToAbsent) {
    return LessonProgressCompanion(
      lessonId: Value(lessonId),
      completed: Value(completed),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory LessonProgressData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonProgressData(
      lessonId: serializer.fromJson<String>(json['lessonId']),
      completed: serializer.fromJson<bool>(json['completed']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lessonId': serializer.toJson<String>(lessonId),
      'completed': serializer.toJson<bool>(completed),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  LessonProgressData copyWith(
          {String? lessonId,
          bool? completed,
          Value<DateTime?> completedAt = const Value.absent()}) =>
      LessonProgressData(
        lessonId: lessonId ?? this.lessonId,
        completed: completed ?? this.completed,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  LessonProgressData copyWithCompanion(LessonProgressCompanion data) {
    return LessonProgressData(
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      completed: data.completed.present ? data.completed.value : this.completed,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressData(')
          ..write('lessonId: $lessonId, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(lessonId, completed, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonProgressData &&
          other.lessonId == this.lessonId &&
          other.completed == this.completed &&
          other.completedAt == this.completedAt);
}

class LessonProgressCompanion extends UpdateCompanion<LessonProgressData> {
  final Value<String> lessonId;
  final Value<bool> completed;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const LessonProgressCompanion({
    this.lessonId = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonProgressCompanion.insert({
    required String lessonId,
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : lessonId = Value(lessonId);
  static Insertable<LessonProgressData> custom({
    Expression<String>? lessonId,
    Expression<bool>? completed,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lessonId != null) 'lesson_id': lessonId,
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonProgressCompanion copyWith(
      {Value<String>? lessonId,
      Value<bool>? completed,
      Value<DateTime?>? completedAt,
      Value<int>? rowid}) {
    return LessonProgressCompanion(
      lessonId: lessonId ?? this.lessonId,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressCompanion(')
          ..write('lessonId: $lessonId, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EarnedBadgesTable extends EarnedBadges
    with TableInfo<$EarnedBadgesTable, EarnedBadge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EarnedBadgesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _badgeIdMeta =
      const VerificationMeta('badgeId');
  @override
  late final GeneratedColumn<String> badgeId = GeneratedColumn<String>(
      'badge_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _earnedAtMeta =
      const VerificationMeta('earnedAt');
  @override
  late final GeneratedColumn<DateTime> earnedAt = GeneratedColumn<DateTime>(
      'earned_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [badgeId, earnedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'earned_badges';
  @override
  VerificationContext validateIntegrity(Insertable<EarnedBadge> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('badge_id')) {
      context.handle(_badgeIdMeta,
          badgeId.isAcceptableOrUnknown(data['badge_id']!, _badgeIdMeta));
    } else if (isInserting) {
      context.missing(_badgeIdMeta);
    }
    if (data.containsKey('earned_at')) {
      context.handle(_earnedAtMeta,
          earnedAt.isAcceptableOrUnknown(data['earned_at']!, _earnedAtMeta));
    } else if (isInserting) {
      context.missing(_earnedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {badgeId};
  @override
  EarnedBadge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EarnedBadge(
      badgeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}badge_id'])!,
      earnedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}earned_at'])!,
    );
  }

  @override
  $EarnedBadgesTable createAlias(String alias) {
    return $EarnedBadgesTable(attachedDatabase, alias);
  }
}

class EarnedBadge extends DataClass implements Insertable<EarnedBadge> {
  final String badgeId;
  final DateTime earnedAt;
  const EarnedBadge({required this.badgeId, required this.earnedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['badge_id'] = Variable<String>(badgeId);
    map['earned_at'] = Variable<DateTime>(earnedAt);
    return map;
  }

  EarnedBadgesCompanion toCompanion(bool nullToAbsent) {
    return EarnedBadgesCompanion(
      badgeId: Value(badgeId),
      earnedAt: Value(earnedAt),
    );
  }

  factory EarnedBadge.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EarnedBadge(
      badgeId: serializer.fromJson<String>(json['badgeId']),
      earnedAt: serializer.fromJson<DateTime>(json['earnedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'badgeId': serializer.toJson<String>(badgeId),
      'earnedAt': serializer.toJson<DateTime>(earnedAt),
    };
  }

  EarnedBadge copyWith({String? badgeId, DateTime? earnedAt}) => EarnedBadge(
        badgeId: badgeId ?? this.badgeId,
        earnedAt: earnedAt ?? this.earnedAt,
      );
  EarnedBadge copyWithCompanion(EarnedBadgesCompanion data) {
    return EarnedBadge(
      badgeId: data.badgeId.present ? data.badgeId.value : this.badgeId,
      earnedAt: data.earnedAt.present ? data.earnedAt.value : this.earnedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EarnedBadge(')
          ..write('badgeId: $badgeId, ')
          ..write('earnedAt: $earnedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(badgeId, earnedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EarnedBadge &&
          other.badgeId == this.badgeId &&
          other.earnedAt == this.earnedAt);
}

class EarnedBadgesCompanion extends UpdateCompanion<EarnedBadge> {
  final Value<String> badgeId;
  final Value<DateTime> earnedAt;
  final Value<int> rowid;
  const EarnedBadgesCompanion({
    this.badgeId = const Value.absent(),
    this.earnedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EarnedBadgesCompanion.insert({
    required String badgeId,
    required DateTime earnedAt,
    this.rowid = const Value.absent(),
  })  : badgeId = Value(badgeId),
        earnedAt = Value(earnedAt);
  static Insertable<EarnedBadge> custom({
    Expression<String>? badgeId,
    Expression<DateTime>? earnedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (badgeId != null) 'badge_id': badgeId,
      if (earnedAt != null) 'earned_at': earnedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EarnedBadgesCompanion copyWith(
      {Value<String>? badgeId, Value<DateTime>? earnedAt, Value<int>? rowid}) {
    return EarnedBadgesCompanion(
      badgeId: badgeId ?? this.badgeId,
      earnedAt: earnedAt ?? this.earnedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (badgeId.present) {
      map['badge_id'] = Variable<String>(badgeId.value);
    }
    if (earnedAt.present) {
      map['earned_at'] = Variable<DateTime>(earnedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EarnedBadgesCompanion(')
          ..write('badgeId: $badgeId, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryBudgetsTable extends CategoryBudgets
    with TableInfo<$CategoryBudgetsTable, CategoryBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _limitAmountMeta =
      const VerificationMeta('limitAmount');
  @override
  late final GeneratedColumn<double> limitAmount = GeneratedColumn<double>(
      'limit_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [category, limitAmount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_budgets';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryBudget> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('limit_amount')) {
      context.handle(
          _limitAmountMeta,
          limitAmount.isAcceptableOrUnknown(
              data['limit_amount']!, _limitAmountMeta));
    } else if (isInserting) {
      context.missing(_limitAmountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {category};
  @override
  CategoryBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryBudget(
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      limitAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}limit_amount'])!,
    );
  }

  @override
  $CategoryBudgetsTable createAlias(String alias) {
    return $CategoryBudgetsTable(attachedDatabase, alias);
  }
}

class CategoryBudget extends DataClass implements Insertable<CategoryBudget> {
  final String category;
  final double limitAmount;
  const CategoryBudget({required this.category, required this.limitAmount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category'] = Variable<String>(category);
    map['limit_amount'] = Variable<double>(limitAmount);
    return map;
  }

  CategoryBudgetsCompanion toCompanion(bool nullToAbsent) {
    return CategoryBudgetsCompanion(
      category: Value(category),
      limitAmount: Value(limitAmount),
    );
  }

  factory CategoryBudget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryBudget(
      category: serializer.fromJson<String>(json['category']),
      limitAmount: serializer.fromJson<double>(json['limitAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'category': serializer.toJson<String>(category),
      'limitAmount': serializer.toJson<double>(limitAmount),
    };
  }

  CategoryBudget copyWith({String? category, double? limitAmount}) =>
      CategoryBudget(
        category: category ?? this.category,
        limitAmount: limitAmount ?? this.limitAmount,
      );
  CategoryBudget copyWithCompanion(CategoryBudgetsCompanion data) {
    return CategoryBudget(
      category: data.category.present ? data.category.value : this.category,
      limitAmount:
          data.limitAmount.present ? data.limitAmount.value : this.limitAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryBudget(')
          ..write('category: $category, ')
          ..write('limitAmount: $limitAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(category, limitAmount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryBudget &&
          other.category == this.category &&
          other.limitAmount == this.limitAmount);
}

class CategoryBudgetsCompanion extends UpdateCompanion<CategoryBudget> {
  final Value<String> category;
  final Value<double> limitAmount;
  final Value<int> rowid;
  const CategoryBudgetsCompanion({
    this.category = const Value.absent(),
    this.limitAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryBudgetsCompanion.insert({
    required String category,
    required double limitAmount,
    this.rowid = const Value.absent(),
  })  : category = Value(category),
        limitAmount = Value(limitAmount);
  static Insertable<CategoryBudget> custom({
    Expression<String>? category,
    Expression<double>? limitAmount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (category != null) 'category': category,
      if (limitAmount != null) 'limit_amount': limitAmount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryBudgetsCompanion copyWith(
      {Value<String>? category,
      Value<double>? limitAmount,
      Value<int>? rowid}) {
    return CategoryBudgetsCompanion(
      category: category ?? this.category,
      limitAmount: limitAmount ?? this.limitAmount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (limitAmount.present) {
      map['limit_amount'] = Variable<double>(limitAmount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryBudgetsCompanion(')
          ..write('category: $category, ')
          ..write('limitAmount: $limitAmount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $UserProfileTable userProfile = $UserProfileTable(this);
  late final $LessonProgressTable lessonProgress = $LessonProgressTable(this);
  late final $EarnedBadgesTable earnedBadges = $EarnedBadgesTable(this);
  late final $CategoryBudgetsTable categoryBudgets =
      $CategoryBudgetsTable(this);
  late final TransactionsDao transactionsDao =
      TransactionsDao(this as AppDatabase);
  late final GoalsDao goalsDao = GoalsDao(this as AppDatabase);
  late final UserProfileDao userProfileDao =
      UserProfileDao(this as AppDatabase);
  late final LessonProgressDao lessonProgressDao =
      LessonProgressDao(this as AppDatabase);
  late final EarnedBadgesDao earnedBadgesDao =
      EarnedBadgesDao(this as AppDatabase);
  late final CategoryBudgetsDao categoryBudgetsDao =
      CategoryBudgetsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        transactions,
        goals,
        userProfile,
        lessonProgress,
        earnedBadges,
        categoryBudgets
      ];
}

typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  required double amount,
  required String category,
  Value<String> type,
  Value<String?> note,
  required DateTime date,
  required String monthKey,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  Value<double> amount,
  Value<String> category,
  Value<String> type,
  Value<String?> note,
  Value<DateTime> date,
  Value<String> monthKey,
});

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get monthKey => $composableBuilder(
      column: $table.monthKey, builder: (column) => ColumnFilters(column));
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get monthKey => $composableBuilder(
      column: $table.monthKey, builder: (column) => ColumnOrderings(column));
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get monthKey =>
      $composableBuilder(column: $table.monthKey, builder: (column) => column);
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> monthKey = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            amount: amount,
            category: category,
            type: type,
            note: note,
            date: date,
            monthKey: monthKey,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double amount,
            required String category,
            Value<String> type = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required DateTime date,
            required String monthKey,
          }) =>
              TransactionsCompanion.insert(
            id: id,
            amount: amount,
            category: category,
            type: type,
            note: note,
            date: date,
            monthKey: monthKey,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()>;
typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  Value<int> id,
  required String title,
  required double targetAmount,
  Value<double> currentAmount,
  required DateTime deadline,
  Value<String> color,
  Value<String?> icon,
  required DateTime createdAt,
  Value<bool> isCompleted,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<double> targetAmount,
  Value<double> currentAmount,
  Value<DateTime> deadline,
  Value<String> color,
  Value<String?> icon,
  Value<DateTime> createdAt,
  Value<bool> isCompleted,
});

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => column);

  GeneratedColumn<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);
}

class $$GoalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalsTable,
    Goal,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
    Goal,
    PrefetchHooks Function()> {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<double> targetAmount = const Value.absent(),
            Value<double> currentAmount = const Value.absent(),
            Value<DateTime> deadline = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
          }) =>
              GoalsCompanion(
            id: id,
            title: title,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            deadline: deadline,
            color: color,
            icon: icon,
            createdAt: createdAt,
            isCompleted: isCompleted,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required double targetAmount,
            Value<double> currentAmount = const Value.absent(),
            required DateTime deadline,
            Value<String> color = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            required DateTime createdAt,
            Value<bool> isCompleted = const Value.absent(),
          }) =>
              GoalsCompanion.insert(
            id: id,
            title: title,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            deadline: deadline,
            color: color,
            icon: icon,
            createdAt: createdAt,
            isCompleted: isCompleted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GoalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalsTable,
    Goal,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
    Goal,
    PrefetchHooks Function()>;
typedef $$UserProfileTableCreateCompanionBuilder = UserProfileCompanion
    Function({
  Value<int> id,
  required String name,
  Value<double> monthlySalary,
  Value<String> currency,
  Value<int> themeMode,
  Value<bool> notificationsEnabled,
});
typedef $$UserProfileTableUpdateCompanionBuilder = UserProfileCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<double> monthlySalary,
  Value<String> currency,
  Value<int> themeMode,
  Value<bool> notificationsEnabled,
});

class $$UserProfileTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monthlySalary => $composableBuilder(
      column: $table.monthlySalary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnFilters(column));
}

class $$UserProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monthlySalary => $composableBuilder(
      column: $table.monthlySalary,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnOrderings(column));
}

class $$UserProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get monthlySalary => $composableBuilder(
      column: $table.monthlySalary, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled, builder: (column) => column);
}

class $$UserProfileTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserProfileTable,
    UserProfileData,
    $$UserProfileTableFilterComposer,
    $$UserProfileTableOrderingComposer,
    $$UserProfileTableAnnotationComposer,
    $$UserProfileTableCreateCompanionBuilder,
    $$UserProfileTableUpdateCompanionBuilder,
    (
      UserProfileData,
      BaseReferences<_$AppDatabase, $UserProfileTable, UserProfileData>
    ),
    UserProfileData,
    PrefetchHooks Function()> {
  $$UserProfileTableTableManager(_$AppDatabase db, $UserProfileTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> monthlySalary = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<int> themeMode = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
          }) =>
              UserProfileCompanion(
            id: id,
            name: name,
            monthlySalary: monthlySalary,
            currency: currency,
            themeMode: themeMode,
            notificationsEnabled: notificationsEnabled,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<double> monthlySalary = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<int> themeMode = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
          }) =>
              UserProfileCompanion.insert(
            id: id,
            name: name,
            monthlySalary: monthlySalary,
            currency: currency,
            themeMode: themeMode,
            notificationsEnabled: notificationsEnabled,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserProfileTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserProfileTable,
    UserProfileData,
    $$UserProfileTableFilterComposer,
    $$UserProfileTableOrderingComposer,
    $$UserProfileTableAnnotationComposer,
    $$UserProfileTableCreateCompanionBuilder,
    $$UserProfileTableUpdateCompanionBuilder,
    (
      UserProfileData,
      BaseReferences<_$AppDatabase, $UserProfileTable, UserProfileData>
    ),
    UserProfileData,
    PrefetchHooks Function()>;
typedef $$LessonProgressTableCreateCompanionBuilder = LessonProgressCompanion
    Function({
  required String lessonId,
  Value<bool> completed,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$LessonProgressTableUpdateCompanionBuilder = LessonProgressCompanion
    Function({
  Value<String> lessonId,
  Value<bool> completed,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

class $$LessonProgressTableFilterComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lessonId => $composableBuilder(
      column: $table.lessonId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$LessonProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lessonId => $composableBuilder(
      column: $table.lessonId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$LessonProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$LessonProgressTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LessonProgressTable,
    LessonProgressData,
    $$LessonProgressTableFilterComposer,
    $$LessonProgressTableOrderingComposer,
    $$LessonProgressTableAnnotationComposer,
    $$LessonProgressTableCreateCompanionBuilder,
    $$LessonProgressTableUpdateCompanionBuilder,
    (
      LessonProgressData,
      BaseReferences<_$AppDatabase, $LessonProgressTable, LessonProgressData>
    ),
    LessonProgressData,
    PrefetchHooks Function()> {
  $$LessonProgressTableTableManager(
      _$AppDatabase db, $LessonProgressTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> lessonId = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LessonProgressCompanion(
            lessonId: lessonId,
            completed: completed,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String lessonId,
            Value<bool> completed = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LessonProgressCompanion.insert(
            lessonId: lessonId,
            completed: completed,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LessonProgressTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LessonProgressTable,
    LessonProgressData,
    $$LessonProgressTableFilterComposer,
    $$LessonProgressTableOrderingComposer,
    $$LessonProgressTableAnnotationComposer,
    $$LessonProgressTableCreateCompanionBuilder,
    $$LessonProgressTableUpdateCompanionBuilder,
    (
      LessonProgressData,
      BaseReferences<_$AppDatabase, $LessonProgressTable, LessonProgressData>
    ),
    LessonProgressData,
    PrefetchHooks Function()>;
typedef $$EarnedBadgesTableCreateCompanionBuilder = EarnedBadgesCompanion
    Function({
  required String badgeId,
  required DateTime earnedAt,
  Value<int> rowid,
});
typedef $$EarnedBadgesTableUpdateCompanionBuilder = EarnedBadgesCompanion
    Function({
  Value<String> badgeId,
  Value<DateTime> earnedAt,
  Value<int> rowid,
});

class $$EarnedBadgesTableFilterComposer
    extends Composer<_$AppDatabase, $EarnedBadgesTable> {
  $$EarnedBadgesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get badgeId => $composableBuilder(
      column: $table.badgeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get earnedAt => $composableBuilder(
      column: $table.earnedAt, builder: (column) => ColumnFilters(column));
}

class $$EarnedBadgesTableOrderingComposer
    extends Composer<_$AppDatabase, $EarnedBadgesTable> {
  $$EarnedBadgesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get badgeId => $composableBuilder(
      column: $table.badgeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get earnedAt => $composableBuilder(
      column: $table.earnedAt, builder: (column) => ColumnOrderings(column));
}

class $$EarnedBadgesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EarnedBadgesTable> {
  $$EarnedBadgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get badgeId =>
      $composableBuilder(column: $table.badgeId, builder: (column) => column);

  GeneratedColumn<DateTime> get earnedAt =>
      $composableBuilder(column: $table.earnedAt, builder: (column) => column);
}

class $$EarnedBadgesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EarnedBadgesTable,
    EarnedBadge,
    $$EarnedBadgesTableFilterComposer,
    $$EarnedBadgesTableOrderingComposer,
    $$EarnedBadgesTableAnnotationComposer,
    $$EarnedBadgesTableCreateCompanionBuilder,
    $$EarnedBadgesTableUpdateCompanionBuilder,
    (
      EarnedBadge,
      BaseReferences<_$AppDatabase, $EarnedBadgesTable, EarnedBadge>
    ),
    EarnedBadge,
    PrefetchHooks Function()> {
  $$EarnedBadgesTableTableManager(_$AppDatabase db, $EarnedBadgesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EarnedBadgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EarnedBadgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EarnedBadgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> badgeId = const Value.absent(),
            Value<DateTime> earnedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EarnedBadgesCompanion(
            badgeId: badgeId,
            earnedAt: earnedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String badgeId,
            required DateTime earnedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              EarnedBadgesCompanion.insert(
            badgeId: badgeId,
            earnedAt: earnedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EarnedBadgesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EarnedBadgesTable,
    EarnedBadge,
    $$EarnedBadgesTableFilterComposer,
    $$EarnedBadgesTableOrderingComposer,
    $$EarnedBadgesTableAnnotationComposer,
    $$EarnedBadgesTableCreateCompanionBuilder,
    $$EarnedBadgesTableUpdateCompanionBuilder,
    (
      EarnedBadge,
      BaseReferences<_$AppDatabase, $EarnedBadgesTable, EarnedBadge>
    ),
    EarnedBadge,
    PrefetchHooks Function()>;
typedef $$CategoryBudgetsTableCreateCompanionBuilder = CategoryBudgetsCompanion
    Function({
  required String category,
  required double limitAmount,
  Value<int> rowid,
});
typedef $$CategoryBudgetsTableUpdateCompanionBuilder = CategoryBudgetsCompanion
    Function({
  Value<String> category,
  Value<double> limitAmount,
  Value<int> rowid,
});

class $$CategoryBudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get limitAmount => $composableBuilder(
      column: $table.limitAmount, builder: (column) => ColumnFilters(column));
}

class $$CategoryBudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get limitAmount => $composableBuilder(
      column: $table.limitAmount, builder: (column) => ColumnOrderings(column));
}

class $$CategoryBudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get limitAmount => $composableBuilder(
      column: $table.limitAmount, builder: (column) => column);
}

class $$CategoryBudgetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoryBudgetsTable,
    CategoryBudget,
    $$CategoryBudgetsTableFilterComposer,
    $$CategoryBudgetsTableOrderingComposer,
    $$CategoryBudgetsTableAnnotationComposer,
    $$CategoryBudgetsTableCreateCompanionBuilder,
    $$CategoryBudgetsTableUpdateCompanionBuilder,
    (
      CategoryBudget,
      BaseReferences<_$AppDatabase, $CategoryBudgetsTable, CategoryBudget>
    ),
    CategoryBudget,
    PrefetchHooks Function()> {
  $$CategoryBudgetsTableTableManager(
      _$AppDatabase db, $CategoryBudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryBudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> category = const Value.absent(),
            Value<double> limitAmount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoryBudgetsCompanion(
            category: category,
            limitAmount: limitAmount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String category,
            required double limitAmount,
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoryBudgetsCompanion.insert(
            category: category,
            limitAmount: limitAmount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoryBudgetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoryBudgetsTable,
    CategoryBudget,
    $$CategoryBudgetsTableFilterComposer,
    $$CategoryBudgetsTableOrderingComposer,
    $$CategoryBudgetsTableAnnotationComposer,
    $$CategoryBudgetsTableCreateCompanionBuilder,
    $$CategoryBudgetsTableUpdateCompanionBuilder,
    (
      CategoryBudget,
      BaseReferences<_$AppDatabase, $CategoryBudgetsTable, CategoryBudget>
    ),
    CategoryBudget,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$UserProfileTableTableManager get userProfile =>
      $$UserProfileTableTableManager(_db, _db.userProfile);
  $$LessonProgressTableTableManager get lessonProgress =>
      $$LessonProgressTableTableManager(_db, _db.lessonProgress);
  $$EarnedBadgesTableTableManager get earnedBadges =>
      $$EarnedBadgesTableTableManager(_db, _db.earnedBadges);
  $$CategoryBudgetsTableTableManager get categoryBudgets =>
      $$CategoryBudgetsTableTableManager(_db, _db.categoryBudgets);
}
