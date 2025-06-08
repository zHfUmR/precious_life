import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

/// 主题模式枚举
/// 支持浅色、深色、蕾姆蓝和拉姆粉四种主题模式
enum AppThemeMode {
  light('light', '浅色模式'),
  dark('dark', '深色模式'),
  remBlue('rem_blue', '蕾姆蓝'),
  ramPink('ram_pink', '拉姆粉');

  const AppThemeMode(this.value, this.label);
  final String value;
  final String label;

  /// 从字符串值创建主题模式
  static AppThemeMode fromString(String value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => AppThemeMode.light,
    );
  }
}

/// 主题状态管理器
/// 负责管理应用的主题模式，支持浅色、深色和跟随系统三种模式
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const String _themeKey = 'app_theme_mode';

  @override
  AppThemeMode build() {
    // 初始化时从本地存储加载主题设置
    _loadThemeFromStorage();
    return AppThemeMode.light;
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
      state = AppThemeMode.light;
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

  /// 切换主题（循环切换）
  Future<void> toggleTheme() async {
    final nextMode = switch (state) {
      AppThemeMode.light => AppThemeMode.dark,
      AppThemeMode.dark => AppThemeMode.remBlue,
      AppThemeMode.remBlue => AppThemeMode.ramPink,
      AppThemeMode.ramPink => AppThemeMode.light,
    };
    await setThemeMode(nextMode);
  }

  /// 获取当前主题的颜色值
  Color get currentThemeColor => switch (state) {
        AppThemeMode.light => const Color(0xFF2196F3),
        AppThemeMode.dark => const Color(0xFF1976D2),
        AppThemeMode.remBlue => const Color(0xFF5A78EA),
        AppThemeMode.ramPink => const Color(0xFFFF4081),
      };
}
