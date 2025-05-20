import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/viewmodels/home_weather_vm.dart';

/// 天气模块组件
class WeatherModule extends ConsumerStatefulWidget {
  const WeatherModule({super.key});

  @override
  ConsumerState<WeatherModule> createState() => _WeatherModuleState();
}

/// 天气模块状态类
class _WeatherModuleState extends ConsumerState<WeatherModule> {
  late HomeWeatherVM _homeWeatherVm;
  
  @override
  Widget build(BuildContext context) {
    _homeWeatherVm = ref.read(homeWeatherVMProvider.notifier);  
    return Container(
        child: Column(children: [
      GestureDetector(
        onTap: () => _homeWeatherVm.fetchWeatherData("101280606"),
        child: Row(
          children: [
            Expanded(
                child: Column(children: [
              Row(children: [
                Icon(Icons.location_on, size: 12, color: CPColors.black),
                Expanded(
                  child: Text(
                    '深圳市南山区深圳湾一号XX大厦',
                    style: CPTextStyles.s12.bold.c(CPColors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
              Text('未来几小时会有雨', style: CPTextStyles.s8.c(CPColors.black)),
            ])),
            Text('29', style: CPTextStyles.s48.bold.c(CPColors.black)),
            Column(children: [
              Text('°C', style: CPTextStyles.s16.c(CPColors.black)),
              Icon(Icons.wb_sunny, size: 20, color: CPColors.black),
            ]),
          ],
        ),
      ),
      Expanded(
          child: SingleChildScrollView(
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 10),
              Text('深圳市-龙岗区', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
              Icon(Icons.wb_sunny, size: 20, color: CPColors.lightGrey),
              Text('29°C', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
              SizedBox(width: 10),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 10),
              Text('深圳市-龙岗区', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
              Icon(Icons.wb_sunny, size: 20, color: CPColors.lightGrey),
              Text('29°C', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
              SizedBox(width: 10),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 10),
              Text('深圳市-龙岗区', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
              Icon(Icons.wb_sunny, size: 20, color: CPColors.lightGrey),
              Text('29°C', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
              SizedBox(width: 10),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 10),
              Text('深圳市-龙岗区', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
              Icon(Icons.wb_sunny, size: 20, color: CPColors.lightGrey),
              Text('29°C', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
              SizedBox(width: 10),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 10),
              Text('深圳市-龙岗区', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
              Icon(Icons.wb_sunny, size: 20, color: CPColors.lightGrey),
              Text('29°C', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
              SizedBox(width: 10),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 5),
              Text('深圳市-龙岗区', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
              Icon(Icons.wb_sunny, size: 20, color: CPColors.lightGrey),
              Text('29°C', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
              SizedBox(width: 5),
            ],
          ),
        ]),
      ))
    ]));
  }
}
