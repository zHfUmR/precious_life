import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/routes.dart';
import '../config/theme.dart';

/// 应用根组件
/// 负责设置应用的主题、路由等基础配置
class PreciousLifeApp extends ConsumerWidget {
  const PreciousLifeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取路由配置
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '惜命 (Precious Life)',
      // 使用自定义主题
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // 跟随系统主题
      // 使用GoRouter进行路由管理
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
} 