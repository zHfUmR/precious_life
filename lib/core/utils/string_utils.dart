import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 字符串工具类
/// 提供对字符串进行操作的实用方法
class StringUtil {
  // 私有构造函数，防止外部实例化
  StringUtil._();
  
  /// 判断字符串是否为空或仅包含空白字符
  static bool isNullOrEmpty(String? str) {
    return str == null || str.trim().isEmpty;
  }
  
  /// 判断字符串是否不为空
  static bool isNotNullOrEmpty(String? str) {
    return !isNullOrEmpty(str);
  }
  
  /// 截断字符串至指定长度，并加上省略号
  static String truncate(String text, int maxLength, {String ellipsis = '...'}) {
    if (text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength) + ellipsis;
  }
  
  /// 将字符串的首字母大写
  static String capitalize(String text) {
    if (isNullOrEmpty(text)) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  /// 将驼峰命名转换为下划线命名
  static String camelToSnake(String text) {
    return text.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }
  
  /// 将下划线命名转换为驼峰命名
  static String snakeToCamel(String text) {
    return text.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (match) => match.group(1)!.toUpperCase(),
    );
  }
  
  /// 隐藏敏感信息（如手机号、邮箱等）
  static String maskSensitiveInfo(String text, {int visibleStart = 3, int visibleEnd = 4, String mask = '*'}) {
    if (isNullOrEmpty(text)) return text;
    
    if (text.length <= visibleStart + visibleEnd) {
      return text;
    }
    
    final start = text.substring(0, visibleStart);
    final end = text.substring(text.length - visibleEnd);
    final middle = mask * (text.length - visibleStart - visibleEnd);
    
    return start + middle + end;
  }
  
  /// 格式化手机号（如：138 **** 8888）
  static String formatPhoneNumber(String phoneNumber) {
    if (isNullOrEmpty(phoneNumber) || phoneNumber.length != 11) {
      return phoneNumber;
    }
    
    return '${phoneNumber.substring(0, 3)} **** ${phoneNumber.substring(7)}';
  }
  
  /// 获取字符串中的数字部分
  static String getNumbers(String text) {
    return text.replaceAll(RegExp(r'[^0-9]'), '');
  }
  
  /// 检查字符串是否为有效电子邮件格式
  static bool isValidEmail(String email) {
    if (isNullOrEmpty(email)) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    return emailRegex.hasMatch(email);
  }
  
  /// 检查字符串是否为有效手机号
  static bool isValidPhoneNumber(String phoneNumber) {
    if (isNullOrEmpty(phoneNumber)) return false;
    
    // 简单的中国大陆手机号验证（1开头，11位数字）
    final phoneRegex = RegExp(r'^1\d{10}$');
    
    return phoneRegex.hasMatch(phoneNumber);
  }
  
  /// 转换文件大小为人类可读格式
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    if (bytes == 0) return '0 ${suffixes[0]}';
    
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
  
  /// 计算文本在指定宽度下的行数
  static int calculateLines(String text, double maxWidth, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1000,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    
    return textPainter.computeLineMetrics().length;
  }
}

// 数学函数
double log(num x, [num? base]) {
  if (base == null) {
    return math.log(x);
  } else {
    return math.log(x) / math.log(base);
  }
}

double pow(num x, num exponent) {
  return math.pow(x, exponent).toDouble();
} 