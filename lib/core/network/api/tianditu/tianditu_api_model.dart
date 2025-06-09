import 'package:freezed_annotation/freezed_annotation.dart';

part 'tianditu_api_model.freezed.dart';
part 'tianditu_api_model.g.dart';

/// 解析状态码字段，支持字符串和数字类型
int _parseStatus(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// 天地图逆地理编码响应模型
@freezed
class TiandituReverseGeocodingResponse with _$TiandituReverseGeocodingResponse {
  const TiandituReverseGeocodingResponse._();

  const factory TiandituReverseGeocodingResponse({
    /// 状态码，0表示成功，非0表示失败
    @JsonKey(fromJson: _parseStatus) required int status,

    /// 状态信息
    required String msg,

    /// 逆地理编码结果
    ReverseGeocodingResult? result,
  }) = _TiandituReverseGeocodingResponse;

  factory TiandituReverseGeocodingResponse.fromJson(Map<String, dynamic> json) =>
      _$TiandituReverseGeocodingResponseFromJson(json);

  /// 是否成功
  bool get isSuccess => status == 0;
}

/// 逆地理编码结果
@freezed
class ReverseGeocodingResult with _$ReverseGeocodingResult {
  const factory ReverseGeocodingResult({
    /// 格式化地址
    @JsonKey(name: 'formatted_address') String? formattedAddress,

    /// 坐标信息
    LocationInfo? location,

    /// 地址组件
    ReverseAddressComponent? addressComponent,

    /// 附近POI列表
    List<NearbyPoi>? pois,
  }) = _ReverseGeocodingResult;

  factory ReverseGeocodingResult.fromJson(Map<String, dynamic> json) => _$ReverseGeocodingResultFromJson(json);
}

/// 逆地理编码地址组件
@freezed
class ReverseAddressComponent with _$ReverseAddressComponent {
  const factory ReverseAddressComponent({
    /// 国家
    String? country,

    /// 国家名称
    String? nation,

    /// 国家代码
    String? countryCode,

    /// 省份
    String? province,

    /// 省份代码
    @JsonKey(name: 'province_code') String? provinceCode,

    /// 城市
    String? city,

    /// 城市代码
    @JsonKey(name: 'city_code') String? cityCode,

    /// 区县
    String? county,

    /// 区县代码
    @JsonKey(name: 'county_code') String? countyCode,

    /// 街道/乡镇
    String? town,

    /// 街道/乡镇代码
    @JsonKey(name: 'town_code') String? townCode,

    /// 道路
    String? road,

    /// 门牌号/地址
    String? address,

    /// POI名称
    String? poi,

    /// POI位置
    @JsonKey(name: 'poi_position') String? poiPosition,

    /// 地址位置
    @JsonKey(name: 'address_position') String? addressPosition,

    /// 道路距离
    @JsonKey(name: 'road_distance') int? roadDistance,

    /// 地址距离
    @JsonKey(name: 'address_distance') int? addressDistance,

    /// POI距离
    @JsonKey(name: 'poi_distance') int? poiDistance,
  }) = _ReverseAddressComponent;

  factory ReverseAddressComponent.fromJson(Map<String, dynamic> json) => _$ReverseAddressComponentFromJson(json);
}

/// 附近POI信息
@freezed
class NearbyPoi with _$NearbyPoi {
  const factory NearbyPoi({
    /// POI名称
    String? name,

    /// POI地址
    String? address,

    /// POI类型
    String? category,

    /// 距离（米）
    double? distance,

    /// 坐标
    PoiLocation? location,
  }) = _NearbyPoi;

  factory NearbyPoi.fromJson(Map<String, dynamic> json) => _$NearbyPoiFromJson(json);
}

/// POI坐标信息
@freezed
class PoiLocation with _$PoiLocation {
  const factory PoiLocation({
    /// 经度
    required double lon,

    /// 纬度
    required double lat,
  }) = _PoiLocation;

  factory PoiLocation.fromJson(Map<String, dynamic> json) => _$PoiLocationFromJson(json);
}

/// 天地图地理编码响应模型
@freezed
class TiandituGeocodingResponse with _$TiandituGeocodingResponse {
  const TiandituGeocodingResponse._();

  const factory TiandituGeocodingResponse({
    /// 状态码，0表示成功，非0表示失败
    @JsonKey(fromJson: _parseStatus) required int status,

    /// 状态信息
    required String msg,

    /// 地理编码结果列表
    List<GeocodingResult>? result,
  }) = _TiandituGeocodingResponse;

  factory TiandituGeocodingResponse.fromJson(Map<String, dynamic> json) => _$TiandituGeocodingResponseFromJson(json);

  /// 是否成功
  bool get isSuccess => status == 0;
}

/// 地理编码结果
@freezed
class GeocodingResult with _$GeocodingResult {
  const factory GeocodingResult({
    /// 地址
    String? address,

    /// 坐标信息
    LocationInfo? location,

    /// 地址组件
    AddressComponent? addressComponent,
  }) = _GeocodingResult;

  factory GeocodingResult.fromJson(Map<String, dynamic> json) => _$GeocodingResultFromJson(json);
}

/// 坐标信息
@freezed
class LocationInfo with _$LocationInfo {
  const factory LocationInfo({
    /// 经度
    required double lon,

    /// 纬度
    required double lat,

    /// 级别
    String? level,
  }) = _LocationInfo;

  factory LocationInfo.fromJson(Map<String, dynamic> json) => _$LocationInfoFromJson(json);
}

/// 地址组件
@freezed
class AddressComponent with _$AddressComponent {
  const factory AddressComponent({
    /// 国家
    String? country,

    /// 省份
    String? province,

    /// 城市
    String? city,

    /// 区县
    String? county,

    /// 街道
    String? road,

    /// 门牌号
    String? address,

    /// 地址详情
    String? addressDetail,
  }) = _AddressComponent;

  factory AddressComponent.fromJson(Map<String, dynamic> json) => _$AddressComponentFromJson(json);
}
