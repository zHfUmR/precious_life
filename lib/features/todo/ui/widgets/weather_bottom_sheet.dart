import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_service.dart';
import 'package:precious_life/core/utils/city_utils.dart';

/// 天气信息底部弹窗
class WeatherBottomSheet extends ConsumerStatefulWidget {
  /// 城市信息
  final CityInfo cityInfo;

  const WeatherBottomSheet({
    super.key,
    required this.cityInfo,
  });

  @override
  ConsumerState<WeatherBottomSheet> createState() => _WeatherBottomSheetState();
}

class _WeatherBottomSheetState extends ConsumerState<WeatherBottomSheet> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  /// 加载天气数据
  Future<void> _loadWeatherData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 使用经纬度查询天气
      final location = '${widget.cityInfo.longitude},${widget.cityInfo.latitude}';
      final response = await QweatherApiService.getNowWeather(location);
      
      if (mounted) {
        setState(() {
          _weatherData = response.toJson();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '获取天气信息失败: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: CPColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: CPColors.leiMuBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.cityInfo.city} - ${widget.cityInfo.district}',
                    style: CPTextStyles.s18.bold.build(),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // 内容区域
          Flexible(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在获取天气信息...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: CPTextStyles.s14.build(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWeatherData,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_weatherData == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text('暂无天气数据'),
        ),
      );
    }

    return _buildWeatherInfo();
  }

  /// 构建天气信息
  Widget _buildWeatherInfo() {
    final now = _weatherData!['now'] as Map<String, dynamic>?;
    if (now == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text('天气数据格式错误'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 主要天气信息
          Row(
            children: [
              // 温度
              Text(
                '${now['temp'] ?? '--'}°',
                style: CPTextStyles.s48.bold.build(),
              ),
              const SizedBox(width: 20),
              
              // 天气描述和图标
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      now['text'] ?? '未知',
                      style: CPTextStyles.s18.build(),
                    ),
                    const SizedBox(height: 4),
                                         Text(
                       '体感温度 ${now['feelsLike'] ?? '--'}°',
                       style: CPTextStyles.s14.withColor(CPColors.darkGrey).build(),
                     ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 详细信息网格
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildInfoItem('湿度', '${now['humidity'] ?? '--'}%'),
              _buildInfoItem('风向', now['windDir'] ?? '--'),
              _buildInfoItem('风力', '${now['windScale'] ?? '--'}级'),
              _buildInfoItem('风速', '${now['windSpeed'] ?? '--'}km/h'),
              _buildInfoItem('气压', '${now['pressure'] ?? '--'}hPa'),
              _buildInfoItem('能见度', '${now['vis'] ?? '--'}km'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 更新时间
          Text(
            '更新时间: ${now['obsTime'] ?? '--'}',
            style: CPTextStyles.s12.withColor(CPColors.darkGrey).build(),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CPColors.lightGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: CPTextStyles.s12.withColor(CPColors.darkGrey).build(),
          ),
          const Spacer(),
          Text(
            value,
            style: CPTextStyles.s12.bold.build(),
          ),
        ],
      ),
    );
  }
}

/// 显示天气信息底部弹窗
void showWeatherBottomSheet(BuildContext context, CityInfo cityInfo) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => WeatherBottomSheet(cityInfo: cityInfo),
  );
} 