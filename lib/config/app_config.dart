import 'package:flutter/foundation.dart';
import 'package:precious_life/core/utils/storage_utils.dart';

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
    debugPrint('AppConfig: 开始初始化应用配置...');
    
    // 在这里可以进行一些异步的初始化操作
    // 例如：读取本地存储的配置、初始化第三方服务等
    
    // 从存储中加载天气API Key
    try {
      debugPrint('AppConfig: 尝试从存储中加载天气API Key...');
      final savedApiKey = await StorageUtils.instance.getString(StorageKeys.weatherApiKey);
      
      if (savedApiKey != null && savedApiKey.isNotEmpty) {
        qweatherApiKey = savedApiKey;
        debugPrint('AppConfig: 成功加载天气API Key - ${savedApiKey.substring(0, 8)}...');
      } else {
        debugPrint('AppConfig: 存储中没有找到天气API Key');
      }
    } catch (e) {
      debugPrint('AppConfig: 加载天气API Key失败: $e');
      // 确保即使加载失败，qweatherApiKey也保持为空字符串
      qweatherApiKey = "";
    }
    
    debugPrint('AppConfig: 应用配置初始化完成');
    debugPrint('AppConfig: 当前API Key状态 - ${qweatherApiKey.isNotEmpty ? '已配置' : '未配置'}');
  }

  // 当前经纬度
  static double currentLatitude = 0;
  static double currentLongitude = 0;

  // 和风天气【https://dev.qweather.com/docs/】
  static String qweatherBaseUrl = "https://m4359dtk6r.re.qweatherapi.com";
  static String qweatherApiKey = "";

} 