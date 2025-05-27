import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:precious_life/core/network/api/qweather/qweather_api_model.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_service.dart';
import 'package:precious_life/features/todo/ui/models/followed_city.dart';

/// 天气信息详情页面组件
/// 重新设计的现代化天气页面，顶部展示天气状态卡片，下方显示预警和预报信息
class WeatherInfoDetailPage extends ConsumerStatefulWidget {
  /// 城市信息
  final FollowedCity city;
  /// 刷新回调
  final VoidCallback? onRefresh;
  /// 是否应该立即加载数据
  final bool shouldLoadData;

  const WeatherInfoDetailPage({
    super.key,
    required this.city,
    this.onRefresh,
    this.shouldLoadData = true,
  });

  @override
  ConsumerState<WeatherInfoDetailPage> createState() => _WeatherInfoDetailPageState();
}

class _WeatherInfoDetailPageState extends ConsumerState<WeatherInfoDetailPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  String? _errorMessage;
  
  // 天气数据
  QweatherNow? _currentWeather;
  QweatherMinutelyResponse? _minutelyData;
  List<QweatherDaily>? _dailyForecast;
  List<QweatherWarning>? _warnings;

  // 动画控制器
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _weatherCardController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;

  // 动画
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _weatherCardAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;

  @override
  bool get wantKeepAlive => true; // 保持页面状态

  @override
  void initState() {
    super.initState();
    _initAnimations();
    if (widget.shouldLoadData) {
      _loadAllWeatherData();
    }
  }

  /// 初始化动画控制器
  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _weatherCardController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
    
    _weatherCardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _weatherCardController, curve: Curves.elasticOut),
    );
    
    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 启动循环动画
    _floatingController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  /// 加载所有天气数据
  Future<void> _loadAllWeatherData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final location = '${widget.city.longitude},${widget.city.latitude}';
      
      // 并发请求所有数据
      final futures = await Future.wait([
        QweatherApiService.getNowWeather(location),
        QweatherApiService.getMinutelyRain(location),
        _getDailyForecast(location),
        _getWarnings(location),
      ]);

      if (mounted) {
        final nowResponse = futures[0] as QweatherNowResponse;
        final minutelyResponse = futures[1] as QweatherMinutelyResponse;
        final dailyResponse = futures[2] as QweatherDailyResponse?;
        final warningResponse = futures[3] as QweatherWarningResponse?;

        setState(() {
          _currentWeather = nowResponse.now;
          _minutelyData = minutelyResponse;
          _dailyForecast = dailyResponse?.daily;
          _warnings = warningResponse?.warning;
          _isLoading = false;
        });
        
        // 启动入场动画
        _fadeController.forward();
        _slideController.forward();
        _weatherCardController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '获取天气信息失败: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  /// 获取7天预报数据
  Future<QweatherDailyResponse?> _getDailyForecast(String location) async {
    try {
      return await QweatherApiService.getDailyForecast(location);
    } catch (e) {
      return null;
    }
  }

  /// 获取预警信息
  Future<QweatherWarningResponse?> _getWarnings(String location) async {
    try {
      return await QweatherApiService.getWeatherWarning(location);
    } catch (e) {
      return null;
    }
  }

  /// 手动加载天气数据（供外部调用）
  void loadWeatherData() {
    if (!_isLoading) {
      _loadAllWeatherData();
    }
  }

  /// 刷新天气数据
  void refreshWeatherData() {
    _loadAllWeatherData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _weatherCardController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用以支持AutomaticKeepAliveClientMixin
    return Scaffold(
      body: Stack(
        children: [
          // 动态渐变背景
          _buildDynamicBackground(),
          // 主要内容
          SafeArea(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  /// 构建动态渐变背景
  Widget _buildDynamicBackground() {
    final colors = _getWeatherGradientColors(_currentWeather?.icon);
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors.map((color) => 
                Color.lerp(color, Colors.white, 0.05 * (1 - _pulseAnimation.value))!
              ).toList(),
            ),
          ),
          child: Stack(
            children: [
              // 浮动装饰元素
              ...List.generate(5, (index) => _buildFloatingDecoration(index)),
            ],
          ),
        );
      },
    );
  }

  /// 获取天气渐变色
  List<Color> _getWeatherGradientColors(String? weatherIcon) {
    switch (weatherIcon) {
      case '100': // 晴天
      case '150':
        return [
          const Color(0xFF87CEEB),
          const Color(0xFFFFD700),
          const Color(0xFFFFA500),
          const Color(0xFFFF6347),
        ];
      case '101': // 多云
      case '102':
      case '103':
        return [
          const Color(0xFF87CEEB),
          const Color(0xFFB0C4DE),
          const Color(0xFF778899),
          const Color(0xFF696969),
        ];
      case '104': // 阴天
        return [
          const Color(0xFF708090),
          const Color(0xFF778899),
          const Color(0xFF696969),
          const Color(0xFF2F4F4F),
        ];
      default: // 雨雪等
        if (weatherIcon != null && weatherIcon.startsWith('3')) {
          return [
            const Color(0xFF4682B4),
            const Color(0xFF5F9EA0),
            const Color(0xFF008B8B),
            const Color(0xFF2F4F4F),
          ];
        } else if (weatherIcon != null && weatherIcon.startsWith('4')) {
          return [
            const Color(0xFFB0E0E6),
            const Color(0xFF87CEEB),
            const Color(0xFF4682B4),
            const Color(0xFF191970),
          ];
        } else {
          return [
            const Color(0xFF87CEEB),
            const Color(0xFF4682B4),
            const Color(0xFF2F4F4F),
            const Color(0xFF191970),
          ];
        }
    }
  }

  /// 构建浮动装饰元素
  Widget _buildFloatingDecoration(int index) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Positioned(
          top: 100 + index * 120 + _floatingAnimation.value * (index % 2 == 0 ? 1 : -1),
          left: 50 + index * 80 + _floatingAnimation.value * 0.5,
          child: Opacity(
            opacity: 0.1,
            child: Container(
              width: 60 + index * 10,
              height: 60 + index * 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建城市标题
  Widget _buildCityHeader() => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            // 城市名称
            Text(
              widget.city.simpleDisplayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 详细地址
            Text(
              widget.city.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            // 定位标识
            if (widget.city.code == 'current_location') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '当前位置',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  /// 构建内容区域
  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
          child: Column(
            children: [
              // 城市名称显示
              _buildCityHeader(),
              const SizedBox(height: 30),
              // 主要天气状态卡片
              _buildMainWeatherCard(),
              const SizedBox(height: 30),
              // 天气状态指示器
              _buildWeatherIndicators(),
              const SizedBox(height: 30),
              // 预警信息
              _buildWarningSection(),
              const SizedBox(height: 30),
              // 7天预报
              _buildDailyForecastSection(),
              const SizedBox(height: 30),
              // 分钟级降雨
              _buildMinutelyRainSection(),
              const SizedBox(height: 20),
              // 更新时间
              _buildUpdateTime(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                      backgroundColor: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '正在获取天气信息...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  /// 构建错误状态
  Widget _buildErrorState() => Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _loadAllWeatherData,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  /// 构建主要天气卡片
  Widget _buildMainWeatherCard() => ScaleTransition(
        scale: _weatherCardAnimation,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              // 天气图标和温度
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 天气图标
                  AnimatedBuilder(
                    animation: _floatingAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatingAnimation.value * 0.5),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: _getWeatherIcon(_currentWeather?.icon, 80),
                        ),
                      );
                    },
                  ),
                  // 温度显示
                  Column(
                    children: [
                      Text(
                        '${_currentWeather?.temp ?? '--'}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.w200,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        _currentWeather?.text ?? '未知',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // 体感温度和湿度
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWeatherDetail(
                    '体感温度',
                    '${_currentWeather?.feelsLike ?? '--'}°',
                    Icons.thermostat,
                  ),
                  _buildWeatherDetail(
                    '湿度',
                    '${_currentWeather?.humidity ?? '--'}%',
                    Icons.water_drop,
                  ),
                  _buildWeatherDetail(
                    '风速',
                    '${_currentWeather?.windSpeed ?? '--'}km/h',
                    Icons.air,
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  /// 构建天气详情项
  Widget _buildWeatherDetail(String label, String value, IconData icon) => Column(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      );

  /// 构建天气状态指示器
  Widget _buildWeatherIndicators() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIndicatorItem('气压', '${_currentWeather?.pressure ?? '--'}hPa'),
                _buildIndicatorItem('能见度', '${_currentWeather?.vis ?? '--'}km'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIndicatorItem('风向', _currentWeather?.windDir ?? '--'),
                _buildIndicatorItem('风力', '${_currentWeather?.windScale ?? '--'}级'),
              ],
            ),
          ],
        ),
      );

  /// 构建指示器项
  Widget _buildIndicatorItem(String label, String value) => Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );

  /// 构建预警信息区域
  Widget _buildWarningSection() {
    if (_warnings == null || _warnings!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 24),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                '当前无气象预警信息',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⚠️ 气象预警',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 15),
        ..._warnings!.map((warning) => _buildWarningCard(warning)),
      ],
    );
  }

  /// 构建预警卡片
  Widget _buildWarningCard(QweatherWarning warning) => Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _getWarningColor(warning.severityColor).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getWarningColor(warning.severityColor).withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getWarningColor(warning.severityColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    warning.typeName ?? '预警',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  warning.severity ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              warning.title ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              warning.text ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w300,
                height: 1.4,
              ),
            ),
          ],
        ),
      );

  /// 获取预警颜色
  Color _getWarningColor(String? severityColor) {
    switch (severityColor?.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// 构建7天预报区域
  Widget _buildDailyForecastSection() {
    if (_dailyForecast == null || _dailyForecast!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Center(
          child: Text(
            '暂无7天预报数据',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📅 7天预报',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: _dailyForecast!.take(7).map((day) => _buildDailyForecastItem(day)).toList(),
          ),
        ),
      ],
    );
  }

  /// 构建每日预报项
  Widget _buildDailyForecastItem(QweatherDaily day) {
    final date = DateTime.tryParse(day.fxDate ?? '');
    final dayName = _getDayName(date);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          // 日期
          SizedBox(
            width: 60,
            child: Text(
              dayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // 天气图标
          _getWeatherIcon(day.iconDay, 24),
          const SizedBox(width: 15),
          // 天气描述
          Expanded(
            child: Text(
              day.textDay ?? '未知',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          // 温度范围
          Text(
            '${day.tempMin ?? '--'}° / ${day.tempMax ?? '--'}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取日期名称
  String _getDayName(DateTime? date) {
    if (date == null) return '--';
    
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day)).inDays;
    
    switch (difference) {
      case 0:
        return '今天';
      case 1:
        return '明天';
      case 2:
        return '后天';
      default:
        final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
        return weekdays[date.weekday - 1];
    }
  }

  /// 构建分钟级降雨区域
  Widget _buildMinutelyRainSection() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🌧️ 分钟级降雨',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              _minutelyData?.summary ?? '暂无降雨信息',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
                height: 1.4,
              ),
            ),
          ],
        ),
      );

  /// 构建更新时间
  Widget _buildUpdateTime() => Center(
        child: Text(
          '更新时间: ${_formatUpdateTime(_currentWeather?.obsTime)}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
      );

  /// 格式化更新时间
  String _formatUpdateTime(String? obsTime) {
    if (obsTime == null) return '--';
    try {
      final dateTime = DateTime.parse(obsTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return obsTime;
    }
  }

  /// 获取天气图标
  Widget _getWeatherIcon(String? icon, double size) {
    if (icon == null) {
      return Icon(Icons.help_outline, size: size, color: Colors.white.withOpacity(0.7));
    }

    IconData iconData;
    Color iconColor = Colors.white;

    switch (icon) {
      // 晴天
      case '100':
      case '150':
        iconData = Icons.wb_sunny;
        iconColor = Colors.orange;
        break;
      // 多云
      case '101':
      case '102':
      case '103':
      case '151':
      case '152':
      case '153':
        iconData = Icons.wb_cloudy;
        iconColor = Colors.white;
        break;
      // 阴天
      case '104':
        iconData = Icons.cloud;
        iconColor = Colors.grey;
        break;
      // 雨天
      case '300':
      case '301':
      case '302':
      case '303':
      case '304':
      case '305':
      case '306':
      case '307':
      case '308':
      case '309':
      case '310':
      case '311':
      case '312':
      case '313':
      case '314':
      case '315':
      case '316':
      case '317':
      case '318':
      case '350':
      case '351':
      case '399':
        iconData = Icons.grain;
        iconColor = Colors.blue;
        break;
      // 雪天
      case '400':
      case '401':
      case '402':
      case '403':
      case '404':
      case '405':
      case '406':
      case '407':
      case '408':
      case '409':
      case '410':
      case '456':
      case '457':
      case '499':
        iconData = Icons.ac_unit;
        iconColor = Colors.lightBlue;
        break;
      // 雾霾
      case '500':
      case '501':
      case '502':
      case '509':
      case '510':
      case '511':
      case '512':
      case '513':
      case '514':
      case '515':
        iconData = Icons.blur_on;
        iconColor = Colors.grey;
        break;
      // 沙尘
      case '503':
      case '504':
      case '507':
      case '508':
        iconData = Icons.waves;
        iconColor = Colors.brown;
        break;
      // 高温/低温
      case '900':
        iconData = Icons.whatshot;
        iconColor = Colors.red;
        break;
      case '901':
        iconData = Icons.ac_unit;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.wb_sunny;
        iconColor = Colors.white.withOpacity(0.7);
    }

    return Icon(iconData, size: size, color: iconColor);
  }
}
