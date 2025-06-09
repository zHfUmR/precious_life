import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_model.dart';
import 'package:precious_life/shared/widgets/loading_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:precious_life/core/utils/weather_utils.dart';
import 'package:precious_life/features/todo/ui/models/followed_city.dart';

part 'weather_card_state.freezed.dart';

/// WeatherCard 主状态类
@freezed
class WeatherCardState with _$WeatherCardState {
  const factory WeatherCardState({
    required WeatherCardConfigState weatherConfigState, // 天气配置状态
    required WeatherCardLocationState weatherLocationState, // 天气定位状态
    required WeatherCardFollowedState weatherFollowedState, // 关注城市状态
    required bool isExpanded, // 关注城市列表是否展开
  }) = _WeatherCardState;
}

/// WeatherCard 天气配置状态
@freezed
class WeatherCardConfigState with _$WeatherCardConfigState {
  const factory WeatherCardConfigState({
    required LoadingStatus loadingStatus,
    String? errorMessage,
  }) = _WeatherCardConfigState;
}

/// WeatherCard 天气定位状态
@freezed
class WeatherCardLocationState with _$WeatherCardLocationState {
  const factory WeatherCardLocationState({
    required LoadingStatus loadingStatus,
    String? errorMessage,
    String? requestIP, // 请求发起的 IP 地址
    String? currentCity, // 当前定位城市
    String? currentAddress, // 当前定位地址
    double? currentLatitude, // 当前定位经纬度
    double? currentLongitude, // 当前定位经纬度
    QweatherNow? currentWeather, // 当前天气
    QweatherMinutelyResponse? currentMinutelyRain, // 当前分钟级降雨
  }) = _WeatherCardLocationState;
}

/// WeatherCard 关注城市天气状态
@freezed
class WeatherCardFollowedState with _$WeatherCardFollowedState {
  const factory WeatherCardFollowedState({
    required LoadingStatus loadingStatus,
    String? errorMessage,
    List<WeatherCardFollowedCityWeather>? followedCitiesWeather, // 关注城市天气列表
  }) = _WeatherCardFollowedState;
}

/// WeatherCard 关注城市天气数据模型
@freezed
class WeatherCardFollowedCityWeather with _$WeatherCardFollowedCityWeather {
  const factory WeatherCardFollowedCityWeather({
    required FollowedCity city,
    required LoadingStatus loadingStatus,
    QweatherNow? weather,
    String? errorMessage,
  }) = _WeatherCardFollowedCityWeather;
}

/// WeatherCardState的扩展类
/// 提供对天气数据的格式化处理
extension WeatherCardStateExt on WeatherCardState {
  /// 获取格式化后的更新时间
  /// 将obsTime格式化为HH:mm格式
  String get updateTime => WeatherUtils.formatUpdateTime(weatherLocationState.currentWeather?.obsTime);

  /// 获取当前天气Text组件
  /// 根据天气代码返回对应的带颜色文本组件
  Text get weatherText =>
      WeatherUtils.getWeatherText(weatherLocationState.currentWeather?.icon, weatherLocationState.currentWeather?.text);
}
