import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/network/network_manager.dart';
import '../core/network/api_service_type.dart';

part 'home_weather_vm.g.dart';

/// 首页天气视图模型
@riverpod
class HomeWeatherVM extends _$HomeWeatherVM {
  /// 构建方法，返回当前天气数据
  @override
  Future<String> build() async {
    // 默认返回北京的天气数据
    return await fetchWeatherData('101010100');
  }

  /// 获取指定位置的天气数据
  Future<String> fetchWeatherData(String location) async {
    try {
      // 获取和风天气API客户端
      final apiClient = NetworkManager.getClient(ApiServiceType.qweather);
      
      // 通过dio发起GET请求获取实时天气
      final response = await apiClient.dio.get('/v7/weather/now', 
        queryParameters: {
          'location': location,
        }
      );
      
      // 返回响应数据的字符串表示
      return response.data.toString();
    } catch (e) {
      // 发生错误时返回错误信息
      return '获取天气数据失败: ${e.toString()} (⋟﹏⋞)';
    }
  }
  
  /// 更新天气数据
  Future<void> refreshWeather(String location) async {
    // 设置为加载状态
    // 使用AsyncValue.guard更新状态
    state = await AsyncValue.guard(() => fetchWeatherData(location));
  }
} 