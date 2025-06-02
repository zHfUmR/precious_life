import 'log_utils.dart';

/// LogUtils 使用示例
///
/// 展示如何使用日志工具类的各种功能
class LogExample {
  static void runExamples() {
    // ============== 新的使用方式：直接静态调用 ==============

    // 基本日志输出 - 直接调用，无需获取实例
    LogUtils.d('这是一条Debug日志');
    LogUtils.i('这是一条Info日志');
    LogUtils.w('这是一条Warning日志');
    LogUtils.e('这是一条Error日志');
    LogUtils.v('这是一条Verbose日志');

    // 带自定义标签的日志
    LogUtils.d('网络请求开始', 'Network');
    LogUtils.i('用户登录成功', 'Auth');
    LogUtils.w('内存使用率较高', 'Performance');

    // 错误日志带异常信息
    try {
      throw Exception('这是一个测试异常');
    } catch (error, stackTrace) {
      LogUtils.e('发生了异常', 'Error', error, stackTrace);
    }

    // 测试长文本分段输出
    String longMessage =
        '这是一条非常长的日志消息，' * 20 + '用来测试自动分段功能是否正常工作。' + '当单行文本超过设定的最大长度时，会自动分成多段输出，' + '每段都会带有序号标识，方便查看完整的日志内容。';
    LogUtils.d(longMessage, 'LongText');

    // 测试多行文本输出
    String multiLineMessage = '''这是第一行
这是第二行
这是第三行，包含一些长内容：${'很长的内容 ' * 30}
这是第四行''';
    LogUtils.i(multiLineMessage, 'MultiLine');

    // 打印分割线
    LogUtils.printDivider();
    LogUtils.printDivider('配置示例');

    // JSON格式化输出
    Map<String, dynamic> testData = {
      'user': {
        'id': 12345,
        'name': '张三',
        'email': 'zhangsan@example.com',
        'roles': ['user', 'admin'],
        'settings': {'theme': 'dark', 'language': 'zh-CN', 'notifications': true}
      },
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0.0'
    };
    LogUtils.json(testData, 'UserData');

    // 配置修改示例
    LogUtils.printDivider('配置修改测试');

    // 修改配置 - 也是直接静态调用
    LogUtils.setShowTimestamp(false);
    LogUtils.i('关闭时间戳后的日志');

    LogUtils.setShowTimestamp(true);
    LogUtils.setMaxLineLength(50); // 设置更短的行长度来测试分段
    LogUtils.i('设置短行长度后的测试：' + '这是一段比较长的文本内容' * 3);

    // 恢复默认设置
    LogUtils.setMaxLineLength(800);
    LogUtils.i('恢复默认设置后的日志');

    LogUtils.printDivider('示例结束');
  }

  /// 演示在不同场景下的使用
  static Future<void> realWorldExamples() async {
    // ============== 真实场景使用示例 ==============

    // 网络请求日志
    LogUtils.i('开始请求用户信息', 'Network');
    LogUtils.d('请求URL: https://api.example.com/user/profile', 'Network');
    LogUtils.d('请求头: {"Authorization": "Bearer ***", "Content-Type": "application/json"}', 'Network');

    // 模拟网络响应
    Map<String, dynamic> response = {
      'code': 200,
      'message': 'success',
      'data': {
        'user_id': 123,
        'username': '测试用户',
        'profile': {'avatar': 'https://example.com/avatar.jpg', 'bio': '这是用户的个人简介'}
      }
    };
    LogUtils.json(response, 'NetworkResponse');

    // 数据库操作日志
    LogUtils.i('开始数据库查询', 'Database');
    LogUtils.d('SQL: SELECT * FROM users WHERE id = ? AND status = ?', 'Database');
    LogUtils.d('参数: [123, "active"]', 'Database');
    LogUtils.i('查询完成，返回1条记录', 'Database');

    // UI事件日志
    LogUtils.d('用户点击了登录按钮', 'UI');
    LogUtils.d('显示加载动画', 'UI');
    LogUtils.i('登录成功，跳转到主页', 'UI');

    // 错误处理日志
    try {
      // 模拟一个错误
      throw FormatException('JSON解析失败：格式不正确');
    } catch (error, stackTrace) {
      LogUtils.e('处理用户数据时发生错误', 'DataProcessor', error, stackTrace);
    }

    // 性能监控日志
    LogUtils.printDivider('性能监控');

    Stopwatch stopwatch = Stopwatch()..start();

    // 模拟一些操作
    await Future.delayed(Duration(milliseconds: 100));

    stopwatch.stop();
    LogUtils.i('操作耗时: ${stopwatch.elapsedMilliseconds}ms', 'Performance');

    // 内存使用情况（模拟）
    LogUtils.w('内存使用率: 75%', 'Memory');
    LogUtils.d('当前堆内存: 120MB / 512MB', 'Memory');
  }

  /// 展示不同的使用方式对比
  static void showUsageComparison() {
    LogUtils.printDivider('使用方式对比');

    // ✅ 推荐方式：直接静态调用
    LogUtils.i('这是推荐的使用方式 - 直接静态调用');
    LogUtils.d('无需创建实例，代码更简洁', 'Recommended');

    // ⚠️ 旧方式：通过实例调用（仍然支持）
    final log = LogUtils.instance;
    // 注意：现在实例上没有 d, i, w, e, v 方法了，都改为静态方法
    // 所以即使获取了实例，也需要使用静态方法

    // 或者使用简短形式获取实例
    final logI = LogUtils.I;
    // 同样，实例方法已移除，使用静态方法

    LogUtils.printDivider('配置示例');

    // 配置也是静态方法
    LogUtils.setTagPrefix('MyApp');
    LogUtils.i('修改标签前缀后的日志');

    LogUtils.setTagPrefix('PreciousLife'); // 恢复默认
    LogUtils.i('恢复默认标签前缀');
  }
}
