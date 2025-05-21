import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_model.dart';

part 'home_weather_state.freezed.dart';

@freezed
class HomeWeatherState with _$HomeWeatherState {
  const factory HomeWeatherState({
    /// 当前定位城市、经纬度、当前天气
    String? currentCity,
    double? currentLatitude,
    double? currentLongitude,
    QweatherNow? currentWeather,
    QweatherMinutelyResponse? currentMinutelyRain,
  }) = _HomeWeatherState;
}

