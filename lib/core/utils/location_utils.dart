import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'log/log_utils.dart';

/// 位置工具类
/// 提供获取设备当前位置的功能
class CPLocation {
  /// 权限请求状态锁，防止并发请求权限
  static Completer<LocationPermission>? _permissionCompleter;
  
  // ==================== 公开API方法 ====================
  
  /// 获取当前位置的详细步骤说明：
  /// 
  /// 📍 第一步：检查位置服务状态
  ///    - 验证设备的位置服务是否已启用
  ///    - 如果未启用，抛出LocationServiceDisabledException异常
  /// 
  /// 🔐 第二步：处理位置权限
  ///    - 检查当前应用的位置权限状态
  ///    - 如果权限被拒绝，尝试请求权限
  ///    - 如果权限被永久拒绝，抛出PermissionDeniedException异常
  ///    - 使用防并发机制，避免同时发起多个权限请求
  /// 
  /// ⚙️ 第三步：配置位置获取参数
  ///    - 根据不同平台(Android/iOS)设置最佳的位置获取配置
  ///    - Android: 使用AndroidSettings，精度高，超时60秒
  ///    - iOS: 使用AppleSettings，精度高，超时30秒
  ///    - 其他平台: 使用通用LocationSettings，超时20秒
  /// 
  /// 📡 第四步：获取当前位置
  ///    - 调用Geolocator.getCurrentPosition()获取实时位置
  ///    - 验证位置数据的有效性(经纬度不能都为0)
  ///    - 如果成功，返回包含经纬度的Position对象
  /// 
  /// 🔄 第五步：异常处理与备选方案
  ///    - 如果获取位置超时或失败，尝试以下备选方案：
  ///      1. 获取最后已知的位置数据
  ///      2. 通过IP地址查询大概位置
  ///    - 如果所有方案都失败，抛出相应异常
  /// 
  /// ⏰ 第六步：全局超时控制
  ///    - 整个流程限制在2分钟内完成
  ///    - 超时后抛出TimeoutException异常
  /// 
  /// 返回值：包含经纬度、精度、时间戳等信息的Position对象
  /// 异常：LocationServiceDisabledException、PermissionDeniedException、TimeoutException等
  static Future<Position> getCurrentPosition() async {
    // 给整个位置获取流程添加全局超时控制
    return await _getCurrentPositionWithTimeout().timeout(
      const Duration(minutes: 2), // 全局超时2分钟
      onTimeout: () {
        CPLog.d("位置获取全局超时（2分钟）");
        throw TimeoutException('位置获取全局超时', const Duration(minutes: 2));
      },
    );
  }

