import 'package:flutter/services.dart' show rootBundle;
import 'cp_log.dart';

/// 城市信息实体类
class CityInfo {
  /// 省份名称
  final String province;

  /// 城市名称
  final String city;

  /// 区县名称
  final String district;

  /// 省份英文名称
  final String provinceEnglish;

  /// 城市英文名称
  final String cityEnglish;

  /// 区县英文名称
  final String districtEnglish;

  /// 城市代码
  final String code;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 行政区划代码
  final String adminCode;

  /// 构造函数
  CityInfo({
    required this.province,
    required this.city,
    required this.district,
    required this.provinceEnglish,
    required this.cityEnglish,
    required this.districtEnglish,
    required this.code,
    required this.latitude,
    required this.longitude,
    required this.adminCode,
  });

  /// 从字符串解析城市信息
  ///
  /// 格式: 省份-城市-区县-省份英文-城市英文-区县英文-城市代码-纬度,经度,行政区划代码
  /// 例如: 北京市-北京市-北京-Beijing-Beijing-Beijing-101010100-39.905,116.4053,110000
  static CityInfo? fromString(String data) {
    try {
      final parts = data.split('-');
      if (parts.length < 8) return null;

      // 解析最后一部分的经纬度和行政区划代码
      final lastPart = parts[7];
      final coordParts = lastPart.split(',');
      if (coordParts.length < 3) return null;

      return CityInfo(
        province: parts[0],
        city: parts[1],
        district: parts[2],
        provinceEnglish: parts[3],
        cityEnglish: parts[4],
        districtEnglish: parts[5],
        code: parts[6],
        latitude: double.tryParse(coordParts[0]) ?? 0.0,
        longitude: double.tryParse(coordParts[1]) ?? 0.0,
        adminCode: coordParts[2],
      );
    } catch (e) {
      CPLog.d('解析城市信息失败: $e');
      return null;
    }
  }

  /// 获取完整的显示名称
  String get fullName => '$province $city $district';

  /// 获取简化的显示名称（城市+区县）
  String get simpleName => '$city $district';

  @override
  String toString() => simpleName;
}

/// 城市工具类
/// 用于懒加载城市数据并提供城市查找功能
class CityUtils {
  // 私有构造函数，防止外部实例化
  CityUtils._();
  // 单例实例
  static final CityUtils _instance = CityUtils._();

  /// 获取单例实例
  static CityUtils get instance => _instance;

  // 城市数据缓存, key为城市名称，value为城市信息
  Map<String, CityInfo>? _cities;

  // 标记是否正在加载
  bool _isLoading = false;

  /// 加载城市数据
  ///
  /// 如果数据已加载，则直接返回
  /// 如果正在加载中，则等待加载完成
  /// 首次加载时从assets读取数据
  Future<Map<String, CityInfo>> loadCities() async {
    // 如果已经加载过，直接返回缓存数据
    if (_cities != null) return _cities!;

    // 防止重复加载
    if (_isLoading) {
      // 等待直到加载完成
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _cities ?? {};
    }

    _isLoading = true;

    try {
      // 从assets加载城市数据
      final String content = await rootBundle.loadString('assets/data/cities.txt');

      // 创建一个新的Map来存储城市信息
      _cities = {};

      // 按行分割并过滤空行，然后解析每一行数据
      content.split('\n').where((line) => line.trim().isNotEmpty).forEach((line) {
        final cityInfo = CityInfo.fromString(line);
        if (cityInfo != null) {
          _cities![line] = cityInfo; // 使用整行作为key
        }
      });

      return _cities!;
    } catch (e) {
      CPLog.d('加载城市数据失败: $e');
      return {};
    } finally {
      _isLoading = false;
    }
  }

  /// 查找匹配关键词的城市
  ///
  /// [keyword] 查找关键词
  /// [caseSensitive] 是否区分大小写，默认不区分
  ///
  /// 返回包含关键词的城市信息列表
  Future<List<CityInfo>> findCities(String keyword, {bool caseSensitive = false}) async {
    if (keyword.isEmpty) return [];

    // 确保城市数据已加载
    final cities = await loadCities();

    // 如果区分大小写，直接查找；否则转换为小写比较
    if (caseSensitive) {
      return cities.entries
          .where((entry) =>
              entry.key.contains(keyword) ||
              entry.value.province.contains(keyword) ||
              entry.value.city.contains(keyword) ||
              entry.value.district.contains(keyword) ||
              entry.value.provinceEnglish.contains(keyword) ||
              entry.value.cityEnglish.contains(keyword) ||
              entry.value.districtEnglish.contains(keyword))
          .map((entry) => entry.value)
          .toList();
    } else {
      final lowerKeyword = keyword.toLowerCase();
      return cities.entries
          .where((entry) =>
              entry.key.toLowerCase().contains(lowerKeyword) ||
              entry.value.province.toLowerCase().contains(lowerKeyword) ||
              entry.value.city.toLowerCase().contains(lowerKeyword) ||
              entry.value.district.toLowerCase().contains(lowerKeyword) ||
              entry.value.provinceEnglish.toLowerCase().contains(lowerKeyword) ||
              entry.value.cityEnglish.toLowerCase().contains(lowerKeyword) ||
              entry.value.districtEnglish.toLowerCase().contains(lowerKeyword))
          .map((entry) => entry.value)
          .toList();
    }
  }

  /// 获取所有城市信息
  ///
  /// 返回所有已加载的城市信息
  Future<List<CityInfo>> getAllCities() async {
    final cities = await loadCities();
    return cities.values.toList();
  }

  /// 根据城市名称精确获取城市信息
  ///
  /// [cityName] 完整的城市名称
  ///
  /// 返回对应的城市信息，如果未找到则返回null
  Future<CityInfo?> getCityByName(String cityName) async {
    final cities = await loadCities();

    // 查找与城市名完全匹配的城市信息
    for (var entry in cities.entries) {
      if (entry.value.city == cityName || entry.value.district == cityName) {
        return entry.value;
      }
    }
    return null;
  }

  /// 清除缓存数据
  ///
  /// 用于需要重新加载数据的场景
  void clearCache() {
    _cities = null;
  }
}
