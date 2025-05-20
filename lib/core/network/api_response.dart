/// 响应抽象基类，所有响应需继承本类
abstract class ApiResponse {
  /// 通过json构造响应对象
  ApiResponse.fromJson(Map<String, dynamic> json);
} 