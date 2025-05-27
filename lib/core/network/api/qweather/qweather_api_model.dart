import 'package:freezed_annotation/freezed_annotation.dart';

part 'qweather_api_model.freezed.dart';
part 'qweather_api_model.g.dart';

/// 和风天气城市查询响应模型
@freezed
class QweatherCityResponse with _$QweatherCityResponse {
  const factory QweatherCityResponse({
    /// 状态码
    required String code,

    /// 地区/城市信息
    List<QweatherLocation>? location,

    /// 数据引用信息
    QweatherRefer? refer,
  }) = _QweatherCityResponse;

  factory QweatherCityResponse.fromJson(Map<String, dynamic> json) => _$QweatherCityResponseFromJson(json);
}

/// 和风天气城市位置信息
@freezed
class QweatherLocation with _$QweatherLocation {
  const factory QweatherLocation({
    /// 地区/城市名称
    String? name,

    /// 地区/城市ID
    String? id,

    /// 地区/城市纬度
    String? lat,

    /// 地区/城市经度
    String? lon,

    /// 地区/城市的上级行政区划名称
    String? adm2,

    /// 地区/城市所属一级行政区域
    String? adm1,

    /// 地区/城市所属国家名称
    String? country,

    /// 地区/城市所在时区
    String? tz,

    /// 地区/城市目前与UTC时间偏移的小时数
    String? utcOffset,

    /// 地区/城市是否当前处于夏令时。1 表示当前处于夏令时，0 表示当前不是夏令时
    String? isDst,

    /// 地区/城市的属性
    String? type,

    /// 地区评分
    String? rank,

    /// 该地区的天气预报网页链接，便于嵌入你的网站或应用
    String? fxLink,
  }) = _QweatherLocation;

  factory QweatherLocation.fromJson(Map<String, dynamic> json) => _$QweatherLocationFromJson(json);
}

/// 和风天气数据来源信息
@freezed
class QweatherRefer with _$QweatherRefer {
  const factory QweatherRefer({
    /// 原始数据来源，或数据源说明，可能为空
    List<String>? sources,

    /// 数据许可或版权声明，可能为空
    List<String>? license,
  }) = _QweatherRefer;

  factory QweatherRefer.fromJson(Map<String, dynamic> json) => _$QweatherReferFromJson(json);
}

/// 和风天气实时天气响应模型
@freezed
class QweatherNowResponse with _$QweatherNowResponse {
  const factory QweatherNowResponse({
    /// 状态码
    required String code,

    /// 当前API的最近更新时间
    String? updateTime,

    /// 当前数据的响应式页面，便于嵌入网站或应用
    String? fxLink,

    /// 实时天气数据
    QweatherNow? now,

    /// 数据引用信息
    QweatherRefer? refer,
  }) = _QweatherNowResponse;

  factory QweatherNowResponse.fromJson(Map<String, dynamic> json) => _$QweatherNowResponseFromJson(json);
}

/// 和风天气实时天气数据
@freezed
class QweatherNow with _$QweatherNow {
  const factory QweatherNow({
    /// 数据观测时间
    String? obsTime,

    /// 温度，默认单位：摄氏度
    String? temp,

    /// 体感温度，默认单位：摄氏度
    String? feelsLike,

    /// 天气状况的图标代码
    String? icon,

    /// 天气状况的文字描述，包括阴晴雨雪等天气状态的描述
    String? text,

    /// 风向360角度
    String? wind360,

    /// 风向
    String? windDir,

    /// 风力等级
    String? windScale,

    /// 风速，公里/小时
    String? windSpeed,

    /// 相对湿度，百分比数值
    String? humidity,

    /// 过去1小时降水量，默认单位：毫米
    String? precip,

    /// 大气压强，默认单位：百帕
    String? pressure,

    /// 能见度，默认单位：公里
    String? vis,

    /// 云量，百分比数值。可能为空
    String? cloud,

    /// 露点温度。可能为空
    String? dew,
  }) = _QweatherNow;

