import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:precious_life/config/app_config.dart';
import 'package:precious_life/config/color_style.dart';
import 'package:precious_life/config/text_style.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_service.dart';
import 'package:precious_life/core/utils/storage_utils.dart';
import 'package:precious_life/features/todo/ui/providers/home_weather_vm.dart';
import '../../../../../core/utils/log/log_utils.dart';

/// 天气配置设置页面
/// 用于配置和风天气API Key
class WeatherConfigSettingsPage extends ConsumerStatefulWidget {
  const WeatherConfigSettingsPage({super.key});

  @override
  ConsumerState<WeatherConfigSettingsPage> createState() => _WeatherConfigSettingsPageState();
}

class _WeatherConfigSettingsPageState extends ConsumerState<WeatherConfigSettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentApiKey();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  /// 加载当前的API Key
  Future<void> _loadCurrentApiKey() async {
    try {
      setState(() => _isLoading = true);

      // 从存储中获取API Key，如果没有则使用默认值
      final savedApiKey = await StorageUtils.instance.getString(StorageKeys.weatherApiKey);
      final currentApiKey = savedApiKey ?? AppConfig.qweatherApiKey;

      _apiKeyController.text = currentApiKey;
    } catch (e) {
      LogUtils.d('加载API Key失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 验证并保存API Key配置
  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      _showAlert('错误', 'API Key不能为空');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 临时更新AppConfig中的API Key用于验证
      final originalApiKey = AppConfig.qweatherApiKey;
      AppConfig.qweatherApiKey = apiKey;

      // 使用北京的经纬度进行验证
      const testLocation = '116.4074,39.9042'; // 北京天安门
      final response = await QweatherApiService.getNowWeather(testLocation);

      if (response.code == '200') {
        // API Key有效，保存到本地存储
        await StorageUtils.instance.setString(StorageKeys.weatherApiKey, apiKey);

        // 确保AppConfig中的API Key保持更新状态
        AppConfig.qweatherApiKey = apiKey;
        LogUtils.d('WeatherConfig: API Key验证成功并已保存 - ${apiKey.substring(0, 8)}...');

        _showSuccessAndClose();
      } else {
        // API Key无效，恢复原始值
        AppConfig.qweatherApiKey = originalApiKey;
        _showAlert('API Key错误', 'API Key无效，请检查后重试。错误代码: ${response.code}');
      }
    } catch (e) {
      // 发生异常，恢复原始API Key
      final savedApiKey = await StorageUtils.instance.getString(StorageKeys.weatherApiKey);
      AppConfig.qweatherApiKey = savedApiKey ?? AppConfig.qweatherApiKey;

      _showAlert('验证失败', '无法验证API Key，请检查网络连接后重试。\n错误信息: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// 显示提示弹窗
  void _showAlert(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示保存成功提示并关闭页面
  void _showSuccessAndClose() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('配置成功'),
        content: const Text('API Key验证通过并已保存成功！'),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              ref.read(homeWeatherVmProvider.notifier).init();
              Navigator.of(context).pop(); // 关闭弹窗
              context.pop(true); // 关闭页面并返回true表示配置成功
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 处理输入框变化
  void _onApiKeyChanged(String value) {
    // 输入框变化处理，暂时不需要特殊逻辑
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('天气配置'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: const Icon(CupertinoIcons.back),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(
                child: CupertinoActivityIndicator(radius: 20),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 说明文本
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CPColors.lightGrey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '和风天气API配置',
                            style: CPTextStyles.s16.bold.build(),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '请输入您的和风天气API Key。保存时会自动验证API Key的有效性。如果您还没有API Key，请访问 https://dev.qweather.com 注册并获取。',
                            style: CPTextStyles.s14.c(CPColors.darkGrey),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // API Key输入框
                    Text(
                      'API Key',
                      style: CPTextStyles.s16.bold.build(),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _apiKeyController,
                      placeholder: '请输入和风天气API Key',
                      onChanged: _onApiKeyChanged,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CPColors.lightGrey.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      style: CPTextStyles.s14.build(),
                    ),

                    const SizedBox(height: 24),

                    // 保存按钮
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        onPressed: _isSaving ? null : _saveApiKey,
                        color: CupertinoColors.systemGreen,
                        borderRadius: BorderRadius.circular(8),
                        child: _isSaving
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CupertinoActivityIndicator(
                                    radius: 10,
                                    color: CupertinoColors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text('验证并保存中...'),
                                ],
                              )
                            : const Text('验证并保存配置'),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 帮助信息
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.info_circle,
                                color: CupertinoColors.systemBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '使用说明',
                                style: CPTextStyles.s16.bold.c(CupertinoColors.systemBlue),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '1. 访问和风天气开发者平台注册账号\n'
                            '2. 创建应用并获取API Key\n'
                            '3. 将API Key粘贴到上方输入框\n'
                            '4. 点击"验证并保存配置"完成设置\n'
                            '5. 系统会自动验证API Key的有效性',
                            style: CPTextStyles.s12.c(CupertinoColors.systemBlue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
