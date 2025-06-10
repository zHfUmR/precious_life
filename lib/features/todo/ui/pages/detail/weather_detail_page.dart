import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/core/utils/storage_utils.dart';
import 'package:precious_life/features/todo/ui/models/followed_city.dart';
import 'package:precious_life/features/todo/ui/pages/detail/weather_info_page.dart';
import 'package:precious_life/features/todo/ui/providers/home_weather_vm.dart';
import '../../../../../core/utils/log/log_utils.dart';

/// 天气详情页面
/// 全屏显示，包含定位城市和关注城市的天气详情
class WeatherDetailPage extends ConsumerStatefulWidget {
  /// 初始显示的城市索引
  final int? initialCityIndex;
  
  /// 初始显示的城市代码
  final String? initialCityCode;
  
  const WeatherDetailPage({super.key, this.initialCityIndex, this.initialCityCode});

  @override
  ConsumerState<WeatherDetailPage> createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends ConsumerState<WeatherDetailPage> {
  late PageController _pageController;
  List<FollowedCity> _allCities = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  /// 懒加载页面的GlobalKey，用于刷新特定页面
  final Map<int, GlobalKey<_LazyLoadPageState>> _pageKeys = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadCitiesData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 加载城市数据
  Future<void> _loadCitiesData() async {
    try {
      setState(() => _isLoading = true);

      final List<FollowedCity> cities = [];

      // 添加当前定位城市（如果有的话）
      final homeWeatherState = ref.read(homeWeatherVmProvider);
      if (homeWeatherState.weatherLocationState.currentCity != null &&
          homeWeatherState.weatherLocationState.currentLatitude != null &&
          homeWeatherState.weatherLocationState.currentLongitude != null) {
        // 解析当前城市名称
        final cityParts = homeWeatherState.weatherLocationState.currentCity!.split('-');
        final currentCity = FollowedCity(
          province: cityParts.length > 1 ? cityParts[0] : '当前位置',
          name: cityParts.length > 1 ? cityParts[0] : '当前位置',
          region: cityParts.length > 1 ? cityParts[1] : '当前位置',
          code: 'current_location',
          latitude: homeWeatherState.weatherLocationState.currentLatitude!,
          longitude: homeWeatherState.weatherLocationState.currentLongitude!,
          order: -1, // 定位城市排在最前面
        );
        cities.add(currentCity);
        CPLog.d('🌍 详情页添加定位城市: ${currentCity.simpleDisplayName} (索引0)');
      }

      // 添加关注的城市
      final citiesData = await StorageUtils.instance.getObjectList(StorageKeys.followedPoints);
      if (citiesData != null) {
        final followedCities = citiesData.map((data) => FollowedCity.fromJson(data)).toList();
        followedCities.sort((a, b) => a.order.compareTo(b.order));
        cities.addAll(followedCities);
        
        CPLog.d('🏙️ 详情页添加关注城市:');
        for (int i = 0; i < followedCities.length; i++) {
          final startIndex = cities.indexOf(followedCities[i]);
          CPLog.d('  - ${followedCities[i].simpleDisplayName} (索引$startIndex)');
        }
      }

      setState(() {
        _allCities = cities;
        _isLoading = false;
        // 重新生成页面keys
        _pageKeys.clear();
        for (int i = 0; i < cities.length; i++) {
          _pageKeys[i] = GlobalKey<_LazyLoadPageState>();
        }
        CPLog.d('🎯 详情页总城市列表: ${cities.map((c) => c.simpleDisplayName).toList()}');
        CPLog.d('🎯 接收到的initialCityIndex: ${widget.initialCityIndex}');
        CPLog.d('🎯 接收到的initialCityCode: ${widget.initialCityCode}');
        
        // 优先使用城市代码查找，如果没有则使用索引
        if (widget.initialCityCode != null) {
          final targetIndex = cities.indexWhere((city) => city.code == widget.initialCityCode);
          if (targetIndex >= 0) {
            _currentIndex = targetIndex;
            CPLog.d('🎯 通过城市代码找到索引: $_currentIndex, 城市: ${cities[_currentIndex].simpleDisplayName}');
          } else {
            CPLog.d('❌ 未找到城市代码: ${widget.initialCityCode}');
          }
        } else if (widget.initialCityIndex != null && 
            widget.initialCityIndex! >= 0 && 
            widget.initialCityIndex! < cities.length) {
          _currentIndex = widget.initialCityIndex!;
          CPLog.d('🎯 使用索引: $_currentIndex, 城市: ${cities[_currentIndex].simpleDisplayName}');
        }
        
        // 跳转到目标页面
        if (_currentIndex > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _pageController.animateToPage(
              _currentIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            // 确保当前页面被加载
            _loadCurrentPage(_currentIndex);
          });
        } else {
          // 加载第一个页面
          _loadCurrentPage(_currentIndex);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      CPLog.d('加载城市数据失败: $e');
    }
  }

  /// 处理页面变化
  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    // 只加载当前页面，不预加载其他页面
    _loadCurrentPage(index);
  }

  /// 加载当前页面
  void _loadCurrentPage(int currentIndex) {
    if (currentIndex >= 0 && currentIndex < _allCities.length && _pageKeys.containsKey(currentIndex)) {
      final pageState = _pageKeys[currentIndex]!.currentState;
      pageState?._preloadIfNeeded();
    }
  }

  /// 刷新当前页面
  void _refreshCurrentPage() {
    final currentPageKey = _pageKeys[_currentIndex];
    if (currentPageKey != null) {
      final pageState = currentPageKey.currentState;
      pageState?._refreshPage();
    }
  }

  /// 关闭页面
  void _closePage() => context.pop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? _buildLoadingView() : _buildPageView(),
    );
  }