  factory QweatherNow.fromJson(Map<String, dynamic> json) => _$QweatherNowFromJson(json);
}

/// 和风天气分钟级降水响应模型
@freezed
class QweatherMinutelyResponse with _$QweatherMinutelyResponse {
  const factory QweatherMinutelyResponse({
    /// 状态码
    required String code,

    /// 当前API的最近更新时间
    String? updateTime,

    /// 当前数据的响应式页面，便于嵌入网站或应用
    String? fxLink,

    /// 分钟级降水数据
    List<QweatherMinutely>? minutely,

    /// 未来两小时降水总量，单位mm
    String? summary,

    /// 数据引用信息
    QweatherRefer? refer,
  }) = _QweatherMinutelyResponse;

  factory QweatherMinutelyResponse.fromJson(Map<String, dynamic> json) => _$QweatherMinutelyResponseFromJson(json);
}

/// 和风天气分钟级降水数据
@freezed
class QweatherMinutely with _$QweatherMinutely {
  const factory QweatherMinutely({
    /// 预报时间，格式yyyy-MM-dd HH:mm
    String? fxTime,

    /// 降水量，默认单位：毫米
    String? precip,

    /// 降水类型，rain表示雨，snow表示雪
    String? type,
  }) = _QweatherMinutely;

  factory QweatherMinutely.fromJson(Map<String, dynamic> json) => _$QweatherMinutelyFromJson(json);
}

/// 和风天气7天预报响应模型
@freezed
class QweatherDailyResponse with _$QweatherDailyResponse {
  const factory QweatherDailyResponse({
    /// 状态码
    required String code,

    /// 当前API的最近更新时间
    String? updateTime,

    /// 当前数据的响应式页面，便于嵌入网站或应用
    String? fxLink,

    /// 7天预报数据
    List<QweatherDaily>? daily,

    /// 数据引用信息
    QweatherRefer? refer,
  }) = _QweatherDailyResponse;

  factory QweatherDailyResponse.fromJson(Map<String, dynamic> json) => _$QweatherDailyResponseFromJson(json);
}

/// 和风天气每日预报数据
@freezed
class QweatherDaily with _$QweatherDaily {
  const factory QweatherDaily({
    /// 预报日期
    String? fxDate,

    /// 日出时间，在高纬度地区可能为空
    String? sunrise,

    /// 日落时间，在高纬度地区可能为空
    String? sunset,

    /// 当天月升时间，可能为空
    String? moonrise,

    /// 当天月落时间，可能为空
    String? moonset,

    /// 月相名称
    String? moonPhase,

    /// 月相图标代码
    String? moonPhaseIcon,

    /// 预报当天最高温度
    String? tempMax,

    /// 预报当天最低温度
    String? tempMin,

    /// 预报白天天气状况的图标代码
    String? iconDay,

    /// 预报白天天气状况文字描述
    String? textDay,

    /// 预报夜间天气状况的图标代码
    String? iconNight,

    /// 预报晚间天气状况文字描述
    String? textNight,

    /// 预报白天风向360角度
    String? wind360Day,

    /// 预报白天风向
    String? windDirDay,

    /// 预报白天风力等级
    String? windScaleDay,

    /// 预报白天风速，公里/小时
    String? windSpeedDay,

    /// 预报夜间风向360角度
    String? wind360Night,

    /// 预报夜间当天风向
    String? windDirNight,

    /// 预报夜间风力等级
    String? windScaleNight,

    /// 预报夜间风速，公里/小时
    String? windSpeedNight,

    /// 相对湿度，百分比数值
    String? humidity,

    /// 预报当天总降水量，默认单位：毫米
    String? precip,

    /// 大气压强，默认单位：百帕
    String? pressure,

    /// 能见度，默认单位：公里
    String? vis,

    /// 云量，百分比数值。可能为空
    String? cloud,

    /// 紫外线强度指数
    String? uvIndex,
  }) = _QweatherDaily;

