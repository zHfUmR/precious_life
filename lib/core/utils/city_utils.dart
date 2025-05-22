import 'package:flutter/services.dart' show rootBundle;

/// 城市工具类
/// 用于懒加载城市数据并提供城市查找功能
class CityUtils {
  // 私有构造函数，防止外部实例化
  CityUtils._();
  
  // 单例实例
  static final CityUtils _instance = CityUtils._();
  
  /// 获取单例实例
  static CityUtils get instance => _instance;
  
  // 城市数据缓存
  List<String>? _cities;
  
  // 标记是否正在加载
  bool _isLoading = false;
  
  /// 加载城市数据
  /// 
  /// 如果数据已加载，则直接返回
  /// 如果正在加载中，则等待加载完成
  /// 首次加载时从assets读取数据
  Future<List<String>> loadCities() async {
    // 如果已经加载过，直接返回缓存数据
    if (_cities != null) return _cities!;
    
    // 防止重复加载
    if (_isLoading) {
      // 等待直到加载完成
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _cities ?? [];
    }
    
    _isLoading = true;
    
    try {
      // 从assets加载城市数据
      final String content = await rootBundle.loadString('assets/data/cities.txt');
      
      // 按行分割并过滤空行
      _cities = content
          .split('\n')
          .where((city) => city.trim().isNotEmpty)
          .toList();
      
      return _cities!;
    } catch (e) {
      print('加载城市数据失败: $e');
      return [];
    } finally {
      _isLoading = false;
    }
  }
  
  /// 查找匹配关键词的城市
  /// 
  /// [keyword] 查找关键词
  /// [caseSensitive] 是否区分大小写，默认不区分
  /// 
  /// 返回包含关键词的城市列表
  Future<List<String>> findCities(String keyword, {bool caseSensitive = false}) async {
    if (keyword.isEmpty) return [];
    
    // 确保城市数据已加载
    final cities = await loadCities();
    
    // 如果区分大小写，直接查找；否则转换为小写比较
    if (caseSensitive) {
      return cities.where((city) => city.contains(keyword)).toList();
    } else {
      final lowerKeyword = keyword.toLowerCase();
      return cities.where((city) => city.toLowerCase().contains(lowerKeyword)).toList();
    }
  }
  
  /// 获取所有城市
  /// 
  /// 返回所有已加载的城市
  Future<List<String>> getAllCities() => loadCities();
  
  /// 清除缓存数据
  /// 
  /// 用于需要重新加载数据的场景
  void clearCache() {
    _cities = null;
  }
}
