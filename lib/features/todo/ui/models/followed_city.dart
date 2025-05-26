import 'package:precious_life/core/utils/city_utils.dart';

/// 关注的城市信息模型
class FollowedCity {
  /// 省份名称（如：北京市）
  final String province;

  /// 城市名称（如：北京市）
  final String name;

  /// 地区名称（如：北京）
  final String region;

  /// 城市代码
  final String code;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 排序顺序
  final int order;

  const FollowedCity({
    required this.province,
    required this.name,
    required this.region,
    required this.code,
    required this.latitude,
    required this.longitude,
    required this.order,
  });

  /// 从CityInfo创建FollowedCity
  factory FollowedCity.fromCityInfo(CityInfo cityInfo, int order) => FollowedCity(
        province: cityInfo.province,
        name: cityInfo.city,
        region: cityInfo.district,
        code: cityInfo.code,
        latitude: cityInfo.latitude,
        longitude: cityInfo.longitude,
        order: order,
      );

  /// 从JSON创建FollowedCity
  factory FollowedCity.fromJson(Map<String, dynamic> json) => FollowedCity(
        province: json['province'] as String? ?? '', // 兼容旧数据
        name: json['name'] as String,
        region: json['region'] as String,
        code: json['code'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        order: json['order'] as int,
      );

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
        'province': province,
        'name': name,
        'region': region,
        'code': code,
        'latitude': latitude,
        'longitude': longitude,
        'order': order,
      };

  /// 转换为CityInfo
  CityInfo toCityInfo() => CityInfo(
        province: province,
        city: name,
        district: region,
        provinceEnglish: '', // FollowedCity不存储英文名
        cityEnglish: '',
        districtEnglish: '',
        code: code,
        latitude: latitude,
        longitude: longitude,
        adminCode: '',
      );

  /// 显示名称（省-市-区格式）
  String get displayName => '$province-$name-$region';

  /// 简化显示名称（市-区格式，移除"市"后缀，特殊地区显示简称）
  String get simpleDisplayName {
    // 处理特殊行政区
    if (province.contains('香港')) return '香港-$region';
    if (province.contains('澳门')) return '澳门-$region';
    if (province.contains('台湾')) return '台湾-$region';
    // 处理城市名称，移除"市"后缀
    String cityName = name;
    if (cityName.endsWith('市')) {
      cityName = cityName.substring(0, cityName.length - 1);
    }
    // 标准格式：城市-地区
    return '$cityName-$region';
  }

  /// 复制并修改字段
  FollowedCity copyWith({
    String? province,
    String? name,
    String? region,
    String? code,
    double? latitude,
    double? longitude,
    int? order,
  }) =>
      FollowedCity(
        province: province ?? this.province,
        name: name ?? this.name,
        region: region ?? this.region,
        code: code ?? this.code,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        order: order ?? this.order,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FollowedCity &&
          runtimeType == other.runtimeType &&
          province == other.province &&
          name == other.name &&
          region == other.region &&
          code == other.code;

  @override
  int get hashCode => province.hashCode ^ name.hashCode ^ region.hashCode ^ code.hashCode;

  @override
  String toString() => 'FollowedCity(province: $province, name: $name, region: $region, order: $order)';
}
