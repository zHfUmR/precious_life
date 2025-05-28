import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'config/app_config.dart';
import 'core/utils/storage_utils.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  // 设置应用方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // 初始化应用配置
  await AppConfig.initialize();
  // 初始化本地存储
  await StorageUtils.instance.init();
  // 运行应用
  runApp(const ProviderScope(child: App()));
}
