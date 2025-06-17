import 'package:precious_life/config/app_config.dart';
import 'package:precious_life/core/network/api/tianditu/tianditu_api_client.dart';
import 'package:precious_life/core/network/api/tianditu/tianditu_api_model.dart';
import 'package:precious_life/core/utils/cp_storage.dart';
import '../../../utils/cp_log.dart';

/// 天地图API服务类
/// 提供地理编码和逆地理编码功能
class TiandituApiService {
  /// 单例
  TiandituApiService._();
  static final TiandituApiService _instance = TiandituApiService._();
  static TiandituApiService get instance => _instance;

  /// API客户端
  final TiandituApiClient _apiClient = TiandituApiClient.instance;

  /// 检查天地图Key是否配置
  static Future<bool> isKeyConfigured() async {
     try {
      // 1. 先检查内存中是否配置（AppConfig）
      if (AppConfig.tiandituApiKey.isNotEmpty) return true;
      
      // 2. 再检查存储中是否配置
      final savedApiKey = await CPStorage.instance.getString(StorageKeys.tiandituApiKey);
      if (savedApiKey != null && savedApiKey.isNotEmpty) {
        // 如果存储中有API Key，更新内存中的配置
        AppConfig.tiandituApiKey = savedApiKey;
        return true;
      }
      // 3. 都没有配置
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 地理编码 - 将地址转换为坐标
  ///
  /// [address] 地址字符串，如："北京市朝阳区阜通东大街6号"
  /// [level] 地址级别，可选值：11(省级)、12(市级)、13(区县级)、14(乡镇级)、15(村庄级)、16(道路级)、17(门牌号级)
  /// [region] 指定查询区域，如："北京市"
  /// 返回地理编码结果
  Future<TiandituGeocodingResponse> geocoding({
    required String address,
    int? level,
    String? region,
  }) async {
    try {
      CPLog.d('TiandituApiService: 开始地理编码 - address: $address, level: $level, region: $region');

      // 构建ds参数 - 按照天地图官方文档格式
      final dsParams = <String, dynamic>{
        'keyWord': address,
      };

      // 添加可选参数
      if (level != null) {
        dsParams['level'] = level;
      }
      if (region != null && region.isNotEmpty) {
        dsParams['region'] = region;
      }

      // 手动构建符合天地图要求的JSON格式字符串（去掉引号和空格）
      final dsBuffer = StringBuffer('{');
      dsParams.forEach((key, value) {
        if (dsBuffer.length > 1) dsBuffer.write(',');
        dsBuffer.write('$key:$value');
      });
      dsBuffer.write('}');

      final queryParameters = <String, dynamic>{
        'ds': dsBuffer.toString(),
      };

      CPLog.d('TiandituApiService: ds参数: ${dsBuffer.toString()}');

      final response = await _apiClient.get<TiandituGeocodingResponse>(
        path: '/geocoder',
        queryParameters: queryParameters,
        fromJson: TiandituGeocodingResponse.fromJson,
      );

      CPLog.d('TiandituApiService: 地理编码成功 - 结果数量: ${response.result?.length ?? 0}');
      return response;
    } catch (e) {
      CPLog.d('TiandituApiService: 地理编码失败 - $e');
      rethrow;
    }
  }

  /// 逆地理编码 - 将坐标转换为地址
  ///
  /// [longitude] 经度
  /// [latitude] 纬度
  /// [ver] 版本号，默认为1
  /// [radius] 搜索半径（米），默认为1000
  /// [extensions] 是否返回扩展信息，默认为false
  /// 返回逆地理编码结果
  Future<TiandituReverseGeocodingResponse> reverseGeocoding({
    required double longitude,
    required double latitude,
    int ver = 1,
    int radius = 1000,
    bool extensions = false,
  }) async {
    try {
      CPLog.d('TiandituApiService: 开始逆地理编码 - lon: $longitude, lat: $latitude');

      // 构建postStr参数 - 按照天地图官方文档格式
      final postStrParams = <String, dynamic>{
        'lon': longitude,
        'lat': latitude,
        'ver': ver,
      };

      // 添加可选参数
      if (radius != 1000) {
        postStrParams['radius'] = radius;
      }
      if (extensions) {
        postStrParams['extensions'] = 'all';
      }

      // 手动构建符合天地图要求的JSON格式字符串（使用单引号）
      final postStrBuffer = StringBuffer('{');
      postStrParams.forEach((key, value) {
        if (postStrBuffer.length > 1) postStrBuffer.write(',');
        if (value is String) {
          postStrBuffer.write("'$key':'$value'");
        } else {
          postStrBuffer.write("'$key':$value");
        }
      });
      postStrBuffer.write('}');

      final queryParameters = <String, dynamic>{
        'postStr': postStrBuffer.toString(),
        'type': 'geocode',
      };

      CPLog.d('TiandituApiService: postStr参数: ${postStrBuffer.toString()}');

      final response = await _apiClient.get<TiandituReverseGeocodingResponse>(
        path: '/geocoder',
        queryParameters: queryParameters,
        fromJson: TiandituReverseGeocodingResponse.fromJson,
      );

      CPLog.d('TiandituApiService: 逆地理编码成功 - 地址: ${response.result?.formattedAddress ?? '未知'}');
      return response;
    } catch (e) {
      CPLog.d('TiandituApiService: 逆地理编码失败 - $e');
      rethrow;
    }
  }

  /// 批量地理编码
  ///
  /// [addresses] 地址列表
  /// [level] 地址级别
  /// [region] 指定查询区域
  /// 返回地理编码结果列表
  Future<List<TiandituGeocodingResponse>> batchGeocoding({
    required List<String> addresses,
    int? level,
    String? region,
  }) async {
    try {
      CPLog.d('TiandituApiService: 开始批量地理编码 - 地址数量: ${addresses.length}');

      final results = <TiandituGeocodingResponse>[];

      // 并发处理多个地址
      final futures = addresses.map((address) => geocoding(
            address: address,
            level: level,
            region: region,
          ));

      final responses = await Future.wait(futures);
      results.addAll(responses);

      CPLog.d('TiandituApiService: 批量地理编码完成 - 成功数量: ${results.length}');
      return results;
    } catch (e) {
      CPLog.d('TiandituApiService: 批量地理编码失败 - $e');
      rethrow;
    }
  }

  /// 批量逆地理编码
  ///
  /// [coordinates] 坐标列表，每个元素为[经度, 纬度]
  /// [ver] 版本号
  /// [radius] 搜索半径
  /// [extensions] 是否返回扩展信息
  /// 返回逆地理编码结果列表
  Future<List<TiandituReverseGeocodingResponse>> batchReverseGeocoding({
    required List<List<double>> coordinates,
    int ver = 1,
    int radius = 1000,
    bool extensions = false,
  }) async {
    try {
      CPLog.d('TiandituApiService: 开始批量逆地理编码 - 坐标数量: ${coordinates.length}');

      final results = <TiandituReverseGeocodingResponse>[];

      // 并发处理多个坐标
      final futures = coordinates.map((coord) {
        if (coord.length != 2) {
          throw ArgumentError('坐标格式错误，应为[经度, 纬度]');
        }
        return reverseGeocoding(
          longitude: coord[0],
          latitude: coord[1],
          ver: ver,
          radius: radius,
          extensions: extensions,
        );
      });

      final responses = await Future.wait(futures);
      results.addAll(responses);

      CPLog.d('TiandituApiService: 批量逆地理编码完成 - 成功数量: ${results.length}');
      return results;
    } catch (e) {
      CPLog.d('TiandituApiService: 批量逆地理编码失败 - $e');
      rethrow;
    }
  }

  /// 获取当前位置的地址信息
  ///
  /// [longitude] 经度
  /// [latitude] 纬度
  /// 返回格式化的地址字符串
  Future<String?> getCurrentLocationAddress({
    required double longitude,
    required double latitude,
  }) async {
    try {
      final response = await reverseGeocoding(
        longitude: longitude,
        latitude: latitude,
        extensions: true,
      );

      if (response.isSuccess && response.result != null) {
        return response.result!.formattedAddress;
      }
      return null;
    } catch (e) {
      CPLog.d('TiandituApiService: 获取当前位置地址失败 - $e');
      return null;
    }
  }

  /// 搜索地址并获取坐标
  ///
  /// [keyword] 搜索关键词
  /// [region] 搜索区域
  /// 返回第一个匹配结果的坐标，如果没有结果返回null
  Future<List<double>?> searchAddressCoordinate({
    required String keyword,
    String? region,
  }) async {
    try {
      final response = await geocoding(
        address: keyword,
        region: region,
      );

      if (response.isSuccess &&
          response.result != null &&
          response.result!.isNotEmpty &&
          response.result!.first.location != null) {
        final location = response.result!.first.location!;
        return [location.lon, location.lat];
      }
      return null;
    } catch (e) {
      CPLog.d('TiandituApiService: 搜索地址坐标失败 - $e');
      return null;
    }
  }

  /// 普通搜索服务
  ///
  /// [keyWord] 搜索的关键字
  /// [mapBound] 查询的地图范围("minx,miny,maxx,maxy")
  /// [level] 目前查询的级别(1-18级)
  /// [queryType] 搜索类型，1:普通搜索（含地铁公交） 7：地名搜索，默认为1
  /// [start] 返回结果起始位(0-300)，默认为0
  /// [count] 返回的结果数量(1-300)，默认为10
  /// [specify] 指定行政区的国标码（行政区划编码表）
  /// [dataTypes] 数据分类（分类编码表）
  /// [show] 返回poi结果信息类别，1:基本poi信息，2:详细poi信息
  /// 返回普通搜索结果
  Future<TiandituSearchResponse> search({
    required String keyWord,
    String? mapBound,
    int? level,
    int queryType = 1,
    int start = 0,
    int count = 10,
    String? specify,
    String? dataTypes,
    int? show,
  }) async {
    try {
      CPLog.d('TiandituApiService: 开始普通搜索 - keyWord: $keyWord, mapBound: $mapBound, level: $level');

      // 构建postStr参数 - 按照天地图官方文档格式
      final postStrParams = <String, dynamic>{
        'keyWord': keyWord,
        'mapBound': "73.4999,3.9667,135.0906,53.5617",
        'level': 10,
        'queryType': queryType,
        'start': start,
        'count': count,
      };

      // 添加可选参数
      if (specify != null && specify.isNotEmpty) {
        postStrParams['specify'] = specify;
      }
      if (dataTypes != null && dataTypes.isNotEmpty) {
        postStrParams['dataTypes'] = dataTypes;
      }
      if (show != null) {
        postStrParams['show'] = show;
      }

      // 手动构建符合天地图要求的JSON格式字符串（使用双引号）
      final postStrBuffer = StringBuffer('{');
      postStrParams.forEach((key, value) {
        if (postStrBuffer.length > 1) postStrBuffer.write(',');
        if (value is String) {
          postStrBuffer.write('"$key":"$value"');
        } else {
          postStrBuffer.write('"$key":$value');
        }
      });
      postStrBuffer.write('}');

      final queryParameters = <String, dynamic>{
        'postStr': postStrBuffer.toString(),
        'type': 'query',
      };

      CPLog.d('TiandituApiService: postStr参数: ${postStrBuffer.toString()}');

      final response = await _apiClient.get<TiandituSearchResponse>(
        path: '/v2/search',
        queryParameters: queryParameters,
        fromJson: TiandituSearchResponse.fromJson,
      );

      CPLog.d('TiandituApiService: 普通搜索成功 - 结果类型: ${response.resultType}, 数量: ${response.count}');
      return response;
    } catch (e) {
      CPLog.d('TiandituApiService: 普通搜索失败 - $e');
      rethrow;
    }
  }

  /// 搜索POI点并获取坐标列表
  ///
  /// [keyWord] 搜索关键词
  /// [mapBound] 查询的地图范围("minx,miny,maxx,maxy")
  /// [level] 查询级别(1-18级)
  /// [count] 返回的结果数量，默认为10
  /// 返回POI坐标列表，格式为[经度, 纬度]
  Future<List<List<double>>> searchPoiCoordinates({
    required String keyWord,
    required String mapBound,
    required int level,
    int count = 10,
  }) async {
    try {
      final response = await search(
        keyWord: keyWord,
        mapBound: mapBound,
        level: level,
        queryType: 1,
        count: count,
      );

      final coordinates = <List<double>>[];

      if (response.isSuccess && response.pois != null) {
        for (final poi in response.pois!) {
          // 解析坐标字符串，格式为"经度,纬度"
          final lonlatParts = poi.lonlat.split(',');
          if (lonlatParts.length == 2) {
            final lon = double.tryParse(lonlatParts[0]);
            final lat = double.tryParse(lonlatParts[1]);
            if (lon != null && lat != null) {
              coordinates.add([lon, lat]);
            }
          }
        }
      }

      CPLog.d('TiandituApiService: 搜索POI坐标成功 - 数量: ${coordinates.length}');
      return coordinates;
    } catch (e) {
      CPLog.d('TiandituApiService: 搜索POI坐标失败 - $e');
      return [];
    }
  }

  /// 在指定区域搜索关键词
  ///
  /// [keyWord] 搜索关键词
  /// [centerLon] 中心点经度
  /// [centerLat] 中心点纬度  
  /// [radius] 搜索半径（米），默认为1000米
  /// [level] 查询级别，默认为12
  /// [count] 返回结果数量，默认为10
  /// 返回搜索结果
  Future<TiandituSearchResponse> searchNearby({
    required String keyWord,
    required double centerLon,
    required double centerLat,
    double radius = 1000.0,
    int level = 12,
    int count = 10,
  }) async {
    try {
      // 根据中心点和半径计算mapBound
      // 简化计算：1度经纬度约等于111000米
      final deltaLon = radius / 111000.0;
      final deltaLat = radius / 111000.0;

      final minLon = centerLon - deltaLon;
      final maxLon = centerLon + deltaLon;
      final minLat = centerLat - deltaLat;
      final maxLat = centerLat + deltaLat;

      final mapBound = '$minLon,$minLat,$maxLon,$maxLat';

      CPLog.d('TiandituApiService: 附近搜索 - 中心点: ($centerLon,$centerLat), 半径: ${radius}m, 范围: $mapBound');

      return await search(
        keyWord: keyWord,
        mapBound: mapBound,
        level: level,
        count: count,
      );
    } catch (e) {
      CPLog.d('TiandituApiService: 附近搜索失败 - $e');
      rethrow;
    }
  }

  /// 批量搜索多个关键词
  ///
  /// [keyWords] 搜索关键词列表
  /// [mapBound] 查询的地图范围
  /// [level] 查询级别
  /// [count] 每个关键词返回的结果数量，默认为5
  /// 返回搜索结果列表
  Future<List<TiandituSearchResponse>> batchSearch({
    required List<String> keyWords,
    required String mapBound,
    required int level,
    int count = 5,
  }) async {
    try {
      CPLog.d('TiandituApiService: 开始批量搜索 - 关键词数量: ${keyWords.length}');

      final results = <TiandituSearchResponse>[];

      // 并发处理多个搜索
      final futures = keyWords.map((keyword) => search(
            keyWord: keyword,
            mapBound: mapBound,
            level: level,
            count: count,
          ));

      final responses = await Future.wait(futures);
      results.addAll(responses);

      CPLog.d('TiandituApiService: 批量搜索完成 - 成功数量: ${results.length}');
      return results;
    } catch (e) {
      CPLog.d('TiandituApiService: 批量搜索失败 - $e');
      rethrow;
    }
  }
}
