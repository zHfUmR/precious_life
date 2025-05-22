import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_model.dart';
import 'package:precious_life/shared/widgets/loading_status_widget.dart';

part 'home_weather_state.freezed.dart';

@freezed
class HomeWeatherState with _$HomeWeatherState {
  const factory HomeWeatherState({
    required LoadingStatus loadingStatus, // 加载状态
    String? errorMessage, // 错误信息
    String? currentCity, // 当前定位城市
    double? currentLatitude, // 当前定位经纬度
    double? currentLongitude, // 当前定位经纬度
    QweatherNow? currentWeather, // 当前天气
    QweatherMinutelyResponse? currentMinutelyRain, // 当前分钟级降雨
  }) = _HomeWeatherState;
}

/// HomeWeatherState的扩展类
/// 提供对天气数据的格式化处理
extension HomeWeatherStateExt on HomeWeatherState {
  /// 获取格式化后的更新时间
  /// 将obsTime格式化为HH:mm格式
  String get updateTime => currentWeather?.obsTime?.split('T')[1].split('+')[0].substring(0, 5) ?? '--';
}
