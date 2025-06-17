import 'package:intl/intl.dart';

/// 日期工具类
/// 提供处理日期和时间的实用方法
class CPDate {
  // 私有构造函数，防止外部实例化
  CPDate._();
  
  /// 标准日期格式
  static final DateFormat _standardDateFormat = DateFormat('yyyy-MM-dd');
  
  /// 标准时间格式
  static final DateFormat _standardTimeFormat = DateFormat('HH:mm:ss');
  
  /// 标准日期时间格式
  static final DateFormat _standardDateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  
  /// 友好日期格式（如：2023年1月1日）
  static final DateFormat _friendlyDateFormat = DateFormat('yyyy年M月d日');
  
  /// 格式化为标准日期字符串 (yyyy-MM-dd)
  static String formatStandardDate(DateTime date) => _standardDateFormat.format(date);
  
  /// 格式化为标准时间字符串 (HH:mm:ss)
  static String formatStandardTime(DateTime date) => _standardTimeFormat.format(date);
  
  /// 格式化为标准日期时间字符串 (yyyy-MM-dd HH:mm:ss)
  static String formatStandardDateTime(DateTime date) => _standardDateTimeFormat.format(date);
  
  /// 格式化为友好日期字符串 (yyyy年M月d日)
  static String formatFriendlyDate(DateTime date) => _friendlyDateFormat.format(date);
  
  /// 格式化为相对时间（如：刚刚、5分钟前、1小时前等）
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months个月前';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years年前';
    }
  }
  
  /// 获取指定日期所在周的起始日期（周一）
  static DateTime getWeekStart(DateTime date) {
    final day = date.weekday;
    return date.subtract(Duration(days: day - 1));
  }
  
  /// 获取指定日期所在周的结束日期（周日）
  static DateTime getWeekEnd(DateTime date) {
    final day = date.weekday;
    return date.add(Duration(days: 7 - day));
  }
  
  /// 获取指定日期所在月的起始日期
  static DateTime getMonthStart(DateTime date) => DateTime(date.year, date.month, 1);
  
  /// 获取指定日期所在月的结束日期
  static DateTime getMonthEnd(DateTime date) => DateTime(date.year, date.month + 1, 0);
  
  /// 检查日期是否为今天
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  /// 检查日期是否为昨天
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }
  
  /// 检查日期是否为明天
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }
  
  /// 计算两个日期间隔的天数
  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }
} 