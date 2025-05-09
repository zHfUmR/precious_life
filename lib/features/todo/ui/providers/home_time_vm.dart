import 'package:lunar/calendar/Lunar.dart';
import 'package:lunar/calendar/Solar.dart';
import 'package:precious_life/features/todo/data/models/home_time_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_time_vm.g.dart';

@riverpod
class HomeTimeVm extends _$HomeTimeVm {
  final List<String> weekdays = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"];

  @override
  HomeTimeState build() {
    final dateTime = DateTime.now();
    final dateText = '${dateTime.month}-${dateTime.day}  ${weekDay(dateTime.weekday)}';
    // Solar-阳历拿节假日，Lunar-阴历拿节气
    // final Solar solar = Solar.fromYmd(2025, 3, 5); // 测试代码
    final Solar solar = Solar.fromDate(dateTime);
    // 农历+节气
    final Lunar lunar = solar.getLunar();
    String lanarText = "「${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}";
    if (lunar.getJieQi().isNotEmpty) lanarText += "-${lunar.getJieQi()}";
    lanarText += "」";
    // 节气、节日
    List<String> festivalList = [];
    solar.getFestivals().forEach((e) => festivalList.add(e));
    solar.getOtherFestivals().forEach((e) => festivalList.add(e));
    // 重要日子提醒
    String tipText = '';
    return HomeTimeState(
      batteryLevel: 100,
      dateText: dateText,
      lunarText: lanarText,
      festivalList: festivalList,
      tipText: tipText,
      timeText: timeText(dateTime),
    );
  }

  updateBatteryLevel(int batteryLevel) {
    state = state.copyWith(batteryLevel: batteryLevel);
  }

  updateTimeText(DateTime datetime) {
    state = state.copyWith(timeText: timeText(datetime));
  }

  // 触发全部状态刷新，一般是跨日时
  refreshState() {
    state = build();
  }

  weekDay(int weekday) => weekdays[weekday % 7];

  timeText(DateTime dateTime) => "${dateTime.hour < 10 ? '0' : ''}${dateTime.hour}:"
      "${dateTime.minute < 10 ? '0' : ''}${dateTime.minute}:"
      "${dateTime.second < 10 ? '0' : ''}${dateTime.second}";
}
