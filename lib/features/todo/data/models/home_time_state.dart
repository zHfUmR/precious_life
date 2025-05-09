import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_time_state.freezed.dart';

@freezed
class HomeTimeState with _$HomeTimeState {
  const factory HomeTimeState({
    required int batteryLevel,
    required String dateText,
    required String lunarText,
    required List<String> festivalList,
    required String tipText,
    required String timeText,
  }) = _HomeTimeState;
}
