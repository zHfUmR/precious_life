import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:precious_life/core/utils/city_utils.dart';
part 'followed_point.freezed.dart';
part 'followed_point.g.dart';

/// 关注点位实体类
/// 用于存储用户关注的地理位置信息
@freezed
class FollowedPoint with _$FollowedPoint {
  /// 创建关注点位实例
  const factory FollowedPoint({
    /// 省份名称
    String? province,

    /// 城市名称
    String? city,

    /// 区县名称
    String? district,

    /// 省份英文名称
    String? provinceEnglish,

    /// 城市英文名称
    String? cityEnglish,

    /// 区县英文名称
    String? districtEnglish,

    /// 城市代码
    String? code,

    /// 纬度
    double? latitude,

    /// 经度
    double? longitude,

    /// POI地址信息
    String? poiAddress,

    /// POI名称
    String? poiName,

    /// 排序字段
    int? sort,
  }) = _FollowedPoint;

  /// 从JSON创建实例
  factory FollowedPoint.fromJson(Map<String, dynamic> json) => _$FollowedPointFromJson(json);

  /// 从CityInfo创建实例
  factory FollowedPoint.fromCityInfo(CityInfo cityInfo) => FollowedPoint(
        province: cityInfo.province,
        city: cityInfo.city,
        district: cityInfo.district,
        provinceEnglish: cityInfo.provinceEnglish,
        cityEnglish: cityInfo.cityEnglish,
        districtEnglish: cityInfo.districtEnglish,
        code: cityInfo.code,
        latitude: cityInfo.latitude,
        longitude: cityInfo.longitude,
        poiAddress: null,
        poiName: null,
        sort: -1,
      );
}

/// FollowedPoint 扩展方法
extension FollowedPointExt on FollowedPoint {
  /// 获取经纬度字符串
  String get locationStr => "${longitude ?? 0.0},${latitude ?? 0.0}";

  /// 获取显示名称
  String get displayName {
    final cityName = poiName ?? city ?? '未知城市';
    final provinceName = province ?? '未知省份';
    if (cityName == provinceName) {
      return cityName;
    }
    return '$cityName, $provinceName';
  }

  // 关注点唯一标识
  String get uniqueId {
    if (province != null && province!.isNotEmpty) {
      return '$province-$city-$district';
    }
    return poiName ?? '';
  }
}
