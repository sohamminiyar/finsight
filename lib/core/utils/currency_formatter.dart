import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String symbol = '₹', String locale = 'en_IN'}) {
    final formatter = NumberFormat.simpleCurrency(
      locale: locale,
      name: symbol == '₹' ? 'INR' : null, // Handle specific symbol mappings if needed
      decimalDigits: 0,
    );
    
    // For simple currency, if we want to force the symbol:
    String formatted = formatter.format(amount);
    if (symbol != '₹' && !formatted.contains(symbol)) {
       // Fallback if NumberFormat doesn't pick up the custom symbol correctly
       return '$symbol${NumberFormat('#,##,###').format(amount)}';
    }
    
    return formatted;
  }
}
