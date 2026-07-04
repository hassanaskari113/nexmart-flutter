import 'package:flutter/material.dart';
import 'package:nexmart/core/constants/app_colors.dart';
import 'package:nexmart/core/constants/app_sizes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      // fontFamily:                 // we will use default for now

      // Color Scheme
      colorScheme: ColorScheme(
        brightness: Brightness.light, // Brightness.light
        primary: AppColors.primary, // AppColors.primary
        onPrimary: AppColors.white, // AppColors.white
        secondary: AppColors.secondary, // AppColors.secondary
        onSecondary: AppColors.white, // AppColors.white
        error: AppColors.error, // AppColors.error
        onError: AppColors.white, // AppColors.white
        background: AppColors.background, // AppColors.background
        onBackground: AppColors.textPrimary, // AppColors.textPrimary
        surface: AppColors.surface, // AppColors.surface
        onSurface: AppColors.textPrimary, // AppColors.textPrimary
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.background, // AppColors.background
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white, // AppColors.white
        foregroundColor: AppColors.textPrimary, // AppColors.textPrimary
        elevation: 0, // 0
        centerTitle: false, // false
        titleTextStyle: TextStyle(
          fontSize: AppSizes.fontXxl,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ), // TextStyle with fontXxl, bold, textPrimary
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // AppColors.primary
          foregroundColor: AppColors.white, // AppColors.white
          minimumSize: Size(double.infinity, AppSizes.buttonHeight), // Size(double.infinity, buttonHeight)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)), // AppSizes.radiusMd
          ),
          textStyle: TextStyle(fontSize: AppSizes.fontLg), // TextStyle fontLg bold
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true, // true
        fillColor: AppColors.white, // AppColors.white
        contentPadding: EdgeInsets.symmetric(
          vertical: AppSizes.md,
          horizontal: AppSizes.md,
        ), // horizontal md vertical md
        hintStyle: TextStyle(
          fontSize: AppSizes.fontMd,
          color: AppColors.textSecondary,
        ), // TextStyle textSecondary fontMd
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)), // AppSizes.radiusMd
          borderSide: BorderSide(color: AppColors.divider), // AppColors.divider
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)), // AppSizes.radiusMd
          borderSide: BorderSide(color: AppColors.divider), // AppColors.divider
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)), // AppSizes.radiusMd
          borderSide: BorderSide(color: AppColors.primary, width: 2), // AppColors.primary width 2
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)), // AppSizes.radiusMd
          borderSide: BorderSide(color: AppColors.error, width: 2), // AppColors.error
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface, // AppColors.surface
        elevation: 2, // 2
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusLg)), // AppSizes.radiusLg
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white, // AppColors.white
        selectedItemColor: AppColors.primary, // AppColors.primary
        unselectedItemColor: AppColors.textSecondary, // AppColors.textSecondary
        type: BottomNavigationBarType.fixed, // BottomNavigationBarType.fixed
        elevation: 8, // 8
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: AppSizes.fontDisplay,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ), // fontDisplay bold textPrimary
        headlineMedium: TextStyle(
          fontSize: AppSizes.fontXxl,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ), // fontXxl bold textPrimary
        titleLarge: TextStyle(
          fontSize: AppSizes.fontXl,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ), // fontXl semibold textPrimary
        titleMedium: TextStyle(
          fontSize: AppSizes.fontLg,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ), // fontLg semibold textPrimary
        bodyLarge: TextStyle(
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ), // fontMd regular textPrimary
        bodyMedium: TextStyle(
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ), // fontMd regular textSecondary
        bodySmall: TextStyle(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ), // fontSm regular textSecondary
        labelLarge: TextStyle(
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ), // fontMd bold white
        labelSmall: TextStyle(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ), // fontXs regular textSecondary
      ),
    );
  }
}
