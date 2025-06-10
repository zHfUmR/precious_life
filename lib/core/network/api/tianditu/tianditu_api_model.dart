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

/// 天地图普通搜索响应模型
@freezed
class TiandituSearchResponse with _$TiandituSearchResponse {
  const TiandituSearchResponse._();

  const factory TiandituSearchResponse({
    /// 返回结果类型，1-5对应不同响应类型
    required int resultType,

    /// 返回总条数
    required int count,

    /// 搜索关键词
    required String keyword,

    /// POI点集合（resultType=1时返回）
    List<SearchPoi>? pois,

    /// 统计信息（resultType=2时返回）
    SearchStatistics? statistics,

    /// 行政区信息（resultType=3时返回）
    List<SearchArea>? area,

    /// 线路结果（resultType=5时返回）
    List<SearchLineData>? lineData,

    /// 提示信息
    SearchPrompt? prompt,

    /// 状态信息
    required SearchStatus status,
  }) = _TiandituSearchResponse;

  factory TiandituSearchResponse.fromJson(Map<String, dynamic> json) => _$TiandituSearchResponseFromJson(json);

  /// 是否成功
  bool get isSuccess => status.infocode == 1000;
}

/// 搜索POI点信息
@freezed
class SearchPoi with _$SearchPoi {
  const factory SearchPoi({
    /// POI点名称
    required String name,

    /// 电话
    String? phone,

    /// 地址
    String? address,

    /// 坐标
    required String lonlat,

    /// POI类型（101:POI数据 102:公交站点）
    required int poiType,

    /// 英文地址
    String? eaddress,

    /// POI点英文名称
    String? ename,

    /// POI热点ID
    required String hotPointID,

    /// 所属省名称
    String? province,

    /// 省行政区编码
    String? provinceCode,

    /// 所属城市名称
    String? city,

    /// 市行政区编码
    String? cityCode,

    /// 所属区县名称
    String? county,

    /// 区县行政区编码
    String? countyCode,

    /// 数据信息来源
    required String source,

    /// 分类编码
    String? typeCode,

    /// 分类名称
    String? typeName,

    /// 车站信息结构体数据（poiType=102时有效）
    List<StationData>? stationData,
  }) = _SearchPoi;

  factory SearchPoi.fromJson(Map<String, dynamic> json) => _$SearchPoiFromJson(json);
}

/// 车站信息
@freezed
class StationData with _$StationData {
  const factory StationData({
    /// 线路名称
    required String lineName,

    /// 线路的id
    required String uuid,

    /// 公交站uuid
    required String stationUuid,
  }) = _StationData;

  factory StationData.fromJson(Map<String, dynamic> json) => _$StationDataFromJson(json);
}

/// 搜索统计信息
@freezed
class SearchStatistics with _$SearchStatistics {
  const factory SearchStatistics({
    /// 返回搜索POI总数量
    required int count,

    /// 行政区数量
    required int adminCount,

    /// 推荐行政区名称
    required List<PriorityCity> priorityCitys,

    /// 各省包含信息集合
    required List<AllAdmin> allAdmins,
  }) = _SearchStatistics;

  factory SearchStatistics.fromJson(Map<String, dynamic> json) => _$SearchStatisticsFromJson(json);
}

/// 推荐城市信息
@freezed
class PriorityCity with _$PriorityCity {
  const factory PriorityCity({
    /// 行政区名称
    required String name,

    /// 城市数量
    required int count,

    /// 行政区中心点经纬度
    required String lonlat,

    /// 英文行政名称
    required String ename,

    /// 城市国标码
    required int adminCode,
  }) = _PriorityCity;

  factory PriorityCity.fromJson(Map<String, dynamic> json) => _$PriorityCityFromJson(json);
}

/// 各省包含信息
@freezed
class AllAdmin with _$AllAdmin {
  const factory AllAdmin({
    /// 行政区名称
    required String name,

    /// 包含数量
    required int count,

    /// 行政区中心点经纬度
    required String lonlat,

    /// 省国标码
    required String adminCode,

    /// 英文行政名称
    required String ename,

    /// 有无下一级行政区
    required bool isleaf,
  }) = _AllAdmin;

  factory AllAdmin.fromJson(Map<String, dynamic> json) => _$AllAdminFromJson(json);
}

/// 搜索行政区信息
@freezed
class SearchArea with _$SearchArea {
  const factory SearchArea({
    /// 名称
    required String name,

    /// 定位范围
    required String bound,

    /// 定位中心点坐标
    required String lonlat,

    /// 行政区编码
    required int adminCode,

    /// 显示级别（1-18级）
    required int level,
  }) = _SearchArea;

  factory SearchArea.fromJson(Map<String, dynamic> json) => _$SearchAreaFromJson(json);
}

/// 搜索线路结果
@freezed
class SearchLineData with _$SearchLineData {
  const factory SearchLineData({
    /// 站数量
    required String stationNum,

    /// 类型为103
    required String poiType,

    /// 线路名称
    required String name,

    /// 线路id
    required String uuid,
  }) = _SearchLineData;

  factory SearchLineData.fromJson(Map<String, dynamic> json) => _$SearchLineDataFromJson(json);
}

/// 搜索提示信息
@freezed
class SearchPrompt with _$SearchPrompt {
  const factory SearchPrompt({
    /// 提示类型
    required int type,

    /// 行政区信息
    required List<AdminInfo> admins,
  }) = _SearchPrompt;

  factory SearchPrompt.fromJson(Map<String, dynamic> json) => _$SearchPromptFromJson(json);
}

/// 行政区信息
@freezed
class AdminInfo with _$AdminInfo {
  const factory AdminInfo({
    /// 行政区名称
    required String adminName,

    /// 行政区划编码
    required String adminCode,
  }) = _AdminInfo;

  factory AdminInfo.fromJson(Map<String, dynamic> json) => _$AdminInfoFromJson(json);
}

/// 搜索状态信息
@freezed
class SearchStatus with _$SearchStatus {
  const factory SearchStatus({
    /// 信息码
    required int infocode,

    /// 返回中文描述
    required String cndesc,
  }) = _SearchStatus;

  factory SearchStatus.fromJson(Map<String, dynamic> json) => _$SearchStatusFromJson(json);
}
