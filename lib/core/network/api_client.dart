// ignore_for_file: unused_import

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../utils/log/log_utils.dart';
import 'api_exception.dart';

/// API客户端封装了API服务的所有配置
class ApiClient {
  final String baseUrl; // 基础URL
  final Map<String, String> headers; // 请求头
  final List<Interceptor> interceptors; // 拦截器列表
  final int connectTimeout; // 连接超时时间（毫秒）
  final int receiveTimeout; // 接收超时时间（毫秒）
  final int sendTimeout; // 发送超时时间（毫秒）

  ApiClient({
    required this.baseUrl,
    this.headers = const {},
    this.interceptors = const [],
    this.connectTimeout = 15 * Duration.millisecondsPerSecond,
    this.receiveTimeout = 15 * Duration.millisecondsPerSecond,
    this.sendTimeout = 15 * Duration.millisecondsPerSecond,
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
    for (final i in interceptors) {
      dio.interceptors.add(i);
    }
    if (kDebugMode) {
      // 开始时添加日志打印和抓包
      dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        logPrint: (log) {
          CPLog.d('🌐 HTTP: $log');
        },
      ));
      // dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () => localProxyHttpClient());
    }
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

/// 通用请求异常处理拦截器
