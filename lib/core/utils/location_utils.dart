import 'package:geolocator/geolocator.dart';

/// 位置服务工具类
class LocationUtils {
  /// 获取当前位置
  /// 
  /// 返回包含经纬度的Position对象
  /// 当位置服务未启用或权限被拒绝时将返回异常
  static Future<Position> getCurrentLocation() async {
    // 检查位置服务是否启用
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('位置服务未启用，请在设备设置中开启');
    }

    // 检查位置权限
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('位置权限被拒绝');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('位置权限被永久拒绝，请在应用设置中手动开启权限');
    }

    // 获取当前位置
    return await Geolocator.getCurrentPosition();
  }

  /// 获取位置更新流
  /// 
  /// [distanceFilter] 距离过滤器，单位为米，当移动超过该距离时才会触发位置更新
  /// [accuracy] 位置精度，默认为高精度
  static Stream<Position> getLocationStream({
    int distanceFilter = 10,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );
    
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// 打开应用设置
  /// 
  /// 用于引导用户手动开启位置权限
  static Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// 打开位置设置
  /// 
  /// 用于引导用户手动开启位置服务
  static Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  /// 计算两点间距离（米）
  /// 
  /// [startLatitude] 起点纬度
  /// [startLongitude] 起点经度
  /// [endLatitude] 终点纬度
  /// [endLongitude] 终点经度
  static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) => Geolocator.distanceBetween(
      startLatitude, 
      startLongitude, 
      endLatitude, 
      endLongitude
    );
} 