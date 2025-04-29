import 'package:flutter/foundation.dart';

/// 应用配置类
/// 管理应用的全局配置信息
class AppConfig {
  // 私有构造函数，防止外部实例化
  AppConfig._();
  
  // 应用版本
  static String appVersion = '1.0.0';
  
  // API基础URL
  static String apiBaseUrl = kDebugMode 
      ? 'https://api-dev.preciouslife.com/v1' // 开发环境
      : 'https://api.preciouslife.com/v1';    // 生产环境
  
  // 是否启用分析
  static bool enableAnalytics = !kDebugMode;
  
  /// 初始化应用配置
  /// 在应用启动时调用
  static Future<void> initialize() async {
    // 在这里可以进行一些异步的初始化操作
    // 例如：读取本地存储的配置、初始化第三方服务等
    
    debugPrint('AppConfig initialized');
  }
} 