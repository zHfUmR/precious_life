import 'package:geolocator/geolocator.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_service.dart';
import 'package:precious_life/features/todo/data/models/home_weather_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_weather_vm.g.dart';

/// 天气数据提供者
@riverpod
class HomeWeatherVm extends _$HomeWeatherVm {
  /// 构建初始状态
  @override
  HomeWeatherState build() => const HomeWeatherState();

  // 获取当前位置的经纬度
  Future<void> refreshWeather() async {
    final location = await Geolocator.getCurrentPosition();
    final locationStr = "${location.longitude},${location.latitude}";
    final futures = await Future.wait([
      QweatherApiService.lookupCity(locationStr),
      QweatherApiService.getNowWeather(locationStr),
      QweatherApiService.getMinutelyRain(locationStr),
    ]);
    final locationData = futures[0] as dynamic;
    final weatherData = futures[1] as dynamic;
    final rainData = futures[2] as dynamic;
    print("obsTime ${weatherData.now}");
    state = state.copyWith(
      currentLatitude: location.latitude,
      currentLongitude: location.longitude,
      currentCity: "${locationData.location![0].adm2}-${locationData.location![0].name}",
      currentWeather: weatherData.now,
      currentMinutelyRain: rainData,
    );
  }
}
