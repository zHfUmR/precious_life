import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/core/utils/widget_size_helper.dart';
import 'package:precious_life/core/widgets/responsive_widget.dart';

/// 小组件展示页面
/// 用于展示不同尺寸的响应式小组件
class WidgetShowcasePage extends ConsumerStatefulWidget {
  /// 路由名称
  static const routeName = '/widget-showcase';

  const WidgetShowcasePage({Key? key}) : super(key: key);

  @override
  ConsumerState<WidgetShowcasePage> createState() => _WidgetShowcasePageState();
}

class _WidgetShowcasePageState extends ConsumerState<WidgetShowcasePage> {
  final DateTime _now = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('小组件尺寸展示'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('小尺寸组件 (Small Widget)', style: CPTextStyles.s16.bold.c(CPColors.black)),
            const SizedBox(height: 16),
            _buildWidgetContainer(
              child: ClockWidget(
                widgetType: WidgetType.small,
                timeText: _formatTime(_now),
                dateText: _formatDate(_now),
                lunarText: '农历九月初九',
              ),
            ),
            
            const SizedBox(height: 32),
            Text('中尺寸组件 (Medium Widget)', style: CPTextStyles.s16.bold.c(CPColors.black)),
            const SizedBox(height: 16),
            _buildWidgetContainer(
              child: ClockWidget(
                widgetType: WidgetType.medium,
                timeText: _formatTime(_now),
                dateText: _formatDate(_now),
                lunarText: '农历九月初九',
              ),
            ),
            
            const SizedBox(height: 32),
            Text('大尺寸组件 (Large Widget)', style: CPTextStyles.s16.bold.c(CPColors.black)),
            const SizedBox(height: 16),
            _buildWidgetContainer(
              child: ClockWidget(
                widgetType: WidgetType.large,
                timeText: _formatTime(_now),
                dateText: _formatDate(_now),
                lunarText: '农历九月初九',
              ),
            ),
            
            const SizedBox(height: 32),
            Text('自定义响应式组件', style: CPTextStyles.s16.bold.c(CPColors.black)),
            const SizedBox(height: 16),
            _buildWidgetContainer(
              child: ResponsiveWidget(
                widgetType: WidgetType.medium,
                backgroundColor: Colors.blue[50],
                contentBuilder: (context, size) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('宽度: ${size.width.toStringAsFixed(1)}', 
                             style: CPTextStyles.s14.c(CPColors.black)),
                        Text('高度: ${size.height.toStringAsFixed(1)}', 
                             style: CPTextStyles.s14.c(CPColors.black)),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),
            Text('屏幕信息', style: CPTextStyles.s16.bold.c(CPColors.black)),
            const SizedBox(height: 8),
            _buildScreenInfo(),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
  
  /// 构建组件容器（添加居中和背景）
  Widget _buildWidgetContainer({required Widget child}) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
  
  /// 构建屏幕信息显示
  Widget _buildScreenInfo() {
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('屏幕宽度: ${size.width.toStringAsFixed(1)} pts', 
                style: CPTextStyles.s14.c(CPColors.black)),
            Text('屏幕高度: ${size.height.toStringAsFixed(1)} pts', 
                style: CPTextStyles.s14.c(CPColors.black)),
            Text('设备像素比: ${pixelRatio.toStringAsFixed(2)}', 
                style: CPTextStyles.s14.c(CPColors.black)),
            Text('物理像素宽度: ${(size.width * pixelRatio).toStringAsFixed(1)} px', 
                style: CPTextStyles.s14.c(CPColors.black)),
            Text('物理像素高度: ${(size.height * pixelRatio).toStringAsFixed(1)} px', 
                style: CPTextStyles.s14.c(CPColors.black)),
          ],
        ),
      ),
    );
  }
  
  /// 格式化时间
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  /// 格式化日期
  String _formatDate(DateTime dateTime) {
    final month = dateTime.month;
    final day = dateTime.day;
    final weekday = _getWeekdayString(dateTime.weekday);
    return '$month月$day日 $weekday';
  }
  
  /// 获取星期字符串
  String _getWeekdayString(int weekday) {
    switch (weekday) {
      case 1: return '星期一';
      case 2: return '星期二';
      case 3: return '星期三';
      case 4: return '星期四';
      case 5: return '星期五';
      case 6: return '星期六';
      case 7: return '星期日';
      default: return '';
    }
  }
} 