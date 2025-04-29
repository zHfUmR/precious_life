/// 应用常量
/// 定义应用中使用的各种常量

// 应用信息
class AppInfo {
  // 私有构造函数，防止外部实例化
  AppInfo._();
  
  /// 应用名称
  static const String appName = '惜命 (Precious Life)';
  
  /// 应用版本
  static const String appVersion = '1.0.0';
  
  /// 应用描述
  static const String appDescription = 
      '"惜命"应用旨在帮助用户更好地规划时间、获取有价值的信息并提供实用工具，从而珍惜生命、提高生活质量。';
}

// 本地存储键
class StorageKeys {
  // 私有构造函数，防止外部实例化
  StorageKeys._();
  
  /// 用户信息键
  static const String userInfo = 'user_info';
  
  /// 用户设置键
  static const String userSettings = 'user_settings';
  
  /// 主题模式键
  static const String themeMode = 'theme_mode';
  
  /// 待办事项键
  static const String todos = 'todos';
}

// 路由名称
class Routes {
  // 私有构造函数，防止外部实例化
  Routes._();
  
  /// 主页
  static const String home = '/';
  
  /// 信息流页面
  static const String feed = '/feed';
  
  /// 工具页面
  static const String tools = '/tools';
  
  /// 设置页面
  static const String settings = '/settings';
}

// 时间相关常量
class TimeConstants {
  // 私有构造函数，防止外部实例化
  TimeConstants._();
  
  /// 一天的毫秒数
  static const int dayInMilliseconds = 24 * 60 * 60 * 1000;
  
  /// 一小时的毫秒数
  static const int hourInMilliseconds = 60 * 60 * 1000;
  
  /// 一分钟的毫秒数
  static const int minuteInMilliseconds = 60 * 1000;
}

// 错误消息
class ErrorMessages {
  // 私有构造函数，防止外部实例化
  ErrorMessages._();
  
  /// 网络错误
  static const String networkError = '网络连接错误，请检查您的网络连接';
  
  /// 服务器错误
  static const String serverError = '服务器错误，请稍后再试';
  
  /// 未知错误
  static const String unknownError = '发生未知错误';
} 