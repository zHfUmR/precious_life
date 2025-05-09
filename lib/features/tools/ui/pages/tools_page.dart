import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 工具页面
class ToolsPage extends ConsumerWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        color: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 工具卡片组件
class ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback? onTap;

  const ToolCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 工具模型
class Tool {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String? route;

  const Tool({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.route,
  });
}

/// 工具列表
final List<Tool> _tools = [
  Tool(
    icon: Icons.calculate_outlined,
    title: '计算器',
    description: '简单的计算工具',
    color: Colors.blue,
    route: '/tools/calculator',
  ),
  Tool(
    icon: Icons.timer_outlined,
    title: '计时器',
    description: '倒计时和秒表',
    color: Colors.orange,
    route: '/tools/timer',
  ),
  Tool(
    icon: Icons.water_drop_outlined,
    title: '喝水提醒',
    description: '定时提醒补充水分',
    color: Colors.cyan,
    route: '/tools/water_reminder',
  ),
  Tool(
    icon: Icons.note_alt_outlined,
    title: '便签',
    description: '快速记录想法',
    color: Colors.green,
    route: '/tools/notes',
  ),
  Tool(
    icon: Icons.today_outlined,
    title: '日历',
    description: '日期查询与日程安排',
    color: Colors.purple,
    route: '/tools/calendar',
  ),
  Tool(
    icon: Icons.format_quote_outlined,
    title: '每日一句',
    description: '激励人心的名言',
    color: Colors.pink,
    route: '/tools/quotes',
  ),
  Tool(
    icon: Icons.directions_run,
    title: '运动记录',
    description: '记录每日运动情况',
    color: Colors.teal,
    route: '/tools/exercise',
  ),
  Tool(
    icon: Icons.shopping_bag_outlined,
    title: '购物清单',
    description: '创建购物计划',
    color: Colors.amber,
    route: '/tools/shopping_list',
  ),
]; 