import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 屏幕工具类
/// 提供获取屏幕尺寸、屏幕适配等功能
class ScreenUtils {
  // 私有构造函数，防止外部实例化
  ScreenUtils._();

  // 屏幕宽度
  static double _screenWidth = 0;
  // 屏幕高度
  static double _screenHeight = 0;
  // 屏幕密度
  static double _pixelRatio = 0;
  // 状态栏高度
  static double _statusBarHeight = 0;
  // 底部安全区域高度
  static double _bottomBarHeight = 0;
  // 是否已初始化
  static bool _initialized = false;
  // 小组件宽度约占屏幕宽度的40%
  static const double _smallWidghtWidthRatio = 0.4;
  // 大组件宽度约占屏幕宽度的85%
  static const double _largeWidghtWidthRatio = 0.85;
  // 小组件宽度
  static double _smallWidghtWidth = 0;
  // 大组件宽度
  static double _largeWidghtWidth = 0;
  // 组件离屏幕边缘的距离
  static double get widgetEdgeDistance => (_screenWidth - _largeWidghtWidth) / 2;

  /// 初始化屏幕工具类
  /// 在应用启动时调用，通常在首个界面的build方法中
  static void initialize(BuildContext context) {
    if (_initialized) return;

    MediaQueryData mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _pixelRatio = mediaQuery.devicePixelRatio;
    _statusBarHeight = mediaQuery.padding.top;
    _bottomBarHeight = mediaQuery.padding.bottom;
    _smallWidghtWidth = _screenWidth * _smallWidghtWidthRatio;
    _largeWidghtWidth = _screenWidth * _largeWidghtWidthRatio;
    _initialized = true;
  }

  /// 获取屏幕宽度
  static double get screenWidth => _screenWidth;

  /// 获取屏幕高度
  static double get screenHeight => _screenHeight;

  /// 获取屏幕像素密度
  static double get pixelRatio => _pixelRatio;

  /// 获取状态栏高度
  static double get statusBarHeight => _statusBarHeight;

  /// 获取底部安全区域高度
  static double get bottomBarHeight => _bottomBarHeight;

  /// 获取屏幕内容区域高度(不包括状态栏和底部安全区域)
  static double get screenContentHeight => _screenHeight - _statusBarHeight - _bottomBarHeight;

  /// 根据屏幕宽度百分比获取宽度
  static double getWidthByPercent(double percent) => _screenWidth * percent;

  /// 根据屏幕高度百分比获取高度
  static double getHeightByPercent(double percent) => _screenHeight * percent;

  /// 获取小组件宽度
  static double get smallWidghtWidth => _smallWidghtWidth;

  /// 获取大组件宽度
  static double get largeWidghtWidth => _largeWidghtWidth;
}

/// 使用Riverpod提供屏幕尺寸信息的Provider
final screenUtilsProvider = Provider<ScreenUtilsNotifier>((ref) {
  return ScreenUtilsNotifier();
});

/// 屏幕尺寸信息的Notifier类
class ScreenUtilsNotifier {

  void initialize(BuildContext context) {
    ScreenUtils.initialize(context);
  }

  double get screenWidth => ScreenUtils.screenWidth;
  double get screenHeight => ScreenUtils.screenHeight;
  double get statusBarHeight => ScreenUtils.statusBarHeight;
  double get bottomBarHeight => ScreenUtils.bottomBarHeight;
  double get screenContentHeight => ScreenUtils.screenContentHeight;
  double get smallWidghtWidth => ScreenUtils.smallWidghtWidth;
  double get largeWidghtWidth => ScreenUtils.largeWidghtWidth;
  double getWidthByPercent(double percent) => ScreenUtils.getWidthByPercent(percent);
  double getHeightByPercent(double percent) => ScreenUtils.getHeightByPercent(percent);
}
