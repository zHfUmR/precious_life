import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';

/// Todo仓库提供者
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

/// 待办事项仓库
/// 负责管理待办事项的CRUD操作
class TodoRepository {
  // 模拟的待办事项数据
  final List<Todo> _todos = [];
  
  /// 获取所有待办事项
  Future<List<Todo>> getAllTodos() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    return _todos;
  }
  
  /// 根据ID获取待办事项
  Future<Todo?> getTodoById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _todos.firstWhere((todo) => todo.id == id);
  }
  
  /// 创建新的待办事项
  Future<Todo> createTodo(Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _todos.add(todo);
    return todo;
  }
  
  /// 更新待办事项
  Future<Todo> updateTodo(Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index >= 0) {
      _todos[index] = todo;
      return todo;
    }
    throw Exception('找不到ID为 ${todo.id} 的待办事项');
  }
  
  /// 删除待办事项
  Future<void> deleteTodo(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _todos.removeWhere((todo) => todo.id == id);
  }
  
  /// 完成/取消完成待办事项
  Future<Todo> toggleTodoCompletion(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _todos.indexWhere((t) => t.id == id);
    if (index >= 0) {
      final todo = _todos[index];
      final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
      _todos[index] = updatedTodo;
      return updatedTodo;
    }
    throw Exception('找不到ID为 $id 的待办事项');
  }
  
  /// 获取未完成的待办事项
  Future<List<Todo>> getIncompleteTodos() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _todos.where((todo) => !todo.isCompleted).toList();
  }
  
  /// 获取已完成的待办事项
  Future<List<Todo>> getCompletedTodos() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _todos.where((todo) => todo.isCompleted).toList();
  }
} 