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
/// - 支持直接静态调用：LogUtils.d(), LogUtils.i() 等
class LogUtils {
  // 私有构造函数
  LogUtils._();

  // 单例实例
  static LogUtils? _instance;

  /// 获取单例实例
  static LogUtils get instance {
    _instance ??= LogUtils._();
    return _instance!;
  }

  /// 便捷访问方法
  static LogUtils get I => instance;

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
    LogUtils.i(divider);
  }

  /// JSON格式化输出
  static void json(Map<String, dynamic> data, [String? tag]) {
    try {
      // 简单的JSON格式化
      String formatted = instance._formatJson(data, 0);
      LogUtils.d(formatted, tag ?? 'JSON');
    } catch (error) {
      LogUtils.e('JSON格式化失败: $error', tag);
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
}
