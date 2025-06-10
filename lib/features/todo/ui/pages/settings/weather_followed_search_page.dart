import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/core/utils/city_utils.dart';
import '../../../../../core/utils/log/log_utils.dart';

/// 搜索模式枚举
enum SearchMode {
  city('城市'),
  address('地点');

  const SearchMode(this.displayName);
  final String displayName;
}

/// 天气关注点搜索页面
/// 用于搜索并添加新的天气关注点
class WeatherFollowedSearchPage extends ConsumerStatefulWidget {
  const WeatherFollowedSearchPage({super.key});

  @override
  ConsumerState<WeatherFollowedSearchPage> createState() => _WeatherFollowedSearchPageState();
}

class _WeatherFollowedSearchPageState extends ConsumerState<WeatherFollowedSearchPage> 
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _switchButtonKey = GlobalKey(); // 切换按钮的Key
  SearchMode _currentSearchMode = SearchMode.city;
  List<CityInfo> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _searchController.addListener(_onSearchTextChanged);
    
    // 自动聚焦搜索框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  /// 搜索文本变化监听
  void _onSearchTextChanged() {
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text.trim());
    } else {
      setState(() {
        _searchResults.clear();
        _hasSearched = false;
      });
    }
  }

  /// 执行搜索
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      List<CityInfo> results = [];
      
      if (_currentSearchMode == SearchMode.city) {
        // 城市搜索逻辑
        results = await _searchCities(query);
      } else {
        // 地点搜索逻辑
        results = await _searchAddresses(query);
      }

      setState(() {
        _searchResults = results;
      });
      
      _animationController?.forward();
    } catch (e) {
      CPLog.d('搜索失败: $e');
      setState(() => _searchResults.clear());
    } finally {
      setState(() => _isSearching = false);
    }
  }

  /// 搜索城市
  Future<List<CityInfo>> _searchCities(String query) async {
    // TODO: 实现真实的城市搜索API
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络请求
    
    // 模拟搜索结果
    return [
      CityInfo(
        code: 'city_001', 
        city: '北京市', 
        province: '北京',
        district: '北京',
        provinceEnglish: 'Beijing',
        cityEnglish: 'Beijing', 
        districtEnglish: 'Beijing',
        latitude: 39.9042,
        longitude: 116.4074,
        adminCode: '110000',
      ),
      CityInfo(
        code: 'city_002', 
        city: '上海市', 
        province: '上海',
        district: '上海',
        provinceEnglish: 'Shanghai',
        cityEnglish: 'Shanghai', 
        districtEnglish: 'Shanghai',
        latitude: 31.2304,
        longitude: 121.4737,
        adminCode: '310000',
      ),
      CityInfo(
        code: 'city_003', 
        city: '广州市', 
        province: '广东省',
        district: '广州',
        provinceEnglish: 'Guangdong',
        cityEnglish: 'Guangzhou', 
        districtEnglish: 'Guangzhou',
        latitude: 23.1291,
        longitude: 113.2644,
        adminCode: '440000',
      ),
      CityInfo(
        code: 'city_004', 
        city: '深圳市', 
        province: '广东省',
        district: '深圳',
        provinceEnglish: 'Guangdong',
        cityEnglish: 'Shenzhen', 
        districtEnglish: 'Shenzhen',
        latitude: 22.5431,
        longitude: 114.0579,
        adminCode: '440300',
      ),
    ].where((city) => city.city.contains(query)).toList();
  }

  /// 搜索地址
  Future<List<CityInfo>> _searchAddresses(String query) async {
    // TODO: 实现真实的地址搜索API
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络请求
    
    // 模拟搜索结果
    return [
      CityInfo(
        code: 'addr_001', 
        city: '天安门广场', 
        province: '北京市',
        district: '东城区',
        provinceEnglish: 'Beijing',
        cityEnglish: 'Tiananmen Square', 
        districtEnglish: 'Dongcheng',
        latitude: 39.9042,
        longitude: 116.3976,
        adminCode: '110101',
      ),
      CityInfo(
        code: 'addr_002', 
        city: '外滩', 
        province: '上海市',
        district: '黄浦区',
        provinceEnglish: 'Shanghai',
        cityEnglish: 'The Bund', 
        districtEnglish: 'Huangpu',
        latitude: 31.2397,
        longitude: 121.4905,
        adminCode: '310101',
      ),
      CityInfo(
        code: 'addr_003', 
        city: '珠江新城', 
        province: '广东省',
        district: '天河区',
        provinceEnglish: 'Guangdong',
        cityEnglish: 'Zhujiang New Town', 
        districtEnglish: 'Tianhe',
        latitude: 23.1200,
        longitude: 113.3265,
        adminCode: '440106',
      ),
    ].where((addr) => addr.city.contains(query)).toList();
  }

  /// 清空搜索
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults.clear();
      _hasSearched = false;
    });
  }

  /// 切换搜索模式
  void _switchSearchMode(SearchMode mode) {
    setState(() {
      _currentSearchMode = mode;
      _searchResults.clear();
      _hasSearched = false;
    });
    
    // 如果有搜索文本，重新搜索
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text.trim());
    }
  }

  /// 选择搜索结果
  void _selectSearchResult(CityInfo cityInfo) {
    GoRouter.of(context).pop(cityInfo);
  }

  /// 显示搜索模式选择器
  void _showSearchModeSelector() {
    // 获取切换按钮的位置和尺寸
    final RenderBox? renderBox = _switchButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final offset = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;
    
    showMenu<SearchMode>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx, // 按钮左边位置
        offset.dy + buttonSize.height + 2, // 按钮底部位置 + 2px间距
        offset.dx + buttonSize.width, // 按钮右边位置，确保宽度一致
        offset.dy + buttonSize.height + 150, // 底部位置
      ),
      items: SearchMode.values.map((mode) => PopupMenuItem<SearchMode>(
        value: mode,
        height: 36, // 减少高度
        child: Container(
          width: buttonSize.width - 16, // 与按钮宽度一致，减去内边距
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mode.displayName,
                style: TextStyle(
                  color: mode == _currentSearchMode ? CPColors.leiMuBlue : CupertinoColors.label,
                  fontWeight: mode == _currentSearchMode ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              if (mode == _currentSearchMode) ...[
                const Spacer(),
                Icon(
                  CupertinoIcons.checkmark,
                  size: 12,
                  color: CPColors.leiMuBlue,
                ),
              ],
            ],
          ),
        ),
      )).toList(),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ).then((selectedMode) {
      if (selectedMode != null && selectedMode != _currentSearchMode) {
        _switchSearchMode(selectedMode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Column(
          children: [
            // 搜索栏
            _buildSearchBar(),
            // 搜索结果
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.withOpacity(0.95),
        border: const Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 搜索模式切换按钮
          GestureDetector(
            key: _switchButtonKey, // 添加Key
            onTap: _showSearchModeSelector,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: CPColors.leiMuBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: CPColors.leiMuBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentSearchMode.displayName,
                    style: TextStyle(
                      color: CPColors.leiMuBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    CupertinoIcons.chevron_down,
                    color: CPColors.leiMuBlue,
                    size: 10,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 搜索输入框
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CupertinoTextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                placeholder: '搜索${_currentSearchMode.displayName}',
                placeholderStyle: const TextStyle(
                  color: CupertinoColors.placeholderText,
                  fontSize: 16,
                ),
                style: const TextStyle(fontSize: 16),
                decoration: null,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    CupertinoIcons.search,
                    color: CupertinoColors.placeholderText,
                    size: 18,
                  ),
                ),
                suffix: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: _clearSearch,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            CupertinoIcons.clear_circled_solid,
                            color: CupertinoColors.placeholderText,
                            size: 18,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          
          const SizedBox(width: 6),
          
          // 取消按钮
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            minSize: 28,
            onPressed: () => GoRouter.of(context).pop(),
            child: const Text(
              '取消',
              style: TextStyle(
                fontSize: 14,
                color: CPColors.leiMuBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults() {
    if (!_hasSearched) {
      return _buildEmptyState('输入关键词开始搜索', CupertinoIcons.search);
    }

    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 15),
            SizedBox(height: 16),
            Text(
              '搜索中...',
              style: TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState('未找到相关结果', CupertinoIcons.exclamationmark_circle);
    }

    return FadeTransition(
      opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final cityInfo = _searchResults[index];
          final isLast = index == _searchResults.length - 1;
          
          return _buildSearchResultItem(cityInfo, isLast);
        },
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 40,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            text,
            style: CPTextStyles.s16.build(),
          ),
        ],
      ),
    );
  }

  /// 构建搜索结果项
  Widget _buildSearchResultItem(CityInfo cityInfo, bool isLast) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(isLast ? 12 : 0),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: CupertinoListTile(
        onTap: () => _selectSearchResult(cityInfo),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _currentSearchMode == SearchMode.city
                ? CPColors.leiMuBlue.withOpacity(0.1)
                : CupertinoColors.systemOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _currentSearchMode == SearchMode.city 
              ? CupertinoIcons.location 
              : CupertinoIcons.map_pin_ellipse,
            color: _currentSearchMode == SearchMode.city
                ? CPColors.leiMuBlue
                : CupertinoColors.systemOrange,
            size: 16,
          ),
        ),
        title: Text(
          cityInfo.city,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text(
          '${cityInfo.province} ${cityInfo.district}',
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.secondaryLabel,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: const Icon(
          CupertinoIcons.add_circled,
          color: CPColors.leiMuBlue,
          size: 20,
        ),
      ),
    );
  }
}
