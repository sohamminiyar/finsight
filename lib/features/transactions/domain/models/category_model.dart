import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/transaction_type.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
class CategoryModel with _$CategoryModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CategoryModel({
    required String id,
    required String name,
    required String iconPath,
    required String colorHex,
    required TransactionType type,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
}
