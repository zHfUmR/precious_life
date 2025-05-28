import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:async';

/// 位置工具类
/// 提供获取设备当前位置的功能
class LocationUtils {
  /// 获取当前位置
  /// 
  /// 返回包含经纬度的Position对象
  /// 如果用户拒绝位置权限或位置服务关闭，将抛出异常
  static Future<Position> getCurrentPosition() async {
    // 检查位置服务是否可用
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 位置服务未启用，可以引导用户到设置页面
      throw const LocationServiceDisabledException();
    }

    // 检查当前权限状态
    LocationPermission permission = await Geolocator.checkPermission();
    
    // 处理权限被拒绝的情况
    if (permission == LocationPermission.denied) {
      // 请求权限 - 在iOS上，这会触发系统权限弹窗
      // 但需要确保Info.plist中配置了正确的权限描述
      try {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // 权限仍然被拒绝
          throw const PermissionDeniedException('位置权限被拒绝');
        }
      } catch (e) {
        // iOS平台可能会抛出PermissionDefinitionsNotFoundException
        // 如果Info.plist中缺少必要的权限描述
        if (Platform.isIOS && e.toString().contains('PermissionDefinitionsNotFoundException')) {
          throw const PermissionDeniedException(
            'iOS权限配置错误：请在Info.plist中添加NSLocationWhenInUseUsageDescription'
          );
        }
        // 其他权限请求错误
        throw PermissionDeniedException('权限请求失败: ${e.toString()}');
      }
    }
    
    // 处理权限被永久拒绝的情况
    if (permission == LocationPermission.deniedForever) {
      // 权限被永久拒绝，需要用户手动到设置中开启
      throw const PermissionDeniedException('位置权限被永久拒绝，请在设置中手动启用位置权限');
    }

    // 配置位置设置
    LocationSettings locationSettings;
    
    if (Platform.isAndroid) {
      // Android平台特定配置
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        forceLocationManager: false, // 使用FusedLocationProvider（推荐）
        intervalDuration: const Duration(seconds: 10),
        timeLimit: const Duration(seconds: 30),
      );
    } else if (Platform.isIOS) {
      // iOS平台特定配置
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.other,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: true,
        timeLimit: const Duration(seconds: 30),
      );
    } else {
      // 其他平台使用通用配置
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        timeLimit: Duration(seconds: 20),
      );
    }

    // 获取当前位置
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      
      // 验证位置数据的有效性
      if (position.latitude == 0.0 && position.longitude == 0.0) {
        throw const PositionUpdateException('获取到无效的位置数据');
      }
      
      return position;
    } on LocationServiceDisabledException {
      // 重新抛出位置服务异常
      rethrow;
    } on PermissionDeniedException {
      // 重新抛出权限异常
      rethrow;
    } on TimeoutException {
      // 处理超时异常，尝试获取最后已知位置
      print("获取当前位置超时，尝试获取最后已知位置");
      return await _tryGetLastKnownPositionOrThrow(
        '获取位置信息超时，且无可用的历史位置数据',
        () => TimeoutException('获取位置信息超时，且无可用的历史位置数据', const Duration(seconds: 30))
      );
    } catch (e) {
      print("获取当前位置失败: ${e.toString()}");
      return await _tryGetLastKnownPositionOrThrow(
        '无法获取位置信息: ${e.toString()}',
        () => PositionUpdateException('无法获取位置信息: ${e.toString()}')
      );
    }
  }
  
  /// 获取最后已知位置
  /// 
  /// 此方法比getCurrentPosition更快，但可能不准确
  /// 在某些平台上可能返回null
  static Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print("获取最后已知位置失败: ${e.toString()}");
      return null;
    }
  }
  
  /// 检查并请求位置权限（推荐在应用启动时调用）
  /// 
  /// 返回最终的权限状态
  /// 特别适用于iOS平台的权限预检查
  static Future<LocationPermission> checkAndRequestPermission() async {
    // 先检查位置服务是否启用
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }
    
    // 检查当前权限
    LocationPermission permission = await Geolocator.checkPermission();
    
    // 如果权限被拒绝，尝试请求
    if (permission == LocationPermission.denied) {
      try {
        permission = await Geolocator.requestPermission();
      } catch (e) {
        if (Platform.isIOS && e.toString().contains('PermissionDefinitionsNotFoundException')) {
          throw const PermissionDeniedException(
            'iOS权限配置错误：请在Info.plist中添加必要的位置权限描述'
          );
        }
        throw PermissionDeniedException('权限请求失败: ${e.toString()}');
      }
    }
    
    return permission;
  }
  
  /// 打开应用设置页面
  /// 
  /// 引导用户到应用设置页面启用位置权限
  static Future<bool> openAppSettings() => Geolocator.openAppSettings();
  
  /// 打开位置设置页面
  /// 
  /// 引导用户到系统位置设置页面启用位置服务
  static Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
  
  /// 检查位置权限状态
  /// 
  /// 返回当前的位置权限状态
  static Future<LocationPermission> checkPermission() => Geolocator.checkPermission();
  
  /// 检查位置服务是否启用
  /// 
  /// 返回位置服务是否在设备上启用
  static Future<bool> isLocationServiceEnabled() => Geolocator.isLocationServiceEnabled();
  
  /// 尝试获取最后已知位置，如果失败则抛出指定异常
  /// 
  /// [errorMessage] 错误消息
  /// [exceptionFactory] 异常工厂函数
  static Future<Position> _tryGetLastKnownPositionOrThrow(
    String errorMessage,
    Exception Function() exceptionFactory,
  ) async {
    try {
      final lastPosition = await getLastKnownPosition();
      if (lastPosition != null) {
        print("使用最后已知位置作为备选: ${lastPosition.latitude}, ${lastPosition.longitude}");
        return lastPosition;
      }
    } catch (lastPositionError) {
      print("获取最后已知位置也失败: ${lastPositionError.toString()}");
    }
    
    // 如果所有方法都失败，抛出指定的异常
    throw exceptionFactory();
  }
}
