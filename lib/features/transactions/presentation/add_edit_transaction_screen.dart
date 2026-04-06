import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_top_navbar.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../domain/enums/transaction_type.dart';
import '../domain/models/transaction_model.dart';
import '../domain/models/category_model.dart';
import '../providers/transaction_providers.dart';
import '../../../core/utils/icon_mapper.dart';
import 'package:finsight/features/profile/providers/settings_provider.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? initialTransaction;
  final String? initialTransactionId;

  const AddEditTransactionScreen({
    super.key,
    this.initialTransaction,
    this.initialTransactionId,
  });

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen>
    with SingleTickerProviderStateMixin {
  String _amount = '0.00';
  TransactionType _type = TransactionType.expense;
  CategoryModel? _selectedCategory;
  final _titleController = TextEditingController(text: 'New Transaction');
  final _noteController = TextEditingController();
  final _noteFocusNode = FocusNode();
  bool _showAllCategories = false;
  bool _isNoteFocused = false;

  late AnimationController _cursorController;
  late Animation<double> _cursorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeData();

    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cursorAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_cursorController);
    _cursorController.repeat(reverse: true);

    _noteFocusNode.addListener(() {
      setState(() {
        _isNoteFocused = _noteFocusNode.hasFocus;
        if (_isNoteFocused) {
          _showAllCategories = false;
          _cursorController.stop();
        } else {
          _cursorController.repeat(reverse: true);
        }
      });
    });
  }

  Future<void> _initializeData() async {
    // 1. Try directly from widget parameter
    if (widget.initialTransaction != null) {
      _applyTransactionData(widget.initialTransaction!);
      return;
    }

    // 2. Try fetching from ID if provided
    if (widget.initialTransactionId != null) {
      final repo = ref.read(transactionRepositoryProvider);
      final tx = await repo.fetchTransactionById(widget.initialTransactionId!);
      if (tx != null && mounted) {
        setState(() {
          _applyTransactionData(tx);
        });
      }
    }
  }

  void _applyTransactionData(TransactionModel tx) {
    _amount = tx.amount.abs().toStringAsFixed(2);
    if (_amount.endsWith('.00')) _amount = _amount.substring(0, _amount.length - 3);
    _type = tx.type;
    _noteController.text = tx.note;
    _titleController.text = tx.title;
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  void _onNumberPressed(String value) {
    setState(() {
      if (_amount == '0.00') {
        _amount = value;
      } else {
        if (value == '.' && _amount.contains('.')) return;
        if (_amount.contains('.') && _amount.split('.')[1].length >= 2) return;
        _amount += value;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
        if (_amount == '0.') _amount = '0';
      } else {
        _amount = '0.00';
      }
    });
  }

  void _submit() {
    final amountValue = double.tryParse(_amount) ?? 0.0;
    if (amountValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final finalTitle = _noteController.text.isNotEmpty
        ? _noteController.text
        : (_titleController.text.isEmpty || _titleController.text == 'New Transaction'
            ? 'New ${_type.name == 'expense' ? 'Expense' : 'Income'}'
            : _titleController.text);

    final transaction = TransactionModel(
      id: widget.initialTransaction?.id ?? Uuid().v4(),
      title: finalTitle,
      categoryId: _selectedCategory!.id,
      amount: amountValue,
      date: widget.initialTransaction?.date ?? DateTime.now(),
      type: _type,
      note: _noteController.text,
    );

    final notifier = ref.read(transactionListProvider.notifier);
    final Future<void> action = widget.initialTransaction != null
        ? notifier.updateTransaction(transaction)
        : notifier.addTransaction(transaction);

    action.then((_) {
      if (mounted) context.pop();
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    });
  }

  List<CategoryModel> _getSortedCategories(List<CategoryModel> all) {
    if (_selectedCategory == null) return all.take(4).toList();

    final sorted = List<CategoryModel>.from(all);
    // Move selected to front
    sorted.removeWhere((c) => c.id == _selectedCategory!.id);
    sorted.insert(0, _selectedCategory!);
    return sorted.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardSummaryAsync = ref.watch(dashboardSummaryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final settingsAsync = ref.watch(profileSettingsNotifierProvider);
    final currencySymbol = settingsAsync.maybeWhen(
      data: (s) => s.currencySymbol,
      orElse: () => '₹',
    );
    final size = MediaQuery.of(context).size;
    final viewPadding = MediaQuery.of(context).padding;
    final cardHeight = size.height - kToolbarHeight - viewPadding.top;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark ? AppColors.darkScaffold : const Color(0xFFF8F9FB),
      appBar: AppTopNavbar(
        title: widget.initialTransaction != null
            ? 'Edit Transaction'
            : 'Add New Transaction',
        streakDays: dashboardSummaryAsync.asData?.value.streakDays,
      ),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Row: Toggle & Close
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildTypeToggle(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () => context.pop(),
                              icon: Icon(
                                Icons.close,
                                color: isDark ? Colors.white70 : Colors.black45,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Amount Section
                    GestureDetector(
                      onTap: () => _noteFocusNode.unfocus(),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        children: [
                          const Text(
                            'Enter Amount',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                currencySymbol,
                                style: AppTextStyles.headlineLarge(context)
                                    .copyWith(
                                  color: Colors.grey.withValues(alpha: 0.5),
                                  fontSize: 28,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _amount,
                                style: AppTextStyles.headlineLarge(context)
                                    .copyWith(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                              ),
                              if (!_isNoteFocused)
                                FadeTransition(
                                  opacity: _cursorAnimation,
                                  child: Container(
                                    width: 3,
                                    height: 48,
                                    margin: const EdgeInsets.only(left: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          _buildDescriptionField(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Unified Categories & Bottom Area (Numpad or Expanded Grid)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CATEGORY',
                              style: AppTextStyles.labelSmall(context)
                                  .copyWith(
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() {
                                _showAllCategories = !_showAllCategories;
                                if (_showAllCategories) _noteFocusNode.unfocus();
                              }),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                _showAllCategories ? 'Close' : 'View All',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          height: 85,
                          child: categoriesAsync.when(
                            data: (categories) {
                              final filtered =
                                  categories.where((c) => c.type == _type).toList();

                              if (_selectedCategory == null &&
                                  filtered.isNotEmpty) {
                                if (widget.initialTransaction != null) {
                                  _selectedCategory = filtered.firstWhere(
                                    (c) => c.id == widget.initialTransaction!.categoryId,
                                    orElse: () => filtered.first,
                                  );
                                } else {
                                  _selectedCategory = filtered.first;
                                }
                              }

                              final horizontalCats =
                                  _getSortedCategories(filtered);

                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.zero,
                                itemCount: horizontalCats.length,
                                itemBuilder: (context, index) {
                                  final cat = horizontalCats[index];
                                  return _buildCategoryItem(
                                      cat, _selectedCategory?.id == cat.id);
                                },
                              );
                            },
                            loading: () =>
                                const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const SizedBox(),
                          ),
                        ),
                        // Bottom Content: Numpad or Expanded Categories
                        SizedBox(
                          height: 280, // Stable fixed height for interactive area
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _showAllCategories
                                ? _buildExpandedCategoryView(categoriesAsync)
                                : _isNoteFocused
                                    ? const SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: _buildNumpad(),
                                      ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Save Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24, top: 16),
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Save Transaction',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    final isExpense = _type == TransactionType.expense;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.initialTransaction != null;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Opacity(
        opacity: isEditing ? 0.6 : 1.0,
        child: IgnorePointer(
          ignoring: isEditing,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _type = TransactionType.expense;
                    _selectedCategory = null;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: isExpense ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: isExpense
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      'Expense',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isExpense ? AppColors.primary : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _type = TransactionType.income;
                    _selectedCategory = null;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: !isExpense ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: !isExpense
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      'Income',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !isExpense ? AppColors.primary : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(CategoryModel cat, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = cat),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Icon(
                IconMapper.getIcon(cat.iconPath),
                color: isSelected ? Colors.white : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cat.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 240,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _noteController,
        focusNode: _noteFocusNode,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Add a note...',
          hintStyle: TextStyle(
            color: Colors.grey.withValues(alpha: 0.7),
            fontSize: 13,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildExpandedCategoryView(AsyncValue<List<CategoryModel>> categoriesAsync) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkScaffold
            : Colors.grey[50], // Soft background to differentiate from numpad
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: categoriesAsync.when(
        data: (categories) {
          final filtered = categories.where((c) => c.type == _type).toList();
          // Skip first 4 that are already in horizontal list
          final gridCats = filtered.length > 4 ? filtered.sublist(4) : <CategoryModel>[];

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: gridCats.length + 1,
            itemBuilder: (context, index) {
              if (index == gridCats.length) {
                return _buildAddCategoryItem();
              }
              final cat = gridCats[index];
              final isSelected = _selectedCategory?.id == cat.id;
              return _buildCategoryItem(cat, isSelected);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox(),
      ),
    );
  }

  Widget _buildAddCategoryItem() {
    return GestureDetector(
      onTap: _showAddCategoryDialog,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add New',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Category Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              final newCat = CategoryModel(
                id: Uuid().v4(),
                name: controller.text,
                iconPath: 'category_rounded', // Default icon string for IconMapper
                colorHex: '#0080A0', // Default brand color
                type: _type,
              );
              await ref.read(transactionRepositoryProvider).insertCategory(newCat);
              ref.invalidate(categoriesProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(child: _buildNumpadRow(['1', '2', '3'])),
        Flexible(child: _buildNumpadRow(['4', '5', '6'])),
        Flexible(child: _buildNumpadRow(['7', '8', '9'])),
        Flexible(child: _buildNumpadRow(['.', '0', 'delete'])),
      ],
    );
  }

  Widget _buildNumpadRow(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((val) => _buildNumpadButton(val)).toList(),
    );
  }

  Widget _buildNumpadButton(String val) {
    if (val == 'delete') {
      return Expanded(
        child: IconButton(
          onPressed: _onBackspace,
          icon: const Icon(Icons.backspace_outlined, size: 24),
        ),
      );
    }
    return Expanded(
      child: InkWell(
        onTap: () => _onNumberPressed(val),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            val,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}