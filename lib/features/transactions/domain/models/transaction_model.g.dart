// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionModelImpl _$$TransactionModelImplFromJson(
  Map<String, dynamic> json,
) => _$TransactionModelImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  categoryId: json['category_id'] as String,
  amount: (json['amount'] as num).toDouble(),
  note: json['note'] as String,
  date: DateTime.parse(json['date'] as String),
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
);

Map<String, dynamic> _$$TransactionModelImplToJson(
  _$TransactionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'category_id': instance.categoryId,
  'amount': instance.amount,
  'note': instance.note,
  'date': instance.date.toIso8601String(),
  'type': _$TransactionTypeEnumMap[instance.type]!,
};

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
};
