import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/app/routes/app_router.dart';
import '../config/theme.dart';

/// 应用根组件
/// 负责设置应用的主题、路由等基础配置
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // 应用程序可见且可响应用户输入]
        break;
      case AppLifecycleState.inactive:
        // 应用程序在不活跃状态，无法响应用户输入
        break;
      case AppLifecycleState.paused:
        // 应用程序完全不可见
        break;
      case AppLifecycleState.detached:
        // 应用程序仍在运行，但已分离UI
        break;
      case AppLifecycleState.hidden:
        // 应用程序不可见
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MediaQuery(
        // 设置文字大小不随系统设置变化
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
        child: MaterialApp.router(
          title: '惜命 (Precious Life)',
          // 使用自定义主题
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          // 使用GoRouter进行路由管理
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        ),
      );
  }
}
