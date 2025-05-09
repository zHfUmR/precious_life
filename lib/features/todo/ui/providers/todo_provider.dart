import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/models/todo.dart';
import '../../../../data/repositories/todo_repository.dart';

/// 待办事项过滤器类型
enum TodoFilter {
  /// 所有待办事项
  all,
  
  /// 未完成的待办事项
  incomplete,
  
  /// 已完成的待办事项
  completed,
}

/// 当前选择的过滤器
final todoFilterProvider = StateProvider<TodoFilter>((ref) {
  return TodoFilter.all;
});

/// 提供过滤后的待办事项列表
final todoListProvider = AsyncNotifierProvider<TodoListNotifier, List<Todo>>(() {
  return TodoListNotifier();
});

/// 待办事项列表状态管理器
class TodoListNotifier extends AsyncNotifier<List<Todo>> {
  /// 待办事项仓库
  late final TodoRepository _repository;
  
  @override
  Future<List<Todo>> build() async {
    // 获取仓库实例
    _repository = ref.read(todoRepositoryProvider);
    
    // 监听过滤器变化
    ref.watch(todoFilterProvider);
    
    // 根据过滤器获取待办事项
    return _getFilteredTodos();
  }
  
  /// 获取过滤后的待办事项
  Future<List<Todo>> _getFilteredTodos() async {
    final filter = ref.read(todoFilterProvider);
    
    switch (filter) {
      case TodoFilter.all:
        return _repository.getAllTodos();
      case TodoFilter.incomplete:
        return _repository.getIncompleteTodos();
      case TodoFilter.completed:
        return _repository.getCompletedTodos();
    }
  }
  
  /// 添加新的待办事项
  Future<void> addTodo({
    required String title,
    String? description,
    DateTime? dueDate,
    int priority = 3,
  }) async {
    // 设置加载状态
    state = const AsyncValue.loading();
    
    // 创建新的待办事项
    final newTodo = Todo(
      id: const Uuid().v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    state = await AsyncValue.guard(() async {
      // 保存到仓库
      await _repository.createTodo(newTodo);
      // 返回更新后的列表
      return _getFilteredTodos();
    });
  }
  
  /// 删除待办事项
  Future<void> deleteTodo(String id) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await _repository.deleteTodo(id);
      return _getFilteredTodos();
    });
  }
  
  /// 删除待办事项（别名，用于向后兼容）
  Future<void> removeTodo(String id) async {
    return deleteTodo(id);
  }
  
  /// 切换待办事项完成状态
  Future<void> toggleTodoCompletion(String id) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      // 获取当前待办事项
      final todos = await _repository.getAllTodos();
      final todoToUpdate = todos.firstWhere((todo) => todo.id == id);
      
      // 切换完成状态，并在完成时设置completedAt字段
      final isCompleted = !todoToUpdate.isCompleted;
      final updatedTodo = todoToUpdate.copyWith(
        isCompleted: isCompleted,
        completedAt: isCompleted ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );
      
      await _repository.updateTodo(updatedTodo);
      return _getFilteredTodos();
    });
  }
  
  /// 更新待办事项
  Future<void> updateTodo(Todo todo) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await _repository.updateTodo(todo);
      return _getFilteredTodos();
    });
  }
  
  /// 按ID更新待办事项，提供部分更新能力
  Future<void> updateTodoById(
    String id, {
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? dueDate,
    int? priority,
  }) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      // 获取当前待办事项
      final todos = await _repository.getAllTodos();
      final todoToUpdate = todos.firstWhere((todo) => todo.id == id);
      
      // 创建更新后的待办事项
      final updatedTodo = todoToUpdate.copyWith(
        title: title ?? todoToUpdate.title,
        description: description ?? todoToUpdate.description,
        isCompleted: isCompleted ?? todoToUpdate.isCompleted,
        completedAt: completedAt ?? todoToUpdate.completedAt,
        dueDate: dueDate ?? todoToUpdate.dueDate,
        priority: priority ?? todoToUpdate.priority,
        updatedAt: DateTime.now(),
      );
      
      await _repository.updateTodo(updatedTodo);
      return _getFilteredTodos();
    });
  }
} 