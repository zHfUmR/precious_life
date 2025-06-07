import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'log/log_utils.dart';

/// 本地存储工具类
/// 封装SharedPreferences的常用操作
class StorageUtils {
  StorageUtils._();
  static final StorageUtils _instance = StorageUtils._();
  static StorageUtils get instance => _instance;

  SharedPreferences? _prefs;

  /// 初始化SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 确保SharedPreferences已初始化
  Future<SharedPreferences> get prefs async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  /// 保存字符串
  Future<bool> setString(String key, String value) async {
    final sp = await prefs;
    return sp.setString(key, value);
  }

  /// 获取字符串
  Future<String?> getString(String key) async {
    final sp = await prefs;
    return sp.getString(key);
  }

  /// 保存整数
  Future<bool> setInt(String key, int value) async {
    final sp = await prefs;
    return sp.setInt(key, value);
  }

  /// 获取整数
  Future<int?> getInt(String key) async {
    final sp = await prefs;
    return sp.getInt(key);
  }

  /// 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    final sp = await prefs;
    return sp.setBool(key, value);
  }

  /// 获取布尔值
  Future<bool?> getBool(String key) async {
    final sp = await prefs;
    return sp.getBool(key);
  }

  /// 保存双精度浮点数
  Future<bool> setDouble(String key, double value) async {
    final sp = await prefs;
    return sp.setDouble(key, value);
  }

  /// 获取双精度浮点数
  Future<double?> getDouble(String key) async {
    final sp = await prefs;
    return sp.getDouble(key);
  }

  /// 保存字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    final sp = await prefs;
    return sp.setStringList(key, value);
  }

  /// 获取字符串列表
  Future<List<String>?> getStringList(String key) async {
    final sp = await prefs;
    return sp.getStringList(key);
  }

  /// 保存对象（通过JSON序列化）
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    return setString(key, jsonString);
  }

  /// 获取对象（通过JSON反序列化）
  Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      CPLog.d('解析JSON失败: $e');
      return null;
    }
  }

  /// 保存对象列表（通过JSON序列化）
  Future<bool> setObjectList(String key, List<Map<String, dynamic>> value) async {
    final jsonString = jsonEncode(value);
    return setString(key, jsonString);
  }

  /// 获取对象列表（通过JSON反序列化）
  Future<List<Map<String, dynamic>>?> getObjectList(String key) async {
    final jsonString = await getString(key);
    if (jsonString == null) return null;
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      CPLog.d('解析JSON列表失败: $e');
      return null;
    }
  }

  /// 删除指定键的数据
  Future<bool> remove(String key) async {
    final sp = await prefs;
    return sp.remove(key);
  }

  /// 检查是否包含指定键
  Future<bool> containsKey(String key) async {
    final sp = await prefs;
    return sp.containsKey(key);
  }

  /// 清除所有数据
  Future<bool> clear() async {
    final sp = await prefs;
    return sp.clear();
  }

  /// 获取所有键
  Future<Set<String>> getKeys() async {
    final sp = await prefs;
    return sp.getKeys();
  }
}

/// 存储键常量
class StorageKeys {
  StorageKeys._();

  /// 关注的城市列表
  static const String followedCities = 'followed_cities';

  /// 当前选中的城市
  static const String currentCity = 'current_city';

  /// 用户设置
  static const String userSettings = 'user_settings';

  /// 主题模式
  static const String themeMode = 'theme_mode';

  /// 天气API Key
  static const String weatherApiKey = 'weather_api_key';
}
