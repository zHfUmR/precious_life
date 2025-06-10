/// 定义App中所有路由常量
/// 设计理念：集中管理路由名称、防止路由名称拼写错误、便于IDE智能提示和重构
class AppRoutes {
  AppRoutes._();
  static const String home = '/';
  static const String homeTodo = '/home/todo';  // 首页-待办
  static const String homeFeed = '/home/feed';  // 首页-动态
  static const String homeTools = '/home/tools';  // 首页-工具
  static const String widgetShowcase = '/widget-showcase';  // 组件展示
  static const String weatherDetail = '/weather/detail';  // 天气-详情
  static const String weatherConfig = '/weather/config';  // 天气-配置设置
}
