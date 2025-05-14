import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/features/todo/ui/widgets/dashboard_module.dart';

/// 待办事项页面
class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

/// TodoPage的状态类，混入AutomaticKeepAliveClientMixin以保持页面状态
class _TodoPageState extends ConsumerState<TodoPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 告诉Flutter我们希望保持这个页面的状态

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用super.build
    return const Column(children: [
      DashboardModule(),
    ]);
  }
} 