/// 请求抽象基类，所有请求需继承本类
abstract class ApiRequest {
  /// 请求路径
  String get path;
  /// 请求方法（GET/POST等）
  String get method;
  /// 请求参数
  Map<String, dynamic> get params;
} 