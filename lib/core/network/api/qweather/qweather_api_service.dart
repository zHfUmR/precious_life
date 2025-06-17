import 'package:precious_life/config/app_config.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_client.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_model.dart';
import 'package:precious_life/core/utils/cp_log.dart';
import 'package:precious_life/core/utils/cp_storage.dart';

/// 和风天气API服务类
/// 提供一系列发起请求的静态方法
class QweatherApiService {

  /// 检查天气Key是否设置
  static Future<bool> isKeyConfigured() async {
    try {
      // 1. 先检查内存中是否配置（AppConfig）
      if (AppConfig.qweatherApiKey.isNotEmpty) return true;
      
      // 2. 再检查存储中是否配置
      final savedApiKey = await CPSP.instance.getString(StorageKeys.weatherApiKey);
      if (savedApiKey != null && savedApiKey.isNotEmpty) {
        // 如果存储中有API Key，更新内存中的配置
        AppConfig.qweatherApiKey = savedApiKey;
        return true;
      }
      // 3. 都没有配置
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 检查天气Key是否有效，直接用key去请求 北京天安门的经纬度：116.4074,39.9042
  /// 返回true表示有效，false表示无效
  static Future<bool> isKeyValid() async {
    try {
      final response = await getNowWeather('116.4074,39.9042');
      CPLog.d('QweatherApiService: 检查天气Key是否有效 - response: ${response.code}');
      if (response.code == '200') return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 城市信息查询接口
  ///
  /// 通过城市名称或经纬度坐标查询城市信息
  ///
  /// [location] 城市名称、ID或经纬度坐标，例如：'深圳'、'101280604'或'113.92,22.53'
  static Future<QweatherCityResponse> lookupCity(String location) async {
    return QweatherApiClient.instance.get<QweatherCityResponse>(
      path: '/geo/v2/city/lookup',
      queryParameters: {'location': location},
      fromJson: QweatherCityResponse.fromJson,
    );
  }

  /// 实时天气查询接口
  ///
  /// 获取指定城市的实时天气信息
  ///
  /// [location] 城市名称、ID或经纬度坐标，例如：'深圳'、'101280604'或'113.92,22.53'
  static Future<QweatherNowResponse> getNowWeather(String location) async {
    return QweatherApiClient.instance.get<QweatherNowResponse>(
      path: '/v7/weather/now',
      queryParameters: {'location': location},
      fromJson: QweatherNowResponse.fromJson,
    );
  }

  /// 分钟级降水查询接口
  ///
  /// 获取指定城市的分钟级降水信息
  ///
  /// [location] 城市名称、ID或经纬度坐标，例如：'深圳'、'101280604'或'113.92,22.53'
  static Future<QweatherMinutelyResponse> getMinutelyRain(String location) async {
    return QweatherApiClient.instance.get<QweatherMinutelyResponse>(
      path: '/v7/minutely/5m',
      queryParameters: {'location': location},
      fromJson: QweatherMinutelyResponse.fromJson,
    );
  }

  /// 7天天气预报查询接口
  ///
  /// 获取指定城市的7天天气预报信息
  ///
  /// [location] 城市名称、ID或经纬度坐标，例如：'深圳'、'101280604'或'113.92,22.53'
  static Future<QweatherDailyResponse> getDailyForecast(String location) async {
    return QweatherApiClient.instance.get<QweatherDailyResponse>(
      path: '/v7/weather/7d',
      queryParameters: {'location': location},
      fromJson: QweatherDailyResponse.fromJson,
    );
  }

  /// 天气预警查询接口
  ///
  /// 获取指定城市的天气预警信息
  ///
  /// [location] 城市名称、ID或经纬度坐标，例如：'深圳'、'101280604'或'113.92,22.53'
  static Future<QweatherWarningResponse> getWeatherWarning(String location) async {
    return QweatherApiClient.instance.get<QweatherWarningResponse>(
      path: '/v7/warning/now',
      queryParameters: {'location': location},
      fromJson: QweatherWarningResponse.fromJson,
    );
  }

  /// 24小时逐小时天气预报查询接口
  ///
  /// 获取指定城市的24小时逐小时天气预报信息
  ///
  /// [location] 城市名称、ID或经纬度坐标，例如：'深圳'、'101280604'或'113.92,22.53'
  static Future<QweatherHourlyResponse> getHourlyForecast(String location) async {
    return QweatherApiClient.instance.get<QweatherHourlyResponse>(
      path: '/v7/weather/24h',
      queryParameters: {'location': location},
      fromJson: QweatherHourlyResponse.fromJson,
    );
  }


}
