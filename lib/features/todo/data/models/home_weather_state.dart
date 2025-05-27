import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_model.dart';
import 'package:precious_life/shared/widgets/loading_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/core/utils/weather_utils.dart';
import 'package:precious_life/features/todo/ui/models/followed_city.dart';

part 'home_weather_state.freezed.dart';

/// 关注城市天气数据模型
@freezed
class FollowedCityWeather with _$FollowedCityWeather {
  const factory FollowedCityWeather({
    required FollowedCity city,
    QweatherNow? weather,
    String? errorMessage,
  }) = _FollowedCityWeather;
}

@freezed
class HomeWeatherState with _$HomeWeatherState {
  const factory HomeWeatherState({
    required LoadingStatus currentLoadingStatus, // 当前城市加载状态
    String? currentErrorMessage, // 错误信息
    String? currentCity, // 当前定位城市
    double? currentLatitude, // 当前定位经纬度
    double? currentLongitude, // 当前定位经纬度
    QweatherNow? currentWeather, // 当前天气
    QweatherMinutelyResponse? currentMinutelyRain, // 当前分钟级降雨
    List<String>? cityList, // 城市列表
    required LoadingStatus cityLoadingStatus, // 城市列表加载状态
    String? cityErrorMessage, // 城市列表错误信息
    List<QweatherNow>? cityWeatherList, // 城市列表天气
    List<FollowedCityWeather>? followedCitiesWeather, // 关注城市天气列表
  }) = _HomeWeatherState;
}

/// HomeWeatherState的扩展类
/// 提供对天气数据的格式化处理
extension HomeWeatherStateExt on HomeWeatherState {
  /// 获取格式化后的更新时间
  /// 将obsTime格式化为HH:mm格式
  String get updateTime => WeatherUtils.formatUpdateTime(currentWeather?.obsTime);

  /// 获取当前天气Text组件
  /// 根据天气代码返回对应的带颜色文本组件
  Text get weatherText => WeatherUtils.getWeatherText(currentWeather?.icon, currentWeather?.text);
}
