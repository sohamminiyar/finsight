import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_top_navbar.dart';
import '../../transactions/providers/transaction_providers.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../domain/models/profile_settings.dart';
import '../providers/settings_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPadding = MediaQuery.sizeOf(context).width * 0.06;
    final settingsAsync = ref.watch(profileSettingsNotifierProvider);
    final dashboardSummaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      body: settingsAsync.when(
        loading: () => CustomScrollView(
          slivers: [
            SliverAppTopNavbar(
              title: 'Profile', 
              showBack: true,
              streakDays: dashboardSummaryAsync.asData?.value.streakDays,
            ),
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
        error: (err, stack) => CustomScrollView(
          slivers: [
            SliverAppTopNavbar(
              title: 'Profile', 
              showBack: true,
              streakDays: dashboardSummaryAsync.asData?.value.streakDays,
            ),
            SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
          ],
        ),
        data: (settings) => CustomScrollView(
          slivers: [
            SliverAppTopNavbar(
              title: 'Profile',
              showBack: true,
              streakDays: dashboardSummaryAsync.asData?.value.streakDays,
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              sliver: SliverList(    

                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  // Profile Header
                  _buildProfileHeader(context, ref, settings, isDark),
                  const SizedBox(height: 40),
                  
                  // Financial Goals
                  _buildSectionTitle(context, 'Financial Goals', isDark),
                  const SizedBox(height: 16),
                  _buildDailySpendingLimitCard(context, ref, settings, isDark),
                  const SizedBox(height: 16),
                  _buildMonthlySavingsTargetCard(context, ref, settings, isDark),
                  const SizedBox(height: 16),
                  _buildNoSpendStreakCard(context, ref, settings, isDark),
                  const SizedBox(height: 32),
                  
                  // App Settings
                  _buildSectionTitle(context, 'App Settings', isDark),
                  const SizedBox(height: 16),
                  _buildSettingsCard(context, ref, settings, isDark),
                  const SizedBox(height: 32),
                  
                  // Labs (Coming Soon)
                  _buildSectionTitle(context, 'Labs (Coming Soon)', isDark),
                  const SizedBox(height: 16),
                  _buildLabsCard(context, isDark, 
                    icon: Icons.savings_rounded, 
                    title: 'Emergency Fund Tracker',
                  ),
                  const SizedBox(height: 12),
                  _buildLabsCard(context, isDark, 
                    icon: Icons.analytics_rounded, 
                    title: 'Investment Portfolio',
                  ),
                  const SizedBox(height: 40),
                  
                  // Action Buttons
                  _buildActionButton(
                    context,
                    label: 'Export Transactions (CSV)',
                    icon: Icons.file_upload_outlined,
                    onPressed: () => _exportTransactionsAsCsv(context, ref),
                    color: AppColors.primary,
                    isPrimary: true,
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    label: 'Erase All Data',
                    icon: Icons.delete_outline_rounded,
                    onPressed: () => _showEraseDataDialog(context, ref),
                    color: const Color(0xFFFB7185).withOpacity(0.1),
                    textColor: const Color(0xFFE11D48),
                    isPrimary: false,
                  ),
                  const SizedBox(height: 48),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            hintText: 'Enter your name',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(profileSettingsNotifierProvider.notifier)
                    .setUserName(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref, ProfileSettings settings, bool isDark) {
    final name = settings.userName;
    final initials = name.isNotEmpty 
        ? name.split(' ').map((e) => e[0]).take(2).join('').toUpperCase()
        : '??';

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: AppTextStyles.headlineMedium(context).copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF34D399),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _showEditNameDialog(context, ref, name),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTextStyles.headlineMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF34D399).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_rounded, color: Color(0xFF059669), size: 14),
              const SizedBox(width: 6),
              Text(
                'Secured Local Account',
                style: AppTextStyles.labelSmall(context).copyWith(
                  color: const Color(0xFF059669),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTextStyles.titleMedium(context).copyWith(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDailySpendingLimitCard(BuildContext context, WidgetRef ref, ProfileSettings settings, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Spending Limit',
                style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () => _showManualLimitEntry(context, ref, settings.dailySpendingLimit, settings.currencySymbol),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${settings.currencySymbol} ${settings.dailySpendingLimit.toStringAsFixed(0)}',
                    style: AppTextStyles.labelLarge(context).copyWith(
                      color: AppColors.primaryDark,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.grey.withOpacity(0.2),
              thumbColor: AppColors.primaryDark,
              overlayColor: AppColors.primary.withOpacity(0.1),
              trackHeight: 12,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              // Marks/Ticks
              showValueIndicator: ShowValueIndicator.always,
              valueIndicatorColor: AppColors.primaryDark,
            ),
            child: Slider(
              min: 100,
              max: 5000,
              divisions: 49, // 100 steps
              value: settings.dailySpendingLimit.clamp(100, 5000),
              label: '${settings.currencySymbol} ${settings.dailySpendingLimit.toStringAsFixed(0)}',
              onChanged: (v) {
                ref.read(profileSettingsNotifierProvider.notifier).setDailySpendingLimit(v);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${settings.currencySymbol} 100', style: AppTextStyles.bodySmall(context)),
                Text('${settings.currencySymbol} 5,000', style: AppTextStyles.bodySmall(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showManualLimitEntry(BuildContext context, WidgetRef ref, double currentLimit, String symbol) {
    final controller = TextEditingController(text: currentLimit.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Daily Limit'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            prefixText: '$symbol ',
            hintText: 'e.g. 2500',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newValue = double.tryParse(controller.text);
              if (newValue != null && newValue >= 100 && newValue <= 10000) {
                ref.read(profileSettingsNotifierProvider.notifier).setDailySpendingLimit(newValue);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySavingsTargetCard(BuildContext context, WidgetRef ref, ProfileSettings settings, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target Monthly Savings',
                style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () => _showManualSavingsTargetEntry(context, ref, settings.monthlySavingsTarget, settings.currencySymbol),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${settings.currencySymbol} ${settings.monthlySavingsTarget.toStringAsFixed(0)}',
                    style: AppTextStyles.labelLarge(context).copyWith(
                      color: AppColors.primaryDark,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.grey.withOpacity(0.2),
              thumbColor: AppColors.primaryDark,
              overlayColor: AppColors.primary.withOpacity(0.1),
              trackHeight: 12,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              showValueIndicator: ShowValueIndicator.always,
              valueIndicatorColor: AppColors.primaryDark,
            ),
            child: Slider(
              min: 1000,
              max: 50000,
              divisions: 49,
              value: settings.monthlySavingsTarget.clamp(1000, 50000),
              label: '${settings.currencySymbol} ${settings.monthlySavingsTarget.toStringAsFixed(0)}',
              onChanged: (v) {
                ref.read(profileSettingsNotifierProvider.notifier).setMonthlySavingsTarget(v);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${settings.currencySymbol} 1k', style: AppTextStyles.bodySmall(context)),
                Text('${settings.currencySymbol} 50k', style: AppTextStyles.bodySmall(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showManualSavingsTargetEntry(BuildContext context, WidgetRef ref, double currentTarget, String symbol) {
    final controller = TextEditingController(text: currentTarget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Savings Target'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            prefixText: '$symbol ',
            hintText: 'e.g. 10000',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newValue = double.tryParse(controller.text);
              if (newValue != null && newValue >= 1000) {
                ref.read(profileSettingsNotifierProvider.notifier).setMonthlySavingsTarget(newValue);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSpendStreakCard(BuildContext context, WidgetRef ref, ProfileSettings settings, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly No-Spend Streak Target',
                      style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aim for higher resilience',
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    _buildStepperButton(Icons.remove, () {
                      if (settings.streakTargetDays > 1) {
                        ref.read(profileSettingsNotifierProvider.notifier).setStreakTargetDays(settings.streakTargetDays - 1);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${settings.streakTargetDays}',
                        style: AppTextStyles.titleMedium(context).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    _buildStepperButton(Icons.add, () {
                      if (settings.streakTargetDays < 31) {
                        ref.read(profileSettingsNotifierProvider.notifier).setStreakTargetDays(settings.streakTargetDays + 1);
                      }
                    }, isPrimary: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton(IconData icon, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryDark : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            if (!isPrimary)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
              ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: isPrimary ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, WidgetRef ref, ProfileSettings settings, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsRow(
            context,
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: 'Dark Mode',
            trailing: Switch.adaptive(
              value: settings.isDarkMode, 
              onChanged: (v) => ref.read(profileSettingsNotifierProvider.notifier).toggleTheme(),
              activeColor: AppColors.primaryDark,
            ),
          ),
          _buildDivider(),
          _buildSettingsRow(
            context,
            icon: Icons.payments_outlined,
            title: 'Currency',
            trailing: InkWell(
              onTap: () => _showCurrencyPicker(context, ref),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${settings.currencyCode} ${settings.currencySymbol}', 
                    style: AppTextStyles.bodyMedium(context).copyWith(color: Colors.grey)),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
          _buildDivider(),
          _buildSettingsRow(
            context,
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Lock',
            isEnabled: false,
            trailing: Switch.adaptive(
              value: false, 
              onChanged: null,
            ),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    final currencies = [
      {'code': 'USD', 'symbol': '\$'},
      {'code': 'EUR', 'symbol': '€'},
      {'code': 'INR', 'symbol': '₹'},
      {'code': 'GBP', 'symbol': '£'},
      {'code': 'JPY', 'symbol': '¥'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Currency',
              style: AppTextStyles.headlineSmall(context).copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ...currencies.map((c) => ListTile(
              leading: Text(c['symbol']!, style: const TextStyle(fontSize: 20)),
              title: Text(c['code']!),
              onTap: () {
                Navigator.pop(context); // Close picker
                _showCurrencyConfirmationDialog(context, ref, c['code']!, c['symbol']!);
              },
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _exportTransactionsAsCsv(BuildContext context, WidgetRef ref) async {
    String csvData = '';
    try {
      // 1. Fetch transactions & categories
      final repository = ref.read(transactionRepositoryProvider);
      final transactions = await repository.fetchTransactions();
      final categories = await repository.fetchCategories();
      final categoryMap = {for (var c in categories) c.id: c.name};
      
      if (transactions.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No transactions to export.')),
          );
        }
        return;
      }

      // 2. Prepare CSV data
      final List<List<dynamic>> rows = [];
      
      // Header
      rows.add(['Date', 'Title', 'Category', 'Amount', 'Type', 'Note']);
      
      // Data Rows
      for (var tx in transactions) {
        rows.add([
          DateFormat('yyyy-MM-dd HH:mm').format(tx.date),
          tx.title,
          categoryMap[tx.categoryId] ?? 'Unknown',
          tx.amount,
          tx.type.name,
          tx.note,
        ]);
      }

      // 3. Convert to CSV string
      csvData = const ListToCsvConverter().convert(rows);

      // 4. Save to temporary file
      final directory = await getTemporaryDirectory();
      final path = "${directory.path}/transactions_export_${DateTime.now().millisecondsSinceEpoch}.csv";
      final file = File(path);
      await file.writeAsString(csvData);

      // 5. Share file using share_plus
      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(path)],
          subject: 'FinSight Transactions Export',
          text: 'Here is your transaction history from FinSight.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Graceful fallback for MissingPluginException (common if app wasn't restarted after adding plugin)
        if (e.toString().contains('MissingPluginException')) {
          _showClipboardFallbackDialog(context, csvData);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Export failed: $e')),
          );
        }
      }
    }
  }

  void _showClipboardFallbackDialog(BuildContext context, String csvData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Native Export Unavailable'),
        content: const Text(
          'Native sharing is currently unavailable (try restarting the app). \n\nWould you like to copy the CSV data to your clipboard instead?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvData));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CSV data copied to clipboard.')),
              );
            },
            child: const Text('Copy to Clipboard'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyConfirmationDialog(BuildContext context, WidgetRef ref, String code, String symbol) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline_rounded, color: AppColors.primaryDark, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Switch to $code?',
              style: AppTextStyles.headlineSmall(context).copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'Changing your currency updates the display symbol across the app. It does not convert the value of your existing transactions. Do you want to proceed?',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(context).copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.labelLarge(context).copyWith(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(profileSettingsNotifierProvider.notifier).updateCurrency(code, symbol);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Currency updated to $code ($symbol)')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Proceed'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow(BuildContext context, {
    required IconData icon, 
    required String title, 
    required Widget trailing,
    bool isEnabled = true,
  }) {
    final color = isEnabled ? AppColors.primaryDark : Colors.grey;
    final bgColor = isEnabled ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLarge(context).copyWith(
                fontWeight: FontWeight.w500,
                color: isEnabled ? null : Colors.grey,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildLabsCard(BuildContext context, bool isDark, {required IconData icon, required String title}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkCard : AppColors.lightCard).withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLarge(context).copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'BETA',
              style: AppTextStyles.labelSmall(context).copyWith(color: Colors.grey, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required bool isPrimary,
    Color? textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor ?? Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: textColor ?? (isPrimary ? Colors.white : Colors.black87)),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.titleMedium(context).copyWith(
                color: textColor ?? (isPrimary ? Colors.white : Colors.black87),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
    );
  }

  void _showEraseDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFB7185).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48), size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Erase all data?',
              style: AppTextStyles.headlineSmall(context).copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'This action is permanent and will delete all your transactions, goals, and settings.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(context).copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.labelLarge(context).copyWith(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // 1. Clear database
                      final repository = ref.read(transactionRepositoryProvider);
                      await repository.deleteAllTransactions();
                      
                      // 2. Reset settings
                      await ref.read(profileSettingsNotifierProvider.notifier).resetToDefaults();
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All data has been erased.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Erase'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
