import 'dart:io';

import 'package:dio/dio.dart';

/// 拦截器工厂，提供各种常用拦截器实例
class InterceptorFactory {
  /// 创建日志拦截器
  static LogInterceptor createLogInterceptor({
    bool requestBody = true,
    bool responseBody = true,
  }) {
    return LogInterceptor(
        requestHeader: true,
        requestBody: requestBody,
        responseHeader: true,
        responseBody: responseBody,
        logPrint: (log) {
          // 可以替换成自己的日志打印方式
          print('🌐 HTTP: $log');
        });
  }

  /// 创建鉴权拦截器
  static AuthInterceptor createAuthInterceptor(
    String Function() tokenGetter,
  ) {
    return AuthInterceptor(tokenGetter);
  }

  /// 创建错误处理拦截器
  static ErrorInterceptor createErrorInterceptor() {
    return ErrorInterceptor();
  }

}

/// 鉴权拦截器，为请求自动添加Token等认证信息
class AuthInterceptor extends Interceptor {
  final String Function() _getToken;

  AuthInterceptor(this._getToken);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 获取token
    final token = _getToken();
    if (token.isNotEmpty) {
      // 添加Authorization头
      options.headers['Authorization'] = 'Bearer $token';
    }
    return super.onRequest(options, handler);
  }
}

/// 错误处理拦截器，统一处理错误响应
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 统一处理错误
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        err = _handleTimeoutError(err);
        break;
      case DioExceptionType.badResponse:
        err = _handleResponseError(err);
        break;
      default:
        err = _handleDefaultError(err);
    }

    // 继续传递错误
    return super.onError(err, handler);
  }

  /// 处理超时错误
  DioException _handleTimeoutError(DioException err) {
    // 可以自定义错误信息
    return err.copyWith(
      error: '网络连接超时，请检查网络设置',
    );
  }

  /// 处理服务器响应错误
  DioException _handleResponseError(DioException err) {
    final statusCode = err.response?.statusCode;

    if (statusCode == 401) {
      // 处理未授权错误
      // 例如: 可以触发重新登录
      return err.copyWith(
        error: '登录信息已过期，请重新登录',
      );
    } else if (statusCode == 403) {
      return err.copyWith(
        error: '没有权限访问该资源',
      );
    } else if (statusCode == 404) {
      return err.copyWith(
        error: '请求的资源不存在',
      );
    } else if (statusCode! >= 500) {
      return err.copyWith(
        error: '服务器错误，请稍后再试',
      );
    }

    return err;
  }

  /// 处理默认错误
  DioException _handleDefaultError(DioException err) {
    return err.copyWith(
      error: '发生未知错误，请稍后再试',
    );
  }
}

