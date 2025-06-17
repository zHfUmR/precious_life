import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/features/feed/ui/pages/feed_page.dart';
import 'package:precious_life/features/todo/ui/pages/todo_page.dart';
import 'package:precious_life/features/tools/ui/pages/tools_page.dart';
import 'package:precious_life/shared/widgets/cp_bottom_navigation_bar.dart';

/// 主页
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 1; // 默认显示TodoPage

  /// 处理底部导航栏点击事件
  void _onBottomNavTap(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            ToolsPage(),
            TodoPage(),
            FeedPage(),
          ],
        ),
      ),
      bottomNavigationBar: CpBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          CpBottomNavItem(
            icon: Icons.build_outlined,
            activeIcon: Icons.build,
            label: '工具',
          ),
          CpBottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: '首页',
          ),
          CpBottomNavItem(
            icon: Icons.rss_feed_outlined,
            activeIcon: Icons.rss_feed,
            label: '探索',
          ),
        ],
      ),
    );
  }
}
