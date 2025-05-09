import 'package:flutter/material.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/core/utils/widget_size_helper.dart';

/// 响应式小组件基类
/// 根据设备自动调整尺寸，适用于创建类似iOS小组件的界面组件
class ResponsiveWidget extends StatelessWidget {
  /// 小组件类型，决定尺寸大小
  final WidgetType widgetType;
  
  /// 小组件背景颜色
  final Color? backgroundColor;
  
  /// 边框圆角大小
  final double borderRadius;
  
  /// 是否显示阴影
  final bool showShadow;
  
  /// 内容构建器，用于构建小组件内部内容
  final Widget Function(BuildContext context, Size size)? contentBuilder;
  
  /// 小组件内容
  final Widget? child;
  
  /// 内边距
  final EdgeInsetsGeometry? padding;
  
  /// 响应式小组件构造函数
  const ResponsiveWidget({
    Key? key,
    required this.widgetType,
    this.backgroundColor,
    this.borderRadius = 16.0,
    this.showShadow = true,
    this.contentBuilder,
    this.child,
    this.padding,
  }) : assert(contentBuilder != null || child != null, '必须提供contentBuilder或child'),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    // 计算适合当前设备的尺寸
    final widgetSize = WidgetSizeHelper.getPreciseWidgetSize(context, widgetType);
    
    return Container(
      width: widgetSize.width,
      height: widgetSize.height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: contentBuilder != null 
          ? contentBuilder!(context, widgetSize) 
          : child,
    );
  }
}

/// 示例用法 - 时钟小组件
class ClockWidget extends StatelessWidget {
  /// 小组件类型
  final WidgetType widgetType;
  
  /// 时间文本
  final String timeText;
  
  /// 日期文本
  final String dateText;
  
  /// 农历文本
  final String lunarText;
  
  /// 构造函数
  const ClockWidget({
    Key? key,
    required this.widgetType,
    required this.timeText,
    required this.dateText,
    required this.lunarText,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      widgetType: widgetType,
      contentBuilder: (context, size) {
        // 根据组件尺寸调整内容布局
        switch (widgetType) {
          case WidgetType.small:
            return _buildSmallClock();
          case WidgetType.medium:
            return _buildMediumClock();
          case WidgetType.large:
            return _buildLargeClock();
        }
      },
    );
  }
  
  /// 构建小尺寸时钟
  Widget _buildSmallClock() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(timeText, style: CPTextStyles.s20.bold.c(CPColors.black)),
          const SizedBox(height: 4),
          Text(dateText, style: CPTextStyles.s8.bold.c(CPColors.black)),
        ],
      ),
    );
  }
  
  /// 构建中尺寸时钟
  Widget _buildMediumClock() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateText, style: CPTextStyles.s10.bold.c(CPColors.black)),
              Text(lunarText, style: CPTextStyles.s10.bold.c(CPColors.black)),
            ],
          ),
          const SizedBox(height: 8),
          Text(timeText, style: CPTextStyles.s36.bold.italic.c(CPColors.black)),
        ],
      ),
    );
  }
  
  /// 构建大尺寸时钟
  Widget _buildLargeClock() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(timeText, style: CPTextStyles.s36.bold.italic.c(CPColors.black)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(dateText, style: CPTextStyles.s14.bold.c(CPColors.black)),
              const SizedBox(width: 12),
              Text(lunarText, style: CPTextStyles.s14.bold.c(CPColors.black)),
            ],
          ),
          const Spacer(),
          // 底部可以放其他信息，如天气等
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text("天气晴朗", style: CPTextStyles.s12.c(CPColors.black)),
          ),
        ],
      ),
    );
  }
} 