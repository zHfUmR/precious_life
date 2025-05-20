import 'api_service_type.dart';
import 'api_client.dart';
import 'interceptors.dart';
import 'package:dio/dio.dart';

/// 统一管理不同API服务的ApiClient
class NetworkManager {
  static final Map<ApiServiceType, ApiClient> _clientMap = {};

  /// 是否在所有API中启用日志
  static bool enableLog = true;

  /// 获取Token函数
  static String Function() tokenGetter = () => '';

  /// 获取指定类型的ApiClient实例
  static ApiClient getClient(ApiServiceType type) {
    if (!_clientMap.containsKey(type)) {
      _clientMap[type] = _createClient(type);
    }
    return _clientMap[type]!;
  }

  /// 根据API类型创建对应的ApiClient
  static ApiClient _createClient(ApiServiceType type) {
    // 通用拦截器列表
    final List<Interceptor> interceptors = [];

    // 添加通用拦截器
    if (enableLog) {
      interceptors.add(InterceptorFactory.createLogInterceptor());
    }

    // 添加错误拦截器
    interceptors.add(InterceptorFactory.createErrorInterceptor());

    switch (type) {
      case ApiServiceType.main:
        return ApiClient(
          baseUrl: 'https://api.main.com',
          headers: {'Content-Type': 'application/json'},
          requestTransformer: (data) => data,
          responseTransformer: (data) => data,
          interceptors: [
            ...interceptors,
            // 添加鉴权拦截器
            InterceptorFactory.createAuthInterceptor(tokenGetter),
          ],
        );
      case ApiServiceType.qweather:
        return ApiClient(
          baseUrl: 'https://m4359dtk6r.re.qweatherapi.com',
          headers: {'Content-Type': 'application/json', 'X-QW-Api-Key': ''},
          requestTransformer: (data) => data,
          responseTransformer: (data) => data,
          interceptors: [
            LogInterceptor(
              requestBody: true,
              responseBody: true,
            ),
          ], // 不需要鉴权
        );
      case ApiServiceType.auth:
        return ApiClient(
          baseUrl: 'https://api.auth.com',
          headers: {'Content-Type': 'application/json'},
          interceptors: interceptors, // 认证服务一般不需要鉴权拦截器
          // 认证服务可能需要更短的超时时间
          connectTimeout: 10000,
        );
    }
  }

  /// 设置Token获取函数
  static void setTokenGetter(String Function() getter) {
    tokenGetter = getter;
  }

  /// 清除ApiClient缓存
  static void clearClients() {
    _clientMap.clear();
  }
}
