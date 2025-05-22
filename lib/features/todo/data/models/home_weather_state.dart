import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_model.dart';
import 'package:precious_life/shared/widgets/loading_status_widget.dart';
import 'package:flutter/material.dart';

part 'home_weather_state.freezed.dart';

@freezed
class HomeWeatherState with _$HomeWeatherState {
  const factory HomeWeatherState({
    required LoadingStatus currentLoadingStatus, // 当前城市加载状态
    String? currentErrorMessage, // 错误信息
    String? currentCity, // 当前定位城市
    double? currentLatitude, // 当前定位经纬度
    double? currentLongitude, // 当前定位经纬度
    QweatherNow? currentWeather, // 当前天气
    QweatherMinutelyResponse? currentMinutelyRain, // 当前分钟级降雨
    List<String>? cityList, // 城市列表
    required LoadingStatus cityLoadingStatus, // 城市列表加载状态
    String? cityErrorMessage, // 城市列表错误信息
    List<QweatherNow>? cityWeatherList, // 城市列表天气
  }) = _HomeWeatherState;
}

/// HomeWeatherState的扩展类
/// 提供对天气数据的格式化处理
extension HomeWeatherStateExt on HomeWeatherState {
  /// 获取格式化后的更新时间
  /// 将obsTime格式化为HH:mm格式
  String get updateTime => currentWeather?.obsTime?.split('T')[1].split('+')[0].substring(0, 5) ?? '--';

  /// 获取当前天气图标
  /// 根据天气代码返回对应的图标
  IconData get weatherIcon {
    final icon = currentWeather?.icon;
    if (icon == null) return Icons.help_outline;

    switch (icon) {
      // 晴
      case '100':
      case '150':
        return Icons.wb_sunny;

      // 多云
      case '101':
      case '151':
        return Icons.cloud;

      // 少云
      case '102':
      case '152':
        return Icons.cloud_queue;

      // 晴间多云
      case '103':
      case '153':
        return Icons.wb_cloudy;

      // 阴
      case '104':
        return Icons.cloud;

      // 阵雨
      case '300':
      case '350':
        return Icons.grain;

      // 强阵雨
      case '301':
      case '351':
        return Icons.umbrella;

      // 雷阵雨
      case '302':
      case '303':
        return Icons.flash_on;

      // 雷阵雨伴有冰雹
      case '304':
        return Icons.ac_unit;

      // 小雨到大雨
      case '305': // 小雨
      case '306': // 中雨
      case '309': // 毛毛雨/细雨
      case '314': // 小到中雨
        return Icons.water_drop;

      // 大雨到特大暴雨
      case '307': // 大雨
      case '308': // 极端降雨
      case '310': // 暴雨
      case '311': // 大暴雨
      case '312': // 特大暴雨
      case '315': // 中到大雨
      case '316': // 大到暴雨
      case '317': // 暴雨到大暴雨
      case '318': // 大暴雨到特大暴雨
        return Icons.thunderstorm;

      // 冻雨
      case '313':
        return Icons.ac_unit;

      // 雨 (通用)
      case '399':
        return Icons.water_drop;

      // 雪
      case '400': // 小雪
      case '401': // 中雪
      case '402': // 大雪
      case '403': // 暴雪
      case '407': // 阵雪
      case '457': // 阵雪
      case '408': // 小到中雪
      case '409': // 中到大雪
      case '410': // 大到暴雪
      case '499': // 雪
        return Icons.ac_unit;

      // 雨夹雪
      case '404':
      case '405':
      case '406':
      case '456':
        return Icons.snowing;

      // 雾和霾
      case '500': // 薄雾
      case '501': // 雾
      case '509': // 浓雾
      case '510': // 强浓雾
      case '514': // 大雾
      case '515': // 特强浓雾
        return Icons.cloud;

      // 霾
      case '502': // 霾
      case '511': // 中度霾
      case '512': // 重度霾
      case '513': // 严重霾
        return Icons.filter_drama;

      // 沙尘
      case '503': // 扬沙
      case '504': // 浮尘
      case '507': // 沙尘暴
      case '508': // 强沙尘暴
        return Icons.grain;

      // 热
      case '900':
        return Icons.wb_sunny_outlined;

      // 冷
      case '901':
        return Icons.ac_unit_outlined;

      // 默认
      default:
        return Icons.help_outline;
    }
  }
}
