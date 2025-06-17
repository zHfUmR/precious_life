import 'dart:convert';
import 'package:precious_life/core/network/api/qweather/qweather_api_service.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_model.dart';
import 'package:precious_life/core/utils/cp_storage.dart';
import 'package:precious_life/core/utils/cp_log.dart';

/// 天气数据仓库
/// 统一管理天气数据的获取、缓存和存储策略
/// 
/// 数据来源优先级：
/// 1. 内存缓存（最快）
/// 2. 本地数据库缓存（中等速度，未过期）
/// 3. 远程API（最慢，但数据最新）
class WeatherRepository {
  // 内存缓存
  final Map<String, _CachedWeatherData> _memoryCache = {};
  
  // 缓存过期时间（30分钟）
  static const Duration _cacheExpiry = Duration(minutes: 30);

  /// 获取指定位置的天气信息
  /// 
  /// [locationStr] 位置字符串，格式为 "longitude,latitude"
  /// [forceRefresh] 是否强制刷新，忽略缓存
  Future<QweatherNowResponse> getWeatherData(
    String locationStr, {
    bool forceRefresh = false,
  }) async {
    try {
      CPLog.d('WeatherRepository: 开始获取天气数据 - $locationStr');
      
      // 1. 检查内存缓存
      if (!forceRefresh) {
        final cachedData = _getFromMemoryCache(locationStr);
        if (cachedData != null) {
          CPLog.d('WeatherRepository: 从内存缓存获取数据');
          return cachedData;
        }
      }

      // 2. 检查本地存储缓存
      if (!forceRefresh) {
        final localCachedData = await _getFromLocalCache(locationStr);
        if (localCachedData != null) {
          CPLog.d('WeatherRepository: 从本地缓存获取数据');
          // 同时更新内存缓存
          _saveToMemoryCache(locationStr, localCachedData);
          return localCachedData;
        }
      }

      // 3. 从远程API获取最新数据
      CPLog.d('WeatherRepository: 从远程API获取数据');
      final apiResponse = await QweatherApiService.getNowWeather(locationStr);
      
      // 4. 保存到各级缓存
      await _saveToLocalCache(locationStr, apiResponse);
      _saveToMemoryCache(locationStr, apiResponse);
      
      return apiResponse;
      
    } catch (e) {
      CPLog.e('WeatherRepository: 获取天气数据失败 - $e');
      
      // 如果API失败，尝试返回过期的缓存数据
      final expiredCache = await _getFromLocalCache(locationStr, allowExpired: true);
      if (expiredCache != null) {
        CPLog.w('WeatherRepository: 返回过期缓存数据');
        return expiredCache;
      }
      
      throw WeatherRepositoryException('获取天气数据失败: $e');
    }
  }

  /// 批量获取多个位置的天气信息
  /// 
  /// [locations] 位置列表
  /// [maxConcurrency] 最大并发请求数
  Future<Map<String, QweatherNowResponse>> getBatchWeatherData(
    List<String> locations, {
    int maxConcurrency = 3,
  }) async {
    final results = <String, QweatherNowResponse>{};
    
    // 分批处理，避免过多并发请求
    for (int i = 0; i < locations.length; i += maxConcurrency) {
      final batch = locations.skip(i).take(maxConcurrency).toList();
      
      final futures = batch.map((location) async {
        try {
          final data = await getWeatherData(location);
          return MapEntry(location, data);
        } catch (e) {
          CPLog.e('WeatherRepository: 批量获取失败 - $location: $e');
          return null;
        }
      });
      
      final batchResults = await Future.wait(futures);
      
      for (final result in batchResults) {
        if (result != null) {
          results[result.key] = result.value;
        }
      }
    }
    
    return results;
  }

  /// 预加载指定位置的天气数据
  /// 在后台静默获取数据并缓存，提高用户体验
  Future<void> preloadWeatherData(List<String> locations) async {
    try {
      CPLog.d('WeatherRepository: 开始预加载天气数据');
      await getBatchWeatherData(locations, maxConcurrency: 2);
      CPLog.d('WeatherRepository: 预加载完成');
    } catch (e) {
      CPLog.e('WeatherRepository: 预加载失败 - $e');
    }
  }

