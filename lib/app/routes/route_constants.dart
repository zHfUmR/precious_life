/// 定义App中所有路由常量
/// 设计理念：集中管理路由名称、防止路由名称拼写错误、便于IDE智能提示和重构
class AppRoutes {
  AppRoutes._();
  static const String home = '/';
  static const String homeTodo = '/home/todo';
  static const String homeFeed = '/home/feed';
  static const String homeTools = '/home/tools';
  static const String widgetShowcase = '/widget-showcase';
}
