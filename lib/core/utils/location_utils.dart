import 'package:geolocator/geolocator.dart';
import 'dart:io';

/// 位置工具类
/// 提供获取设备当前位置的功能
class LocationUtils {
  /// 获取当前位置
  /// 
  /// 返回包含经纬度的Position对象
  /// 如果用户拒绝位置权限或位置服务关闭，将抛出异常
  static Future<Position> getCurrentPosition() async {
    // 在Android平台检查位置服务是否开启
    // iOS平台在权限请求时会自动检查位置服务状态
    if (Platform.isAndroid) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw '位置服务未开启';
      }
    }

    // 检查应用权限
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw '位置权限被拒绝';
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw '位置权限被永久拒绝，请在设置中启用';
    }

    // 配置位置设置，包括高精度和10秒超时
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 5),
    );

    // 获取当前位置
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    } catch (e) {
      print("获取当前位置失败: ${e.toString()}");
      // 如果获取当前位置失败，尝试获取上次已知位置
      final lastPosition = await getLastKnownPosition();
      if (lastPosition != null) {
        return lastPosition;
      }
      // 如果上次位置也获取不到，则抛出异常
      throw '无法获取位置信息: ${e.toString()}';
    }
  }
  
  /// 获取最后已知位置
  /// 
  /// 此方法比getCurrentPosition更快，但可能不准确
  static Future<Position?> getLastKnownPosition() => Geolocator.getLastKnownPosition();
}
