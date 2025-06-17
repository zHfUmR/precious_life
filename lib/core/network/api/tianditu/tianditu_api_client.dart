import 'package:dio/dio.dart';
import 'package:precious_life/config/app_config.dart';
import 'package:precious_life/core/network/api_client.dart';
import 'package:precious_life/core/network/api_exception.dart';
import '../../../utils/cp_log.dart';

/// 天地图API客户端
/// 负责天地图API的请求处理，使用单例模式
class TiandituApiClient {
  /// 单例
  TiandituApiClient._();
  static final TiandituApiClient _instance = TiandituApiClient._();
  static TiandituApiClient get instance => _instance;

  /// API客户端实例
  late final ApiClient _apiClient = ApiClient(
    baseUrl: AppConfig.tiandituBaseUrl,
    headers: {'Content-Type': 'application/json'},
    interceptors: [
      _TiandituApiInterceptor(),
    ],
  );
  Dio get dio => _apiClient.dio;

  /// 处理天地图API响应
  ///
  /// [response] Dio响应对象
  /// [fromJson] 从JSON转换为对象的函数
  /// 返回处理后的对象
  Future<T> handleResponse<T>(Response response, T Function(Map<String, dynamic> json) fromJson) async {
    final respJson = response.data;
    CPLog.d('TiandituApiClient: 处理响应 - status: ${respJson['status']}, msg: ${respJson['msg'] ?? '无'}');

    // 天地图API中，status为0或'0'表示成功，非0表示失败
    final status = respJson['status'];
    final isSuccess = status == 0 || status == '0';

    if (!isSuccess) {
      final errorStatus = respJson['status'];
      final errorMessage = respJson['msg'] ?? '未知错误';
      CPLog.d('TiandituApiClient: API状态码错误 - status: $errorStatus, msg: $errorMessage');

      // 根据天地图官方文档的错误码提供更友好的错误信息
      String friendlyMessage = errorMessage;
      switch (errorStatus.toString()) {
        case '1':
          friendlyMessage = '请求错误';
          break;
        case '404':
          friendlyMessage = '服务出错：$errorMessage';
          break;
        default:
          friendlyMessage = errorMessage;
          break;
      }

      // 转换errorStatus为int类型
      int? errorCode;
      if (errorStatus is int) {
        errorCode = errorStatus;
      } else if (errorStatus is String) {
        errorCode = int.tryParse(errorStatus);
      }

      throw ApiException(errorCode, friendlyMessage);
    }

    CPLog.d('TiandituApiClient: 响应处理成功，开始解析数据');
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
      CPLog.d('TiandituApiClient: 发起请求 - path: $path, params: $queryParameters');
      CPLog.d(
          'TiandituApiClient: API Key: ${AppConfig.tiandituApiKey.isNotEmpty ? '${AppConfig.tiandituApiKey.substring(0, 8)}...' : '空'}');

      final response = await dio.get(
        path,
        queryParameters: queryParameters,
      );

      CPLog.d('TiandituApiClient: 请求成功 - statusCode: ${response.statusCode}');
      CPLog.d('TiandituApiClient: 响应数据: ${response.data}');

      return handleResponse(response, fromJson);
    } catch (e) {
      CPLog.d('TiandituApiClient: 请求失败 - $e');
      CPLog.d('TiandituApiClient: 错误类型 - ${e.runtimeType}');
      
      // 特殊处理403错误，提供更有用的错误信息
      if (e is DioException && e.response?.statusCode == 403) {
        CPLog.d('TiandituApiClient: 403错误详情 - 可能原因:');
        CPLog.d('  1. API Key无效或已过期');
        CPLog.d('  2. API Key权限不足');
        CPLog.d('  3. 请求参数格式错误');
        CPLog.d('  4. 请求频率超限');
        CPLog.d('TiandituApiClient: 请求URL: ${e.requestOptions.uri}');
        CPLog.d('TiandituApiClient: 响应内容: ${e.response?.data}');
      }
      
      throw ApiException.from(e);
    }
  }
}

/// 天地图API拦截器
class _TiandituApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    /// 为每个请求添加必要的参数，如API密钥
    options.queryParameters.addAll({
      'tk': AppConfig.tiandituApiKey,
    });
    super.onRequest(options, handler);
  }
}