  /// 获取最后已知位置
  ///
  /// 此方法比getCurrentPosition更快，但可能不准确
  /// 在某些平台上可能返回null
  static Future<Position?> getLastKnownPosition() async {
    try {
      // 添加超时机制，防止无限等待
      return await Geolocator.getLastKnownPosition().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          CPLog.d("获取最后已知位置超时");
          return null;
        },
      );
    } catch (e) {
      CPLog.d("获取最后已知位置失败: ${e.toString()}");
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

    // 使用安全的权限检查和请求机制
    return await _checkAndRequestPermissionSafely();
  }

  /// 检查位置权限状态
  ///
  /// 返回当前的位置权限状态
  static Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  /// 检查位置服务是否启用
  ///
  /// 返回位置服务是否在设备上启用
  static Future<bool> isLocationServiceEnabled() => Geolocator.isLocationServiceEnabled();

  /// 打开应用设置页面
  ///
  /// 引导用户到应用设置页面启用位置权限
  static Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// 打开位置设置页面
  ///
  /// 引导用户到系统位置设置页面启用位置服务
  static Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  // ==================== 核心实现方法 ====================

  /// 内部位置获取方法
  ///
  /// 返回包含经纬度的Position对象
  /// 如果用户拒绝位置权限或位置服务关闭，将抛出异常
  static Future<Position> _getCurrentPositionWithTimeout() async {
    // 第一步：检查位置服务是否可用
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    // 第二步：处理位置权限
    LocationPermission permission = await _checkAndRequestPermissionSafely();

    // 处理权限被永久拒绝的情况
    if (permission == LocationPermission.deniedForever) {
      throw const PermissionDeniedException('位置权限被永久拒绝，请在设置中手动启用位置权限');
    }

    // 如果权限仍然被拒绝
    if (permission == LocationPermission.denied) {
      throw const PermissionDeniedException('位置权限被拒绝');
    }

    // 第三步：配置位置设置
    LocationSettings locationSettings = _getLocationSettings();

    // 第四步：获取当前位置
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      // 验证位置数据的有效性
      if (position.latitude == 0.0 && position.longitude == 0.0) {
        throw const PositionUpdateException('获取到无效的位置数据');
      }
      
      CPLog.d('CPLocation: 获取当前位置: ${position.latitude},${position.longitude}');
      return position;
    } on LocationServiceDisabledException {
      rethrow;
    } on PermissionDeniedException {
      rethrow;
    } on TimeoutException catch (timeoutError) {
      // 第五步：处理超时异常，尝试备选方案
      CPLog.d("获取当前位置超时: ${timeoutError.toString()}，尝试获取备选位置");
      return await _tryFallbackPosition('获取位置信息超时，且无可用的历史位置数据');
    } catch (e) {
      CPLog.d("获取当前位置失败: ${e.toString()}");
      return await _tryFallbackPosition('无法获取位置信息: ${e.toString()}');
    }
  }

  /// 根据不同平台配置位置获取参数
  static LocationSettings _getLocationSettings() {
    if (Platform.isAndroid) {
      // Android平台特定配置
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        forceLocationManager: false, 
        intervalDuration: const Duration(seconds: 10),
        timeLimit: const Duration(seconds: 60),
      );
    } else if (Platform.isIOS) {
      // iOS平台特定配置
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.other,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: true,
        timeLimit: const Duration(seconds: 30),
      );
    } else {
      // 其他平台使用通用配置
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        timeLimit: Duration(seconds: 20),
      );
    }
  }

  // ==================== 权限处理方法 ====================

  /// 安全的权限检查和请求机制，防止并发请求
  ///
  /// 返回最终的权限状态
  static Future<LocationPermission> _checkAndRequestPermissionSafely() async {
    // 检查当前权限状态
    LocationPermission permission = await Geolocator.checkPermission();

    // 如果权限已经获得，直接返回
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      return permission;
    }

    // 如果权限被永久拒绝，直接返回
    if (permission == LocationPermission.deniedForever) {
      return permission;
    }

    // 如果权限被拒绝，需要请求权限
    if (permission == LocationPermission.denied) {
      return await _requestPermissionSafely();
    }

    return permission;
  }

  /// 安全地请求位置权限
  static Future<LocationPermission> _requestPermissionSafely() async {
    // 如果已经有权限请求在进行中，等待该请求完成
    if (_permissionCompleter != null && !_permissionCompleter!.isCompleted) {
      CPLog.d("CPLocation: 等待正在进行的权限请求完成");
      return await _permissionCompleter!.future;
    }

    // 创建新的权限请求
    _permissionCompleter = Completer<LocationPermission>();

    try {
      CPLog.d("CPLocation: 开始请求位置权限");
      LocationPermission permission = await Geolocator.requestPermission();
      CPLog.d("CPLocation: 权限请求结果: $permission");
      
      // 完成权限请求
      if (!_permissionCompleter!.isCompleted) {
        _permissionCompleter!.complete(permission);
      }
      
      return permission;
    } catch (e) {
      CPLog.d("CPLocation: 权限请求失败: ${e.toString()}");
      
      // 处理特定的权限请求错误
      Exception error;
      if (Platform.isIOS && e.toString().contains('PermissionDefinitionsNotFoundException')) {
        error = const PermissionDeniedException('iOS权限配置错误：请在Info.plist中添加NSLocationWhenInUseUsageDescription');
      } else {
        error = PermissionDeniedException('权限请求失败: ${e.toString()}');
      }
      
      if (!_permissionCompleter!.isCompleted) {
        _permissionCompleter!.completeError(error);
      }
      throw error;
    } finally {
      // 清理权限请求状态
      _permissionCompleter = null;
    }
  }

  // ==================== 备选方案方法 ====================

  /// 尝试获取备选位置（最后已知位置 -> IP定位）
  static Future<Position> _tryFallbackPosition(String errorMessage) async {
    // 尝试获取最后已知位置
    try {
      CPLog.d("开始尝试获取最后已知位置作为备选");
      final lastPosition = await getLastKnownPosition();
      if (lastPosition != null) {
        CPLog.d("成功使用最后已知位置作为备选: ${lastPosition.latitude}, ${lastPosition.longitude}");
        return lastPosition;
      } else {
        CPLog.d("最后已知位置为空，无法作为备选");
      }
    } catch (lastPositionError) {
      CPLog.d("获取最后已知位置也失败: ${lastPositionError.toString()}");
    }

    // 尝试通过IP获取位置作为最后的备选方案
    try {
      CPLog.d("开始尝试通过IP获取位置作为最后备选");
      final ipPosition = await getPositionByIp();
      CPLog.d("成功通过IP获取位置作为最后备选: ${ipPosition.latitude}, ${ipPosition.longitude}");
      return ipPosition;
    } catch (ipPositionError) {
      CPLog.d("通过IP获取位置也失败: ${ipPositionError.toString()}");
    }

    // 如果所有方法都失败，抛出异常
    CPLog.d("所有位置获取方法均失败，抛出异常: $errorMessage");
    throw PositionUpdateException(errorMessage);
  }

  /// 通过IP查询经纬度
  /// 使用ip2location.io API获取IP对应的地理位置信息
  /// 返回包含经纬度的Position对象
  /// 如果网络请求失败或解析失败，将抛出异常
  static Future<Position> getPositionByIp() async {
    final dio = Dio();
    
    try {
      CPLog.d("CPLocation: 开始通过IP获取位置信息");
      
      // 首先获取本机公网IP
      String publicIp = await _getPublicIp(dio);
      CPLog.d("CPLocation: 获取到公网IP: $publicIp");
      
      // 调用ip2location.io API获取位置信息
      final response = await dio.get(
        'https://api.ip2location.io/',
        queryParameters: {'ip': publicIp},
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return _parseIpLocationResponse(response.data);
      } else {
        throw PositionUpdateException('IP位置查询请求失败，状态码: ${response.statusCode}');
      }
    } on DioException catch (e) {
      CPLog.d("CPLocation: IP位置查询网络请求失败: ${e.message}");
      throw PositionUpdateException('IP位置查询网络请求失败: ${e.message}');
    } catch (e) {
      CPLog.d("CPLocation: IP位置查询失败: ${e.toString()}");
      rethrow;
    } finally {
      dio.close();
    }
  }

  // ==================== 工具方法 ====================

  /// 获取本机公网IP地址
  /// 使用多个服务提供商确保可靠性
  static Future<String> _getPublicIp(Dio dio) async {
    // 定义多个IP查询服务，提高成功率
    final ipServices = [
      'https://api.ipify.org?format=text',
      'https://checkip.amazonaws.com',
      'https://icanhazip.com',
      'https://ipinfo.io/ip',
    ];
    
    for (String service in ipServices) {
      try {
        CPLog.d("CPLocation: 尝试从 $service 获取IP地址");
        final response = await dio.get(
          service,
          options: Options(
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        
        if (response.statusCode == 200 && response.data != null) {
          String ip = response.data.toString().trim();
          // 简单验证IP格式
          if (RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(ip)) {
            CPLog.d("CPLocation: 成功获取IP地址: $ip");
            return ip;
          }
        }
      } catch (e) {
        CPLog.d("CPLocation: 从 $service 获取IP失败: ${e.toString()}");
        continue; // 尝试下一个服务
      }
    }
    
    throw const PositionUpdateException('无法获取本机公网IP地址');
  }

  /// 解析IP定位响应数据
  static Position _parseIpLocationResponse(Map<String, dynamic> data) {
    CPLog.d("CPLocation: IP位置查询响应: ${data.toString()}");
    
    // 提取经纬度信息
    final latitude = data['latitude'] as double?;
    final longitude = data['longitude'] as double?;
    
    if (latitude != null && longitude != null) {
      CPLog.d("CPLocation: 通过IP获取位置成功: $latitude, $longitude");
      
      // 构造Position对象（使用当前时间戳）
      return Position(
        longitude: longitude,
        latitude: latitude,
        timestamp: DateTime.now(),
        accuracy: 1000.0, // IP定位精度较低，设置为1000米
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    } else {
      throw const PositionUpdateException('IP位置查询返回的经纬度数据无效');
    }
  }
}
