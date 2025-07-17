import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// 日志级别枚举
enum LogLevel {
  debug,
  info,
  warning,
  error,
  verbose,
}

/// 通用日志工具类
///
/// 功能特点：
/// - 单例模式实现
/// - 支持不同日志级别
/// - 自动分段输出长文本
/// - 支持颜色标识（Debug模式下）
/// - 可配置是否显示时间戳
/// - 可配置最大单行输出长度
/// - 支持直接静态调用：CPLog.d(), CPLog.i() 等
class CPLog {
  // 私有构造函数
  CPLog._();

  // 单例实例
  static CPLog? _instance;

  /// 获取单例实例
  static CPLog get instance {
    _instance ??= CPLog._();
    return _instance!;
  }

  /// 便捷访问方法
  static CPLog get I => instance;

  // 配置参数
  bool _enableLog = kDebugMode; // 默认只在Debug模式下启用
  bool _showTimestamp = true; // 是否显示时间戳
  int _maxLineLength = 800; // 单行最大长度，超过则分段
  String _tagPrefix = 'PreciousLife'; // 日志标签前缀

  // ANSI 颜色代码（仅在Debug模式下使用）
  static const String _colorReset = '\x1B[0m';
  static const String _colorRed = '\x1B[31m';
  static const String _colorGreen = '\x1B[32m';
  static const String _colorYellow = '\x1B[33m';
  static const String _colorBlue = '\x1B[34m';
  static const String _colorPurple = '\x1B[35m';
  static const String _colorCyan = '\x1B[36m';
  static const String _colorGray = '\x1B[37m';

  // ============== 静态方法 - 主要接口 ==============

  /// Debug级别日志
  static void d(String message, [String? tag]) {
    instance._log(LogLevel.debug, message, tag);
  }

  /// Info级别日志
  static void i(String message, [String? tag]) {
    instance._log(LogLevel.info, message, tag);
  }

  /// Warning级别日志
  static void w(String message, [String? tag]) {
    instance._log(LogLevel.warning, message, tag);
  }

  /// Error级别日志
  static void e(String message, [String? tag, Object? error, StackTrace? stackTrace]) {
    String fullMessage = message;
    if (error != null) {
      fullMessage += '\nError: $error';
    }
    if (stackTrace != null) {
      fullMessage += '\nStackTrace: $stackTrace';
    }
    instance._log(LogLevel.error, fullMessage, tag);
  }

  /// Verbose级别日志
  static void v(String message, [String? tag]) {
    instance._log(LogLevel.verbose, message, tag);
  }

  /// 打印分割线
  static void printDivider([String? title]) {
    String divider = '=' * 50;
    if (title != null && title.isNotEmpty) {
      int titleLength = title.length;
      int padding = (50 - titleLength - 2) ~/ 2;
      divider = '${'=' * padding} $title ${'=' * padding}';
      if (divider.length < 50) {
        divider += '=';
      }
    }
    CPLog.i(divider);
  }

  /// JSON格式化输出
  static void json(Map<String, dynamic> data, [String? tag]) {
    try {
      // 简单的JSON格式化
      String formatted = instance._formatJson(data, 0);
      CPLog.d(formatted, tag ?? 'JSON');
    } catch (error) {
      CPLog.e('JSON格式化失败: $error', tag);
    }
  }

  /// 设置是否启用日志
  static void setEnabled(bool enabled) {
    instance._enableLog = enabled;
  }

  /// 设置是否显示时间戳
  static void setShowTimestamp(bool show) {
    instance._showTimestamp = show;
  }

  /// 设置单行最大长度
  static void setMaxLineLength(int length) {
    instance._maxLineLength = length;
  }

  /// 设置日志标签前缀
  static void setTagPrefix(String prefix) {
    instance._tagPrefix = prefix;
  }

  // ============== 内部实现方法 ==============

  /// 核心日志输出方法
  void _log(LogLevel level, String message, String? tag) {
    if (!_enableLog) return;

    // 构建标签
    String finalTag = _buildTag(level, tag);

    // 构建完整消息
    String fullMessage = _buildFullMessage(message);

    // 获取颜色
    String color = _getColorForLevel(level);

    // 分段输出
    _printSegmented(finalTag, fullMessage, color);
  }

  /// 构建标签
  String _buildTag(LogLevel level, String? customTag) {
    String levelStr = _getLevelString(level);
    String tag = customTag ?? _tagPrefix;
    return '[$tag-$levelStr]';
  }

