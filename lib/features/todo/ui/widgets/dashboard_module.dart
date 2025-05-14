import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/core/utils/screen_utils.dart';
import 'package:precious_life/features/todo/ui/providers/home_time_vm.dart';
import 'package:precious_life/features/todo/ui/widgets/countdown_module.dart';
import 'package:precious_life/features/todo/ui/widgets/weather_module.dart';

class DashboardModule extends ConsumerStatefulWidget {
  const DashboardModule({super.key});

  @override
  ConsumerState<DashboardModule> createState() => _DashboardModuleState();
}

class _DashboardModuleState extends ConsumerState<DashboardModule> with SingleTickerProviderStateMixin {
  late dynamic _timeModuleVm;
  late DateTime _datetime;

  late Ticker _ticker;
  late Battery _battery;
  DateTime? _lastBatteryTime;

  @override
  void initState() {
    super.initState();
    _datetime = DateTime.now();
    _battery = Battery();
    _ticker = createTicker((_) => _tick())..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _timeModuleVm = ref.read(homeTimeVmProvider.notifier);
    return SizedBox(
        height: ScreenUtils.smallWidghtWidth,
        width: ScreenUtils.largeWidghtWidth,
        child: Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 电量、农历、月份、周几
                      buildBatteryWidget(),
                      Text(ref.watch(homeTimeVmProvider.select((value) => value.lunarText)),
                          style: CPTextStyles.s8.bold.c(CPColors.black)),
                      Text(ref.watch(homeTimeVmProvider.select((value) => value.dateText)),
                          style: CPTextStyles.s8.bold.c(CPColors.black)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: CPColors.black, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                    child: Text(ref.watch(homeTimeVmProvider.select((value) => value.timeText)),
                        style: CPTextStyles.s32.bold.c(CPColors.black).copyWith(letterSpacing: -2)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    ref.watch(homeTimeVmProvider.select((value) => value.festivalList)).asMap().entries.map((entry) {
                      final index = entry.key;
                      final value = entry.value;
                      // 每2个添加换行符
                      final needLineBreak = index > 0 && index % 2 == 0;
                      final separator =
                          index == ref.watch(homeTimeVmProvider.select((value) => value.festivalList)).length - 1
                              ? ''
                              : '、';
                      return '${needLineBreak ? '\n' : ''}$value$separator';
                    }).join(''),
                    style: CPTextStyles.s8.bold.c(CPColors.black),
                    textAlign: TextAlign.center,
                  ),
                  const Expanded(child: CountdownModule()),
                ]),
              ),
              const Expanded(child: WeatherModule()),
            ])));
  }

  // 每次帧刷新回调
  void _tick() {
    // 每隔1s才刷新一次时间，减少不必要的重绘
    if (DateTime.now().millisecondsSinceEpoch - _datetime.millisecondsSinceEpoch > 1000) {
      // 判断如果是跨日，触发全部状态刷新
      if (_datetime.day != DateTime.now().day) {
        _timeModuleVm.refreshState();
      } else {
        _timeModuleVm.updateTimeText(_datetime);
      }
      _datetime = DateTime.now();
    }
    // 每2分钟获取一次电量信息
    if (_lastBatteryTime == null ||
        DateTime.now().millisecondsSinceEpoch - _lastBatteryTime!.millisecondsSinceEpoch > 120000) {
      _lastBatteryTime = DateTime.now();
      _battery.batteryLevel.then((value) {
        _timeModuleVm.updateBatteryLevel(value);
      });
    }
  }

  // 创建电量Widget
  Widget buildBatteryWidget() {
    final value = ref.watch(homeTimeVmProvider.select((value) => value.batteryLevel));
    IconData batteryIcon;
    if (value <= 14) {
      batteryIcon = Icons.battery_0_bar_outlined;
    } else if (value <= 29) {
      batteryIcon = Icons.battery_1_bar_outlined;
    } else if (value <= 44) {
      batteryIcon = Icons.battery_2_bar_outlined;
    } else if (value <= 59) {
      batteryIcon = Icons.battery_3_bar_outlined;
    } else if (value <= 74) {
      batteryIcon = Icons.battery_4_bar_outlined;
    } else if (value <= 89) {
      batteryIcon = Icons.battery_5_bar_outlined;
    } else {
      batteryIcon = Icons.battery_full_outlined;
    }
    return Row(
      children: [
        Icon(batteryIcon, color: CPColors.black, size: 12),
        Text("$value%", style: CPTextStyles.s8.bold.c(CPColors.black)),
      ],
    );
  }
}
