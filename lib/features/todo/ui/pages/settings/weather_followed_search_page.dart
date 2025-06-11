import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/features/todo/ui/models/followed_point.dart';
import 'package:precious_life/features/todo/ui/providers/weather_card_vm.dart';
import 'package:precious_life/shared/widgets/loading_status_widget.dart';
import 'package:precious_life/core/utils/city_utils.dart';
import 'package:precious_life/core/network/api/tianditu/tianditu_api_service.dart';
import 'package:precious_life/core/network/api/tianditu/tianditu_api_model.dart';
import 'dart:async';

/// 搜索类型枚举
enum SearchType {
  city('城市'),
  location('地名');

  const SearchType(this.displayName);
  final String displayName;
}

/// 天气关注搜索页面
/// 用于搜索并添加关注的城市或地名
class WeatherFollowedSearchPage extends ConsumerStatefulWidget {
  const WeatherFollowedSearchPage({super.key});

  @override
  ConsumerState<WeatherFollowedSearchPage> createState() => _WeatherFollowedSearchPageState();
}

class _WeatherFollowedSearchPageState extends ConsumerState<WeatherFollowedSearchPage> with TickerProviderStateMixin {
  late final WeatherCardVm _weatherCardVm;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final ValueNotifier<SearchType> _searchTypeNotifier;
  late final ValueNotifier<LoadingStatus> _loadingStatusNotifier;
  late final ValueNotifier<bool> _isSearchingNotifier;
  late final ValueNotifier<List<CityInfo>> _cityResultsNotifier;
  late final ValueNotifier<List<SearchPoi>> _poiResultsNotifier;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _weatherCardVm = ref.read(weatherCardVmProvider.notifier);
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchTypeNotifier = ValueNotifier<SearchType>(SearchType.city);
    _loadingStatusNotifier = ValueNotifier<LoadingStatus>(LoadingStatus.initial);
    _isSearchingNotifier = ValueNotifier<bool>(false);
    _cityResultsNotifier = ValueNotifier<List<CityInfo>>([]);
    _poiResultsNotifier = ValueNotifier<List<SearchPoi>>([]);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _animationController?.forward();

    // 监听搜索框文本变化
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchTypeNotifier.dispose();
    _loadingStatusNotifier.dispose();
    _isSearchingNotifier.dispose();
    _cityResultsNotifier.dispose();
    _poiResultsNotifier.dispose();
    _searchTimer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  /// 搜索文本变化处理
  void _onSearchTextChanged() {
    final text = _searchController.text.trim();

    // 取消之前的搜索定时器
    _searchTimer?.cancel();

    if (text.isNotEmpty) {
      // 根据搜索类型设置不同的延迟时间
      final searchType = _searchTypeNotifier.value;
      final delay = searchType == SearchType.city
          ? const Duration(milliseconds: 500) // 城市搜索延时0.5s
          : const Duration(seconds: 1); // 地名搜索延时1s

      _searchTimer = Timer(delay, () {
        if (mounted) {
          _performSearch(text);
        }
      });
    } else {
      _loadingStatusNotifier.value = LoadingStatus.initial;
      _cityResultsNotifier.value = [];
      _poiResultsNotifier.value = [];
    }
  }

  /// 执行搜索
  void _performSearch(String keyword) async {
    if (keyword.isEmpty) return;

    _isSearchingNotifier.value = true;
    _loadingStatusNotifier.value = LoadingStatus.loading;

    try {
      final searchType = _searchTypeNotifier.value;

      if (searchType == SearchType.city) {
        // 城市搜索 - 查询内存数据
        await _searchCities(keyword);
      } else {
        // 地名搜索 - 查询网络数据
        await _searchPlaces(keyword);
      }
    } catch (e) {
      print('搜索失败: $e');
      if (mounted) {
        _loadingStatusNotifier.value = LoadingStatus.failure;
      }
    } finally {
      if (mounted) {
        _isSearchingNotifier.value = false;
      }
    }
  }

