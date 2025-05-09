
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/app/routes/route_constants.dart';
import 'package:precious_life/features/home/ui/pages/home_page.dart';


/// 路由配置提供者
/// 使用 Riverpod Provider包装GoRouter实例，便于依赖注入和全局访问
/// 支持动态路由配置，根据应用状态可进行路由重定向和拦截
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
});