  /// 构建加载视图
  Widget _buildLoadingView() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // 天空蓝
              Color(0xFFFFFFFF), // 白色
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                '正在加载城市数据...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );

  /// 构建PageView
  Widget _buildPageView() {
    if (_allCities.isEmpty) {
      return _buildEmptyView();
    }

    return Stack(
      children: [
        // PageView内容
        PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: _allCities.length,
          itemBuilder: (context, index) {
            final city = _allCities[index];
            return _LazyLoadPage(
              key: _pageKeys[index],
              city: city,
              isActive: index == _currentIndex,
              shouldLoad: _shouldLoadPage(index),
              onRefresh: () => _refreshCurrentPage(),
            );
          },
        ),

        // 顶部控制栏
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTopBar(),
        ),
      ],
    );
  }

  /// 判断是否应该加载页面
  /// 只加载当前页面
  bool _shouldLoadPage(int index) {
    return index == _currentIndex;
  }

  /// 构建空视图
  Widget _buildEmptyView() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // 天空蓝
              Color(0xFFFFFFFF), // 白色
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_off,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无城市数据',
                style: CPTextStyles.s18.bold.c(Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '请先添加关注的城市',
                style: CPTextStyles.s14.c(Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _closePage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                ),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );

  /// 构建顶部控制栏
  Widget _buildTopBar() => SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 关闭按钮
              GestureDetector(
                onTap: _closePage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              // 页面指示器（如果有多个城市）
              if (_allCities.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_allCities.length, (index) {
                      final isActive = index == _currentIndex;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: isActive ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                )
              else
                const SizedBox.shrink(),

              // 刷新按钮
              GestureDetector(
                onTap: _refreshCurrentPage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

/// 懒加载页面包装器
/// 只有当页面需要显示时才真正加载天气数据
class _LazyLoadPage extends StatefulWidget {
  /// 城市信息
  final FollowedCity city;

  /// 是否为当前活跃页面
  final bool isActive;

  /// 是否应该加载数据
  final bool shouldLoad;

  /// 刷新回调
  final VoidCallback? onRefresh;

  const _LazyLoadPage({
    super.key,
    required this.city,
    required this.isActive,
    required this.shouldLoad,
    this.onRefresh,
  });

  @override
  State<_LazyLoadPage> createState() => _LazyLoadPageState();
}

class _LazyLoadPageState extends State<_LazyLoadPage> {
  /// 是否已经创建过页面
  bool _hasCreated = false;

  /// 缓存的天气页面组件
  Widget? _cachedPage;

  @override
  void didUpdateWidget(_LazyLoadPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果从不需要加载变为需要加载，则创建页面
    if (!oldWidget.shouldLoad && widget.shouldLoad && !_hasCreated) {
      _createPage();
    }
  }

  @override
  void initState() {
    super.initState();
    // 如果初始化时就需要加载，则立即创建页面
    if (widget.shouldLoad) {
      _createPage();
    }
  }

  /// 创建页面组件
  void _createPage() {
    if (_hasCreated) return;

    setState(() {
      _hasCreated = true;
      _cachedPage = WeatherInfoPage(
        key: ValueKey('weather_${widget.city.code}'),
        city: widget.city,
        onRefresh: widget.onRefresh,
        shouldLoadData: true,
      );
    });
  }

  /// 预加载页面（供外部调用）
  void _preloadIfNeeded() {
    if (!_hasCreated) {
      _createPage();
    }
  }

  /// 刷新页面（供外部调用）
  void _refreshPage() {
    // 重新创建页面以触发数据刷新
    if (_hasCreated) {
      setState(() {
        _cachedPage = WeatherInfoPage(
          key: ValueKey('weather_${widget.city.code}_${DateTime.now().millisecondsSinceEpoch}'),
          city: widget.city,
          onRefresh: widget.onRefresh,
          shouldLoadData: true,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果不需要加载，显示占位符
    if (!widget.shouldLoad && !_hasCreated) {
      return _buildPlaceholder();
    }

    // 如果需要加载但还没加载完成，显示加载状态
    if (widget.shouldLoad && !_hasCreated) {
      // 延迟加载，添加动画效果
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _createPage();
        }
      });
      return _buildLoadingPlaceholder();
    }

    // 返回缓存的页面，添加淡入动画
    return _cachedPage != null 
        ? AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _cachedPage,
          )
        : _buildLoadingPlaceholder();
  }

  /// 构建占位符
  Widget _buildPlaceholder() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // 天空蓝
              Color(0xFFFFFFFF), // 白色
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_city,
                size: 64,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                widget.city.simpleDisplayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '左右滑动切换到此页面',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '天气数据将自动加载',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      );

  /// 构建加载占位符
  Widget _buildLoadingPlaceholder() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // 天空蓝
              Color(0xFFFFFFFF), // 白色
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.city.simpleDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '正在加载天气数据...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
