import 'package:geolocator/geolocator.dart';
import 'package:precious_life/config/app_config.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_service.dart';
import 'package:precious_life/core/utils/location_utils.dart';
import 'package:precious_life/core/utils/storage_utils.dart';
import 'package:precious_life/features/todo/data/models/home_weather_state.dart';
import 'package:precious_life/features/todo/ui/models/followed_city.dart';
import 'package:precious_life/shared/widgets/loading_status_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

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
    debugPrint('HomeWeatherVm: 开始刷新当前天气数据...');
    debugPrint('HomeWeatherVm: 当前API Key状态 - ${AppConfig.qweatherApiKey.isNotEmpty ? '已配置' : '未配置'}');
    debugPrint('HomeWeatherVm: 当前状态 - currentLoadingStatus: ${state.currentLoadingStatus}');
    
    state = state.copyWith(currentLoadingStatus: LoadingStatus.loading);
    debugPrint('HomeWeatherVm: 状态已更新为loading');
    
    if (AppConfig.currentLatitude == 0 && AppConfig.currentLongitude == 0) {
      Position location;
      try {
        debugPrint('HomeWeatherVm: 获取当前位置...');
        location = await LocationUtils.getCurrentPosition();
        // 更新AppConfig中的经纬度值
        AppConfig.currentLatitude = location.latitude;
        AppConfig.currentLongitude = location.longitude;
        debugPrint('HomeWeatherVm: 位置获取成功 - lat: ${location.latitude}, lng: ${location.longitude}');
      } catch (e) {
        debugPrint('HomeWeatherVm: 位置获取失败 - $e');
        state = state.copyWith(
          currentLoadingStatus: LoadingStatus.failure, 
          currentErrorMessage: '位置获取失败: ${e.toString()}'
        );
        debugPrint('HomeWeatherVm: 状态已更新为failure - ${state.currentErrorMessage}');
        return;
      }
    } else {
      debugPrint('HomeWeatherVm: 使用缓存位置 - lat: ${AppConfig.currentLatitude}, lng: ${AppConfig.currentLongitude}');
    }
    
    // 使用AppConfig的经纬度值拼接locationStr
    final locationStr = "${AppConfig.currentLongitude},${AppConfig.currentLatitude}";
    debugPrint('HomeWeatherVm: 使用位置 $locationStr 获取天气数据...');
    debugPrint('HomeWeatherVm: API Key: ${AppConfig.qweatherApiKey.isNotEmpty ? AppConfig.qweatherApiKey.substring(0, 8) + '...' : '空'}');
    
    try {
      debugPrint('HomeWeatherVm: 开始并发请求天气数据...');
      final futures = await Future.wait([
        QweatherApiService.lookupCity(locationStr),
        QweatherApiService.getNowWeather(locationStr),
        QweatherApiService.getMinutelyRain(locationStr),
      ]);
      final locationData = futures[0] as dynamic;
      final weatherData = futures[1] as dynamic;
      final rainData = futures[2] as dynamic;
      
      debugPrint('HomeWeatherVm: 天气数据获取成功');
      debugPrint('HomeWeatherVm: 城市信息 - ${locationData.location?.isNotEmpty == true ? locationData.location![0].name : '未知'}');
      debugPrint('HomeWeatherVm: 天气信息 - 温度: ${weatherData.now?.temp ?? '未知'}°C');
      
      final newState = state.copyWith(
        currentLoadingStatus: LoadingStatus.success,
        currentLatitude: AppConfig.currentLatitude,
        currentLongitude: AppConfig.currentLongitude,
        currentCity: "${locationData.location![0].adm2}-${locationData.location![0].name}",
        currentWeather: weatherData.now,
        currentMinutelyRain: rainData,
        currentErrorMessage: null, // 清除之前的错误信息
      );
      
      debugPrint('HomeWeatherVm: 准备更新状态为success');
      debugPrint('HomeWeatherVm: 新状态 - currentCity: ${newState.currentCity}, temp: ${newState.currentWeather?.temp}');
      
      state = newState;
      
      debugPrint('HomeWeatherVm: 状态更新完成 - currentLoadingStatus: ${state.currentLoadingStatus}');
    } catch (e) {
      debugPrint('HomeWeatherVm: 天气数据获取失败 - $e');
      debugPrint('HomeWeatherVm: 错误类型 - ${e.runtimeType}');
      state = state.copyWith(
        currentLoadingStatus: LoadingStatus.failure, 
        currentErrorMessage: '天气数据获取失败: ${e.toString()}'
      );
      debugPrint('HomeWeatherVm: 状态已更新为failure - ${state.currentErrorMessage}');
    }
  }

  /// 刷新关注城市列表天气
  Future<void> refreshCityWeather() async {
    debugPrint('HomeWeatherVm: 开始刷新关注城市天气数据...');
    state = state.copyWith(cityLoadingStatus: LoadingStatus.loading);
    
    try {
      // 从本地存储加载关注的城市列表
      final citiesData = await StorageUtils.instance.getObjectList(StorageKeys.followedCities);
      debugPrint('HomeWeatherVm: 从存储中获取到 ${citiesData?.length ?? 0} 个城市数据');
      
      if (citiesData == null || citiesData.isEmpty) {
        debugPrint('HomeWeatherVm: 没有关注的城市');
        state = state.copyWith(
          cityLoadingStatus: LoadingStatus.success,
          followedCitiesWeather: [],
          cityErrorMessage: null,
        );
        return;
      }

      // 解析关注城市数据
      final followedCities = citiesData.map((data) => FollowedCity.fromJson(data)).toList();
      followedCities.sort((a, b) => a.order.compareTo(b.order));
      debugPrint('HomeWeatherVm: 找到 ${followedCities.length} 个关注城市');

      // 并发获取所有关注城市的天气数据
      final List<FollowedCityWeather> citiesWeather = [];
      
      for (final city in followedCities) {
        try {
          final locationStr = "${city.longitude},${city.latitude}";
          debugPrint('HomeWeatherVm: 获取 ${city.simpleDisplayName} 的天气数据，位置: $locationStr');
          final weatherResponse = await QweatherApiService.getNowWeather(locationStr);
          
          citiesWeather.add(FollowedCityWeather(
            city: city,
            weather: weatherResponse.now,
          ));
          debugPrint('HomeWeatherVm: ${city.simpleDisplayName} 天气数据获取成功 - 温度: ${weatherResponse.now?.temp ?? '未知'}°C');
        } catch (e) {
          // 单个城市获取失败时，添加错误信息但不影响其他城市
          citiesWeather.add(FollowedCityWeather(
            city: city,
            errorMessage: e.toString(),
          ));
          debugPrint('HomeWeatherVm: ${city.simpleDisplayName} 天气数据获取失败 - $e');
        }
      }

      debugPrint('HomeWeatherVm: 关注城市天气数据刷新完成，成功获取 ${citiesWeather.where((c) => c.weather != null).length} 个城市的天气');
      state = state.copyWith(
        cityLoadingStatus: LoadingStatus.success,
        followedCitiesWeather: citiesWeather,
        cityErrorMessage: null,
      );
    } catch (e) {
      debugPrint('HomeWeatherVm: 关注城市天气数据刷新失败 - $e');
      state = state.copyWith(
        cityLoadingStatus: LoadingStatus.failure,
        cityErrorMessage: '关注城市天气获取失败: ${e.toString()}',
      );
    }
  }
}
