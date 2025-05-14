import 'dart:math';

import 'package:flutter/material.dart';
import 'package:precious_life/config/color_style.dart';

class CountdownModule extends StatefulWidget {
  const CountdownModule({super.key});

  @override
  State<CountdownModule> createState() => _CountdownModuleState();
}

class _CountdownModuleState extends State<CountdownModule> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ColorCircleEntity> entities;

  @override
  void initState() {
    DateTime birthday = DateTime(1993, 10, 6); // 生日
    DateTime today = DateTime.now(); // 今天
    int lifeSumDays = 73 * 365; // 假设成年男性能活到73岁，转换为对应总天数
    int lifeDays = today.difference(birthday).inDays;
    int yearSumDays = today.year % 4 == 0 ? 366 : 365; // 今年总天数
    int yearDays = today.difference(DateTime(today.year, 1, 1)).inDays; // 今年已过天数
    int monthSumDays = DateTime(today.year, today.month + 1, 0).day; // 本月总天数
    int monthDays = today.day; // 本月已过天数
    entities = [
      ColorCircleEntity(
        name: '人生',
        startColor: CPColors.progressBlueStart,
        endColor: CPColors.progressBlueEnd,
        progressValue: lifeDays,
        totalValue: lifeSumDays,
      ),
      ColorCircleEntity(
        name: '今年',
        startColor: CPColors.progressPinkStart,
        endColor: CPColors.progressPinkEnd,
        progressValue: yearDays,
        totalValue: yearSumDays,
      ),
      ColorCircleEntity(
        name: '本月',
        startColor: CPColors.progressGreenStart,
        endColor: CPColors.progressGreenEnd,
        progressValue: monthDays,
        totalValue: monthSumDays,
      ),
    ];
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..forward()
      ..drive(CurveTween(curve: Curves.easeInOutCubic));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RepaintBoundary(
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: ColorCircleProgressPainter(entities, _controller),
          ),
        );
      },
    );
  }
}

class ColorCircleProgressPainter extends CustomPainter {
  late double width;
  late double height;
  final List<ColorCircleEntity> entities; // 数据实体
  final Animation<double> repaint; // 动画

  ColorCircleProgressPainter(this.entities, this.repaint) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    width = size.width;
    height = size.height;
    
    const horizontalPadding = 10.0; // 水平间隔
    const spaceDistance = 15.0; // 元素间距

    // 水平布局参数
    int itemCount = entities.length; // 总项数

    // 计算每个圆环的尺寸和位置
    double itemWidth = (width - horizontalPadding * 2 - spaceDistance * (itemCount - 1)) / itemCount;
    double circleRadius = min(itemWidth, height / 2) / 2 - 5;
    const circleStrokeWidth = 5.0;

    for (int i = 0; i < entities.length; i++) {
      final entity = entities[i];
      final progressValue = (entity.progressValue / entity.totalValue) * repaint.value;
      if (progressValue > 1) throw Exception('进度值不能大于总值');

      // 计算当前项的水平位置
      double itemStartX = horizontalPadding + i * (itemWidth + spaceDistance);

      // 圆心位置 - 水平居中，垂直在画布中央
      Offset circleCenterPosition = Offset(
        itemStartX + itemWidth / 2,
        height / 2, // 将圆心位置改为垂直居中
      );

      // 绘制圆环
      const startAngle = -pi / 2;
      final sweepAngle = 2 * pi * (1 - progressValue);

      // 背景圆圈
      final bgPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = circleStrokeWidth
        ..color = entity.startColor.withOpacity(0.2);
      canvas.drawArc(
          Rect.fromCircle(center: circleCenterPosition, radius: circleRadius), startAngle, 2 * pi, false, bgPaint);

      // 进度百分比
      final percentPainter = TextPainter(
        text: TextSpan(
          text: '${(progressValue * 100).toStringAsFixed(0)}%',
          style: const TextStyle(color: CPColors.darkGrey, fontSize: 8),
        ),
        textDirection: TextDirection.ltr,
      );
      percentPainter.layout();
      percentPainter.paint(
        canvas,
        Offset(
          circleCenterPosition.dx - percentPainter.width / 2,
          circleCenterPosition.dy - percentPainter.height / 2,
        ),
      );

      // 进度圆圈
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..shader = LinearGradient(
          colors: [entity.startColor, entity.endColor],
        ).createShader(Rect.fromCircle(
          center: circleCenterPosition,
          radius: circleRadius,
        ));
      canvas.drawArc(
        Rect.fromCircle(center: circleCenterPosition, radius: circleRadius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );

      // 文字尺寸
      double nameTextSize = 10.0; // 减小name字体大小
      double progressTextSize = nameTextSize - 1;

      // 绘制名称 - 在圆环上方
      final namePainter = TextPainter(
        text: TextSpan(
          text: entity.name,
          style: TextStyle(color: entity.startColor, fontSize: nameTextSize, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      namePainter.layout();
      namePainter.paint(
        canvas,
        Offset(
          circleCenterPosition.dx - namePainter.width / 2,
          circleCenterPosition.dy - circleRadius - namePainter.height - 5,
        ),
      );

      // 绘制进度值 - 在圆环下方
      final progressPainter = TextPainter(
        text: TextSpan(
          text: '${entity.progressValue}/${entity.totalValue}',
          style: TextStyle(color: CPColors.darkGrey, fontSize: progressTextSize, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      progressPainter.layout();
      progressPainter.paint(
        canvas,
        Offset(
          circleCenterPosition.dx - progressPainter.width / 2,
          circleCenterPosition.dy + circleRadius + 8,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 颜色圆环实体
class ColorCircleEntity {
  final String name;
  final Color startColor;
  final Color endColor;
  final int progressValue;
  final int totalValue;

  const ColorCircleEntity({
    required this.name,
    required this.progressValue,
    required this.totalValue,
    required this.startColor,
    required this.endColor,
  });
}
