import 'package:flutter/material.dart';

/// 小组件类型枚举
enum WidgetType {
  /// 小尺寸组件
  small,
  
  /// 中尺寸组件
  medium,
  
  /// 大尺寸组件
  large,
}

/// 小组件尺寸计算工具类
/// 提供了根据设备屏幕动态计算不同尺寸小组件的方法
class WidgetSizeHelper {
  /// 根据设备屏幕计算小组件尺寸
  /// @param context 构建上下文
  /// @param widgetType 小组件类型（小、中、大）
  /// @return 返回计算后的尺寸Size
  static Size calculateWidgetSize(BuildContext context, WidgetType widgetType) {
    // 获取屏幕尺寸
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    
    // 定义基础比例配置
    // 这些比例是根据iPhone基础尺寸计算的近似值
    double smallWidthRatio = 0.4; // 小组件宽度约占屏幕宽度的40%
    double mediumWidthRatio = 0.85; // 中组件宽度约占屏幕宽度的85%
    double largeWidthRatio = 0.85; // 大组件宽度约占屏幕宽度的85%
    
    // 高度比例
    double smallHeightRatio = 0.4; // 小组件是正方形
    double mediumHeightRatio = 0.4; // 中组件高度约为宽度的一半
    double largeHeightRatio = 0.9; // 大组件高度约为宽度的两倍
    
    // 根据组件类型返回对应尺寸
    switch (widgetType) {
      case WidgetType.small:
        double size = width * smallWidthRatio;
        return Size(size, size); // 小组件是正方形
        
      case WidgetType.medium:
        double widgetWidth = width * mediumWidthRatio;
        return Size(widgetWidth, widgetWidth * mediumHeightRatio);
        
      case WidgetType.large:
        double widgetWidth = width * largeWidthRatio;
        return Size(widgetWidth, widgetWidth * largeHeightRatio);
    }
  }
  
  /// 根据设备型号获取更精确的小组件尺寸
  /// 参考iOS原生小组件尺寸规格
  /// @param context 构建上下文
  /// @param widgetType 小组件类型
  /// @return 返回针对特定设备优化的尺寸
  static Size getPreciseWidgetSize(BuildContext context, WidgetType widgetType) {
    // 获取设备像素比
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    // 获取屏幕物理尺寸
    final physicalScreenSize = MediaQuery.of(context).size * pixelRatio;
    
    // 判断设备类型并返回对应尺寸
    // 参考了iOS设备的常见分辨率
    if (isIPhoneProMax(physicalScreenSize)) {
      // iPhone Pro Max系列 (约1284 x 2778)
      switch (widgetType) {
        case WidgetType.small: return const Size(170, 170);
        case WidgetType.medium: return const Size(364, 170);
        case WidgetType.large: return const Size(364, 382);
      }
    } else if (isIPhonePro(physicalScreenSize)) {
      // iPhone Pro系列 (约1170 x 2532)
      switch (widgetType) {
        case WidgetType.small: return const Size(158, 158);
        case WidgetType.medium: return const Size(338, 158);
        case WidgetType.large: return const Size(338, 354);
      }
    } else if (isIPhoneMini(physicalScreenSize)) {
      // iPhone Mini系列 (约1080 x 2340)
      switch (widgetType) {
        case WidgetType.small: return const Size(155, 155);
        case WidgetType.medium: return const Size(329, 155);
        case WidgetType.large: return const Size(329, 345);
      }
    } else if (isIPhoneClassic(physicalScreenSize)) {
      // iPhone 经典尺寸 (约750 x 1334)
      switch (widgetType) {
        case WidgetType.small: return const Size(148, 148);
        case WidgetType.medium: return const Size(321, 148);
        case WidgetType.large: return const Size(321, 324);
      }
    } else if (isIPhonePlus(physicalScreenSize)) {
      // iPhone Plus系列 (约1080 x 1920)
      switch (widgetType) {
        case WidgetType.small: return const Size(157, 157);
        case WidgetType.medium: return const Size(348, 157);
        case WidgetType.large: return const Size(348, 351);
      }
    } else {
      // 其他设备使用基本计算
      return calculateWidgetSize(context, widgetType);
    }
  }
  
  /// 判断设备是否为iPhone Pro Max系列
  static bool isIPhoneProMax(Size physicalSize) {
    // iPhone Pro Max的分辨率范围检查
    return physicalSize.width >= 1250 && physicalSize.width <= 1300 &&
           physicalSize.height >= 2700 && physicalSize.height <= 2800;
  }
  
  /// 判断设备是否为iPhone Pro系列
  static bool isIPhonePro(Size physicalSize) {
    // iPhone Pro的分辨率范围检查
    return physicalSize.width >= 1150 && physicalSize.width <= 1200 &&
           physicalSize.height >= 2500 && physicalSize.height <= 2600;
  }
  
  /// 判断设备是否为iPhone Mini系列
  static bool isIPhoneMini(Size physicalSize) {
    // iPhone Mini的分辨率范围检查
    return physicalSize.width >= 1050 && physicalSize.width <= 1100 &&
           physicalSize.height >= 2300 && physicalSize.height <= 2400;
  }
  
  /// 判断设备是否为iPhone经典尺寸(6/7/8/SE2)
  static bool isIPhoneClassic(Size physicalSize) {
    // iPhone经典尺寸的分辨率范围检查
    return physicalSize.width >= 730 && physicalSize.width <= 770 &&
           physicalSize.height >= 1300 && physicalSize.height <= 1350;
  }
  
  /// 判断设备是否为iPhone Plus系列
  static bool isIPhonePlus(Size physicalSize) {
    // iPhone Plus系列的分辨率范围检查
    return physicalSize.width >= 1050 && physicalSize.width <= 1100 &&
           physicalSize.height >= 1900 && physicalSize.height <= 1950;
  }
} 