import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:precious_life/app/routes/route_constants.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/core/utils/city_utils.dart';
import 'package:precious_life/core/utils/storage_utils.dart';
import 'package:precious_life/features/todo/ui/models/followed_city.dart';
import 'package:precious_life/features/todo/ui/providers/home_weather_vm.dart';
import 'package:precious_life/features/todo/ui/widgets/weather_bottom_sheet.dart';
import '../../../../../core/utils/log/log_utils.dart';

/// 天气城市设置页面
/// 用于配置天气显示的城市信息
class WeatherCitySettingsPage extends ConsumerStatefulWidget {
  const WeatherCitySettingsPage({super.key});

  @override
  ConsumerState<WeatherCitySettingsPage> createState() => _WeatherCitySettingsPageState();
}

class _WeatherCitySettingsPageState extends ConsumerState<WeatherCitySettingsPage> with TickerProviderStateMixin {
  List<FollowedCity> _followedCities = [];
  bool _isLoading = true;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  int? _swipedIndex; // 记录当前被滑动的项目索引
  late HomeWeatherVm _homeWeatherVm;
  bool _hasDataChanged = false; // 标记数据是否发生变化

  @override
  void initState() {
    super.initState();
    _homeWeatherVm = ref.read(homeWeatherVmProvider.notifier);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _loadFollowedCities();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  /// 处理页面返回，传递数据是否发生变化的信息
  void _handlePageReturn() {
    // 只需要检查_hasDataChanged即可，因为所有数据变化都会设置这个标记
    GoRouter.of(context).pop(_hasDataChanged);
  }

  /// 加载关注的城市列表
  Future<void> _loadFollowedCities() async {
    try {
      setState(() => _isLoading = true);

      final citiesData = await StorageUtils.instance.getObjectList(StorageKeys.followedCities);
      if (citiesData != null) {
        final cities = citiesData.map((data) => FollowedCity.fromJson(data)).toList();
        cities.sort((a, b) => a.order.compareTo(b.order));
        setState(() {
          _followedCities = cities;
          _hasDataChanged = false;
        });
      } else {
        setState(() {
          _followedCities = [];
          _hasDataChanged = false;
        });
      }

      _animationController?.forward();
    } catch (e) {
      CPLog.d('加载关注城市失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 保存关注的城市列表
  Future<void> _saveFollowedCities() async {
    try {
      final citiesData = _followedCities.map((city) => city.toJson()).toList();
      await StorageUtils.instance.setObjectList(StorageKeys.followedCities, citiesData);

      // 保存成功后刷新天气模块的关注城市天气数据
      if (_hasDataChanged) {
        _homeWeatherVm.refreshCityWeather();
      }
    } catch (e) {
      CPLog.d('保存关注城市失败: $e');
    }
  }

  /// 添加关注城市
  Future<void> _addFollowedCity(CityInfo cityInfo) async {
    // 检查是否已经关注
    final isAlreadyFollowed = _followedCities.any((city) => city.code == cityInfo.code);
    if (isAlreadyFollowed) {
      return;
    }

    final newCity = FollowedCity.fromCityInfo(cityInfo, _followedCities.length);
    setState(() {
      _followedCities.add(newCity);
      _hasDataChanged = true; // 标记数据已变化
    });
    await _saveFollowedCities();
  }

  /// 删除关注城市
  Future<void> _removeFollowedCity(int index) async {
    setState(() {
      _followedCities.removeAt(index);
      _swipedIndex = null; // 重置滑动状态
      _hasDataChanged = true; // 标记数据已变化
    });

    // 重新排序
    for (int i = 0; i < _followedCities.length; i++) {
      _followedCities[i] = _followedCities[i].copyWith(order: i);
    }

    await _saveFollowedCities();
  }

  /// 重新排序关注城市
  Future<void> _reorderFollowedCities(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    final city = _followedCities.removeAt(oldIndex);
    _followedCities.insert(newIndex, city);

    // 重新设置order
    for (int i = 0; i < _followedCities.length; i++) {
      _followedCities[i] = _followedCities[i].copyWith(order: i);
    }

    setState(() {
      _hasDataChanged = true; // 标记数据已变化
    });
    await _saveFollowedCities();
  }

  /// 显示城市搜索页面
  Future<void> _showCitySearchPage() async {
    final result = await context.push<CityInfo>(AppRoutes.citySearch);
    if (result != null) {
      _addFollowedCity(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _handlePageReturn();
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.systemBackground.withOpacity(0.8),
          border: null,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _handlePageReturn,
            child: const Text('返回'),
          ),
          middle: const Text(
            '城市设置',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CupertinoActivityIndicator(radius: 15),
                )
              : FadeTransition(
                  opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                  child: CustomScrollView(
                    slivers: [
                      // 搜索按钮区域
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: _buildSearchButton(),
                        ),
                      ),

                      // 关注城市列表
                      _buildFollowedCitiesList(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  /// 构建搜索按钮
  Widget _buildSearchButton() => Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          onPressed: _showCitySearchPage,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: CPColors.leiMuBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.search,
                  color: CPColors.leiMuBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '搜索城市',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.label,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey,
                size: 16,
              ),
            ],
          ),
        ),
      );

  /// 构建关注城市列表
  Widget _buildFollowedCitiesList() {
    if (_followedCities.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  CupertinoIcons.location,
                  size: 40,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '暂无关注的城市',
                style: CPTextStyles.s18.bold.build(),
              ),
              const SizedBox(height: 8),
              Text(
                '点击上方按钮搜索并添加城市',
                style: CPTextStyles.s14.build(),
              ),
            ],
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 标题
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      '关注城市',
                      style: CPTextStyles.s16.bold.build(),
                    ),
                    const Spacer(),
                    Text(
                      '${_followedCities.length}个',
                      style: CPTextStyles.s14.build(),
                    ),
                  ],
                ),
              ),

              // 城市列表
              GestureDetector(
                onTap: () {
                  // 点击空白区域关闭已滑开的项
                  if (_swipedIndex != null) {
                    setState(() => _swipedIndex = null);
                  }
                },
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _followedCities.length,
                  onReorder: (oldIndex, newIndex) {
                    // 重新排序时关闭已滑开的项
                    if (_swipedIndex != null) {
                      setState(() => _swipedIndex = null);
                    }
                    _reorderFollowedCities(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final city = _followedCities[index];
                    final isLast = index == _followedCities.length - 1;

                    return Container(
                      key: Key(city.code),
                      child: _buildCityItem(city, index, isLast),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建城市项
  Widget _buildCityItem(FollowedCity city, int index, bool isLast) {
    final isSwipedOpen = _swipedIndex == index;

    return GestureDetector(
      onTap: () {
        if (isSwipedOpen) {
          // 如果当前项已经滑开，点击关闭
          setState(() => _swipedIndex = null);
        } else {
          // 关闭其他已滑开的项，然后执行正常点击
          if (_swipedIndex != null) {
            setState(() => _swipedIndex = null);
          } else {
            showWeatherBottomSheet(context, city.toCityInfo());
          }
        }
      },
      onHorizontalDragUpdate: (details) {
        // 检测左滑手势
        if (details.delta.dx < -2) {
          // 左滑，显示删除按钮
          if (_swipedIndex != index) {
            setState(() => _swipedIndex = index);
          }
        } else if (details.delta.dx > 2) {
          // 右滑，关闭删除按钮
          if (_swipedIndex == index) {
            setState(() => _swipedIndex = null);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
          borderRadius: isLast
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                )
              : BorderRadius.zero,
        ),
        child: Stack(
          children: [
            // 删除按钮背景
            if (isSwipedOpen)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _swipedIndex = null);
                    _removeFollowedCity(index);
                  },
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: CupertinoColors.destructiveRed,
                      borderRadius: isLast
                          ? const BorderRadius.only(
                              bottomRight: Radius.circular(12),
                            )
                          : BorderRadius.zero,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.delete_solid,
                          color: CupertinoColors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 主要内容
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(
                isSwipedOpen ? -80.0 : 0.0,
                0.0,
                0.0,
              ),
              child: Container(
                color: CupertinoColors.systemBackground,
                child: CupertinoListTile(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CPColors.leiMuBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.location_solid,
                      color: CPColors.leiMuBlue,
                      size: 16,
                    ),
                  ),
                  title: Text(
                    city.simpleDisplayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  trailing: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.line_horizontal_3,
                        color: CupertinoColors.systemGrey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
