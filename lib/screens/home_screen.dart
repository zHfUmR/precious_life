import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/features/todo/ui/pages/todo_page.dart';
import 'package:precious_life/features/feed/ui/pages/feed_page.dart';
import 'package:precious_life/features/tools/ui/pages/tools_page.dart';

/// 页面索引提供者
final currentPageProvider = StateProvider<int>((ref) => 0);

/// 主页面
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// PageView控制器
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(currentPageProvider);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          ref.read(currentPageProvider.notifier).state = index;
        },
        children: const [
          TodoPage(),
          FeedPage(),
          ToolsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: '任务',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            label: '信息流',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets),
            label: '工具',
          ),
        ],
      ),
    );
  }
} 