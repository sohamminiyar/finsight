import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTextStyles {
  // Editorial Headlines (Plus Jakarta Sans)
  static TextStyle headlineLarge(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.2,
      );

  static TextStyle headlineMedium(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle headlineSmall(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // Body Text (Inter)
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  // Labels & Data (Inter with Tabular Figures)
  static TextStyle labelLarge(BuildContext context) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle labelMedium(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static TextStyle labelSmall(BuildContext context) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  static TextStyle titleMedium(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle displayLarge(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
      );
}
