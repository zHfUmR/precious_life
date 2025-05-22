import 'package:geolocator/geolocator.dart';
import 'package:precious_life/config/app_config.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_service.dart';
import 'package:precious_life/core/utils/location_utils.dart';
import 'package:precious_life/features/todo/data/models/home_weather_state.dart';
import 'package:precious_life/shared/widgets/loading_status_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_weather_vm.g.dart';

/// 天气数据提供者
@riverpod
class HomeWeatherVm extends _$HomeWeatherVm {
  /// 构建初始状态
  @override
  HomeWeatherState build() => const HomeWeatherState(loadingStatus: LoadingStatus.initial);

  // 获取当前位置的经纬度
  Future<void> refreshWeather() async {
    state = state.copyWith(loadingStatus: LoadingStatus.loading);
    if (AppConfig.currentLatitude == 0 && AppConfig.currentLongitude == 0) {
      Position location;
      try {
        location = await LocationUtils.getCurrentPosition();
        // 更新AppConfig中的经纬度值
        AppConfig.currentLatitude = location.latitude;
        AppConfig.currentLongitude = location.longitude;
      } catch (e) {
        state = state.copyWith(loadingStatus: LoadingStatus.failure, errorMessage: e.toString());
        return;
      }
    }
    // 使用AppConfig的经纬度值拼接locationStr
    final locationStr = "${AppConfig.currentLongitude},${AppConfig.currentLatitude}";
    final futures = await Future.wait([
      QweatherApiService.lookupCity(locationStr),
      QweatherApiService.getNowWeather(locationStr),
      QweatherApiService.getMinutelyRain(locationStr),
    ]);
    final locationData = futures[0] as dynamic;
    final weatherData = futures[1] as dynamic;
    final rainData = futures[2] as dynamic;
    state = state.copyWith(
      loadingStatus: LoadingStatus.success,
      currentLatitude: AppConfig.currentLatitude,
      currentLongitude: AppConfig.currentLongitude,
      currentCity: "${locationData.location![0].adm2}-${locationData.location![0].name}",
      currentWeather: weatherData.now,
      currentMinutelyRain: rainData,
    );
  }
}
