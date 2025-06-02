import 'package:geolocator/geolocator.dart';
import 'package:precious_life/config/app_config.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_service.dart';
import 'package:precious_life/core/network/api/tianditu/tianditu_api_service.dart';
import 'package:precious_life/core/utils/location_utils.dart';
import 'package:precious_life/core/utils/storage_utils.dart';
import 'package:precious_life/core/utils/weather_utils.dart';
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
  HomeWeatherState build() => const HomeWeatherState(
        weatherConfigState: WeatherConfigState(loadingStatus: LoadingStatus.initial),
        weatherLocationState: WeatherLocationState(loadingStatus: LoadingStatus.initial),
        weatherFollowedState: WeatherFollowedState(loadingStatus: LoadingStatus.initial),
      );

  /// 初始化，流程：
  ///
  /// 1. 检查Key是否配置，是否可用，更新weatherConfigState的状态
  /// 2. 检查是否可以获取位置，更新weatherLocationState的状态
  /// 3. 获取当前位置的天气，更新weatherFollowedState的状态
  /// 4. 获取关注城市列表，更新weatherFollowedState的状态
  /// 5. 获取关注城市列表的天气，更新weatherFollowedState的状态
  ///
  Future<void> init() async {
    await weatherConfig();
    if (state.weatherConfigState.loadingStatus == LoadingStatus.failure) return;
    weatherLocation();
    weatherFollowed();
  }

  /// 天气配置
  Future<void> weatherConfig() async {
    state = state.copyWith(weatherConfigState: const WeatherConfigState(loadingStatus: LoadingStatus.loading));
    try {
      final isConfigured = await WeatherUtils.isWeatherApiKeyConfigured();
      if (isConfigured) {
        // 检查API Key是否可用
        final isApiKeyValid = await WeatherUtils.isWeatherApiKeyValid();
        if (isApiKeyValid) {
          state = state.copyWith(weatherConfigState: const WeatherConfigState(loadingStatus: LoadingStatus.success));
        } else {
          state = state.copyWith(
              weatherConfigState:
                  const WeatherConfigState(loadingStatus: LoadingStatus.failure, errorMessage: 'API Key不可用'));
        }
      } else {
        state = state.copyWith(
            weatherConfigState:
                const WeatherConfigState(loadingStatus: LoadingStatus.failure, errorMessage: 'API Key未配置'));
      }
    } catch (e) {
      state = state.copyWith(
          weatherConfigState:
              WeatherConfigState(loadingStatus: LoadingStatus.failure, errorMessage: 'API Key配置失败: $e'));
    }
  }

  /// 天气定位，流程
  ///
  /// 1. 检查AppConfig中的经纬度是否为0，如果为0，则获取当前位置的经纬度
  /// 2. 如果AppConfig中的经纬度不为0，则使用AppConfig中的经纬度拼接locationStr
  /// 3. 使用locationStr获取当前位置的天气
  /// 4. 更新weatherLocationState的状态
  Future<void> weatherLocation() async {
    state = state.copyWith(weatherLocationState: const WeatherLocationState(loadingStatus: LoadingStatus.loading));
    if (AppConfig.currentLatitude == 0 && AppConfig.currentLongitude == 0) {
      Position location;
      try {
        location = await LocationUtils.getCurrentPosition();
        // 更新AppConfig中的经纬度值
        AppConfig.currentLatitude = location.latitude;
        AppConfig.currentLongitude = location.longitude;
      } catch (e) {
        state = state.copyWith(
            weatherLocationState:
                WeatherLocationState(loadingStatus: LoadingStatus.failure, errorMessage: '位置获取失败: ${e.toString()}'));
        return;
      }
    }
    final locationStr = "${AppConfig.currentLongitude},${AppConfig.currentLatitude}";
    try {
      final futures = await Future.wait([
        TiandituApiService.instance.reverseGeocoding(
          longitude: AppConfig.currentLongitude,
          latitude: AppConfig.currentLatitude,
        ),
        QweatherApiService.lookupCity(locationStr),
        QweatherApiService.getNowWeather(locationStr),
        QweatherApiService.getMinutelyRain(locationStr),
      ]);
      final locationData = futures[0] as dynamic;
      final weatherData = futures[1] as dynamic;
      final rainData = futures[2] as dynamic;
      final newState = state.copyWith(
        weatherLocationState: WeatherLocationState(
            loadingStatus: LoadingStatus.success,
            currentLatitude: AppConfig.currentLatitude,
            currentLongitude: AppConfig.currentLongitude,
            currentCity: "${locationData.result?.formattedAddress ?? '未知位置'}",
            currentWeather: weatherData.now,
            currentMinutelyRain: rainData),
      );
      state = newState;
    } catch (e) {
      state = state.copyWith(
          weatherLocationState:
              WeatherLocationState(loadingStatus: LoadingStatus.failure, errorMessage: '天气数据获取失败: ${e.toString()}'));
    }
  }

  /// 关注城市天气，流程
  ///
  /// 1. 获取关注城市列表
  /// 2. 获取关注城市列表的天气
  /// 3. 更新weatherFollowedState的状态
  Future<void> weatherFollowed() async {
    state = state.copyWith(weatherFollowedState: const WeatherFollowedState(loadingStatus: LoadingStatus.loading));
    try {
      final citiesData = await StorageUtils.instance.getObjectList(StorageKeys.followedCities);
      if (citiesData == null || citiesData.isEmpty) {
        state = state.copyWith(
            weatherFollowedState:
                const WeatherFollowedState(loadingStatus: LoadingStatus.success, followedCitiesWeather: []));
        return;
      }
      final followedCities = citiesData.map((data) => FollowedCity.fromJson(data)).toList();
      // 按照order排序
      followedCities.sort((a, b) => a.order.compareTo(b.order));
      final List<FollowedCityWeather> citiesWeather = [];
      for (final city in followedCities) {
        try {
          final locationStr = "${city.longitude},${city.latitude}";
          final weatherResponse = await QweatherApiService.getNowWeather(locationStr);
          citiesWeather.add(FollowedCityWeather(city: city, weather: weatherResponse.now));
        } catch (e) {
          citiesWeather.add(FollowedCityWeather(city: city, errorMessage: e.toString()));
        }
      }
      state = state.copyWith(
          weatherFollowedState:
              WeatherFollowedState(loadingStatus: LoadingStatus.success, followedCitiesWeather: citiesWeather));
    } catch (e) {
      state = state.copyWith(
          weatherFollowedState:
              WeatherFollowedState(loadingStatus: LoadingStatus.failure, errorMessage: '关注城市天气获取失败: ${e.toString()}'));
    }
  }

  /// 刷新关注城市列表天气
  Future<void> refreshCityWeather() async {
    state = state.copyWith(weatherFollowedState: const WeatherFollowedState(loadingStatus: LoadingStatus.loading));

    try {
      // 从本地存储加载关注的城市列表
      final citiesData = await StorageUtils.instance.getObjectList(StorageKeys.followedCities);

      if (citiesData == null || citiesData.isEmpty) {
        state = state.copyWith(
            weatherFollowedState:
                const WeatherFollowedState(loadingStatus: LoadingStatus.success, followedCitiesWeather: []));
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
        weatherFollowedState:
            WeatherFollowedState(loadingStatus: LoadingStatus.success, followedCitiesWeather: citiesWeather),
      );
    } catch (e) {
      state = state.copyWith(
        weatherFollowedState:
            WeatherFollowedState(loadingStatus: LoadingStatus.failure, errorMessage: '关注城市天气获取失败: ${e.toString()}'),
      );
    }
  }
}