  /// 搜索城市
  Future<void> _searchCities(String keyword) async {
    try {
      final cities = await CityUtils.instance.findCities(keyword);
      if (mounted) {
        _cityResultsNotifier.value = cities;
        _poiResultsNotifier.value = [];
        if (cities.isEmpty) {
          _loadingStatusNotifier.value = LoadingStatus.noData;
        } else {
          _loadingStatusNotifier.value = LoadingStatus.success;
        }
      }
    } catch (e) {
      print('城市搜索失败: $e');
      if (mounted) {
        _loadingStatusNotifier.value = LoadingStatus.failure;
      }
    }
  }

  /// 搜索地名
  Future<void> _searchPlaces(String keyword) async {
    try {
      final response = await TiandituApiService.instance.search(
        keyWord: keyword,
        count: 20, // 返回更多结果
      );

      if (mounted) {
        _cityResultsNotifier.value = [];
        _poiResultsNotifier.value = response.pois ?? [];

        if (response.isSuccess) {
          if ((response.pois ?? []).isEmpty) {
            _loadingStatusNotifier.value = LoadingStatus.noData;
          } else {
            _loadingStatusNotifier.value = LoadingStatus.success;
          }
        } else {
          _loadingStatusNotifier.value = LoadingStatus.failure;
        }
      }
    } catch (e) {
      print('地名搜索失败: $e');
      if (mounted) {
        _loadingStatusNotifier.value = LoadingStatus.failure;
      }
    }
  }

  /// 清空搜索
  void _clearSearch() {
    _searchController.clear();
    _loadingStatusNotifier.value = LoadingStatus.initial;
    _isSearchingNotifier.value = false;
    _cityResultsNotifier.value = [];
    _poiResultsNotifier.value = [];
    _searchTimer?.cancel();
  }

