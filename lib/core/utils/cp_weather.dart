import 'package:flutter/material.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/core/utils/cp_storage.dart';
import 'package:precious_life/config/app_config.dart';

/// 天气工具类
/// 统一处理天气相关的图标、颜色、文本等逻辑
class CPWeather {
  CPWeather._();

  /// 检查天气API Key是否已配置
  /// 
  /// 返回true表示已配置有效的API Key，false表示未配置或使用默认值
  static Future<bool> isWeatherApiKeyConfigured() async {
    try {
      // 从存储中获取保存的API Key
      final savedApiKey = await CPSP.instance.getString(StorageKeys.weatherApiKey);
      
      // 优先使用存储中的API Key
      if (savedApiKey != null && savedApiKey.isNotEmpty) {
        // 如果存储中有API Key，确保AppConfig同步
        if (AppConfig.qweatherApiKey != savedApiKey) {
          AppConfig.qweatherApiKey = savedApiKey;
        }
        return true;
      }
      
      // 如果存储中没有，但AppConfig中有（可能是初始化时设置的默认值）
      if (AppConfig.qweatherApiKey.isNotEmpty) {
                  await CPSP.instance.setString(StorageKeys.weatherApiKey, AppConfig.qweatherApiKey);
        return true;
      }
      
      // 都没有配置
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 根据天气代码获取对应的图标数据
  /// 
  /// [icon] 天气代码
  /// 返回包含图标和颜色信息的WeatherIconData
  static WeatherIconData getWeatherIconData(String? icon) {
    if (icon == null) {
      return const WeatherIconData(
        iconData: Icons.help_outline,
        color: CPColors.lightGrey,
      );
    }

    switch (icon) {
      // 晴天
      case '100':
      case '150':
        return const WeatherIconData(
          iconData: Icons.wb_sunny,
          color: Colors.orange,
        );

      // 多云
      case '101':
      case '102':
      case '103':
      case '151':
      case '152':
      case '153':
        return const WeatherIconData(
          iconData: Icons.wb_cloudy,
          color: CPColors.lightGrey,
        );

      // 阴天
      case '104':
        return const WeatherIconData(
          iconData: Icons.cloud,
          color: CPColors.darkGrey,
        );

      // 雨天
      case '300':
      case '301':
      case '302':
      case '303':
      case '304':
      case '305':
      case '306':
      case '307':
      case '308':
      case '309':
      case '310':
      case '311':
      case '312':
      case '313':
      case '314':
      case '315':
      case '316':
      case '317':
      case '318':
      case '350':
      case '351':
      case '399':
        return const WeatherIconData(
          iconData: Icons.grain,
          color: Colors.blue,
        );

      // 雪天
      case '400':
      case '401':
      case '402':
      case '403':
      case '404':
      case '405':
      case '406':
      case '407':
      case '408':
      case '409':
      case '410':
      case '456':
      case '457':
      case '499':
        return const WeatherIconData(
          iconData: Icons.ac_unit,
          color: Colors.lightBlue,
        );

      // 雾霾
      case '500':
      case '501':
      case '502':
      case '509':
      case '510':
      case '511':
      case '512':
      case '513':
      case '514':
      case '515':
        return const WeatherIconData(
          iconData: Icons.blur_on,
          color: CPColors.darkGrey,
        );

      // 沙尘
      case '503':
      case '504':
      case '507':
      case '508':
        return const WeatherIconData(
          iconData: Icons.waves,
          color: Colors.brown,
        );

      // 高温/低温
      case '900':
        return const WeatherIconData(
          iconData: Icons.whatshot,
          color: Colors.red,
        );
      case '901':
        return const WeatherIconData(
          iconData: Icons.ac_unit,
          color: Colors.blue,
        );

      default:
        return const WeatherIconData(
          iconData: Icons.wb_sunny,
          color: CPColors.lightGrey,
        );
    }
  }

  /// 获取天气图标组件
  /// 
  /// [icon] 天气代码
  /// [size] 图标大小
  /// [defaultColor] 默认颜色，如果不传则使用预设颜色
  static Widget getWeatherIcon(String? icon, double size, {Color? defaultColor}) {
    final iconData = getWeatherIconData(icon);
    return Icon(
      iconData.iconData,
      size: size,
      color: defaultColor ?? iconData.color,
    );
  }

  /// 获取天气文本组件
  /// 
  /// [icon] 天气代码
  /// [text] 天气文本描述
  /// [fontSize] 字体大小，默认为8
  static Text getWeatherText(String? icon, String? text, {double fontSize = 8}) {
    if (icon == null || text == null) {
      return Text('未知', style: CPTextStyles.s8.c(Colors.grey));
    }

    Color textColor;
    switch (icon) {
      // 晴天 - 橙色/黄色
      case '100':
      case '150':
        textColor = Colors.orange;
        break;

      // 多云 - 灰蓝色
      case '101':
      case '151':
        textColor = Colors.blueGrey;
        break;

      // 少云 - 淡蓝色
      case '102':
      case '152':
        textColor = Colors.lightBlue;
        break;

      // 晴间多云 - 橙蓝混合
      case '103':
      case '153':
        textColor = Colors.amber;
        break;

      // 阴天 - 深灰色
      case '104':
        textColor = Colors.grey[600]!;
        break;

      // 阵雨 - 蓝色
      case '300':
      case '350':
        textColor = Colors.blue;
        break;

      // 强阵雨 - 深蓝色
      case '301':
      case '351':
        textColor = Colors.indigo;
        break;

      // 雷阵雨 - 紫色
      case '302':
      case '303':
        textColor = Colors.purple;
        break;

      // 雷阵雨伴有冰雹 - 深紫色
      case '304':
        textColor = Colors.deepPurple;
        break;

      // 小雨到中雨 - 浅蓝色
      case '305': // 小雨
        textColor = Colors.lightBlue[300]!;
        break;
      case '306': // 中雨
        textColor = Colors.blue[400]!;
        break;
      case '309': // 毛毛雨/细雨
        textColor = Colors.lightBlue[200]!;
        break;
      case '314': // 小到中雨
        textColor = Colors.lightBlue[400]!;
        break;

      // 大雨到特大暴雨 - 深蓝色系
      case '307': // 大雨
        textColor = Colors.blue[600]!;
        break;
      case '308': // 极端降雨
        textColor = Colors.blue[800]!;
        break;
      case '310': // 暴雨
        textColor = Colors.indigo[600]!;
        break;
      case '311': // 大暴雨
        textColor = Colors.indigo[700]!;
        break;
      case '312': // 特大暴雨
        textColor = Colors.indigo[800]!;
        break;
      case '315': // 中到大雨
        textColor = Colors.blue[500]!;
        break;
      case '316': // 大到暴雨
        textColor = Colors.indigo[500]!;
        break;
      case '317': // 暴雨到大暴雨
        textColor = Colors.indigo[600]!;
        break;
      case '318': // 大暴雨到特大暴雨
        textColor = Colors.indigo[800]!;
        break;

      // 冻雨 - 青色
      case '313':
        textColor = Colors.cyan[600]!;
        break;

      // 雨 (通用) - 蓝色
      case '399':
        textColor = Colors.blue;
        break;

      // 雪 - 白色/浅灰色
      case '400': // 小雪
        textColor = Colors.grey[300]!;
        break;
      case '401': // 中雪
        textColor = Colors.grey[400]!;
        break;
      case '402': // 大雪
        textColor = Colors.grey[500]!;
        break;
      case '403': // 暴雪
        textColor = Colors.grey[600]!;
        break;
      case '407': // 阵雪
      case '457': // 阵雪
        textColor = Colors.grey[300]!;
        break;
      case '408': // 小到中雪
        textColor = Colors.grey[350]!;
        break;
      case '409': // 中到大雪
        textColor = Colors.grey[450]!;
        break;
      case '410': // 大到暴雪
        textColor = Colors.grey[550]!;
        break;
      case '499': // 雪
        textColor = Colors.grey[400]!;
        break;

      // 雨夹雪 - 青灰色
      case '404':
      case '405':
      case '406':
      case '456':
        textColor = Colors.blueGrey[400]!;
        break;

      // 雾 - 淡灰色系
      case '500': // 薄雾
        textColor = Colors.grey[300]!;
        break;
      case '501': // 雾
        textColor = Colors.grey[400]!;
        break;
      case '509': // 浓雾
        textColor = Colors.grey[500]!;
        break;
      case '510': // 强浓雾
        textColor = Colors.grey[600]!;
        break;
      case '514': // 大雾
        textColor = Colors.grey[550]!;
        break;
      case '515': // 特强浓雾
        textColor = Colors.grey[700]!;
        break;

      // 霾 - 棕色系
      case '502': // 霾
        textColor = Colors.brown[300]!;
        break;
      case '511': // 中度霾
        textColor = Colors.brown[400]!;
        break;
      case '512': // 重度霾
        textColor = Colors.brown[500]!;
        break;
      case '513': // 严重霾
        textColor = Colors.brown[600]!;
        break;

      // 沙尘 - 黄褐色系
      case '503': // 扬沙
        textColor = Colors.orange[300]!;
        break;
      case '504': // 浮尘
        textColor = Colors.orange[400]!;
        break;
      case '507': // 沙尘暴
        textColor = Colors.orange[600]!;
        break;
      case '508': // 强沙尘暴
        textColor = Colors.orange[700]!;
        break;

      // 温度 - 红色/蓝色
      case '900': // 高温
        textColor = Colors.red;
        break;
      case '901': // 低温
        textColor = Colors.blue[600]!;
        break;

      // 默认
      default:
        textColor = Colors.grey;
        break;
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  /// 获取天气渐变色
  /// 
  /// [weatherIcon] 天气代码
  /// 返回用于背景渐变的颜色列表
  static List<Color> getWeatherGradientColors(String? weatherIcon) {
    switch (weatherIcon) {
      case '100': // 晴天
      case '150':
        return [
          const Color(0xFF87CEEB),
          const Color(0xFFFFD700),
          const Color(0xFFFFA500),
          const Color(0xFFFF6347),
        ];
      case '101': // 多云
      case '102':
      case '103':
        return [
          const Color(0xFF87CEEB),
          const Color(0xFFB0C4DE),
          const Color(0xFF778899),
          const Color(0xFF696969),
        ];
      case '104': // 阴天
        return [
          const Color(0xFF708090),
          const Color(0xFF778899),
          const Color(0xFF696969),
          const Color(0xFF2F4F4F),
        ];
      default: // 雨雪等
        if (weatherIcon != null && weatherIcon.startsWith('3')) {
          return [
            const Color(0xFF4682B4),
            const Color(0xFF5F9EA0),
            const Color(0xFF008B8B),
            const Color(0xFF2F4F4F),
          ];
        } else if (weatherIcon != null && weatherIcon.startsWith('4')) {
          return [
            const Color(0xFFB0E0E6),
            const Color(0xFF87CEEB),
            const Color(0xFF4682B4),
            const Color(0xFF191970),
          ];
        } else {
          return [
            const Color(0xFF87CEEB),
            const Color(0xFF4682B4),
            const Color(0xFF2F4F4F),
            const Color(0xFF191970),
          ];
        }
    }
  }

  /// 获取预警颜色
  /// 
  /// [severityColor] 预警等级颜色字符串
  /// 返回对应的Color对象
  static Color getWarningColor(String? severityColor) {
    switch (severityColor?.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// 格式化更新时间
  /// 
  /// [obsTime] 观测时间字符串
  /// 返回格式化后的时间字符串 (HH:mm)
  static String formatUpdateTime(String? obsTime) {
    if (obsTime == null) return '--';
    try {
      // 处理带时区的时间格式，如：2025-05-27T13:50+08:00
      DateTime dateTime;
      if (obsTime.contains('+') || obsTime.contains('Z')) {
        // 如果包含时区信息，直接解析
        dateTime = DateTime.parse(obsTime);
        // 转换为本地时间
        dateTime = dateTime.toLocal();
      } else {
        // 如果没有时区信息，当作本地时间处理
        dateTime = DateTime.parse(obsTime);
      }
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return obsTime;
    }
  }

  /// 格式化逐小时预报时间
  /// 
  /// [fxTime] 预报时间字符串
  /// 返回格式化后的时间字符串 (HH:mm)
  static String formatHourlyTime(String? fxTime) {
    if (fxTime == null) return '--';
    try {
      final dateTime = DateTime.parse(fxTime);
      // 统一显示为 HH:MM 格式
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--';
    }
  }

  /// 获取日期名称
  /// 
  /// [date] 日期对象
  /// 返回友好的日期名称（今天、明天、后天、周几）
  static String getDayName(DateTime? date) {
    if (date == null) return '--';
    
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day)).inDays;
    
    switch (difference) {
      case 0:
        return '今天';
      case 1:
        return '明天';
      case 2:
        return '后天';
      default:
        final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
        return weekdays[date.weekday - 1];
    }
  }

  static Future<bool> isWeatherApiKeyValid() async {
    final isConfigured = await isWeatherApiKeyConfigured();
    if (!isConfigured) return false;
    return true;
  }
}

/// 天气图标数据类
/// 包含图标和颜色信息
class WeatherIconData {
  /// 图标数据
  final IconData iconData;
  /// 图标颜色
  final Color color;

  const WeatherIconData({
    required this.iconData,
    required this.color,
  });
} 