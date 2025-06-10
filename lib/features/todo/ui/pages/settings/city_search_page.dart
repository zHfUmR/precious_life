import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/core/utils/city_utils.dart';
import 'package:precious_life/core/utils/log/log_utils.dart';
import 'package:precious_life/core/utils/storage_utils.dart';
import 'package:precious_life/features/todo/ui/models/followed_city.dart';

/// 城市搜索页面
/// 用于搜索和选择城市
class CitySearchPage extends ConsumerStatefulWidget {
  const CitySearchPage({super.key});

  @override
  ConsumerState<CitySearchPage> createState() => _CitySearchPageState();
}

class _CitySearchPageState extends ConsumerState<CitySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<CityInfo> _searchResults = [];
  final List<FollowedCity> _followedCities = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadFollowedCities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 加载已关注的城市列表
  Future<void> _loadFollowedCities() async {
    try {
      final citiesData = await StorageUtils.instance.getObjectList(StorageKeys.followedPoints);
      if (citiesData != null && mounted) {
        final cities = citiesData.map((data) => FollowedCity.fromJson(data)).toList();
        setState(() {
          _followedCities.clear();
          _followedCities.addAll(cities);
        });
      }
    } catch (e) {
      CPLog.d('加载关注城市失败: $e');
    }
  }

  /// 判断城市是否已被关注
  bool _isCityFollowed(CityInfo cityInfo) => _followedCities.any((city) => city.code == cityInfo.code);

  /// 搜索城市
  Future<void> _searchCity(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await CityUtils.instance.findCities(keyword);
      if (mounted) {
        setState(() {
          _searchResults.clear();
          _searchResults.addAll(results);
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('搜索失败', style: CPTextStyles.s16.bold.build()),
            content: Text(
              '搜索城市失败: ${e.toString()}',
              style: CPTextStyles.s14.build(),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '确定',
                  style: CPTextStyles.s16.bold.build(),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  /// 处理城市选择（添加到关注列表）
  void _onCitySelected(CityInfo cityInfo) {
    // 返回选中的城市信息
    context.pop(cityInfo);
  }

  /// 处理城市点击（查看天气详情）
  void _onCityTapped(CityInfo cityInfo) {
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.8),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: const Text('取消'),
        ),
        middle: Text(
          '搜索城市',
          style: CPTextStyles.s16.bold.build(),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 搜索框
            Padding(
              padding: const EdgeInsets.all(16),
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
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  placeholder: '输入城市名称',
                  onChanged: _searchCity,
                  style: CPTextStyles.s16.build(),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // 搜索结果
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CupertinoActivityIndicator(radius: 15),
                    )
                  : _searchResults.isEmpty && _searchController.text.isNotEmpty
                      ? Center(
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
                                  CupertinoIcons.search,
                                  size: 40,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '未找到相关城市',
                                style: CPTextStyles.s16.build(),
                              ),
                            ],
                          ),
                        )
                      : _searchResults.isEmpty
                          ? Center(
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
                                      CupertinoIcons.search,
                                      size: 40,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    '搜索城市',
                                    style: CPTextStyles.s18.bold.build(),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '输入城市名称进行搜索',
                                    style: CPTextStyles.s14.build(),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              child: _buildSearchResults(),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建搜索结果列表
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7, // 限制最大高度
            ),
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
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final city = _searchResults[index];
                final isLast = index == _searchResults.length - 1;
                final isFollowed = _isCityFollowed(city);

                return Container(
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : Border(
                            bottom: BorderSide(
                              color: CupertinoColors.separator.withOpacity(0.5),
                              width: 0.5,
                            ),
                          ),
                  ),
                  child: CupertinoListTile(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        CupertinoIcons.location,
                        size: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    title: Text(
                      '${city.city} - ${city.district}',
                      style: CPTextStyles.s15.bold.c(CPColors.black),
                    ),
                    trailing: isFollowed
                        ? null
                        : CupertinoButton(
                            padding: const EdgeInsets.all(6),
                            onPressed: () => _onCitySelected(city),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: CPColors.leiMuBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                CupertinoIcons.add,
                                color: CPColors.leiMuBlue,
                                size: 14,
                              ),
                            ),
                          ),
                    onTap: () => _onCityTapped(city),
                  ),
                );
              },
            ),
          ),
          // 底部边距
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
