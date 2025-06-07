import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeatherCard extends ConsumerStatefulWidget {
  const WeatherCard({super.key});

  @override
  ConsumerState<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends ConsumerState<WeatherCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
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
            _buildLocationRow(),
            const SizedBox(height: 8),

            // 天气信息行
            _buildWeatherInfoRow(),
            const SizedBox(height: 8),

            // 展开/收起按钮
            _buildExpandButton(),

            // 展开的关注城市列表 - 使用AnimatedContainer替代AnimatedSize
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildFollowedCitiesList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow() {
    return Row(
      children: [
        const Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 18,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '北京市朝阳区',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherInfoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 温度
        Text(
          '25°',
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
            const Icon(
              Icons.wb_sunny,
              color: Colors.orange,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              '晴天',
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
              const Text('0%', style: TextStyle(fontSize: 12)),
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('当前无告警信息')),
                      );
                    },
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('正在更新天气信息...')),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            // 时间文本
            Text(
              '5分钟前',
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

  Widget _buildExpandButton() {
    return Center(
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
  }

  Widget _buildFollowedCitiesList() {
    final followedCities = [
      {'name': '上海市', 'temp': '28°', 'weather': '多云', 'icon': Icons.cloud},
      {'name': '广州市', 'temp': '32°', 'weather': '雷雨', 'icon': Icons.thunderstorm},
      {'name': '深圳市', 'temp': '30°', 'weather': '晴天', 'icon': Icons.wb_sunny},
    ];

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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('正在刷新关注城市...')),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  iconSize: 14,
                  padding: EdgeInsets.zero,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ...followedCities.asMap().entries.map((entry) {
          final index = entry.key;
          final city = entry.value;
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            curve: Curves.easeOutBack,
            transform: Matrix4.translationValues(
              _isExpanded ? 0 : -20,
              0,
              0,
            ),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 150 + (index * 50)),
              opacity: _isExpanded ? 1.0 : 0.0,
              child: _buildCityWeatherCard(city),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCityWeatherCard(Map<String, dynamic> cityData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 城市名称行
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.grey,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  cityData['name'],
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 天气信息行
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 温度
              Text(
                cityData['temp'],
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
                  Icon(
                    cityData['icon'],
                    color: _getWeatherIconColor(cityData['icon']),
                    size: 16,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cityData['weather'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                        ),
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
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    const Text('10%', style: TextStyle(fontSize: 10)),
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${cityData['name']}当前无告警信息')),
                            );
                          },
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('正在更新${cityData['name']}天气信息...')),
                            );
                          },
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
                    '10分钟前',
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

  Color _getWeatherIconColor(IconData icon) {
    switch (icon) {
      case Icons.wb_sunny:
        return Colors.orange;
      case Icons.cloud:
        return Colors.grey;
      case Icons.thunderstorm:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
