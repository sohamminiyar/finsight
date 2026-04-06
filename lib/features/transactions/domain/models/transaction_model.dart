import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/transaction_type.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
class TransactionModel with _$TransactionModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TransactionModel({
    required String id,
    required String title,
    required String categoryId,
    required double amount,
    required String note,
    required DateTime date,
    required TransactionType type,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}
