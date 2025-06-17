import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:precious_life/config/app_config.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_model.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_service.dart';
import 'package:precious_life/core/network/api/tianditu/tianditu_api_service.dart';
import 'package:precious_life/core/utils/cp_location.dart';
import 'package:precious_life/core/utils/cp_storage.dart';
import 'package:precious_life/features/todo/data/models/weather_card_state.dart';
import 'package:precious_life/features/todo/ui/models/followed_point.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:precious_life/shared/widgets/loading_status_widget.dart';
part 'weather_card_vm.g.dart';

/// 天气卡片视图模型
@riverpod
class WeatherCardVm extends _$WeatherCardVm {
  /// 构建初始状态
  @override
  WeatherCardState build() => const WeatherCardState(
      weatherConfigState: WeatherCardConfigState(loadingStatus: LoadingStatus.initial),
      weatherLocationState: WeatherCardLocationState(loadingStatus: LoadingStatus.initial),
      weatherFollowedState: WeatherCardFollowedState(loadingStatus: LoadingStatus.initial),
      isExpanded: false);

  // 初始化逻辑：
  // 1.检查天气Key是否配置，未配置则提示用户配置
  // 2.获取定位天气信息，获取失败则提示用户
  // 3.获取关注城市天气信息，获取失败则提示用户
  Future<void> init() async {
    bool isWeatherKeyConfigured = await checkWeatherKey();
    if (isWeatherKeyConfigured) {
      loadLocationWeather();
      loadFollowedWeather();
    }
  }

  /// 检查天气Key是否配置，是否可用，未配置则提示用户配置，显示对应错误文案，返回false，否则返回true
  Future<bool> checkWeatherKey() async {
    state = state.copyWith(weatherConfigState: const WeatherCardConfigState(loadingStatus: LoadingStatus.loading));
    try {
      final isConfigured = await QweatherApiService.isKeyConfigured();
      if (isConfigured) {
        final isApiKeyValid = await QweatherApiService.isKeyValid();
        if (isApiKeyValid) {
          state =
              state.copyWith(weatherConfigState: const WeatherCardConfigState(loadingStatus: LoadingStatus.success));
        } else {
          state = state.copyWith(
              weatherConfigState: const WeatherCardConfigState(
            loadingStatus: LoadingStatus.failure,
            errorMessage: '天气Key不可用，请检查配置',
          ));
          return false;
        }
      } else {
        state = state.copyWith(
            weatherConfigState: const WeatherCardConfigState(
          loadingStatus: LoadingStatus.failure,
          errorMessage: '天气Key未配置，请检查配置',
        ));
        return false;
      }
    } catch (e) {
      state = state.copyWith(
          weatherConfigState:
              WeatherCardConfigState(loadingStatus: LoadingStatus.failure, errorMessage: '天气Key配置失败: $e'));
      return false;
    }
    return true;
  }

