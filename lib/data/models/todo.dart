import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

/// 待办事项模型
@freezed
class Todo with _$Todo {
  const factory Todo({
    /// 待办事项唯一ID
    required String id,
    
    /// 标题
    required String title,
    
    /// 详细描述
    String? description,
    
    /// 是否已完成
    @Default(false) bool isCompleted,
    
    /// 完成时间
    DateTime? completedAt,
    
    /// 截止日期
    DateTime? dueDate,
    
    /// 优先级 (1-5，5为最高)
    @Default(3) int priority,
    
    /// 创建时间
    required DateTime createdAt,
    
    /// 最后更新时间
    required DateTime updatedAt,
    
    /// 相关标签
    @Default([]) List<String> tags,
  }) = _Todo;

  /// 从JSON创建待办事项
  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
} 