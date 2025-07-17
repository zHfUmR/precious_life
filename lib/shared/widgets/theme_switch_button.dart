import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/config/theme/theme_provider.dart';

/// 主题切换按钮组件
/// 支持点击切换和长按选择主题模式
class ThemeSwitchButton extends ConsumerWidget {
  /// 按钮样式
  final ThemeSwitchButtonStyle style;

  const ThemeSwitchButton({
    super.key,
    this.style = ThemeSwitchButtonStyle.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return switch (style) {
      ThemeSwitchButtonStyle.icon => _buildIconButton(context, currentTheme, themeNotifier),
      ThemeSwitchButtonStyle.tile => _buildListTile(context, currentTheme, themeNotifier),
      ThemeSwitchButtonStyle.card => _buildCard(context, currentTheme, themeNotifier),
    };
  }

  /// 构建图标按钮样式
  Widget _buildIconButton(BuildContext context, AppThemeMode currentTheme, ThemeNotifier themeNotifier) {
    return GestureDetector(
      onTap: () => themeNotifier.toggleTheme(),
      onLongPress: () => _showThemeSelector(context, themeNotifier),
      child: Tooltip(
        message: '点击切换主题，长按选择主题模式',
        child: Icon(
          _getThemeIcon(currentTheme),
          size: 18,
        ),
      ),
    );
  }

  /// 构建列表项样式
  Widget _buildListTile(BuildContext context, AppThemeMode currentTheme, ThemeNotifier themeNotifier) {
    return ListTile(
      leading: Icon(_getThemeIcon(currentTheme)),
      title: const Text('主题模式'),
      subtitle: Text(currentTheme.label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeSelector(context, themeNotifier),
    );
  }

  /// 构建卡片样式
  Widget _buildCard(BuildContext context, AppThemeMode currentTheme, ThemeNotifier themeNotifier) {
    return Card(
      child: InkWell(
        onTap: () => _showThemeSelector(context, themeNotifier),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(_getThemeIcon(currentTheme), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('主题模式', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      currentTheme.label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  /// 根据主题模式获取对应图标
  IconData _getThemeIcon(AppThemeMode mode) => switch (mode) {
        AppThemeMode.light => Icons.light_mode, // 浅色模式
        AppThemeMode.dark => Icons.dark_mode, // 深色模式
      };

  /// 显示主题选择器
  void _showThemeSelector(BuildContext context, ThemeNotifier themeNotifier) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ThemeSelector(themeNotifier: themeNotifier),
    );
  }
}

/// 主题切换按钮样式枚举
enum ThemeSwitchButtonStyle {
  icon, // 图标按钮
  tile, // 列表项
  card, // 卡片
}

/// 主题选择器组件
class ThemeSelector extends ConsumerWidget {
  final ThemeNotifier themeNotifier;

  const ThemeSelector({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              const Icon(Icons.palette),
              const SizedBox(width: 8),
              Text(
                '选择主题模式',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 主题选项列表
          ...AppThemeMode.values.map((mode) => ListTile(
                leading: Icon(_getThemeIcon(mode)),
                title: Text(mode.label),
                trailing: currentTheme == mode ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  themeNotifier.setThemeMode(mode);
                  Navigator.of(context).pop();
                },
              )),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// 根据主题模式获取对应图标
  IconData _getThemeIcon(AppThemeMode mode) => switch (mode) {
        AppThemeMode.light => Icons.light_mode, // 浅色模式
        AppThemeMode.dark => Icons.dark_mode, // 深色模式
      };
}
