import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:precious_life/app/routes/route_constants.dart';
import 'package:precious_life/core/utils/cp_log.dart';
import 'package:precious_life/features/todo/data/models/weather_card_state.dart';
import 'package:precious_life/features/todo/ui/providers/weather_card_vm.dart';
import 'package:precious_life/shared/widgets/loading_status_widget.dart';
import 'package:precious_life/core/utils/cp_weather.dart';

/// 天气卡片组件
class WeatherCard extends ConsumerStatefulWidget {
  const WeatherCard({super.key});

  @override
  ConsumerState<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends ConsumerState<WeatherCard> {
  late WeatherCardVm _weatherCardVm;

  @override
  void initState() {
    super.initState();
    _weatherCardVm = ref.read(weatherCardVmProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _weatherCardVm.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherCardVmProvider);
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: LoadingStatusWidget(
          status: weatherState.weatherConfigState.loadingStatus,
          onRetry: () => GoRouter.of(context).push(AppRoutes.weatherConfig),
          errorMessage: weatherState.weatherConfigState.errorMessage,
          child: _buildWeatherContent(weatherState),
        ),
      ),
    );
  }

  /// 构建天气内容
  Widget _buildWeatherContent(weatherState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLocationWeather(weatherState),
        const SizedBox(height: 8),
        _buildExpandButton(weatherState),
        if (weatherState.isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildFollowedWeather(weatherState),
          ),
      ],
    );
  }

  /// 构建定位天气部分
  Widget _buildLocationWeather(weatherState) {
    return LoadingStatusWidget(
      status: weatherState.weatherLocationState.loadingStatus,
      loadingMessage: '获取定位 & 查询天气中...',
      onRetry: () => _weatherCardVm.loadLocationWeather(),
      errorMessage: weatherState.weatherLocationState.errorMessage,
      child: GestureDetector(
        onTap: () => {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLocationRow(weatherState),
            const SizedBox(height: 8),
            _buildWeatherInfoRow(weatherState),
          ],
        ),
      ),
    );
  }

  /// 构建定位信息行
  Widget _buildLocationRow(weatherState) {
    final locationState = weatherState.weatherLocationState;
    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: Theme.of(context).colorScheme.primary,
          size: 16,
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Text(
            locationState.currentAddress ?? '获取位置中...',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  /// 构建天气信息行
  Widget _buildWeatherInfoRow(weatherState) {
    final locationState = weatherState.weatherLocationState;
    final weather = locationState.currentWeather;
    final minutelyRain = locationState.currentMinutelyRain;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 温度
        Text(
          '${weather?.temp ?? '--'}°',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(width: 4),
        // 天气图标和状况
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CPWeather.getWeatherIcon(weather?.icon, 16),
            Text(
              weather?.text ?? '未知',
              style: Theme.of(context).textTheme.labelSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(width: 8),
        // 降雨信息
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.water_drop,
                color: Theme.of(context).colorScheme.primary,
                size: 14,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  minutelyRain?.summary ?? '无降雨',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
        // 刷新按钮
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => _weatherCardVm.loadLocationWeather(),
                icon: const Icon(Icons.refresh),
                iconSize: 18,
                padding: EdgeInsets.zero,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            // 时间文本
            Text(
              _getUpdateTime(weather?.obsTime),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建展开/收起按钮
  Widget _buildExpandButton(weatherState) => Center(
        child: InkWell(
          onTap: () => _weatherCardVm.toggleExpandedState(),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedRotation(
                  turns: weatherState.isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down, size: 20),
                ),
              ],
            ),
          ),
        ),
      );

  /// 构建关注城市内容
  Widget _buildFollowedWeather(weatherState) {
    return LoadingStatusWidget(
      status: weatherState.weatherFollowedState.loadingStatus,
      loadingMessage: '获取关注城市天气中...',
      onRetry: () => _weatherCardVm.loadFollowedWeather(),
      errorMessage: weatherState.weatherFollowedState.errorMessage,
      child: _buildFollowedWeatherContent(weatherState),
    );
  }

  /// 构建关注城市天气内容
  Widget _buildFollowedWeatherContent(weatherState) {
    final points = weatherState.weatherFollowedState.followedWeather ?? [];
    // 检查是否有关注点数据
    if (points.isEmpty) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => GoRouter.of(context).push(AppRoutes.weatherFollowedSettings),
        child: Container(
          padding: const EdgeInsets.all(2.0),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_city,
                size: 32,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                '暂无关注城市，请点击添加',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: points.length,
      itemBuilder: (context, index) {
        final pointWeather = points[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: (200 + index * 50).toInt()),
          curve: Curves.easeOutBack,
          transform: Matrix4.translationValues(
            weatherState.isExpanded ? 0 : -20,
            0,
            0,
          ),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: (150 + index * 50).toInt()),
            opacity: weatherState.isExpanded ? 1.0 : 0.0,
            child: Padding(
              padding: index > 0 ? const EdgeInsets.only(top: 8.0) : EdgeInsets.zero,
              child: GestureDetector(
                // 点击跳转到天气详情页，传递城市代码而不是索引
                onTap: () {
                  CPLog.d("跳转天气详情，点击项信息：${pointWeather.point.toJson()}");
                },
                // 长按跳转到城市设置页
                onLongPress: () => GoRouter.of(context).push(AppRoutes.weatherFollowedSettings),
                child: _buildFollowedWeatherItem(pointWeather),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建关注城市天气卡片
  Widget _buildFollowedWeatherItem(WeatherCardFollowedWeather pointWeather) {
    final point = pointWeather.point;
    final weather = pointWeather.weather;
    final errorMessage = pointWeather.errorMessage;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.15),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3), 
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: LoadingStatusWidget(
          status: pointWeather.loadingStatus,
          loadingMessage: '获取天气中...',
          onRetry: () => {},
          errorMessage: errorMessage,
          isVertical: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 位置信息
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.place,
                      color: Theme.of(context).colorScheme.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            // 根据poiName是否为空决定显示内容
                            (point.poiName == null || point.poiName!.isEmpty) 
                              ? (point.city ?? '未知城市')
                              : point.poiName!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            // 根据poiName是否为空决定显示内容
                            (point.poiName == null || point.poiName!.isEmpty)
                              ? (point.district ?? '未知区县')
                              : (point.poiAddress ?? '未知地址'),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 温度
              Text(
                '${weather?.temp ?? '--'}°',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              // 天气图标和状况
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CPWeather.getWeatherIcon(weather?.icon, 14),
                  Text(
                    weather?.text ?? '未知',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // 刷新按钮和更新时间
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () async => await _weatherCardVm.getFollowedWeather(point),
                      icon: const Icon(Icons.refresh),
                      iconSize: 14,
                      padding: EdgeInsets.zero,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    _getUpdateTime(weather?.obsTime),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取更新时间字符串
  String _getUpdateTime(String? obsTime) {
    if (obsTime == null) return '未知';
    try {
      final dateTime = DateTime.parse(obsTime);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}分钟前';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}小时前';
      } else {
        return '${difference.inDays}天前';
      }
    } catch (e) {
      return '未知';
    }
  }
}
