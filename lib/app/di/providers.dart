import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/todo_repository.dart';
import '../../data/repositories/feed_repository.dart';

/// 应用级依赖注入配置
/// 集中管理全局依赖

// 存储库提供者
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

// 其他全局服务提供者可以在这里定义 