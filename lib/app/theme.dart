import 'package:flutter/material.dart';

/// رموز الهوية البصرية — منقولة من `globals.css` بنفس القيم بالحرف.
class AppColors {
  AppColors._();

  static const gold = Color(0xFFC9A227);
  static const goldLight = Color(0xFFE7C65A);
  static const goldDark = Color(0xFFA8851A);

  static const navy = Color(0xFF0F1B3D);
  static const navy2 = Color(0xFF1A2A5E);

  // ألوان الفاتورة — لا تُغيّر أبدًا
  static const invoiceNavy = Color(0xFF0E10B3);
  static const invoiceBlue = Color(0xFF1F9CF0);
  static const invoiceHeaderBg = Color(0xFFFCD5B4);

  // أزرار
  static const btnBlue1 = Color(0xFF2563EB);
  static const btnBlue2 = Color(0xFF1D4ED8);
  static const btnBlue3 = Color(0xFF1E40AF);
  static const btnRed1 = Color(0xFFEF4444);
  static const btnRed2 = Color(0xFFDC2626);
  static const btnRed3 = Color(0xFFB91C1C);

  // خلفيات
  static const surface = Color(0xFFF6F8FC);
  static const cardTop = Color(0xFFFFFFFF);
  static const cardBottom = Color(0xFFEEF2F9);
  static const border = Color(0x1A0F1B3D);

  static const textPrimary = Color(0xFF0F1B3D);
  static const textMuted = Color(0xFF64748B);
  static const navText = Color(0xFFC7CEE0);

  // ألوان بطاقات الإحصائيات
  static const statBlue = Color(0xFF3B82F6);
  static const statGreen = Color(0xFF22C55E);
  static const statPurple = Color(0xFF8B5CF6);
  static const statOrange = Color(0xFFF97316);
  static const statYellow = Color(0xFFEAB308);
  static const statEmerald = Color(0xFF10B981);
}

const String kFontFamily = 'IBMPlexSansArabic';

class AppRadius {
  AppRadius._();
  static const card = 18.0;
  static const button = 14.0;
  static const field = 14.0;
  static const nav = 26.0;
}

/// ظلال متعددة الطبقات (تقليد ظلال CSS الفاخرة)
class AppShadows {
  AppShadows._();

  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x0F0F1B3D), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x140F1B3D), blurRadius: 18, offset: Offset(0, 10)),
  ];

  static const cardHover = <BoxShadow>[
    BoxShadow(color: Color(0x1A0F1B3D), blurRadius: 26, offset: Offset(0, 16)),
  ];

  static const button = <BoxShadow>[
    BoxShadow(color: Color(0x332563EB), blurRadius: 14, offset: Offset(0, 6)),
  ];

  static const nav = <BoxShadow>[
    BoxShadow(color: Color(0x400F1B3D), blurRadius: 24, offset: Offset(0, 10)),
  ];
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: kFontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      primary: AppColors.navy,
      secondary: AppColors.gold,
      surface: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.surface,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: kFontFamily,
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: kFontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: kFontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFF9AA5B8), fontSize: 14),
      labelStyle: const TextStyle(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: Color(0xFFD8DEE9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: Color(0xFFD8DEE9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.btnBlue1, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.btnRed2, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.btnRed2, width: 1.6),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.navy,
      contentTextStyle: const TextStyle(
        fontFamily: kFontFamily,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      textStyle: const TextStyle(
        fontFamily: kFontFamily,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE6EAF2),
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.gold,
    ),
  );
}
