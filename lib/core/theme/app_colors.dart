import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Accents
  static const Color primary = Color(0xFF38BDF8); // Sky Blue
  static const Color primaryDark = Color(0xFF006286); // Sky Blue Depth (Stitch)

  // Status Colors
  static const Color income = Color(0xFF34D399); // Soft Mint Green
  static const Color expense = Color(0xFFFB7185); // Soft Rose

  // Light Mode Colors
  static const Color lightScaffold = Color(0xFFF8FAFC); // Slate White
  static const Color lightCard = Color(0xFFFFFFFF); // Pure White
  static const Color lightTextPrimary = Color(0xFF0F172A); // Deep Charcoal
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate Grey

  // Dark Mode Colors
  static const Color darkScaffold = Color(0xFF0F172A); // Deep Charcoal
  static const Color darkCard = Color(0xFF1E293B); // Blue-Grey
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate White
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate Grey

  // Tonal/Glassmorphism Helpers
  static const Color glassBackgroundLight = Color(0x1AFFFFFF); // 10% Opacity White
  static const Color glassBackgroundDark = Color(0x1A0F172A); // 10% Opacity Charcoal
}
