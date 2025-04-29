import 'package:flutter/material.dart';

/// 应用主题配置
/// 定义应用的亮色和暗色主题
class AppTheme {
  // 私有构造函数，防止外部实例化
  AppTheme._();
  
  // 主色调
  static const Color primaryColor = Color(0xFF4A6572);
  static const Color accentColor = Color(0xFF60A3BC);
  
  // 文本颜色
  static const Color textColorLight = Color(0xFF2D3436);
  static const Color textColorDark = Color(0xFFF0F0F0);
  
  // 背景颜色
  static const Color backgroundColorLight = Color(0xFFF5F5F5);
  static const Color backgroundColorDark = Color(0xFF121212);
  
  /// 亮色主题
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundColorLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: textColorLight, fontSize: 22, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: textColorLight, fontSize: 18, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: textColorLight, fontSize: 16),
      bodyMedium: TextStyle(color: textColorLight, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
    iconTheme: const IconThemeData(
      color: primaryColor,
    ),
  );
  
  /// 暗色主题
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: backgroundColorDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: textColorDark, fontSize: 22, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: textColorDark, fontSize: 18, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: textColorDark, fontSize: 16),
      bodyMedium: TextStyle(color: textColorDark, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
    ),
    iconTheme: const IconThemeData(
      color: accentColor,
    ),
  );
} 