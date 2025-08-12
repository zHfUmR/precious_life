import 'package:flutter/material.dart';
import 'package:precious_life/config/theme/theme_provider.dart';

/// 应用主题配置类
/// 定义了浅色和深色两套主题配置
class AppTheme {
  AppTheme._();

  /// 浅色主题颜色配置
  static const Map<String, Color> _lightThemeColors = {
    'background': Color(0xFFFFFFFF), // 主背景（白）
    'surface': Color(0xFFF5F5F5),   // 次级背景（浅灰）
    'onBackground': Color(0xFF1C1B1F), // 背景上的文字（深灰黑）
    'onSurface': Color(0xFF000000),  // 次级背景上的文字（纯黑）
    'primary': Color(0xFF2196F3),    // 主色（蓝）
    'primaryVariant': Color(0xFF1976D2), // 主色深变体
    'secondary': Color(0xFF4CAF50),  // 辅助色（绿）
    'error': Color(0xFFF44336),      // 错误色（红）
  };

  /// 深色主题颜色配置
  static const Map<String, Color> _darkThemeColors = {
    'background': Color(0xFF121212), // 主背景（深灰黑）
    'surface': Color(0xFF1E1E1E),   // 次级背景（稍亮灰黑）
    'onBackground': Color(0xFFFFFFFF), // 背景上的文字（白）
    'onSurface': Color(0xFFFFFFFF),  // 次级背景上的文字（白）
    'primary': Color(0xFF64B5F6),    // 主色（浅蓝，更柔和）
    'primaryVariant': Color(0xFF1976D2), // 主色深变体（保持一致）
    'secondary': Color(0xFF81C784),  // 辅助色（浅绿）
    'error': Color(0xFFF06292),      // 错误色（浅粉）
  };

  /// 根据主题模式获取对应的主题数据
  static ThemeData getTheme(AppThemeMode mode) {
    final (colors, brightness) = switch (mode) {
      AppThemeMode.light => (_lightThemeColors, Brightness.light),
      AppThemeMode.dark => (_darkThemeColors, Brightness.dark),
    };

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors['primary']!,
      onPrimary: brightness == Brightness.light ? Colors.white : Colors.black,
      secondary: colors['secondary']!,
      onSecondary: brightness == Brightness.light ? Colors.white : Colors.black,
      error: colors['error']!,
      onError: Colors.white,
      surface: colors['surface']!,
      onSurface: colors['onSurface']!,
    );

    return ThemeData(
      useMaterial3: true,
      
      // 使用自定义配色方案
      colorScheme: colorScheme,

      // 文本主题
      textTheme: _textTheme,

      // 卡片主题
      cardTheme: CardThemeData(
        elevation: 4,
        color: colors['surface'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // 应用栏主题
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors['primary'],
        foregroundColor: brightness == Brightness.light ? Colors.white : Colors.black,
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
        backgroundColor: colors['primary'],
        foregroundColor: brightness == Brightness.light ? Colors.white : Colors.black,
      ),

      // 进度指示器主题
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors['primary'],
      ),

      // 脚手架背景色
      scaffoldBackgroundColor: colors['background'],
    );
  }

  /// 浅色主题
  static ThemeData get lightTheme => getTheme(AppThemeMode.light);

  /// 深色主题
  static ThemeData get darkTheme => getTheme(AppThemeMode.dark);

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
    // 更小的字体
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
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );
}
