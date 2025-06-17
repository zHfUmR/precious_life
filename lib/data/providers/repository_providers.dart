import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/data/repositories/weather_repository.dart';

/// 全局共享Repository的Riverpod Provider配置
/// 只包含跨模块共享的数据层Provider

/// 天气仓库Provider (全局共享 - todo、home、dashboard都可能用到)
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository();
});

/// 未来的全局Provider
/// 
/// 位置仓库Provider (全局共享 - 多个模块都需要定位)
/// final locationRepositoryProvider = Provider<LocationRepository>((ref) {
///   return LocationRepository();
/// });
/// 
/// 设置仓库Provider (全局共享 - 应用设置)
/// final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
///   return SettingsRepository();
/// });
/// 
/// 数据库Provider (全局共享)
/// final databaseProvider = Provider<AppDatabase>((ref) {
///   return AppDatabase();
/// });

/// 使用示例：
/// 
/// class WeatherCardVm extends ConsumerNotifier<WeatherCardState> {
///   @override
///   WeatherCardState build() => const WeatherCardState.initial();
/// 
///   Future<void> loadWeatherData(String location) async {
///     try {
///       // 使用全局共享的WeatherRepository
///       final repository = ref.read(weatherRepositoryProvider);
///       final weatherData = await repository.getWeatherData(location);
///       state = state.copyWith(weatherData: weatherData);
///     } catch (e) {
///       state = state.copyWith(error: e.toString());
///     }
///   }
/// } 