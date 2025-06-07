import 'package:dio/dio.dart';
import '../../../utils/log/log_utils.dart';
import '../../api_client.dart';
import 'package:precious_life/config/app_config.dart';
import 'package:precious_life/core/network/api_exception.dart';

/// 和风天气API客户端
/// 负责和风天气API的请求处理，使用单例模式
class QweatherApiClient {
  /// 单例
  QweatherApiClient._();
  static final QweatherApiClient _instance = QweatherApiClient._();
  static QweatherApiClient get instance => _instance;

  /// API客户端实例
  late final ApiClient _apiClient = ApiClient(
    baseUrl: AppConfig.qweatherBaseUrl,
    headers: {'Content-Type': 'application/json'},
    interceptors: [
      _QweatherApiInterceptor(),
    ],
  );
  Dio get dio => _apiClient.dio;

  /// 处理和风天气API响应
  ///
  /// [response] Dio响应对象
  /// [fromJson] 从JSON转换为对象的函数
  /// 返回处理后的对象
  Future<T> handleResponse<T>(Response response, T Function(Map<String, dynamic> json) fromJson) async {
    final respJson = response.data;
    CPLog.d('QweatherApiClient: 处理响应 - code: ${respJson['code']}, message: ${respJson['message'] ?? '无'}');

    if (respJson['error'] != null) {
      CPLog.d('QweatherApiClient: API返回错误 - ${respJson['error']}');
      throw ApiException(respJson['error']['status'], respJson['error']['detail']);
    }

    if (respJson['code'] != '200') {
      final errorCode = respJson['code'];
      final errorMessage = respJson['message'] ?? '未知错误';
      CPLog.d('QweatherApiClient: API状态码错误 - code: $errorCode, message: $errorMessage');

      // 根据和风天气的错误码提供更友好的错误信息
      String friendlyMessage = errorMessage;
      switch (errorCode) {
        case '401':
          friendlyMessage = 'API Key无效或已过期';
          break;
        case '402':
          friendlyMessage = 'API Key超过调用次数限制';
          break;
        case '403':
          friendlyMessage = 'API Key没有权限访问该接口';
          break;
        case '404':
          friendlyMessage = '请求的资源不存在';
          break;
        case '429':
          friendlyMessage = '请求过于频繁，请稍后再试';
          break;
        case '500':
          friendlyMessage = '和风天气服务器内部错误';
          break;
      }

      throw ApiException(errorCode, friendlyMessage);
    }

    CPLog.d('QweatherApiClient: 响应处理成功，开始解析数据');
    return fromJson(respJson);
  }

  /// 执行API请求并处理响应
  ///
  /// [path] API请求路径
  /// [queryParameters] 查询参数
  /// [fromJson] 从JSON转换为对象的函数
  /// 返回处理后的对象
  Future<T> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    try {
      CPLog.d('QweatherApiClient: 发起请求 - path: $path, params: $queryParameters');
      CPLog.d(
          'QweatherApiClient: API Key: ${AppConfig.qweatherApiKey.isNotEmpty ? '${AppConfig.qweatherApiKey.substring(0, 8)}...' : '空'}');

      final response = await dio.get(
        path,
        queryParameters: queryParameters,
      );

      CPLog.d('QweatherApiClient: 请求成功 - statusCode: ${response.statusCode}');
      CPLog.d('QweatherApiClient: 响应数据: ${response.data}');

      return handleResponse(response, fromJson);
    } catch (e) {
      CPLog.d('QweatherApiClient: 请求失败 - $e');
      CPLog.d('QweatherApiClient: 错误类型 - ${e.runtimeType}');
      throw ApiException.from(e);
    }
  }
}

/// 和风天气API拦截器
class _QweatherApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    /// 为每个请求添加必要的参数，如API密钥
    options.headers.addAll({
      'X-QW-Api-Key': AppConfig.qweatherApiKey,
    });
    super.onRequest(options, handler);
  }
}
