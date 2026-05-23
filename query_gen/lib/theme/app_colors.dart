import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Cores fixas (independem do tema)
  static const accent     = Color(0xFF2563EB);
  static const accent2    = Color(0xFF3B82F6);
  static const green      = Color(0xFF10B981);
  static const red        = Color(0xFFEF4444);
  static const amber      = Color(0xFFF59E0B);
  static const accentGlow = Color(0x402563EB);

  // Dark mode 
  static const darkBg      = Color(0xFF080C12);
  static const darkPanel   = Color(0xFF0D1320);
  static const darkSurface = Color(0xFF111827);
  static const darkBorder  = Color(0xFF1E2D45);
  static const darkText    = Color(0xFFF0F4FF);
  static const darkText2   = Color(0xFF8899BB);
  static const darkText3   = Color(0xFF4A5E80);

  // Light mode 
  static const lightBg      = Color(0xFFF4F6FB);
  static const lightPanel   = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF8FAFD);
  static const lightBorder  = Color(0xFFDDE3EF);
  static const lightText    = Color(0xFF0F172A);
  static const lightText2   = Color(0xFF4A5E80);
  static const lightText3   = Color(0xFF94A3B8);

  // Aliases estáticos (dark por padrão — retrocompatível) ─
  static const bg      = darkBg;
  static const panel   = darkPanel;
  static const surface = darkSurface;
  static const border  = darkBorder;
  static const text    = darkText;
  static const text2   = darkText2;
  static const text3   = darkText3;

  // Helpers dinâmicos via BuildContext
  static Color bgOf(BuildContext context)      => _d(context) ? darkBg      : lightBg;
  static Color panelOf(BuildContext context)   => _d(context) ? darkPanel   : lightPanel;
  static Color surfaceOf(BuildContext context) => _d(context) ? darkSurface : lightSurface;
  static Color borderOf(BuildContext context)  => _d(context) ? darkBorder  : lightBorder;
  static Color textOf(BuildContext context)    => _d(context) ? darkText    : lightText;
  static Color text2Of(BuildContext context)   => _d(context) ? darkText2   : lightText2;
  static Color text3Of(BuildContext context)   => _d(context) ? darkText3   : lightText3;

  static bool _d(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}