import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

/// 主题模式枚举
/// 支持浅色和深色两种主题模式
enum AppThemeMode {
  light('light', '浅色模式'),
  dark('dark', '深色模式');

  const AppThemeMode(this.value, this.label);
  final String value;
  final String label;

  /// 从字符串值创建主题模式
  static AppThemeMode fromString(String value) => AppThemeMode.values.firstWhere(
        (mode) => mode.value == value,
        orElse: () => AppThemeMode.dark,
      );
}

/// 主题状态管理器
/// 负责管理应用的主题模式，支持浅色和深色两种模式
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const String _themeKey = 'app_theme_mode';

  @override
  AppThemeMode build() {
    // 初始化时从本地存储加载主题设置
    _loadThemeFromStorage();
    return AppThemeMode.dark;
  }

  /// 从本地存储加载主题设置
  Future<void> _loadThemeFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      if (savedTheme != null) {
        state = AppThemeMode.fromString(savedTheme);
      }
    } catch (e) {
      // 加载失败时使用默认主题
      state = AppThemeMode.dark;
    }
  }

  /// 保存主题设置到本地存储
  Future<void> _saveThemeToStorage(AppThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.value);
    } catch (e) {
      // 保存失败时仅记录错误，不影响主题切换
    }
  }

  /// 切换到指定主题模式
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    await _saveThemeToStorage(mode);
  }

  /// 切换主题（在浅色和深色之间切换）
  Future<void> toggleTheme() async {
    final nextMode = state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
    await setThemeMode(nextMode);
  }

  /// 获取当前主题的颜色值
  Color get currentThemeColor => switch (state) {
        AppThemeMode.light => const Color(0xFF2196F3),
        AppThemeMode.dark => const Color(0xFF64B5F6),
      };
}
