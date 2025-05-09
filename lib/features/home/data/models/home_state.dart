import 'package:flutter/foundation.dart';

/// Home页面状态管理类
/// 
/// 用于存储和管理Home页面的各项状态数据
class HomeState {
  /// 是否正在加载数据
  final bool isLoading;
  
  /// 当前用户名称
  final String userName;
  
  /// 构造函数
  const HomeState({
    this.isLoading = false,
    this.userName = '',
  });

  /// 创建初始状态
  factory HomeState.initial() {
    return const HomeState();
  }

  /// 复制并更新状态
  HomeState copyWith({
    bool? isLoading,
    String? userName,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
    );
  }

  /// 重写相等运算符
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is HomeState &&
        other.isLoading == isLoading &&
        other.userName == userName;
  }

  /// 重写哈希值计算
  @override
  int get hashCode => isLoading.hashCode ^ userName.hashCode;
} 