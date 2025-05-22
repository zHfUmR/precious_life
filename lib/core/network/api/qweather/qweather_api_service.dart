import 'package:precious_life/core/network/api/qweather/qweather_api_client.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_model.dart';

/// 和风天气API服务类
/// 提供一系列发起请求的静态方法
class QweatherApiService {
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
}