  /// 清理过期缓存
  Future<void> cleanExpiredCache() async {
    try {
      // 清理内存缓存
      final now = DateTime.now();
      _memoryCache.removeWhere((key, value) => 
          now.difference(value.timestamp) > _cacheExpiry);
      
      // 清理本地存储缓存
      await _cleanExpiredLocalCache();
      
      CPLog.d('WeatherRepository: 缓存清理完成');
    } catch (e) {
      CPLog.e('WeatherRepository: 缓存清理失败 - $e');
    }
  }

  /// 从内存缓存获取数据
  QweatherNowResponse? _getFromMemoryCache(String locationStr) {
    final cached = _memoryCache[locationStr];
    if (cached == null) return null;
    
    final now = DateTime.now();
    if (now.difference(cached.timestamp) > _cacheExpiry) {
      _memoryCache.remove(locationStr);
      return null;
    }
    
    return cached.data;
  }

  /// 保存到内存缓存
  void _saveToMemoryCache(String locationStr, QweatherNowResponse data) {
    _memoryCache[locationStr] = _CachedWeatherData(
      data: data,
      timestamp: DateTime.now(),
    );
  }

  /// 从本地存储获取缓存数据
  Future<QweatherNowResponse?> _getFromLocalCache(
    String locationStr, {
    bool allowExpired = false,
  }) async {
    try {
      final cacheKey = 'weather_cache_$locationStr';
      final cachedJson = await CPSP.instance.getString(cacheKey);
      
      if (cachedJson == null) return null;
      
      final cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cachedData['timestamp'] as String);
      final weatherData = cachedData['data'] as Map<String, dynamic>;
      
      // 检查是否过期
      if (!allowExpired) {
        final now = DateTime.now();
        if (now.difference(timestamp) > _cacheExpiry) {
          return null;
        }
      }
      
      return QweatherNowResponse.fromJson(weatherData);
    } catch (e) {
      CPLog.e('WeatherRepository: 读取本地缓存失败 - $e');
      return null;
    }
  }

  /// 保存到本地存储缓存
  Future<void> _saveToLocalCache(String locationStr, QweatherNowResponse data) async {
    try {
      final cacheKey = 'weather_cache_$locationStr';
      final cacheData = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': data.toJson(),
      };
      
      await CPSP.instance.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      CPLog.e('WeatherRepository: 保存本地缓存失败 - $e');
    }
  }

  /// 清理过期的本地缓存
  Future<void> _cleanExpiredLocalCache() async {
    try {
      final keys = await CPSP.instance.getKeys();
      final weatherCacheKeys = keys.where((key) => key.startsWith('weather_cache_'));
      
      for (final key in weatherCacheKeys) {
        final cachedJson = await CPSP.instance.getString(key);
        if (cachedJson != null) {
          try {
            final cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;
            final timestamp = DateTime.parse(cachedData['timestamp'] as String);
            final now = DateTime.now();
            
            if (now.difference(timestamp) > _cacheExpiry) {
              await CPSP.instance.remove(key);
            }
          } catch (e) {
            // 如果解析失败，直接删除损坏的缓存
            await CPSP.instance.remove(key);
          }
        }
      }
    } catch (e) {
      CPLog.e('WeatherRepository: 清理本地缓存失败 - $e');
    }
  }

  /// 获取缓存统计信息
  Future<WeatherCacheStats> getCacheStats() async {
    final memoryCount = _memoryCache.length;
    
    final keys = await CPSP.instance.getKeys();
    final localCacheCount = keys.where((key) => key.startsWith('weather_cache_')).length;
    
    return WeatherCacheStats(
      memoryCache: memoryCount,
      localCache: localCacheCount,
    );
  }
}

/// 内存缓存数据包装类
class _CachedWeatherData {
  final QweatherNowResponse data;
  final DateTime timestamp;

  const _CachedWeatherData({
    required this.data,
    required this.timestamp,
  });
}

/// 天气缓存统计信息
class WeatherCacheStats {
  final int memoryCache;
  final int localCache;

  const WeatherCacheStats({
    required this.memoryCache,
    required this.localCache,
  });
}

/// 天气仓库异常
class WeatherRepositoryException implements Exception {
  final String message;
  const WeatherRepositoryException(this.message);
  
  @override
  String toString() => 'WeatherRepositoryException: $message';
} 