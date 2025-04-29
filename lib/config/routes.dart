import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/todo/ui/pages/todo_page.dart';
import '../features/feed/ui/pages/feed_page.dart';
import '../features/tools/ui/pages/tools_page.dart';

/// 提供应用路由配置的Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          // 主界面包含底部导航栏
          return HomeScaffold(child: child);
        },
        routes: [
          // 待办事项页面
          GoRoute(
            path: '/',
            name: 'todo',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const TodoPage(),
            ),
          ),
          // 信息流页面
          GoRoute(
            path: '/feed',
            name: 'feed',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const FeedPage(),
            ),
          ),
          // 工具页面
          GoRoute(
            path: '/tools',
            name: 'tools',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ToolsPage(),
            ),
          ),
        ],
      ),
    ],
  );
});

/// 主页面脚手架，包含底部导航栏
class HomeScaffold extends StatelessWidget {
  final Widget child;
  
  const HomeScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: '待办',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: '信息流',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handyman),
            label: '工具',
          ),
        ],
      ),
    );
  }

  /// 根据当前路由计算选中的底部导航项
  int _calculateSelectedIndex(BuildContext context) {
    // 获取当前路由路径
    final String location = GoRouterState.of(context).uri.path;
    
    if (location.startsWith('/feed')) {
      return 1;
    } else if (location.startsWith('/tools')) {
      return 2;
    }
    return 0; // 默认选中待办页面
  }

  /// 处理底部导航栏项点击
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
        break;
      case 1:
        GoRouter.of(context).go('/feed');
        break;
      case 2:
        GoRouter.of(context).go('/tools');
        break;
    }
  }
} 