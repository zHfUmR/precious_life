import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/todo_provider.dart';
import '../../../../data/models/todo.dart';

/// 待办事项页面
class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取待办事项列表
    final todoState = ref.watch(todoListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('待办事项'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context, ref);
            },
          ),
        ],
      ),
      body: todoState.when(
        data: (todos) {
          if (todos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('暂无待办事项', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('点击下方按钮添加新的待办事项', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return TodoListItem(todo: todo);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('加载失败: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  /// 显示过滤对话框
  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('筛选待办事项'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('所有'),
                onTap: () {
                  ref.read(todoFilterProvider.notifier).state = TodoFilter.all;
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('待完成'),
                onTap: () {
                  ref.read(todoFilterProvider.notifier).state = TodoFilter.incomplete;
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('已完成'),
                onTap: () {
                  ref.read(todoFilterProvider.notifier).state = TodoFilter.completed;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// 显示添加待办事项对话框
  void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加新待办事项'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '标题',
                  hintText: '输入待办事项标题',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述（可选）',
                  hintText: '输入详细描述',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  ref.read(todoListProvider.notifier).addTodo(
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }
}

/// 待办事项列表项
class TodoListItem extends ConsumerWidget {
  final Todo todo;
  
  const TodoListItem({
    super.key,
    required this.todo,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) {
            ref.read(todoListProvider.notifier).toggleTodoCompletion(todo.id);
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: todo.description != null && todo.description!.isNotEmpty
            ? Text(
                todo.description!,
                style: TextStyle(
                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                _showEditTodoDialog(context, ref, todo);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteConfirmDialog(context, ref, todo);
              },
            ),
          ],
        ),
        onTap: () {
          _showTodoDetailsDialog(context, ref, todo);
        },
      ),
    );
  }
  
  /// 显示待办事项详情对话框
  void _showTodoDetailsDialog(BuildContext context, WidgetRef ref, Todo todo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(todo.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description != null && todo.description!.isNotEmpty) ...[
                const Text('描述:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(todo.description!),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  const Text('状态:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(todo.isCompleted ? '已完成' : '未完成'),
                    backgroundColor: todo.isCompleted ? Colors.green[100] : Colors.grey[300],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('创建时间:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text(_formatDate(todo.createdAt)),
                ],
              ),
              // 暂时注释掉完成时间显示，待功能完善后再添加
              // if (todo.completedAt != null) ...[
              //   const SizedBox(height: 8),
              //   Row(
              //     children: [
              //       const Text('完成时间:', style: TextStyle(fontWeight: FontWeight.bold)),
              //       const SizedBox(width: 8),
              //       Text(_formatDate(todo.completedAt!)),
              //     ],
              //   ),
              // ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }
  
  /// 显示编辑待办事项对话框
  void _showEditTodoDialog(BuildContext context, WidgetRef ref, Todo todo) {
    final titleController = TextEditingController(text: todo.title);
    final descriptionController = TextEditingController(text: todo.description ?? '');
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('编辑待办事项'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '标题',
                  hintText: '输入待办事项标题',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述（可选）',
                  hintText: '输入详细描述',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  ref.read(todoListProvider.notifier).updateTodoById(
                        todo.id,
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }
  
  /// 显示删除确认对话框
  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, Todo todo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除待办事项"${todo.title}"吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                ref.read(todoListProvider.notifier).deleteTodo(todo.id);
                Navigator.pop(context);
              },
              child: const Text('删除', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  
  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
} 