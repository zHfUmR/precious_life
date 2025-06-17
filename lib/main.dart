import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/app/app.dart';
import 'core/utils/cp_storage.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  // 设置应用方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // 初始化存储工具类，确保在使用前完成初始化
  await CPSP.instance.init();
  // 运行应用
  runApp(const ProviderScope(child: App()));
}