  /// 关闭页面
  void _closePage() {
    GoRouter.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
          child: Column(
            children: [
              // 搜索栏
              _buildSearchBar(),
              // 搜索结果区域
              Expanded(
                child: _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      color: CupertinoColors.systemBackground,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          // 类型切换下拉框
          ValueListenableBuilder<SearchType>(
            valueListenable: _searchTypeNotifier,
            builder: (context, searchType, child) {
              return GestureDetector(
                onTap: _showSearchTypeSelector,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CupertinoColors.systemGrey4,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        searchType.displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: CupertinoColors.label,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        CupertinoIcons.chevron_down,
                        size: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          // 搜索输入框
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // 搜索图标
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(
                      CupertinoIcons.search,
                      size: 18,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),

                  // 输入框
                  Expanded(
                    child: CupertinoTextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      placeholder: '请输入搜索关键词',
                      placeholderStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: CupertinoColors.systemGrey,
                          ),
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: null,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      clearButtonMode: OverlayVisibilityMode.never,
                    ),
                  ),

                  // 清空按钮
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, child) {
                      if (value.text.isNotEmpty) {
                        return GestureDetector(
                          onTap: _clearSearch,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              CupertinoIcons.clear_circled_solid,
                              size: 18,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        );
                      }
                      return const SizedBox(width: 6);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 取消按钮
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _closePage,
            child: Text(
              '取消',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CPColors.leiMuBlue,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults() {
    return ValueListenableBuilder<LoadingStatus>(
      valueListenable: _loadingStatusNotifier,
      builder: (context, status, child) {
        return LoadingStatusWidget(
          status: status,
          loadingMessage: '搜索中...',
          errorMessage: '搜索失败，请稍后重试',
          onRetry: () {
            final text = _searchController.text.trim();
            if (text.isNotEmpty) {
              _performSearch(text);
            }
          },
          child: _buildSearchResultsList(),
        );
      },
    );
  }

  /// 构建搜索结果列表
  Widget _buildSearchResultsList() {
    return ValueListenableBuilder<SearchType>(
      valueListenable: _searchTypeNotifier,
      builder: (context, searchType, child) {
        if (searchType == SearchType.city) {
          // 城市搜索结果
          return ValueListenableBuilder<List<CityInfo>>(
            valueListenable: _cityResultsNotifier,
            builder: (context, cities, child) {
              if (cities.isEmpty) {
                return _buildEmptyState(searchType);
              }
              return _buildCityResultsList(cities);
            },
          );
        } else {
          // 地名搜索结果
          return ValueListenableBuilder<List<SearchPoi>>(
            valueListenable: _poiResultsNotifier,
            builder: (context, pois, child) {
              if (pois.isEmpty) {
                return _buildEmptyState(searchType);
              }
              return _buildPoiResultsList(pois);
            },
          );
        }
      },
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(SearchType searchType) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
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
                  Icon(
                    searchType == SearchType.city ? CupertinoIcons.building_2_fill : CupertinoIcons.location_fill,
                    size: 40,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '搜索${searchType.displayName}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '输入关键词开始搜索',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: CupertinoColors.secondaryLabel,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建城市搜索结果列表
  Widget _buildCityResultsList(List<CityInfo> cities) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final city = cities[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CupertinoListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: CPColors.leiMuBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        CupertinoIcons.building_2_fill,
                        color: CPColors.leiMuBlue,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      city.simpleName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label,
                          ),
                    ),
                    subtitle: Text(
                      city.fullName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: CupertinoColors.secondaryLabel,
                          ),
                    ),
                    trailing: const Icon(
                      CupertinoIcons.add_circled,
                      color: CPColors.leiMuBlue,
                    ),
                    onTap: () {
                      _weatherCardVm.addFollowedPoint(FollowedPoint(
                        city: city.city,
                        province: city.province,
                        district: city.district,
                        latitude: city.latitude,
                        longitude: city.longitude,
                      ));
                      GoRouter.of(context).pop();
                    },
                  ),
                );
              },
              childCount: cities.length,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建地名搜索结果列表
  Widget _buildPoiResultsList(List<SearchPoi> pois) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final poi = pois[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CupertinoListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        CupertinoIcons.location_fill,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      poi.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label,
                          ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (poi.address != null && poi.address!.isNotEmpty) ...[
                          Text(
                            poi.address!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: CupertinoColors.secondaryLabel,
                                ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          '${poi.province ?? ''} ${poi.city ?? ''} ${poi.county ?? ''}'.trim(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: CupertinoColors.systemGrey,
                              ),
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      CupertinoIcons.add_circled,
                      color: CPColors.leiMuBlue,
                    ),
                    onTap: () => _addPoi(poi),
                  ),
                );
              },
              childCount: pois.length,
            ),
          ),
        ),
      ],
    );
  }

  /// 添加POI地点
  void _addPoi(SearchPoi poi) {
    // TODO: 实现添加POI到关注列表的逻辑
    print('添加地点: ${poi.name}');
    GoRouter.of(context).pop();
  }

  /// 显示搜索类型选择器
  void _showSearchTypeSelector() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(
            '选择搜索类型',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          actions: SearchType.values.map((type) {
            return CupertinoActionSheetAction(
              onPressed: () {
                _searchTypeNotifier.value = type;
                GoRouter.of(context).pop();

                // 清空之前的搜索结果
                _cityResultsNotifier.value = [];
                _poiResultsNotifier.value = [];
                _loadingStatusNotifier.value = LoadingStatus.initial;

                // 取消之前的搜索定时器
                _searchTimer?.cancel();

                // 如果有搜索内容，重新搜索
                final text = _searchController.text.trim();
                if (text.isNotEmpty) {
                  _onSearchTextChanged();
                }
              },
              child: Text(
                type.displayName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: CPColors.leiMuBlue,
                    ),
              ),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => GoRouter.of(context).pop(),
            child: Text(
              '取消',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        );
      },
    );
  }
}
