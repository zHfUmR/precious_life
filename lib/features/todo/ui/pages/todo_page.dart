import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/features/todo/ui/widgets/dashboard_module.dart';

/// 待办事项页面
class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      return const Column(children: [
        DashboardModule(),
      ]);
    });
  }
} 