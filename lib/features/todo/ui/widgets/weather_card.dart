import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/shared/widgets/theme_switch_button.dart';
import 'package:precious_life/features/todo/ui/providers/weather_card_vm.dart';
import 'package:precious_life/shared/widgets/loading_status_widget.dart';
import 'package:precious_life/core/utils/weather_utils.dart';

/// 天气卡片组件
class WeatherCard extends ConsumerStatefulWidget {
  const WeatherCard({super.key});

  @override
  ConsumerState<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends ConsumerState<WeatherCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // 页面初始化时加载天气数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherCardVmProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherCardVmProvider);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 定位信息行
            _buildLocationRow(weatherState),
            const SizedBox(height: 8),

            // 天气信息行
            _buildWeatherInfoRow(weatherState),
            const SizedBox(height: 8),

            // 展开/收起按钮
            _buildExpandButton(),

            // 展开的关注城市列表
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildFollowedCitiesList(weatherState),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建定位信息行
  Widget _buildLocationRow(weatherState) {
    final locationState = weatherState.weatherLocationState;
    String cityName = '获取位置中...';
    Color iconColor = Colors.grey;

    // 根据加载状态显示不同的城市信息
    switch (locationState.loadingStatus) {
      case LoadingStatus.success:
        cityName = locationState.currentCity ?? '未知位置';
        iconColor = Colors.blue;
        break;
      case LoadingStatus.failure:
        cityName = locationState.errorMessage ?? '位置获取失败';
        iconColor = Colors.red;
        break;
      case LoadingStatus.loading:
        cityName = '正在获取位置...';
        iconColor = Colors.orange;
        break;
      default:
        break;
    }

    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: iconColor,
          size: 18,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            cityName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  /// 构建天气信息行
  Widget _buildWeatherInfoRow(weatherState) {
    final locationState = weatherState.weatherLocationState;
    final configState = weatherState.weatherConfigState;

    // 检查配置状态
    if (configState.loadingStatus == LoadingStatus.failure) {
      return _buildErrorWeatherInfo(configState.errorMessage ?? 'API配置错误');
    }

    // 检查位置状态
    if (locationState.loadingStatus == LoadingStatus.loading) {
      return _buildLoadingWeatherInfo();
    }

    if (locationState.loadingStatus == LoadingStatus.failure) {
      return _buildErrorWeatherInfo(locationState.errorMessage ?? '天气数据获取失败');
    }

    // 显示天气数据
    final weather = locationState.currentWeather;
    final minutelyRain = locationState.currentMinutelyRain;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 温度
        Text(
          '${weather?.temp ?? '--'}°',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
        ),
        const SizedBox(width: 8),

        // 天气图标和状况
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WeatherUtils.getWeatherIcon(weather?.icon, 22),
            const SizedBox(height: 2),
            Text(
              weather?.text ?? '未知',
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(width: 8),

        // 降雨信息
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.water_drop,
                color: Colors.blue,
                size: 14,
              ),
              const SizedBox(width: 2),
              Text(
                _getRainProbability(minutelyRain),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),

        // 按钮组和时间
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 告警按钮和刷新按钮在同一行
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 告警按钮
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => _showWeatherWarning(),
                    icon: const Icon(Icons.warning_amber),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 6),

                // 刷新按钮
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => _refreshWeather(),
                    icon: const Icon(Icons.refresh),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 6),

                // 主题切换按钮
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const ThemeSwitchButton(),
                ),
              ],
            ),
            const SizedBox(height: 2),
            // 时间文本
            Text(
              _getUpdateTime(weather?.obsTime),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建加载中的天气信息
  Widget _buildLoadingWeatherInfo() => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 16),
          Text(
            '正在加载天气数据...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );

  /// 构建错误状态的天气信息
  Widget _buildErrorWeatherInfo(String errorMessage) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

  /// 构建展开/收起按钮
  Widget _buildExpandButton() => Center(
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _isExpanded ? '收起' : '关注城市',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );

  /// 构建关注城市列表
  Widget _buildFollowedCitiesList(weatherState) {
    final followedState = weatherState.weatherFollowedState;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '关注城市',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => _refreshFollowedCities(),
                  icon: followedState.loadingStatus == LoadingStatus.loading
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  iconSize: 14,
                  padding: EdgeInsets.zero,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _buildFollowedCitiesContent(followedState),
      ],
    );
  }

  /// 构建关注城市内容
  Widget _buildFollowedCitiesContent(followedState) {
    switch (followedState.loadingStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        );
      case LoadingStatus.failure:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              followedState.errorMessage ?? '加载关注城市失败',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      case LoadingStatus.success:
        final cities = followedState.followedCitiesWeather ?? [];
        if (cities.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('暂无关注城市'),
            ),
          );
        }
        return Column(
          children: cities.asMap().entries.map<Widget>((entry) {
            final index = entry.key;
            final cityWeather = entry.value;
            return AnimatedContainer(
              duration: Duration(milliseconds: (200 + index * 50).toInt()),
              curve: Curves.easeOutBack,
              transform: Matrix4.translationValues(
                _isExpanded ? 0 : -20,
                0,
                0,
              ),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: (150 + index * 50).toInt()),
                opacity: _isExpanded ? 1.0 : 0.0,
                child: _buildCityWeatherCard(cityWeather),
              ),
            );
          }).toList(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 构建单个城市天气卡片
  Widget _buildCityWeatherCard(cityWeather) {
    final city = cityWeather.city;
    final weather = cityWeather.weather;
    final hasError = cityWeather.errorMessage != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: hasError ? Colors.red.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasError ? Colors.red.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 城市名称行
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: hasError ? Colors.red : Colors.grey,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  city.simpleDisplayName,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 天气信息行或错误信息
          if (hasError)
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cityWeather.errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 温度
                Text(
                  '${weather?.temp ?? '--'}°',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                ),
                const SizedBox(width: 8),

                // 天气图标和状况
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WeatherUtils.getWeatherIcon(weather?.icon, 16),
                    const SizedBox(height: 2),
                    Text(
                      weather?.text ?? '未知',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(width: 8),

                // 体感温度信息
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.thermostat,
                        color: Colors.orange,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${weather?.feelsLike ?? '--'}°',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),

                // 按钮组和时间
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 告警按钮和刷新按钮在同一行
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 告警按钮
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => _showCityWeatherWarning(city.simpleDisplayName),
                            icon: const Icon(Icons.warning_amber),
                            iconSize: 14,
                            padding: EdgeInsets.zero,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 6),

                        // 刷新按钮
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => _refreshFollowedCities(),
                            icon: const Icon(Icons.refresh),
                            iconSize: 14,
                            padding: EdgeInsets.zero,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // 时间文本
                    Text(
                      _getUpdateTime(weather?.obsTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 9,
                          ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// 获取降雨概率字符串
  String _getRainProbability(minutelyRain) {
    if (minutelyRain?.summary?.isNotEmpty == true) {
      return minutelyRain!.summary!;
    }
    return '无降雨';
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

  /// 刷新天气数据
  void _refreshWeather() {
    ref.read(weatherCardVmProvider.notifier).weatherLocation();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在更新天气信息...')),
    );
  }

  /// 刷新关注城市数据
  void _refreshFollowedCities() {
    ref.read(weatherCardVmProvider.notifier).refreshCityWeather();
  }

  /// 显示天气告警信息
  void _showWeatherWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('当前无告警信息')),
    );
  }

  /// 显示城市天气告警信息
  void _showCityWeatherWarning(String cityName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$cityName当前无告警信息')),
    );
  }
}
