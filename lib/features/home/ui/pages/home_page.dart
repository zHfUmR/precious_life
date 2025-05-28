import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/core/utils/screen_utils.dart';
import 'package:precious_life/features/feed/ui/pages/feed_page.dart';
import 'package:precious_life/features/todo/ui/pages/todo_page.dart';
import 'package:precious_life/features/tools/ui/pages/tools_page.dart';

/// 主页
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = PageController(initialPage: 1);
    return SafeArea(
        child: Stack(
      fit: StackFit.expand,
      children: [
        // 背景图
        Positioned.fill(
          child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
        ),
        // 毛玻璃效果
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: ClipRect(
            child: Container(
              color: Colors.white.withOpacity(0.2),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
        ),
        // 页面内容
        PageView(
          controller: pageController,
          onPageChanged: (index) {},
          children: const [
            ToolsPage(),
            TodoPage(),
            FeedPage(),
          ],
        ),
      ],
    ));
  }
}
