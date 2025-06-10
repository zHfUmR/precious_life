import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:precious_life/features/todo/ui/models/followed_city.dart';

part 'followed_point.freezed.dart';
part 'followed_point.g.dart';

/// 跟随点实体类
/// 用于定义用户关注的地理位置信息
@freezed
class FollowedPoint with _$FollowedPoint {
  const factory FollowedPoint({
    /// 省份名称（如：北京市）
    String? province,

    /// 城市名称（如：北京市）
    String? name,

    /// 地区名称（如：北京）
    String? region,

    /// 城市代码
    String? code,

    /// 纬度
    required double latitude,

    /// 经度
    required double longitude,

    /// POI名称
    String? poiName,

    /// POI地址
    String? poiAddress,

    /// 排序顺序
    required int order,
  }) = _FollowedPoint;

  /// 从JSON创建实例
  factory FollowedPoint.fromJson(Map<String, dynamic> json) => _$FollowedPointFromJson(json);

  /// 从FollowedCity创建FollowedPoint
  /// 用于简化从FollowedCity到FollowedPoint的转换
  factory FollowedPoint.fromFollowedCity(FollowedCity city) => FollowedPoint(
        province: city.province,
        name: city.name,
        region: city.region,
        code: city.code,
        latitude: city.latitude,
        longitude: city.longitude,
        poiName: null,
        poiAddress: null,
        order: city.order,
      );

  /// 从另一个FollowedPoint复制创建新实例
  /// 用于简化FollowedPoint之间的复制操作
  factory FollowedPoint.copyFrom(FollowedPoint other) => FollowedPoint(
        province: other.province,
        name: other.name,
        region: other.region,
        code: other.code,
        latitude: other.latitude,
        longitude: other.longitude,
        poiName: other.poiName,
        poiAddress: other.poiAddress,
        order: other.order,
      );
}

/// FollowedPoint扩展方法
/// 提供便利的转换和操作方法
extension FollowedPointExt on FollowedPoint {
  /// 获取显示名称
  /// 如果有POI名称则显示POI名称，否则显示城市-地区格式
  String get displayName {
    if (poiName != null && poiName!.isNotEmpty) {
      return poiName!;
    }
    return '${name ?? ''}-${region ?? ''}';
  }

  /// 获取简化显示名称
  /// 移除"市"后缀，处理特殊行政区
  String get simpleDisplayName {
    if (poiName != null && poiName!.isNotEmpty) {
      return poiName!;
    }
    
    // 处理特殊行政区
    if (province?.contains('香港') == true) return '香港-${region ?? ''}';
    if (province?.contains('澳门') == true) return '澳门-${region ?? ''}';
    if (province?.contains('台湾') == true) return '台湾-${region ?? ''}';
    
    // 处理城市名称，移除"市"后缀
    String cityName = name ?? '';
    if (cityName.endsWith('市')) {
      cityName = cityName.substring(0, cityName.length - 1);
    }
    
    // 标准格式：城市-地区
    return '$cityName-${region ?? ''}';
  }

  /// 获取位置字符串
  /// 返回经纬度格式的字符串，用于API调用
  String get locationString => '$longitude,$latitude';
}
