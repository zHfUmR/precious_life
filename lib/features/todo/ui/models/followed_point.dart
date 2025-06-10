import 'package:freezed_annotation/freezed_annotation.dart';
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
  factory FollowedPoint.fromJson(Map<String, dynamic> json) =>
      _$FollowedPointFromJson(json);
}
