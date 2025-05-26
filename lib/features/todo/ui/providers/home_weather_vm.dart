import 'package:geolocator/geolocator.dart';
import 'package:precious_life/config/app_config.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_service.dart';
import 'package:precious_life/core/utils/location_utils.dart';
import 'package:precious_life/core/utils/storage_utils.dart';
import 'package:precious_life/features/todo/data/models/home_weather_state.dart';
import 'package:precious_life/features/todo/ui/models/followed_city.dart';
import 'package:precious_life/shared/widgets/loading_status_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_weather_vm.g.dart';

/// 天气数据提供者
@riverpod
class HomeWeatherVm extends _$HomeWeatherVm {
  /// 构建初始状态
  @override
  HomeWeatherState build() =>
      const HomeWeatherState(currentLoadingStatus: LoadingStatus.initial, cityLoadingStatus: LoadingStatus.initial);

  // 获取当前位置的经纬度
  Future<void> refreshCurrentWeather() async {
    state = state.copyWith(currentLoadingStatus: LoadingStatus.loading);
    if (AppConfig.currentLatitude == 0 && AppConfig.currentLongitude == 0) {
      Position location;
      try {
        location = await LocationUtils.getCurrentPosition();
        // 更新AppConfig中的经纬度值
        AppConfig.currentLatitude = location.latitude;
        AppConfig.currentLongitude = location.longitude;
      } catch (e) {
        state = state.copyWith(currentLoadingStatus: LoadingStatus.failure, currentErrorMessage: e.toString());
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
      currentLoadingStatus: LoadingStatus.success,
      currentLatitude: AppConfig.currentLatitude,
      currentLongitude: AppConfig.currentLongitude,
      currentCity: "${locationData.location![0].adm2}-${locationData.location![0].name}",
      currentWeather: weatherData.now,
      currentMinutelyRain: rainData,
    );
  }

  /// 刷新关注城市列表天气
  Future<void> refreshCityWeather() async {
    state = state.copyWith(cityLoadingStatus: LoadingStatus.loading);
    
    try {
      // 从本地存储加载关注的城市列表
      final citiesData = await StorageUtils.instance.getObjectList(StorageKeys.followedCities);
      if (citiesData == null || citiesData.isEmpty) {
        state = state.copyWith(
          cityLoadingStatus: LoadingStatus.success,
          followedCitiesWeather: [],
        );
        return;
      }

      // 解析关注城市数据
      final followedCities = citiesData.map((data) => FollowedCity.fromJson(data)).toList();
      followedCities.sort((a, b) => a.order.compareTo(b.order));

      // 并发获取所有关注城市的天气数据
      final List<FollowedCityWeather> citiesWeather = [];
      
      for (final city in followedCities) {
        try {
          final locationStr = "${city.longitude},${city.latitude}";
          final weatherResponse = await QweatherApiService.getNowWeather(locationStr);
          
          citiesWeather.add(FollowedCityWeather(
            city: city,
            weather: weatherResponse.now,
          ));
        } catch (e) {
          // 单个城市获取失败时，添加错误信息但不影响其他城市
          citiesWeather.add(FollowedCityWeather(
            city: city,
            errorMessage: e.toString(),
          ));
        }
      }

      state = state.copyWith(
        cityLoadingStatus: LoadingStatus.success,
        followedCitiesWeather: citiesWeather,
      );
    } catch (e) {
      state = state.copyWith(
        cityLoadingStatus: LoadingStatus.failure,
        cityErrorMessage: e.toString(),
      );
    }
  }
}
