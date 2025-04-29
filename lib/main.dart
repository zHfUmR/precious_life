import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'config/app_config.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化应用配置
  await AppConfig.initialize();
  
  // 使用ProviderScope包装应用，提供Riverpod状态管理
  runApp(
    const ProviderScope(
      child: PreciousLifeApp(),
    ),
  );
} 