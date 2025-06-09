import 'package:flutter/material.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';

/// 加载状态枚举
enum LoadingStatus {
  initial, // 初始状态
  loading, // 加载中
  failure, // 加载失败
  success, // 加载完成
  noData, // 无数据
}

/// 根据不同加载状态显示对应视图的组件
class LoadingStatusWidget extends StatelessWidget {
  /// 当前加载状态
  final LoadingStatus status;

  /// 加载成功时显示的内容
  final Widget child;

  /// 加载中时的提示文案  
  final String? loadingMessage;

  /// 加载失败时的错误信息
  final String? errorMessage;

  /// 点击重试按钮时的回调函数
  final VoidCallback? onRetry;

  /// 构造函数
  const LoadingStatusWidget({
    Key? key,
    required this.status,
    required this.child,
    this.loadingMessage,
    this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case LoadingStatus.initial:
        return _buildScrollableCenter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_outlined,
                color: CPColors.lightGrey,
                size: 20,
              ),
              const SizedBox(height: 8),
              Text(
                '准备加载...',
                style: CPTextStyles.s12.c(CPColors.lightGrey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      case LoadingStatus.loading:
        return _buildScrollableCenter(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CPColors.leiMuBlue),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              loadingMessage ?? '加载中...',
              style: CPTextStyles.s12.c(CPColors.lightGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ));
      case LoadingStatus.failure:
        return _buildScrollableCenter(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRetry,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage ?? '加载失败',
                  style: CPTextStyles.s12.c(CPColors.lightGrey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      case LoadingStatus.noData:
        return _buildScrollableCenter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inbox_outlined,
                color: CPColors.lightGrey,
                size: 20,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无数据',
                style: CPTextStyles.s12.c(CPColors.lightGrey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      case LoadingStatus.success:
        return child;
    }
  }

  /// 构建可滚动的居中容器
  /// 当约束宽高为无限大或者0时，设置默认最小宽高
  Widget _buildScrollableCenter({required Widget child}) => LayoutBuilder(
        builder: (context, constraints) {
          // 处理无限大或0值的约束
          final double minHeight =
              (constraints.maxHeight.isInfinite || constraints.maxHeight <= 0) ? 50 : constraints.maxHeight;
          final double minWidth =
              (constraints.maxWidth.isInfinite || constraints.maxWidth <= 0) ? 100 : constraints.maxWidth;
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: minHeight,
                minWidth: minWidth,
              ),
              child: Center(child: child),
            ),
          );
        },
      );
}
