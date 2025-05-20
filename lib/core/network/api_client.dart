import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// 请求转换器类型定义
typedef RequestTransformer = dynamic Function(dynamic data);

/// 响应转换器类型定义
typedef ResponseTransformer<T> = T Function(dynamic data);

/// ApiClient 封装了API服务的所有配置
class ApiClient {
  /// 基础URL
  final String baseUrl;
  /// 请求头
  final Map<String, String> headers;
  /// 请求转换器
  final RequestTransformer? requestTransformer;
  /// 响应转换器
  final ResponseTransformer? responseTransformer;
  /// 拦截器列表
  final List<Interceptor> interceptors;
  /// 超时时间（毫秒）
  final int connectTimeout;
  final int receiveTimeout;
  final int sendTimeout;

  ApiClient({
    required this.baseUrl,
    this.headers = const {},
    this.requestTransformer,
    this.responseTransformer,
    this.interceptors = const [],
    this.connectTimeout = 15000,
    this.receiveTimeout = 15000,
    this.sendTimeout = 15000,
  });

  /// 获取配置好的Dio实例
  Dio get dio {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: headers,
      connectTimeout: Duration(milliseconds: connectTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      sendTimeout: Duration(milliseconds: sendTimeout),
    ));
    
    // 添加拦截器
    for (final i in interceptors) {
      dio.interceptors.add(i);
    }
    dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () => localProxyHttpClient());
    return dio;
  }
} 


/// 本地代理抓包拦截器
HttpClient localProxyHttpClient() {
  return HttpClient()
  // 将请求代理到 本机IP:8888，是抓包电脑的IP！！！不要直接用localhost，会报错:
  // SocketException: Connection refused (OS Error: Connection refused, errno = 111), address = localhost, port = 47972
    ..findProxy = (uri) {
      return 'PROXY 192.168.102.108:8888';
    }
  // 抓包工具一般会提供一个自签名的证书，会通不过证书校验，这里需要禁用下，直接返回true
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
}