  /// 获取定位天气信息，逻辑:
  ///
  /// 1. 获取定位信息，先获取内存中的经纬度，未获取到则获取位置，未获取到位置，显示错误信息
  /// 2. 能获取到的话，检查是否配置天地图Key，有通过逆编码接口获得详细定位，否则调用天气逆编码接口
  /// 3. 拉取天气信息、降雨、预警信息
  Future<void> loadLocationWeather() async {
    state = state.copyWith(weatherLocationState: const WeatherCardLocationState(loadingStatus: LoadingStatus.loading));
    if (AppConfig.currentLatitude == 0 && AppConfig.currentLongitude == 0) {
      Position location;
      try {
        location = await CPLocation.getCurrentPosition();
        // 更新AppConfig中的经纬度值
        AppConfig.currentLatitude = location.latitude;
        AppConfig.currentLongitude = location.longitude;
      } catch (e) {
        state = state.copyWith(
            weatherLocationState: WeatherCardLocationState(
                loadingStatus: LoadingStatus.failure, errorMessage: '位置获取失败: ${e.toString()}'));
        return;
      }
    }

    // 构建经纬度字符串，格式为：经度,纬度
    final locationStr = "${AppConfig.currentLongitude},${AppConfig.currentLatitude}";

    // 判断天地图Key是否配置，有则调用逆编码接口，否则调用天气逆编码接口
    String? currentAddress = AppConfig.currentAddress;
    if (currentAddress.isEmpty) {
      final isTiandituKeyConfigured = await TiandituApiService.isKeyConfigured();
      if (isTiandituKeyConfigured) {
        try {
          final tiandituResponse = await TiandituApiService.instance.reverseGeocoding(
            longitude: AppConfig.currentLongitude,
            latitude: AppConfig.currentLatitude,
          );
          if (tiandituResponse.status == 0) {
            final location = tiandituResponse.result?.formattedAddress;
            if (location != null && location.isNotEmpty) {
              currentAddress = location;
            }
          }
        } catch (e) {
          rethrow;
        }
      }
    }

    // 如果天地图逆编码失败或未配置，则调用天气逆编码接口
    if (currentAddress.isEmpty) {
      try {
        final qweatherResponse = await QweatherApiService.lookupCity(locationStr);
        if (qweatherResponse.code == '200') {
          final firstLocation = qweatherResponse.location?.first;
          if (firstLocation != null) {
            currentAddress = "${firstLocation.adm2}-${firstLocation.name}";
          }
        }
      } catch (e) {
        state = state.copyWith(
            weatherLocationState: WeatherCardLocationState(
                loadingStatus: LoadingStatus.failure, errorMessage: '位置解析失败: ${e.toString()}'));
        return;
      }
    }

    // 判断地址是否为空，为空的话显示错误信息
    if (currentAddress.isEmpty) {
      state = state.copyWith(
          weatherLocationState:
              const WeatherCardLocationState(loadingStatus: LoadingStatus.failure, errorMessage: '位置获取失败: 未获取到地址'));
      return;
    }

    AppConfig.currentAddress = currentAddress;

    // 获取天气信息，使用经纬度字符串而不是地址字符串
    try {
      final futures = await Future.wait([
        QweatherApiService.getNowWeather(locationStr),
        QweatherApiService.getMinutelyRain(locationStr),
      ]);
      final weatherData = futures[0] as QweatherNowResponse;
      final rainData = futures[1] as QweatherMinutelyResponse;

      // 从之前的地址解析结果中提取城市名
      String currentCity = '未知位置';
      if (currentAddress.contains('-')) {
        final parts = currentAddress.split('-');
        currentCity = parts.length > 1 ? parts[1] : parts[0];
      } else {
        currentCity = currentAddress;
      }

      final newState = state.copyWith(
        weatherLocationState: WeatherCardLocationState(
            loadingStatus: LoadingStatus.success,
            currentLatitude: AppConfig.currentLatitude,
            currentLongitude: AppConfig.currentLongitude,
            currentAddress: currentAddress,
            currentCity: currentCity,
            currentWeather: weatherData.now,
            currentMinutelyRain: rainData),
      );
      state = newState;
    } catch (e) {
      state = state.copyWith(
          weatherLocationState: WeatherCardLocationState(
              loadingStatus: LoadingStatus.failure, errorMessage: '天气数据获取失败: ${e.toString()}'));
      rethrow;
    }
  }

  /// 获取关注城市天气信息，逻辑:
  ///
  /// 1. 获取关注点列表，如果为空，则显示空列表
  /// 2. 获取关注点天气信息，如果获取失败，则显示错误信息
  /// 3. 更新状态
  Future<void> loadFollowedWeather() async {
    state = state.copyWith(weatherFollowedState: const WeatherCardFollowedState(loadingStatus: LoadingStatus.loading));
    // 读取SP里的数据
    final followedPointsJson = await CPStorage.instance.getString(StorageKeys.followedWeatherPoints);
    if (followedPointsJson == null || followedPointsJson.isEmpty) {
      state = state.copyWith(
          weatherFollowedState:
              const WeatherCardFollowedState(loadingStatus: LoadingStatus.success, followedWeather: []));
      return;
    }
    // followedPointsJson 字符串先转换为列表，再转换为FollowedPoint列表
    final followedPoints = jsonDecode(followedPointsJson) as List<dynamic>;
    final followedPointsList = followedPoints.map((e) => FollowedPoint.fromJson(e)).toList();
    // 并发获取所有关注点的天气信息，包容失败的请求
    final weatherResults = <WeatherCardFollowedWeather>[];

    // 为每个关注点创建独立的天气请求任务
    final weatherFutures = followedPointsList.map((point) async {
      try {
        final weatherResponse = await QweatherApiService.getNowWeather(point.locationStr);
        return WeatherCardFollowedWeather(
          point: point,
          loadingStatus: LoadingStatus.success,
          weather: weatherResponse.now,
        );
      } catch (e) {
        // 如果单个城市天气获取失败，记录错误但不影响其他城市
        return WeatherCardFollowedWeather(
          point: point,
          loadingStatus: LoadingStatus.failure,
          errorMessage: '天气获取失败: ${e.toString()}',
        );
      }
    }).toList();

    // 等待所有请求完成（包括失败的）
    final results = await Future.wait(weatherFutures);
    weatherResults.addAll(results);

    // 更新状态为成功，包含所有关注点的天气数据（成功或失败）
    state = state.copyWith(
        weatherFollowedState:
            WeatherCardFollowedState(loadingStatus: LoadingStatus.success, followedWeather: weatherResults));
  }

