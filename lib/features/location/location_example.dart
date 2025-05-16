import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/utils/location_utils.dart';

/// 主函数，仅当直接运行此文件时使用
/// 
/// 使用方式：flutter run -t lib/features/location/location_example.dart
void main() {
  runApp(const MaterialApp(
    title: '位置服务测试',
    debugShowCheckedModeBanner: false,
    home: LocationExamplePage(),
  ));
}

/// 位置服务示例页面
class LocationExamplePage extends StatefulWidget {
  const LocationExamplePage({super.key});

  @override
  State<LocationExamplePage> createState() => _LocationExamplePageState();
}

class _LocationExamplePageState extends State<LocationExamplePage> {
  String _locationMessage = "获取位置中...";
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _currentPosition;
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  
  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  /// 获取当前位置
  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationUtils.getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _locationMessage = "当前位置: ${position.latitude}, ${position.longitude}";
      });
    } catch (e) {
      setState(() {
        _locationMessage = "获取位置失败: $e";
      });
    }
  }

  /// 开始监听位置变化
  void _startLocationUpdates() {
    _positionStreamSubscription?.cancel();
    
    _positionStreamSubscription = LocationUtils.getLocationStream(
      distanceFilter: 5, // 5米更新一次
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _locationMessage = "位置更新: ${position.latitude}, ${position.longitude}";
      });
    }, onError: (e) {
      setState(() {
        _locationMessage = "位置监听错误: $e";
      });
    });
  }

  /// 停止监听位置变化
  void _stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    setState(() {
      _locationMessage = _currentPosition != null
          ? "最后位置: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}"
          : "未获取到位置";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('位置服务示例'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _locationMessage,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text('获取当前位置'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _positionStreamSubscription == null
                  ? _startLocationUpdates
                  : null,
              child: const Text('开始位置监听'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _positionStreamSubscription != null
                  ? _stopLocationUpdates
                  : null,
              child: const Text('停止位置监听'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => LocationUtils.openLocationSettings(),
              child: const Text('打开位置设置'),
            ),
            if (_currentPosition != null) ...[
              const SizedBox(height: 20),
              const Text('当前位置详情：', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('纬度: ${_currentPosition!.latitude}'),
              Text('经度: ${_currentPosition!.longitude}'),
              Text('精度: ${_currentPosition!.accuracy} 米'),
              Text('海拔: ${_currentPosition!.altitude} 米'),
              Text('速度: ${_currentPosition!.speed} 米/秒'),
              Text('方向: ${_currentPosition!.heading}°'),
              Text('时间: ${DateTime.fromMillisecondsSinceEpoch(_currentPosition!.timestamp.millisecondsSinceEpoch)}'),
            ],
          ],
        ),
      ),
    );
  }
} 