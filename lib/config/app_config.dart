import 'package:flutter/foundation.dart';
import 'package:precious_life/core/utils/cp_storage.dart';

/// 应用配置类
/// 管理应用的全局配置信息
class AppConfig {
  // 私有构造函数，防止外部实例化
  AppConfig._();


  /// 初始化应用配置
  /// 在应用启动时调用
  static Future<void> initialize() async {
    // 在这里可以进行一些异步的初始化操作
    // 例如：读取本地存储的配置、初始化第三方服务等

    // 从存储中加载天气API Key
    try {
      final savedApiKey = await CPSP.instance.getString(StorageKeys.weatherApiKey);

      if (savedApiKey != null && savedApiKey.isNotEmpty) {
        qweatherApiKey = savedApiKey;
      }
    } catch (e) {
      // 确保即使加载失败，qweatherApiKey也保持为空字符串
      qweatherApiKey = "";
    }
  }

  // 当前经纬度
  static double currentLatitude = 0;
  static double currentLongitude = 0;
  // 当前定位地址
  static String currentAddress = "";

  // 和风天气【https://dev.qweather.com/docs/】
  static String qweatherBaseUrl = "https://m4359dtk6r.re.qweatherapi.com";
  static String qweatherApiKey = "";

  // 天地图【http://lbs.tianditu.gov.cn/server/geocoding.html】
  static String tiandituBaseUrl = "http://api.tianditu.gov.cn";
  static String tiandituApiKey = "";
}
