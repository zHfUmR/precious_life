import 'package:flutter/material.dart';
import 'location_example.dart';

/// 位置服务测试应用入口点
void main() {
  runApp(const LocationTestApp());
}

/// 位置服务测试应用
class LocationTestApp extends StatelessWidget {
  /// 构造函数
  const LocationTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '位置服务测试',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LocationExamplePage(),
    );
  }
} 