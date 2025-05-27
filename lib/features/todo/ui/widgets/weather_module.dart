import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:precious_life/app/routes/route_constants.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/core/utils/weather_utils.dart';
import 'package:precious_life/features/todo/data/models/home_weather_state.dart';
import 'package:precious_life/features/todo/ui/providers/home_weather_vm.dart';
import 'package:precious_life/shared/widgets/loading_status_widget.dart';
import 'dart:async';

/// 天气模块组件
class WeatherModule extends ConsumerStatefulWidget {
  const WeatherModule({super.key});

  @override
  ConsumerState<WeatherModule> createState() => _WeatherModuleState();
}

/// 天气模块状态类
class _WeatherModuleState extends ConsumerState<WeatherModule> {
  bool _isApiKeyConfigured = false;
  bool _isCheckingApiKey = true;
  bool _hasInitialized = false; // 添加初始化标记

  @override
  void initState() {
    super.initState();
    debugPrint('WeatherModule: initState() 开始初始化');
    
    // 使用addPostFrameCallback确保在widget构建完成后再进行检查
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      debugPrint('WeatherModule: PostFrameCallback 触发，开始检查API Key');
      _checkApiKeyAndInitialize();
    });
  }

  /// 检查API Key配置并初始化天气数据
  Future<void> _checkApiKeyAndInitialize() async {
    try {
      setState(() {
        _isCheckingApiKey = true;
      });
      
      debugPrint('WeatherModule: 开始检查API Key配置...');
      
      // 检查API Key配置状态
      final isConfigured = await WeatherUtils.isWeatherApiKeyConfigured();
      
      debugPrint('WeatherModule: API Key配置检查结果: $isConfigured');
      
      if (mounted) {
        setState(() {
          _isApiKeyConfigured = isConfigured;
          _isCheckingApiKey = false;
          _hasInitialized = true;
        });
        
        // 如果API Key已配置，则加载天气数据
        if (isConfigured) {
          debugPrint('WeatherModule: API Key已配置，开始加载天气数据');
          
          // 先强制初始化Provider状态
          final currentState = ref.read(homeWeatherVmProvider);
          debugPrint('WeatherModule: 当前Provider状态 - ${currentState.currentLoadingStatus}');
          
          // 确保在下一帧执行，避免状态更新冲突
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              debugPrint('WeatherModule: PostFrameCallback - 开始刷新天气数据');
              // 直接使用ref.read获取最新的notifier实例
              final notifier = ref.read(homeWeatherVmProvider.notifier);
              debugPrint('WeatherModule: 获取到notifier实例');
              
              notifier.refreshCurrentWeather();
              notifier.refreshCityWeather();
              
              // 强制触发一次UI更新
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  debugPrint('WeatherModule: 强制触发UI更新');
                  _forceRefresh();
                }
              });
            }
          });
        } else {
          debugPrint('WeatherModule: API Key未配置，显示配置提示');
        }
      }
    } catch (e) {
      debugPrint('WeatherModule: 检查API Key配置失败: $e');
      if (mounted) {
        setState(() {
          _isApiKeyConfigured = false;
          _isCheckingApiKey = false;
          _hasInitialized = true;
        });
      }
    }
  }

  /// 重置状态并重新检查（用于配置完成后的刷新）
  Future<void> _resetAndRecheck() async {
    debugPrint('WeatherModule: 重置状态并重新检查API Key');
    
    if (mounted) {
      setState(() {
        _hasInitialized = false;
        _isCheckingApiKey = false; // 先设为false，避免防重复逻辑干扰
        _isApiKeyConfigured = false;
      });
      
      // 等待一帧，确保状态更新完成
      await Future.delayed(const Duration(milliseconds: 50));
      
      if (mounted) {
        await _checkApiKeyAndInitialize();
      }
    }
  }

  /// 强制刷新状态（调试用）
  void _forceRefresh() {
    debugPrint('WeatherModule: 强制刷新状态');
    if (mounted) {
      setState(() {
        // 强制触发重建
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('WeatherModule: build() - _isCheckingApiKey: $_isCheckingApiKey, _isApiKeyConfigured: $_isApiKeyConfigured, _hasInitialized: $_hasInitialized');
    
    // 如果正在检查API Key配置，显示加载状态
    if (_isCheckingApiKey) {
      debugPrint('WeatherModule: 显示加载状态');
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    // 如果API Key未配置，显示配置提示
    if (!_isApiKeyConfigured) {
      debugPrint('WeatherModule: 显示API Key配置提示');
      return _buildApiKeyConfigPrompt();
    }
    
    // API Key已配置，显示天气数据
    debugPrint('WeatherModule: 显示天气数据界面');
    final homeWeatherState = ref.watch(homeWeatherVmProvider);
    
    // 添加详细的状态调试信息
    debugPrint('WeatherModule: homeWeatherState.currentLoadingStatus = ${homeWeatherState.currentLoadingStatus}');
    debugPrint('WeatherModule: homeWeatherState.currentCity = ${homeWeatherState.currentCity}');
    debugPrint('WeatherModule: homeWeatherState.currentWeather?.temp = ${homeWeatherState.currentWeather?.temp}');
    debugPrint('WeatherModule: homeWeatherState.currentErrorMessage = ${homeWeatherState.currentErrorMessage}');
    debugPrint('WeatherModule: homeWeatherState.cityLoadingStatus = ${homeWeatherState.cityLoadingStatus}');
    debugPrint('WeatherModule: homeWeatherState.followedCitiesWeather?.length = ${homeWeatherState.followedCitiesWeather?.length}');
    
    return Column(
      children: [
        // 添加一个测试按钮
        if (homeWeatherState.currentLoadingStatus == LoadingStatus.initial)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                debugPrint('WeatherModule: 手动触发数据加载');
                ref.read(homeWeatherVmProvider.notifier).refreshCurrentWeather();
              },
              child: const Text('手动加载天气数据'),
            ),
          ),
        Expanded(
          flex: 2,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push(AppRoutes.weatherDetail),
            onLongPress: () async {
              final result = await context.push<bool>(AppRoutes.weatherConfig);
              // 如果配置成功，重新检查API Key并刷新天气数据
              if (result == true) {
                _resetAndRecheck();
              }
            },
            child: LoadingStatusWidget(
              status: homeWeatherState.currentLoadingStatus,
              onRetry: () => ref.read(homeWeatherVmProvider.notifier).refreshCurrentWeather(),
              errorMessage: homeWeatherState.currentErrorMessage,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '更新于：${homeWeatherState.updateTime}',
                          style: CPTextStyles.s8.c(CPColors.lightGrey),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, size: 12, color: CPColors.black),
                            Flexible(
                              child: Text(
                                homeWeatherState.currentCity ?? '--',
                                style: CPTextStyles.s12.bold.c(CPColors.black),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(homeWeatherState.currentMinutelyRain?.summary ?? '--',
                              style: CPTextStyles.s8.c(CPColors.laMuPink), textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                  Text(homeWeatherState.currentWeather?.temp ?? '--', style: CPTextStyles.s40.bold.c(CPColors.black)),
                  Column(
                    children: [
                      Text('°C', style: CPTextStyles.s16.c(CPColors.black)),
                      homeWeatherState.weatherText,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // 关注城市群天气
        Expanded(
          flex: 3,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push(AppRoutes.weatherDetail),
            onLongPress: () async {
              final result = await context.push<bool>(AppRoutes.weatherCitySettings);
              // 只有在数据发生变化时才刷新关注城市天气数据
              if (result == true) {
                debugPrint('WeatherModule: 城市设置有变化，刷新关注城市天气');
                ref.read(homeWeatherVmProvider.notifier).refreshCityWeather();
              }
            },
            child: LoadingStatusWidget(
              status: homeWeatherState.cityLoadingStatus,
              onRetry: () => ref.read(homeWeatherVmProvider.notifier).refreshCityWeather(),
              errorMessage: homeWeatherState.cityErrorMessage,
              child: _buildFollowedCitiesWeather(homeWeatherState),
            ),
          ),
        )
      ],
    );
  }

  /// 构建API Key配置提示组件
  Widget _buildApiKeyConfigPrompt() {
    debugPrint('WeatherModule: 构建API Key配置提示组件');
    return GestureDetector(
      onTap: () async {
        debugPrint('WeatherModule: 用户点击配置提示，跳转到配置页面');
        // 跳转到天气配置页面
        final result = await context.push<bool>(AppRoutes.weatherConfig);
        debugPrint('WeatherModule: 配置页面返回结果: $result');
        // 如果配置成功，重新检查API Key
        if (result == true) {
          debugPrint('WeatherModule: 配置成功，开始重新检查');
          _resetAndRecheck();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: CPColors.lightGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CPColors.lightGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.settings,
              size: 48,
              color: CPColors.lightGrey,
            ),
            const SizedBox(height: 16),
            Text(
              '天气功能需要配置',
              style: CPTextStyles.s16.bold.c(CPColors.black),
            ),
            const SizedBox(height: 8),
            Text(
              '请配置和风天气API Key',
              style: CPTextStyles.s12.c(CPColors.lightGrey),
            ),
            const SizedBox(height: 4),
            Text(
              '点击进入设置',
              style: CPTextStyles.s10.c(CPColors.lightGrey),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建关注城市天气列表
  Widget _buildFollowedCitiesWeather(HomeWeatherState homeWeatherState) {
    final followedCitiesWeather = homeWeatherState.followedCitiesWeather;

    // 如果没有关注城市数据，显示提示
    if (followedCitiesWeather == null || followedCitiesWeather.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 32, color: CPColors.lightGrey),
            const SizedBox(height: 8),
            Text('暂无关注的城市', style: CPTextStyles.s12.c(CPColors.lightGrey)),
            const SizedBox(height: 4),
            Text('长按进入设置', style: CPTextStyles.s10.c(CPColors.lightGrey)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: followedCitiesWeather.map((cityWeather) {
          return _buildCityWeatherRow(cityWeather);
        }).toList(),
      ),
    );
  }

  /// 构建单个城市天气行
  Widget _buildCityWeatherRow(FollowedCityWeather cityWeather) {
    final city = cityWeather.city;
    final weather = cityWeather.weather;
    final errorMessage = cityWeather.errorMessage;

    // 如果有错误信息，显示错误状态
    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                city.simpleDisplayName,
                style: CPTextStyles.s12.bold.c(CPColors.lightGrey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.error_outline, size: 16, color: Colors.red),
            Text('--°C', style: CPTextStyles.s12.bold.c(CPColors.lightGrey)),
            const SizedBox(width: 10),
          ],
        ),
      );
    }

    // 显示正常天气数据
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              city.simpleDisplayName,
              style: CPTextStyles.s12.bold.c(CPColors.lightGrey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          WeatherUtils.getWeatherIcon(weather?.icon, 16),
          Text(
            '${weather?.temp ?? '--'}°C',
            style: CPTextStyles.s12.bold.c(CPColors.lightGrey),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
