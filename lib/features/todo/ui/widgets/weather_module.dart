import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:precious_life/app/routes/route_constants.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/core/utils/weather_utils.dart';
import 'package:precious_life/features/todo/data/models/home_weather_state.dart';
import 'package:precious_life/features/todo/ui/providers/home_weather_vm.dart';
import 'package:precious_life/shared/widgets/loading_status_widget.dart';

/// 天气模块组件
class WeatherModule extends ConsumerStatefulWidget {
  const WeatherModule({super.key});

  @override
  ConsumerState<WeatherModule> createState() => _WeatherModuleState();
}

/// 天气模块状态类
class _WeatherModuleState extends ConsumerState<WeatherModule> {
  late HomeWeatherVm _homeWeatherVm;

  @override
  void initState() {
    super.initState();
    _homeWeatherVm = ref.read(homeWeatherVmProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeWeatherVm.refreshCurrentWeather();
      _homeWeatherVm.refreshCityWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeWeatherState = ref.watch(homeWeatherVmProvider);
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push(AppRoutes.weatherDetail),
            child: LoadingStatusWidget(
              status: homeWeatherState.currentLoadingStatus,
              onRetry: () => _homeWeatherVm.refreshCurrentWeather(),
              errorMessage: homeWeatherState.currentErrorMessage,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '更新于：${homeWeatherState.updateTime}',
                          style: CPTextStyles.s8.c(CPColors.lightGrey),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, size: 12, color: CPColors.black),
                            Flexible(
                              child: Text(
                                homeWeatherState.currentCity ?? '--',
                                style: CPTextStyles.s12.bold.c(CPColors.black),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(homeWeatherState.currentMinutelyRain?.summary ?? '--',
                              style: CPTextStyles.s8.c(CPColors.laMuPink), textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                  Text(homeWeatherState.currentWeather?.temp ?? '--', style: CPTextStyles.s40.bold.c(CPColors.black)),
                  Column(
                    children: [
                      Text('°C', style: CPTextStyles.s16.c(CPColors.black)),
                      homeWeatherState.weatherText,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // 关注城市群天气
        Expanded(
          flex: 3,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push(AppRoutes.weatherDetail),
            onDoubleTap: () => _homeWeatherVm.refreshCityWeather(),
            onLongPress: () async {
              final result = await context.push<bool>(AppRoutes.weatherCitySettings);
              // 只有在数据发生变化时才刷新关注城市天气数据
              if (result == true) {
                _homeWeatherVm.refreshCityWeather();
              }
            },
            child: LoadingStatusWidget(
              status: homeWeatherState.cityLoadingStatus,
              onRetry: () => _homeWeatherVm.refreshCityWeather(),
              errorMessage: homeWeatherState.cityErrorMessage,
              child: _buildFollowedCitiesWeather(homeWeatherState),
            ),
          ),
        )
      ],
    );
  }

  /// 构建关注城市天气列表
  Widget _buildFollowedCitiesWeather(HomeWeatherState homeWeatherState) {
    final followedCitiesWeather = homeWeatherState.followedCitiesWeather;

    // 如果没有关注城市数据，显示提示
    if (followedCitiesWeather == null || followedCitiesWeather.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 32, color: CPColors.lightGrey),
            const SizedBox(height: 8),
            Text('暂无关注的城市', style: CPTextStyles.s12.c(CPColors.lightGrey)),
            const SizedBox(height: 4),
            Text('长按进入设置', style: CPTextStyles.s10.c(CPColors.lightGrey)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: followedCitiesWeather.map((cityWeather) {
          return _buildCityWeatherRow(cityWeather);
        }).toList(),
      ),
    );
  }

  /// 构建单个城市天气行
  Widget _buildCityWeatherRow(FollowedCityWeather cityWeather) {
    final city = cityWeather.city;
    final weather = cityWeather.weather;
    final errorMessage = cityWeather.errorMessage;

    // 如果有错误信息，显示错误状态
    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                city.simpleDisplayName,
                style: CPTextStyles.s12.bold.c(CPColors.lightGrey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.error_outline, size: 16, color: Colors.red),
            Text('--°C', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
            const SizedBox(width: 10),
          ],
        ),
      );
    }

    // 显示正常天气数据
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              city.simpleDisplayName,
              style: CPTextStyles.s12.bold.c(CPColors.lightGrey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          WeatherUtils.getWeatherIcon(weather?.icon, 16),
          Text(
            '${weather?.temp ?? '--'}°C',
            style: CPTextStyles.s12.bold.c(CPColors.lightGrey),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }


}
