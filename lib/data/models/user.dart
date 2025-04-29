import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// 用户模型
@freezed
class User with _$User {
  const factory User({
    /// 用户唯一ID
    required String id,
    
    /// 用户名
    required String username,
    
    /// 电子邮箱
    required String email,
    
    /// 头像URL
    String? avatarUrl,
    
    /// 昵称/显示名
    String? displayName,
    
    /// 注册时间
    required DateTime createdAt,
    
    /// 最后登录时间
    DateTime? lastLoginAt,
    
    /// 用户角色
    @Default('user') String role,
    
    /// 是否已验证邮箱
    @Default(false) bool isEmailVerified,
    
    /// 用户偏好设置
    @Default({}) Map<String, dynamic> preferences,
  }) = _User;

  /// 从JSON创建用户
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
} 