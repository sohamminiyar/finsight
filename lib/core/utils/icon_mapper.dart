import 'package:flutter/material.dart';

class IconMapper {
  static IconData getIcon(String iconPath) {
    switch (iconPath) {
      case 'assets/icons/groceries.png':
        return Icons.shopping_basket_outlined;
      case 'assets/icons/salary.png':
        return Icons.account_balance_wallet_outlined;
      case 'assets/icons/transport.png':
        return Icons.directions_car_outlined;
      case 'assets/icons/entertainment.png':
        return Icons.local_play_outlined;
      case 'assets/icons/dining.png':
        return Icons.restaurant_outlined;
      case 'assets/icons/freelance.png':
        return Icons.work_outline_rounded;
      case 'assets/icons/rent.png':
        return Icons.home_outlined;
      case 'assets/icons/health.png':
        return Icons.health_and_safety_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
