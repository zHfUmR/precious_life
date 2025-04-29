import 'package:flutter/foundation.dart';

/// API相关常量
/// 定义API端点和相关配置

// API基础配置
class ApiConfig {
  // 私有构造函数，防止外部实例化
  ApiConfig._();
  
  /// API基础URL
  static String baseUrl = kDebugMode 
      ? 'https://api-dev.preciouslife.com/v1' // 开发环境
      : 'https://api.preciouslife.com/v1';    // 生产环境
  
  /// 连接超时（毫秒）
  static const int connectionTimeout = 30000;
  
  /// 接收超时（毫秒）
  static const int receiveTimeout = 30000;
  
  /// API版本
  static const String apiVersion = 'v1';
}

// API端点
class ApiEndpoints {
  // 私有构造函数，防止外部实例化
  ApiEndpoints._();
}

/// 用户相关API端点
class UserEndpoints {
  // 私有构造函数，防止外部实例化
  UserEndpoints._();
  
  /// 登录
  static const String login = '/auth/login';
  
  /// 注册
  static const String register = '/auth/register';
  
  /// 刷新令牌
  static const String refreshToken = '/auth/refresh';
  
  /// 用户信息
  static const String profile = '/users/profile';
  
  /// 更新用户信息
  static const String updateProfile = '/users/profile';
}

/// 待办事项相关API端点
class TodoEndpoints {
  // 私有构造函数，防止外部实例化
  TodoEndpoints._();
  
  /// 获取所有待办事项
  static const String getAll = '/todos';
  
  /// 创建待办事项
  static const String create = '/todos';
  
  /// 更新待办事项
  static const String update = '/todos/{id}';
  
  /// 删除待办事项
  static const String delete = '/todos/{id}';
}

/// 文章相关API端点
class ArticleEndpoints {
  // 私有构造函数，防止外部实例化
  ArticleEndpoints._();
  
  /// 获取所有文章
  static const String getAll = '/articles';
  
  /// 获取文章详情
  static const String getDetail = '/articles/{id}';
  
  /// 按分类获取文章
  static const String getByCategory = '/articles/category/{category}';
  
  /// 获取推荐文章
  static const String getRecommended = '/articles/recommended';
  
  /// 搜索文章
  static const String search = '/articles/search';
}

// HTTP状态码
class HttpStatus {
  // 私有构造函数，防止外部实例化
  HttpStatus._();
  
  /// 成功
  static const int ok = 200;
  
  /// 已创建
  static const int created = 201;
  
  /// 无内容
  static const int noContent = 204;
  
  /// 错误请求
  static const int badRequest = 400;
  
  /// 未授权
  static const int unauthorized = 401;
  
  /// 禁止访问
  static const int forbidden = 403;
  
  /// 未找到
  static const int notFound = 404;
  
  /// 服务器错误
  static const int internalServerError = 500;
} 