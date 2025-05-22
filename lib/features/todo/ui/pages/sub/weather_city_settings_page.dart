import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/config/app_config.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_service.dart';
import 'package:precious_life/core/utils/city_utils.dart';
import 'package:precious_life/features/todo/ui/providers/home_weather_vm.dart';

/// 天气城市设置页面
/// 用于配置天气显示的城市信息
class WeatherCitySettingsPage extends ConsumerStatefulWidget {
  const WeatherCitySettingsPage({super.key});

  @override
  ConsumerState<WeatherCitySettingsPage> createState() => _WeatherCitySettingsPageState();
}

class _WeatherCitySettingsPageState extends ConsumerState<WeatherCitySettingsPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _searchResults = [];
  bool _isSearching = false;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadCurrentCity();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 加载当前城市
  Future<void> _loadCurrentCity() async {
    final homeWeatherState = ref.read(homeWeatherVmProvider);
    if (homeWeatherState.currentCity != null) {
      setState(() {
        _selectedCity = homeWeatherState.currentCity;
      });
    }
  }

  /// 搜索城市
  Future<void> _searchCity(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await CityUtils.instance.findCities(keyword);
      setState(() {
        _searchResults.clear();
        _searchResults.addAll(results);
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('搜索城市失败: ${e.toString()}')),
      );
    }
  }

  /// 选择城市
  Future<void> _selectCity(String city) async {
    setState(() {
      _selectedCity = city;
      _searchController.clear();
      _searchResults.clear();
    });

    try {
      // 查询城市经纬度
      final cityResponse = await QweatherApiService.lookupCity(city);
      if (cityResponse.location != null && cityResponse.location!.isNotEmpty) {
        final location = cityResponse.location![0];
        
        // 更新AppConfig中的位置信息
        if (location.lon != null && location.lat != null) {
          AppConfig.currentLongitude = double.parse(location.lon!);
          AppConfig.currentLatitude = double.parse(location.lat!);
          
          // 刷新天气数据
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('城市设置成功')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('设置城市失败: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('城市设置'),
        backgroundColor: CPColors.leiMuBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前城市显示
            if (_selectedCity != null) ...[
              Text('当前城市', style: CPTextStyles.s14.bold.build()),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CPColors.lightGrey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 20),
                    const SizedBox(width: 8),
                    Text(_selectedCity!, style: CPTextStyles.s16.build()),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // 搜索框
            Text('搜索城市', style: CPTextStyles.s14.bold.build()),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '输入城市名称',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onChanged: _searchCity,
            ),
            
            // 搜索结果
            const SizedBox(height: 16),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty && _searchController.text.isNotEmpty
                      ? Center(child: Text('未找到城市', style: CPTextStyles.s14.build()))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final city = _searchResults[index];
                            return ListTile(
                              title: Text(city),
                              onTap: () => _selectCity(city),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
