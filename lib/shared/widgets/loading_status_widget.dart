import 'package:flutter/material.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';

/// 加载状态枚举
enum LoadingStatus {
  initial, // 初始状态
  loading, // 加载中
  failure, // 加载失败
  success, // 加载完成
}

/// 根据不同加载状态显示对应视图的组件
class LoadingStatusWidget extends StatelessWidget {
  /// 当前加载状态
  final LoadingStatus status;

  /// 加载成功时显示的内容
  final Widget child;

  /// 加载失败时的错误信息
  final String? errorMessage;

  /// 点击重试按钮时的回调函数
  final VoidCallback? onRetry;

  /// 构造函数
  const LoadingStatusWidget({
    Key? key,
    required this.status,
    required this.child,
    this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case LoadingStatus.initial:
        return const SizedBox.shrink();
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CPColors.leiMuBlue),
          ),
        );
      case LoadingStatus.failure:
        return GestureDetector(
          onTap: onRetry,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                ),
              ],
            ),
          ),
        );
      case LoadingStatus.success:
        return child;
    }
  }
}
