import 'package:flutter/material.dart';
import 'package:precious_life/config/theme/theme_provider.dart';

/// 应用主题配置类
/// 定义了蕾姆蓝和拉姆粉两套主题配置
class AppTheme {
  AppTheme._();

  /// 浅色主题色
  static const Color _lightColor = Color(0xFF2196F3);

  /// 深色主题色
  static const Color _darkColor = Color(0xFF1976D2);

  /// 蕾姆蓝主题色
  static const Color _remBlueColor = Color(0xFF5A78EA);

  /// 拉姆粉主题色
  static const Color _ramPinkColor = Color(0xFFFF4081);

  /// 根据主题模式获取对应的主题数据
  static ThemeData getTheme(AppThemeMode mode) {
    final (seedColor, brightness) = switch (mode) {
      AppThemeMode.light => (_lightColor, Brightness.light),
      AppThemeMode.dark => (_darkColor, Brightness.dark),
      AppThemeMode.remBlue => (_remBlueColor, Brightness.light),
      AppThemeMode.ramPink => (_ramPinkColor, Brightness.light),
    };

    return ThemeData(
      useMaterial3: true,

      // 使用种子颜色生成配色方案
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),

      // 文本主题
      textTheme: _textTheme,

      // 卡片主题
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // 应用栏主题
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: seedColor,
        foregroundColor: Colors.white,
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // 浮动操作按钮主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: seedColor,
        foregroundColor: Colors.white,
      ),

      // 进度指示器主题
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: seedColor,
      ),
    );
  }

  /// 浅色主题
  static ThemeData get lightTheme => getTheme(AppThemeMode.light);

  /// 深色主题
  static ThemeData get darkTheme => getTheme(AppThemeMode.dark);

  /// 蕾姆蓝主题
  static ThemeData get remBlueTheme => getTheme(AppThemeMode.remBlue);

  /// 拉姆粉主题
  static ThemeData get ramPinkTheme => getTheme(AppThemeMode.ramPink);

  /// 统一的文本主题配置
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );
}