  factory QweatherDaily.fromJson(Map<String, dynamic> json) => _$QweatherDailyFromJson(json);
}

/// 和风天气预警响应模型
@freezed
class QweatherWarningResponse with _$QweatherWarningResponse {
  const factory QweatherWarningResponse({
    /// 状态码
    required String code,

    /// 当前API的最近更新时间
    String? updateTime,

    /// 当前数据的响应式页面，便于嵌入网站或应用
    String? fxLink,

    /// 预警数据
    List<QweatherWarning>? warning,

    /// 数据引用信息
    QweatherRefer? refer,
  }) = _QweatherWarningResponse;

  factory QweatherWarningResponse.fromJson(Map<String, dynamic> json) => _$QweatherWarningResponseFromJson(json);
}

/// 和风天气预警数据
@freezed
class QweatherWarning with _$QweatherWarning {
  const factory QweatherWarning({
    /// 本条预警的唯一标识
    String? id,

    /// 预警发布单位，可能为空
    String? sender,

    /// 预警发布时间
    String? pubTime,

    /// 预警信息标题
    String? title,

    /// 预警开始时间，可能为空
    String? startTime,

    /// 预警结束时间，可能为空
    String? endTime,

    /// 预警信息的发布状态
    String? status,

    /// 预警等级（已弃用）
    String? level,

    /// 预警严重等级
    String? severity,

    /// 预警严重等级颜色，可能为空
    String? severityColor,

    /// 预警类型ID
    String? type,

    /// 预警类型名称
    String? typeName,

    /// 预警信息的紧迫程度，可能为空
    String? urgency,

    /// 预警信息的确定性，可能为空
    String? certainty,

    /// 预警详细文字描述
    String? text,

    /// 与本条预警相关联的预警ID，可能为空
    String? related,
  }) = _QweatherWarning;

  factory QweatherWarning.fromJson(Map<String, dynamic> json) => _$QweatherWarningFromJson(json);
}

/// 和风天气24小时逐小时预报响应模型
@freezed
class QweatherHourlyResponse with _$QweatherHourlyResponse {
  const factory QweatherHourlyResponse({
    /// 状态码
    required String code,

    /// 当前API的最近更新时间
    String? updateTime,

    /// 当前数据的响应式页面，便于嵌入网站或应用
    String? fxLink,

    /// 逐小时预报数据
    List<QweatherHourly>? hourly,

    /// 数据引用信息
    QweatherRefer? refer,
  }) = _QweatherHourlyResponse;

  factory QweatherHourlyResponse.fromJson(Map<String, dynamic> json) => _$QweatherHourlyResponseFromJson(json);
}

/// 和风天气逐小时预报数据
@freezed
class QweatherHourly with _$QweatherHourly {
  const factory QweatherHourly({
    /// 预报时间
    String? fxTime,

    /// 温度，默认单位：摄氏度
    String? temp,

    /// 天气状况的图标代码
    String? icon,

    /// 天气状况的文字描述
    String? text,

    /// 风向360角度
    String? wind360,

    /// 风向
    String? windDir,

    /// 风力等级
    String? windScale,

    /// 风速，公里/小时
    String? windSpeed,

    /// 相对湿度，百分比数值
    String? humidity,

    /// 逐小时预报降水概率，百分比数值，可能为空
    String? pop,

    /// 当前小时累计降水量，默认单位：毫米
    String? precip,

    /// 大气压强，默认单位：百帕
    String? pressure,

    /// 云量，百分比数值。可能为空
    String? cloud,

    /// 露点温度。可能为空
    String? dew,
  }) = _QweatherHourly;

  factory QweatherHourly.fromJson(Map<String, dynamic> json) => _$QweatherHourlyFromJson(json);
}


