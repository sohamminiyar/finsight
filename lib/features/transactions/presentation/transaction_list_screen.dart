import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/transaction_providers.dart';
import '../domain/models/transaction_model.dart';
import '../domain/enums/transaction_type.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../../shared/widgets/app_top_navbar.dart';
import 'package:finsight/features/profile/providers/settings_provider.dart';
import 'widgets/transaction_list_item.dart';

// Provider to manage search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionsAsync = ref.watch(transactionListProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final filterType = ref.watch(transactionTypeFilterProvider);

    final dashboardSummaryAsync = ref.watch(dashboardSummaryProvider);
    final settingsAsync = ref.watch(profileSettingsNotifierProvider);
    final currencySymbol = settingsAsync.maybeWhen(
      data: (s) => s.currencySymbol,
      orElse: () => '₹',
    );

    return Scaffold(
      body: transactionsAsync.when(
        loading: () => const CustomScrollView(
          slivers: [
            SliverAppTopNavbar(title: 'History'),
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
        error: (error, stack) => CustomScrollView(
          slivers: [
            SliverAppTopNavbar(title: 'History'),
            SliverFillRemaining(
              child: Center(child: Text('Error: $error')),
            ),
          ],
        ),
        data: (List<TransactionModel> transactions) {
          return CustomScrollView(
            slivers: [
              SliverAppTopNavbar(
                title: 'History',
                streakDays: dashboardSummaryAsync.asData?.value.streakDays,
              ),
              // Pinned Total Spending Card
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 166, // Estimated height for TotalSpendingCard + its margins
                titleSpacing: 0,
                title: TotalSpendingCard(
                  transactions: transactions,
                  symbol: currencySymbol,
                ),
              ),
              
              // Filter Status (if active)
              if (filterType != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Filtering: ${filterType == TransactionType.income ? 'Income' : 'Expenses'}',
                                style: AppTextStyles.bodySmall(context).copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => ref.read(transactionTypeFilterProvider.notifier).state = null,
                                child: const Icon(Icons.close_rounded, size: 16, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              
              // Floating Search Bar
              SliverAppBar(
                floating: true,
                pinned: false,
                snap: true,
                elevation: 0,
                backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
                automaticallyImplyLeading: false,
                centerTitle: false,
                toolbarHeight: 105,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AppTextField(
                    label: 'Search Transactions',
                    hint: 'Search by title or category...',
                    controller: _searchController,
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    validator: (_) => null,
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              
              // Grouped Transaction List
              SliverGroupedTransactionList(
                transactions: transactions,
                searchQuery: searchQuery,
                filterType: filterType,
                symbol: currencySymbol,
                onDelete: (id) {
                  ref.read(transactionListProvider.notifier).deleteTransaction(id);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Total Spending Card Widget
// ---------------------------------------------------------------------
class TotalSpendingCard extends StatelessWidget {
  final List<TransactionModel> transactions;
  final String symbol;

  const TotalSpendingCard({
    super.key, 
    required this.transactions,
    required this.symbol,
  });

  double _getTotalExpenseForMonth(int month, int year) {
    return transactions
        .where((t) {
          final date = t.date;
          return t.type == TransactionType.expense &&
              date.month == month &&
              date.year == year;
        })
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    int lastMonth = currentMonth - 1;
    int lastMonthYear = currentYear;
    if (lastMonth == 0) {
      lastMonth = 12;
      lastMonthYear = currentYear - 1;
    }

    final currentTotal = _getTotalExpenseForMonth(currentMonth, currentYear);
    final lastMonthTotal = _getTotalExpenseForMonth(lastMonth, lastMonthYear);

    String percentChangeText = '';
    bool isLower = false;
    if (lastMonthTotal > 0) {
      final change = ((currentTotal - lastMonthTotal) / lastMonthTotal) * 100;
      isLower = change < 0;
      percentChangeText =
          '${isLower ? '' : '+'}${change.toStringAsFixed(1)}% ${isLower ? 'less' : 'more'} than last month';
    } else if (currentTotal > 0) {
      percentChangeText = '+100% more than last month';
      isLower = false;
    } else {
      percentChangeText = 'No data from last month';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL SPENDING',
            style: AppTextStyles.labelLarge(context).copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(symbol: symbol, decimalDigits: 2).format(currentTotal),
            style: AppTextStyles.displayLarge(context).copyWith(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isLower ? Icons.trending_down : Icons.trending_up,
                size: 18,
                color: isLower ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                percentChangeText,
                style: AppTextStyles.bodySmall(context).copyWith(
                  color: isLower ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Sliver Grouped Transaction List Widget
// ---------------------------------------------------------------------
class SliverGroupedTransactionList extends ConsumerWidget {
  final List<TransactionModel> transactions;
  final String searchQuery;
  final TransactionType? filterType;
  final String symbol;
  final Function(String) onDelete;

  const SliverGroupedTransactionList({
    super.key,
    required this.transactions,
    required this.searchQuery,
    this.filterType,
    required this.symbol,
    required this.onDelete,
  });

  List<TransactionModel> _filterTransactions(List<TransactionModel> transactions) {
    return transactions.where((t) {
      final matchesSearch = searchQuery.isEmpty || 
          t.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesType = filterType == null || t.type == filterType;
      return matchesSearch && matchesType;
    }).toList();
  }

  Map<DateTime, List<TransactionModel>> _groupTransactions(List<TransactionModel> filtered) {
    final Map<DateTime, List<TransactionModel>> groups = {};
    for (var t in filtered) {
      final date = DateTime(t.date.year, t.date.month, t.date.day);
      groups.putIfAbsent(date, () => []).add(t);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return categoriesAsync.when(
      data: (categories) {
        final filtered = _filterTransactions(transactions);
        final grouped = _groupTransactions(filtered);
        
        final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        if (sortedDates.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 80,
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No transactions yet',
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your journey by adding your first insight.',
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.5) : AppColors.lightTextSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final date = sortedDates[index];
                final groupTransactions = grouped[date]!;
                
                String header;
                if (date == today) {
                  header = 'TODAY';
                } else if (date == yesterday) {
                  header = 'YESTERDAY';
                } else {
                  header = DateFormat('MMM dd, yyyy').format(date).toUpperCase();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        header,
                        style: AppTextStyles.labelLarge(context).copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Column(
                        children: groupTransactions.map((tx) {
                          final category = categories.firstWhere(
                            (c) => c.id == tx.categoryId,
                            orElse: () => categories.first,
                          );
                          
                          return TransactionListItem(
                            transaction: tx,
                            categoryName: category.name,
                            categoryIcon: IconMapper.getIcon(category.iconPath),
                            symbol: symbol,
                            onDelete: () => onDelete(tx.id),
                            onLongPress: () => context.push(
                              '/add-transaction?id=${tx.id}',
                              extra: tx,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
              childCount: sortedDates.length,
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => SliverFillRemaining(
        child: Center(child: Text('Error loading data: $err')),
      ),
    );
  }
}