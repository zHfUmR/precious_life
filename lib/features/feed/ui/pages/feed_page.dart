import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 信息流页面
/// 显示用户的信息流内容，包括文章、动态等
class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

/// FeedPage的状态类，混入AutomaticKeepAliveClientMixin以保持页面状态
class _FeedPageState extends ConsumerState<FeedPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 告诉Flutter我们希望保持这个页面的状态

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用super.build
    return Scaffold(
      body: Container(
        color: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
