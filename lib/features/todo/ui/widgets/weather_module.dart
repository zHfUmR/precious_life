import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';
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
      _homeWeatherVm.refreshWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeWeatherState = ref.watch(homeWeatherVmProvider);
    return Column(
      children: [
        LoadingStatusWidget(
          status: homeWeatherState.loadingStatus,
          onRetry: () => _homeWeatherVm.refreshWeather(),
          errorMessage: homeWeatherState.errorMessage,
          child: GestureDetector(
            onTap: () => _homeWeatherVm.refreshWeather(),
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
                      Text(homeWeatherState.currentMinutelyRain?.summary ?? '--',
                          style: CPTextStyles.s8.c(CPColors.black), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                Text(homeWeatherState.currentWeather?.temp ?? '--', style: CPTextStyles.s40.bold.c(CPColors.black)),
                Column(
                  children: [
                    Text('°C', style: CPTextStyles.s16.c(CPColors.black)),
                    const Icon(Icons.wb_sunny, size: 20, color: CPColors.black),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 10),
                    Text('深圳市-龙岗区', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
                    const Icon(Icons.wb_sunny, size: 20, color: CPColors.lightGrey),
                    Text('29°C', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
                    const SizedBox(width: 10),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 10),
                    Text('深圳市-龙岗区', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
                    const Icon(Icons.wb_sunny, size: 20, color: CPColors.lightGrey),
                    Text('29°C', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
                    const SizedBox(width: 10),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 10),
                    Text('深圳市-龙岗区', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
                    const Icon(Icons.wb_sunny, size: 20, color: CPColors.lightGrey),
                    Text('29°C', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
                    const SizedBox(width: 10),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 10),
                    Text('深圳市-龙岗区', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
                    const Icon(Icons.wb_sunny, size: 20, color: CPColors.lightGrey),
                    Text('29°C', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
                    const SizedBox(width: 10),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 10),
                    Text('深圳市-龙岗区', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
                    const Icon(Icons.wb_sunny, size: 20, color: CPColors.lightGrey),
                    Text('29°C', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
                    const SizedBox(width: 10),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(width: 5),
                    Text('深圳市-龙岗区', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
                    const Icon(Icons.wb_sunny, size: 20, color: CPColors.lightGrey),
                    Text('29°C', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
                    const SizedBox(width: 5),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