  /// 构建完整消息
  String _buildFullMessage(String message) {
    if (!_showTimestamp) return message;

    DateTime now = DateTime.now();
    String timestamp = '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';

    return '[$timestamp] $message';
  }

  /// 获取日志级别字符串
  String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'D';
      case LogLevel.info:
        return 'I';
      case LogLevel.warning:
        return 'W';
      case LogLevel.error:
        return 'E';
      case LogLevel.verbose:
        return 'V';
    }
  }

  /// 获取日志级别对应的颜色
  String _getColorForLevel(LogLevel level) {
    if (!kDebugMode) return '';

    switch (level) {
      case LogLevel.debug:
        return _colorBlue;
      case LogLevel.info:
        return _colorGreen;
      case LogLevel.warning:
        return _colorYellow;
      case LogLevel.error:
        return _colorRed;
      case LogLevel.verbose:
        return _colorGray;
    }
  }

  /// 分段输出长文本
  void _printSegmented(String tag, String message, String color) {
    // 如果消息长度小于等于最大长度，直接输出
    if (message.length <= _maxLineLength) {
      String output = '$tag $message';
      if (kDebugMode && color.isNotEmpty) {
        developer.log('$color$output$_colorReset');
      } else {
        developer.log(output);
      }
      return;
    }

    // 需要分段输出
    List<String> lines = message.split('\n');
    int segmentIndex = 1;

    for (String line in lines) {
      if (line.length <= _maxLineLength) {
        // 单行不需要分割
        String output = lines.length > 1 || segmentIndex > 1 ? '$tag [$segmentIndex] $line' : '$tag $line';

        if (kDebugMode && color.isNotEmpty) {
          developer.log('$color$output$_colorReset');
        } else {
          developer.log(output);
        }
        segmentIndex++;
      } else {
        // 单行需要分割
        for (int i = 0; i < line.length; i += _maxLineLength) {
          int end = (i + _maxLineLength < line.length) ? i + _maxLineLength : line.length;

          String segment = line.substring(i, end);
          String output = '$tag [$segmentIndex] $segment';

          if (kDebugMode && color.isNotEmpty) {
            developer.log('$color$output$_colorReset');
          } else {
            developer.log(output);
          }
          segmentIndex++;
        }
      }
    }
  }

  /// 简单的JSON格式化方法
  String _formatJson(dynamic data, int indent) {
    String indentStr = '  ' * indent;

    if (data is Map) {
      if (data.isEmpty) return '{}';

      StringBuffer buffer = StringBuffer('{\n');
      List<String> keys = data.keys.map((k) => k.toString()).toList();
      for (int i = 0; i < keys.length; i++) {
        String key = keys[i];
        dynamic value = data[key];
        buffer.write('$indentStr  "$key": ');
        buffer.write(_formatJson(value, indent + 1));
        if (i < keys.length - 1) buffer.write(',');
        buffer.write('\n');
      }
      buffer.write('$indentStr}');
      return buffer.toString();
    } else if (data is List) {
      if (data.isEmpty) return '[]';

      StringBuffer buffer = StringBuffer('[\n');
      for (int i = 0; i < data.length; i++) {
        buffer.write('$indentStr  ');
        buffer.write(_formatJson(data[i], indent + 1));
        if (i < data.length - 1) buffer.write(',');
        buffer.write('\n');
      }
      buffer.write('$indentStr]');
      return buffer.toString();
    } else if (data is String) {
      return '"$data"';
    } else {
      return data.toString();
    }
  }

  // ============== 使用示例方法 ==============

  /// 运行基本使用示例
  /// 
  /// 展示如何使用日志工具类的各种功能
  static void runExamples() {
    // ============== 新的使用方式：直接静态调用 ==============

    // 基本日志输出 - 直接调用，无需获取实例
    CPLog.d('这是一条Debug日志');
    CPLog.i('这是一条Info日志');
    CPLog.w('这是一条Warning日志');
    CPLog.e('这是一条Error日志');
    CPLog.v('这是一条Verbose日志');

    // 带自定义标签的日志
    CPLog.d('网络请求开始', 'Network');
    CPLog.i('用户登录成功', 'Auth');
    CPLog.w('内存使用率较高', 'Performance');

    // 错误日志带异常信息
    try {
      throw Exception('这是一个测试异常');
    } catch (error, stackTrace) {
      CPLog.e('发生了异常', 'Error', error, stackTrace);
    }

    // 测试长文本分段输出
    String longMessage =
        '${'这是一条非常长的日志消息，' * 20}用来测试自动分段功能是否正常工作。当单行文本超过设定的最大长度时，会自动分成多段输出，每段都会带有序号标识，方便查看完整的日志内容。';
    CPLog.d(longMessage, 'LongText');

    // 测试多行文本输出
    String multiLineMessage = '''这是第一行
这是第二行
这是第三行，包含一些长内容：${'很长的内容 ' * 30}
这是第四行''';
    CPLog.i(multiLineMessage, 'MultiLine');

    // 打印分割线
    CPLog.printDivider();
    CPLog.printDivider('配置示例');

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
    CPLog.json(testData, 'UserData');

    // 配置修改示例
    CPLog.printDivider('配置修改测试');

    // 修改配置 - 也是直接静态调用
    CPLog.setShowTimestamp(false);
    CPLog.i('关闭时间戳后的日志');

    CPLog.setShowTimestamp(true);
    CPLog.setMaxLineLength(50); // 设置更短的行长度来测试分段
    CPLog.i('设置短行长度后的测试：${'这是一段比较长的文本内容' * 3}');

    // 恢复默认设置
    CPLog.setMaxLineLength(800);
    CPLog.i('恢复默认设置后的日志');

    CPLog.printDivider('示例结束');
  }

  /// 演示在不同场景下的使用
  /// 
  /// 展示真实开发场景中的日志使用方式
  static Future<void> realWorldExamples() async {
    // ============== 真实场景使用示例 ==============

    // 网络请求日志
    CPLog.i('开始请求用户信息', 'Network');
    CPLog.d('请求URL: https://api.example.com/user/profile', 'Network');
    CPLog.d('请求头: {"Authorization": "Bearer ***", "Content-Type": "application/json"}', 'Network');

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
    CPLog.json(response, 'NetworkResponse');

    // 数据库操作日志
    CPLog.i('开始数据库查询', 'Database');
    CPLog.d('SQL: SELECT * FROM users WHERE id = ? AND status = ?', 'Database');
    CPLog.d('参数: [123, "active"]', 'Database');
    CPLog.i('查询完成，返回1条记录', 'Database');

    // UI事件日志
    CPLog.d('用户点击了登录按钮', 'UI');
    CPLog.d('显示加载动画', 'UI');
    CPLog.i('登录成功，跳转到主页', 'UI');

    // 错误处理日志
    try {
      // 模拟一个错误
      throw const FormatException('JSON解析失败：格式不正确');
    } catch (error, stackTrace) {
      CPLog.e('处理用户数据时发生错误', 'DataProcessor', error, stackTrace);
    }

    // 性能监控日志
    CPLog.printDivider('性能监控');

    Stopwatch stopwatch = Stopwatch()..start();

    // 模拟一些操作
    await Future.delayed(const Duration(milliseconds: 100));

    stopwatch.stop();
    CPLog.i('操作耗时: ${stopwatch.elapsedMilliseconds}ms', 'Performance');

    // 内存使用情况（模拟）
    CPLog.w('内存使用率: 75%', 'Memory');
    CPLog.d('当前堆内存: 120MB / 512MB', 'Memory');
  }

  /// 展示不同的使用方式对比
  /// 
  /// 对比新旧使用方式，展示最佳实践
  static void showUsageComparison() {
    CPLog.printDivider('使用方式对比');

    // ✅ 推荐方式：直接静态调用
    CPLog.i('这是推荐的使用方式 - 直接静态调用');
    CPLog.d('无需创建实例，代码更简洁', 'Recommended');

    // ⚠️ 旧方式：通过实例调用（仍然支持）
    final log = CPLog.instance;
    // 注意：现在实例上没有 d, i, w, e, v 方法了，都改为静态方法
    // 所以即使获取了实例，也需要使用静态方法

    // 或者使用简短形式获取实例
    final logI = CPLog.I;
    // 同样，实例方法已移除，使用静态方法

    CPLog.printDivider('配置示例');

    // 配置也是静态方法
    CPLog.setTagPrefix('MyApp');
    CPLog.i('修改标签前缀后的日志');

    CPLog.setTagPrefix('PreciousLife'); // 恢复默认
    CPLog.i('恢复默认标签前缀');
  }
}
