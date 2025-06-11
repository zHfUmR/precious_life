import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:precious_life/app/routes/route_constants.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/features/todo/ui/models/followed_point.dart';
import 'package:precious_life/features/todo/ui/providers/weather_card_vm.dart';
import 'package:precious_life/shared/widgets/loading_status_widget.dart';

/// 天气关注设置页面
/// 用于配置天气显示的城市信息
class WeatherFollowedSettingsPage extends ConsumerStatefulWidget {
  const WeatherFollowedSettingsPage({super.key});

  @override
  ConsumerState<WeatherFollowedSettingsPage> createState() => _WeatherFollowedSettingsPageState();
}

class _WeatherFollowedSettingsPageState extends ConsumerState<WeatherFollowedSettingsPage>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  final ValueNotifier<int?> _swipedIndexNotifier = ValueNotifier<int?>(null);
  late final WeatherCardVm _weatherCardVm;
  late final ValueNotifier<LoadingStatus> _loadingStatusNotifier;

  @override
  void initState() {
    super.initState();
    _weatherCardVm = ref.read(weatherCardVmProvider.notifier);
    _loadingStatusNotifier = ValueNotifier<LoadingStatus>(LoadingStatus.loading);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _animationController?.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _swipedIndexNotifier.dispose();
    _loadingStatusNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherCardVmProvider);
    // 根据followedWeather的状态设置loadingStatus
    final followedWeather = weatherState.weatherFollowedState.followedWeather;
    if (followedWeather == null || followedWeather.isEmpty == true) {
      _loadingStatusNotifier.value = LoadingStatus.noData;
    } else {
      _loadingStatusNotifier.value = LoadingStatus.success;
    }
    return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.systemBackground.withOpacity(0.8),
          border: null,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => GoRouter.of(context).pop(),
            child: Text(
              '返回',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          middle: Text(
            '关注设置',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => GoRouter.of(context).push(AppRoutes.weatherFollowedSearch),
            child: const Icon(
              CupertinoIcons.add,
              size: 18,
              color: CPColors.leiMuBlue,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: LoadingStatusWidget(
              status: _loadingStatusNotifier.value,
              loadingMessage: '加载中...',
              onRetry: () => _weatherCardVm.loadFollowedWeather(),
              errorMessage: '加载失败',
              child: FadeTransition(
                opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                child: CustomScrollView(
                  slivers: [
                    // 关注城市列表
                    _buildFollowedCitiesList(),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  /// 构建关注城市列表
  Widget _buildFollowedCitiesList() {
    final weatherState = ref.watch(weatherCardVmProvider);
    final followedWeather = weatherState.weatherFollowedState.followedWeather;
    if (followedWeather == null || followedWeather.isEmpty) {
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '点击上方按钮搜索并添加城市',
                style: Theme.of(context).textTheme.bodyMedium,
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
                      '关注数',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${followedWeather.length}个',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              // 分割线
              Container(
                height: 0.5,
                color: CupertinoColors.separator.withOpacity(0.5),
              ),
              // 城市列表
              GestureDetector(
                onTap: () {
                  // 点击空白区域关闭已滑开的项
                  if (_swipedIndexNotifier.value != null) {
                    _swipedIndexNotifier.value = null;
                  }
                },
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: followedWeather.length,
                  onReorder: (oldIndex, newIndex) {
                    // 重新排序时关闭已滑开的项
                    if (_swipedIndexNotifier.value != null) _swipedIndexNotifier.value = null;
                    _weatherCardVm.refreshFollowedPoints(followedWeather);
                  },
                  itemBuilder: (context, index) {
                    final point = followedWeather[index];
                    final isLast = index == followedWeather.length - 1;

                    return Container(
                      key: Key('${point.point.uniqueId}_$index'),
                      child: _buildCityItem(point.point, index, isLast),
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
  Widget _buildCityItem(FollowedPoint point, int index, bool isLast) {
    return ValueListenableBuilder<int?>(
      valueListenable: _swipedIndexNotifier,
      builder: (context, swipedIndex, child) {
        final isSwipedOpen = swipedIndex == index;

        return GestureDetector(
          onTap: () {
            if (isSwipedOpen) {
              // 如果当前项已经滑开，点击关闭
              _swipedIndexNotifier.value = null;
            } else {
              // 关闭其他已滑开的项
              if (_swipedIndexNotifier.value != null) {
                _swipedIndexNotifier.value = null;
              }
            }
          },
          onHorizontalDragUpdate: (details) {
            // 检测左滑手势
            if (details.delta.dx < -2) {
              // 左滑，显示删除按钮
              if (_swipedIndexNotifier.value != index) {
                _swipedIndexNotifier.value = index;
              }
            } else if (details.delta.dx > 2) {
              // 右滑，关闭删除按钮
              if (_swipedIndexNotifier.value == index) {
                _swipedIndexNotifier.value = null;
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
                        _swipedIndexNotifier.value = null;
                        _weatherCardVm.deleteFollowedPoint(point.uniqueId);
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
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBackground,
                      borderRadius: isLast
                          ? const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            )
                          : BorderRadius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // 图标
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: CPColors.leiMuBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              CupertinoIcons.location_solid,
                              color: CPColors.leiMuBlue,
                              size: 12,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // 文本内容
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  // 根据poiName是否为空决定显示内容
                                  (point.poiName == null || point.poiName!.isEmpty) 
                                    ? (point.city ?? '未知城市')
                                    : point.poiName!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: CupertinoColors.label,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  // 根据poiName是否为空决定显示内容  
                                  (point.poiName == null || point.poiName!.isEmpty)
                                    ? (point.district ?? '未知区县')
                                    : (point.poiAddress ?? '未知地址'),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: CupertinoColors.secondaryLabel,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          // 拖拽图标
                          const Icon(
                            CupertinoIcons.line_horizontal_3,
                            color: CupertinoColors.systemGrey,
                            size: 14,
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
      },
    );
  }
}
