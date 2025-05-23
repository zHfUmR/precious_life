import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_model.dart';
import 'package:precious_life/shared/widgets/loading_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:precious_life/config/text_style.dart';

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

  /// 获取当前天气Text组件
  /// 根据天气代码返回对应的带颜色文本组件
  Text get weatherText {
    final icon = currentWeather?.icon;
    if (icon == null) return Text('未知', style: CPTextStyles.s8.c(Colors.grey));

    switch (icon) {
      // 晴天 - 橙色/黄色
      case '100':
      case '150':
        return Text('晴', style: CPTextStyles.s8.c(Colors.orange));

      // 多云 - 灰蓝色
      case '101':
      case '151':
        return Text('多云', style: CPTextStyles.s8.c(Colors.blueGrey));

      // 少云 - 淡蓝色
      case '102':
      case '152':
        return Text('少云', style: CPTextStyles.s8.c(Colors.lightBlue));

      // 晴间多云 - 橙蓝混合
      case '103':
      case '153':
        return Text('晴间多云', style: CPTextStyles.s8.c(Colors.amber));

      // 阴天 - 深灰色
      case '104':
        return Text('阴', style: CPTextStyles.s8.c(Colors.grey[600]!));

      // 阵雨 - 蓝色
      case '300':
      case '350':
        return Text('阵雨', style: CPTextStyles.s8.c(Colors.blue));

      // 强阵雨 - 深蓝色
      case '301':
      case '351':
        return Text('强阵雨', style: CPTextStyles.s8.c(Colors.indigo));

      // 雷阵雨 - 紫色
      case '302':
      case '303':
        return Text('雷阵雨', style: CPTextStyles.s8.c(Colors.purple));

      // 雷阵雨伴有冰雹 - 深紫色
      case '304':
        return Text('雷阵雨伴有冰雹', style: CPTextStyles.s8.c(Colors.deepPurple));

      // 小雨到中雨 - 浅蓝色
      case '305': // 小雨
        return Text('小雨', style: CPTextStyles.s8.c(Colors.lightBlue[300]!));
      case '306': // 中雨
        return Text('中雨', style: CPTextStyles.s8.c(Colors.blue[400]!));
      case '309': // 毛毛雨/细雨
        return Text('毛毛雨', style: CPTextStyles.s8.c(Colors.lightBlue[200]!));
      case '314': // 小到中雨
        return Text('小到中雨', style: CPTextStyles.s8.c(Colors.lightBlue[400]!));

      // 大雨到特大暴雨 - 深蓝色系
      case '307': // 大雨
        return Text('大雨', style: CPTextStyles.s8.c(Colors.blue[600]!));
      case '308': // 极端降雨
        return Text('极端降雨', style: CPTextStyles.s8.c(Colors.blue[800]!));
      case '310': // 暴雨
        return Text('暴雨', style: CPTextStyles.s8.c(Colors.indigo[600]!));
      case '311': // 大暴雨
        return Text('大暴雨', style: CPTextStyles.s8.c(Colors.indigo[700]!));
      case '312': // 特大暴雨
        return Text('特大暴雨', style: CPTextStyles.s8.c(Colors.indigo[800]!));
      case '315': // 中到大雨
        return Text('中到大雨', style: CPTextStyles.s8.c(Colors.blue[500]!));
      case '316': // 大到暴雨
        return Text('大到暴雨', style: CPTextStyles.s8.c(Colors.indigo[500]!));
      case '317': // 暴雨到大暴雨
        return Text('暴雨到大暴雨', style: CPTextStyles.s8.c(Colors.indigo[600]!));
      case '318': // 大暴雨到特大暴雨
        return Text('大暴雨到特大暴雨', style: CPTextStyles.s8.c(Colors.indigo[800]!));

      // 冻雨 - 青色
      case '313':
        return Text('冻雨', style: CPTextStyles.s8.c(Colors.cyan[600]!));

      // 雨 (通用) - 蓝色
      case '399':
        return Text('雨', style: CPTextStyles.s8.c(Colors.blue));

      // 雪 - 白色/浅灰色
      case '400': // 小雪
        return Text('小雪', style: CPTextStyles.s8.c(Colors.grey[300]!));
      case '401': // 中雪
        return Text('中雪', style: CPTextStyles.s8.c(Colors.grey[400]!));
      case '402': // 大雪
        return Text('大雪', style: CPTextStyles.s8.c(Colors.grey[500]!));
      case '403': // 暴雪
        return Text('暴雪', style: CPTextStyles.s8.c(Colors.grey[600]!));
      case '407': // 阵雪
      case '457': // 阵雪
        return Text('阵雪', style: CPTextStyles.s8.c(Colors.grey[300]!));
      case '408': // 小到中雪
        return Text('小到中雪', style: CPTextStyles.s8.c(Colors.grey[350]!));
      case '409': // 中到大雪
        return Text('中到大雪', style: CPTextStyles.s8.c(Colors.grey[450]!));
      case '410': // 大到暴雪
        return Text('大到暴雪', style: CPTextStyles.s8.c(Colors.grey[550]!));
      case '499': // 雪
        return Text('雪', style: CPTextStyles.s8.c(Colors.grey[400]!));

      // 雨夹雪 - 青灰色
      case '404':
      case '405':
      case '406':
      case '456':
        return Text('雨夹雪', style: CPTextStyles.s8.c(Colors.blueGrey[400]!));

      // 雾 - 淡灰色系
      case '500': // 薄雾
        return Text('薄雾', style: CPTextStyles.s8.c(Colors.grey[300]!));
      case '501': // 雾
        return Text('雾', style: CPTextStyles.s8.c(Colors.grey[400]!));
      case '509': // 浓雾
        return Text('浓雾', style: CPTextStyles.s8.c(Colors.grey[500]!));
      case '510': // 强浓雾
        return Text('强浓雾', style: CPTextStyles.s8.c(Colors.grey[600]!));
      case '514': // 大雾
        return Text('大雾', style: CPTextStyles.s8.c(Colors.grey[550]!));
      case '515': // 特强浓雾
        return Text('特强浓雾', style: CPTextStyles.s8.c(Colors.grey[700]!));

      // 霾 - 棕色系
      case '502': // 霾
        return Text('霾', style: CPTextStyles.s8.c(Colors.brown[300]!));
      case '511': // 中度霾
        return Text('中度霾', style: CPTextStyles.s8.c(Colors.brown[400]!));
      case '512': // 重度霾
        return Text('重度霾', style: CPTextStyles.s8.c(Colors.brown[500]!));
      case '513': // 严重霾
        return Text('严重霾', style: CPTextStyles.s8.c(Colors.brown[600]!));

      // 沙尘 - 黄褐色系
      case '503': // 扬沙
        return Text('扬沙', style: CPTextStyles.s8.c(Colors.orange[300]!));
      case '504': // 浮尘
        return Text('浮尘', style: CPTextStyles.s8.c(Colors.orange[400]!));
      case '507': // 沙尘暴
        return Text('沙尘暴', style: CPTextStyles.s8.c(Colors.orange[600]!));
      case '508': // 强沙尘暴
        return Text('强沙尘暴', style: CPTextStyles.s8.c(Colors.orange[700]!));

      // 温度 - 红色/蓝色
      case '900': // 高温
        return Text('高温', style: CPTextStyles.s8.c(Colors.red));
      case '901': // 低温
        return Text('低温', style: CPTextStyles.s8.c(Colors.blue[600]!));

      // 默认
      default:
        return Text('未知', style: CPTextStyles.s8.c(Colors.grey));
    }
  }
}
