// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'b7301c7d5d8c31ff43b3e1262d165aa0f009f713';

/// See also [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<Database>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<Database>;
String _$transactionRepositoryHash() =>
    r'3ca07a53295905c6dc6c962605901bd0cd9c4f83';

/// See also [transactionRepository].
@ProviderFor(transactionRepository)
final transactionRepositoryProvider =
    AutoDisposeProvider<ITransactionRepository>.internal(
      transactionRepository,
      name: r'transactionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$transactionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransactionRepositoryRef =
    AutoDisposeProviderRef<ITransactionRepository>;
String _$categoriesHash() => r'50c925e36d04cd897d532ea8e593858bb84ac487';

/// See also [categories].
@ProviderFor(categories)
final categoriesProvider =
    AutoDisposeFutureProvider<List<CategoryModel>>.internal(
      categories,
      name: r'categoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoriesRef = AutoDisposeFutureProviderRef<List<CategoryModel>>;
String _$transactionListHash() => r'e9a768bb313780689ad8f0e1240dfbdd1cd7beab';

/// See also [TransactionList].
@ProviderFor(TransactionList)
final transactionListProvider =
    AutoDisposeAsyncNotifierProvider<
      TransactionList,
      List<TransactionModel>
    >.internal(
      TransactionList.new,
      name: r'transactionListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$transactionListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TransactionList = AutoDisposeAsyncNotifier<List<TransactionModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
