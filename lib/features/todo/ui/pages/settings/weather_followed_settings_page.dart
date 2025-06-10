import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/features/todo/data/models/weather_card_state.dart';
import 'package:precious_life/features/todo/ui/models/followed_point.dart';
import 'package:precious_life/features/todo/ui/providers/weather_card_vm.dart';
import 'package:precious_life/app/routes/route_constants.dart';

/// 天气关注点设置页面
/// 用于配置天气显示的关注点信息
class WeatherFollowedSettingsPage extends ConsumerStatefulWidget {
  const WeatherFollowedSettingsPage({super.key});

  @override
  ConsumerState<WeatherFollowedSettingsPage> createState() => _WeatherFollowedSettingsPageState();
}

class _WeatherFollowedSettingsPageState extends ConsumerState<WeatherFollowedSettingsPage>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  final ValueNotifier<int?> _swipedIndexNotifier = ValueNotifier<int?>(null); // 使用ValueNotifier记录当前被滑动的项目索引
  late WeatherCardVm _weatherCardVm;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _weatherCardVm = ref.read(weatherCardVmProvider.notifier);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _swipedIndexNotifier.dispose();
    super.dispose();
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
          onPressed: () => GoRouter.of(context).pop(),
          child: const Text(
            '返回',
            style: TextStyle(fontSize: 16),
          ),
        ),
        middle: const Text(
          '关注点编辑',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => GoRouter.of(context).push(AppRoutes.weatherFollowedSearch),
          child: const Text(
            '添加',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [_buildFollowedPointsList()],
        ),
      ),
    );
  }

  /// 构建关注点列表
  Widget _buildFollowedPointsList() {
    final followedPoints = ref.watch(weatherCardVmProvider).weatherFollowedState.followedWeather ?? [];
    if (followedPoints.isEmpty) {
      return SliverFillRemaining(
        child: GestureDetector(
          onTap: () => GoRouter.of(context).push(AppRoutes.weatherFollowedSearch),
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
                  '暂无关注的点',
                  style: CPTextStyles.s18.bold.build(),
                ),
                const SizedBox(height: 8),
                Text(
                  '点击上方按钮添加关注点',
                  style: CPTextStyles.s14.build(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                      '我的关注点',
                      style: CPTextStyles.s16.bold.build(),
                    ),
                    const Spacer(),
                    Text(
                      '${followedPoints.length}个',
                      style: CPTextStyles.s14.build(),
                    ),
                  ],
                ),
              ),
              // 点列表
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
                  itemCount: followedPoints.length,
                  onReorder: (oldIndex, newIndex) {
                    // 重新排序时关闭已滑开的项
                    if (_swipedIndexNotifier.value != null) _swipedIndexNotifier.value = null;
                    // 重新排序逻辑
                    if (newIndex > oldIndex) newIndex--;
                    final reorderedList = List<WeatherCardFollowedWeather>.from(followedPoints);
                    final item = reorderedList.removeAt(oldIndex);
                    reorderedList.insert(newIndex, item);
                    _weatherCardVm.updateFollowedPoints(reorderedList.map((e) => e.point).toList());
                  },
                  itemBuilder: (context, index) {
                    final followedPoint = followedPoints[index];
                    final isLast = index == followedPoints.length - 1;
                    return Container(
                      key: Key(followedPoint.point.code ?? ''),
                      child: _buildPointItem(followedPoint.point, index, isLast),
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

  /// 获取圆角配置
  BorderRadius _getBorderRadius(bool isFirst, bool isLast) {
    if (isFirst && isLast) {
      // 只有一个项目时，四个角都要圆角
      return BorderRadius.circular(12);
    } else if (isFirst) {
      // 第一个项目，只有顶部圆角
      return const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      );
    } else if (isLast) {
      // 最后一个项目，只有底部圆角
      return const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    } else {
      // 中间项目，无圆角
      return BorderRadius.zero;
    }
  }

  /// 获取删除按钮的圆角配置
  BorderRadius _getDeleteButtonBorderRadius(bool isFirst, bool isLast) {
    if (isFirst && isLast) {
      // 只有一个项目时，右侧圆角
      return const BorderRadius.only(
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    } else if (isFirst) {
      // 第一个项目，只有右上角圆角
      return const BorderRadius.only(
        topRight: Radius.circular(12),
      );
    } else if (isLast) {
      // 最后一个项目，只有右下角圆角
      return const BorderRadius.only(
        bottomRight: Radius.circular(12),
      );
    } else {
      // 中间项目，无圆角
      return BorderRadius.zero;
    }
  }

  /// 构建关注点项
  Widget _buildPointItem(FollowedPoint point, int index, bool isLast) {
    final isFirst = index == 0;

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
              // 关闭其他已滑开的项，然后执行正常点击
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
              borderRadius: _getBorderRadius(isFirst, isLast),
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
                        _weatherCardVm.updateFollowedPoints(ref.read(weatherCardVmProvider).weatherFollowedState.followedWeather?.where((e) => e.point.code != point.code).map((e) => e.point).toList() ?? []);
                      },
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: CupertinoColors.destructiveRed,
                          borderRadius: _getDeleteButtonBorderRadius(isFirst, isLast),
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
                          CupertinoIcons.map_pin_ellipse,
                          color: CPColors.leiMuBlue,
                          size: 16,
                        ),
                      ),
                      title: Text(
                        point.simpleDisplayName,
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
      },
    );
  }
}