  /// 获取关注点天气信息
  Future<void> getFollowedWeather(FollowedPoint point) async {
    // 获取当前关注点列表
    List<WeatherCardFollowedWeather>? followedWeatherList = state.weatherFollowedState.followedWeather ?? [];
    
    // 找到要刷新的关注点并设置为loading状态
    final updatedList = followedWeatherList.map((item) {
      if (item.point.uniqueId == point.uniqueId) {
        return item.copyWith(loadingStatus: LoadingStatus.loading);
      }
      return item;
    }).toList();
    
    // 更新状态为loading
    state = state.copyWith(
      weatherFollowedState: WeatherCardFollowedState(
        loadingStatus: LoadingStatus.success,
        followedWeather: updatedList,
      ),
    );
    
    try {
      // 发起天气请求
      final weatherResponse = await QweatherApiService.getNowWeather(point.locationStr);
      
      // 更新成功状态
      final finalList = updatedList.map((item) {
        if (item.point.uniqueId == point.uniqueId) {
          return item.copyWith(
            loadingStatus: LoadingStatus.success,
            weather: weatherResponse.now,
            errorMessage: null,
          );
        }
        return item;
      }).toList();
      
      // 保存到本地存储
      final pointsToStore = finalList.map((e) => e.point).toList();
      final newPointsJson = jsonEncode(pointsToStore);
      await CPStorage.instance.setString(StorageKeys.followedWeatherPoints, newPointsJson);
      
      state = state.copyWith(
        weatherFollowedState: WeatherCardFollowedState(
          loadingStatus: LoadingStatus.success,
          followedWeather: finalList,
        ),
      );
    } catch (e) {
      // 更新失败状态
      final errorList = updatedList.map((item) {
        if (item.point.uniqueId == point.uniqueId) {
          return item.copyWith(
            loadingStatus: LoadingStatus.failure,
            errorMessage: '天气获取失败: ${e.toString()}',
          );
        }
        return item;
      }).toList();
      
      state = state.copyWith(
        weatherFollowedState: WeatherCardFollowedState(
          loadingStatus: LoadingStatus.success,
          followedWeather: errorList,
        ),
      );
    }
  }

  /// 添加关注点
  Future<void> addFollowedPoint(FollowedPoint point) async {
    List<WeatherCardFollowedWeather>? followedWeatherList = state.weatherFollowedState.followedWeather ?? [];
    final weatherResponse = await QweatherApiService.getNowWeather(point.locationStr);
    // 构造新的WeatherCardFollowedWeather对象
    final newPoint = WeatherCardFollowedWeather(
      point: point.copyWith(sort: followedWeatherList.length + 1),
      loadingStatus: LoadingStatus.success,
      weather: weatherResponse.now,
    );
    final newPoints = [...followedWeatherList, newPoint];
    // 只存储FollowedPoint列表，不存储整个WeatherCardFollowedWeather对象
    final pointsToStore = newPoints.map((e) => e.point).toList();
    final newPointsJson = jsonEncode(pointsToStore);
    await CPStorage.instance.setString(StorageKeys.followedWeatherPoints, newPointsJson);
    state = state.copyWith(
        weatherFollowedState:
            WeatherCardFollowedState(loadingStatus: LoadingStatus.success, followedWeather: newPoints));
  }

  /// 删除关注点
  Future<void> deleteFollowedPoint(String uniqueId) async {
    List<WeatherCardFollowedWeather>? followedWeatherList = state.weatherFollowedState.followedWeather ?? [];
    final newPoints = followedWeatherList.where((e) => e.point.uniqueId != uniqueId).toList();
    // 只存储FollowedPoint列表，不存储整个WeatherCardFollowedWeather对象
    final pointsToStore = newPoints.map((e) => e.point).toList();
    final newPointsJson = jsonEncode(pointsToStore);
    await CPStorage.instance.setString(StorageKeys.followedWeatherPoints, newPointsJson);
    state = state.copyWith(
        weatherFollowedState:
            WeatherCardFollowedState(loadingStatus: LoadingStatus.success, followedWeather: newPoints));
  }

  /// 刷新关注点列表
  Future<void> refreshFollowedPoints(List<WeatherCardFollowedWeather> points) async {
    // 只存储FollowedPoint列表，不存储整个WeatherCardFollowedWeather对象
    final pointsToStore = points.map((e) => e.point).toList();
    final newPointsJson = jsonEncode(pointsToStore);
    await CPStorage.instance.setString(StorageKeys.followedWeatherPoints, newPointsJson);
    state = state.copyWith(
        weatherFollowedState: WeatherCardFollowedState(loadingStatus: LoadingStatus.success, followedWeather: points));
  }

  /// 切换展开状态
  void toggleExpandedState() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }
}
