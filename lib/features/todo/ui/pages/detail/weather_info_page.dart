import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_model.dart';
import 'package:precious_life/core/network/api/qweather/qweather_api_service.dart';
import 'package:precious_life/core/utils/weather_utils.dart';
import 'package:precious_life/features/todo/ui/models/followed_city.dart';

/// 天气信息页面组件
/// 重新设计的现代化天气页面，顶部展示天气状态卡片，下方显示预警和预报信息
class WeatherInfoPage extends ConsumerStatefulWidget {
  /// 城市信息
  final FollowedCity city;
  /// 刷新回调
  final VoidCallback? onRefresh;
  /// 是否应该立即加载数据
  final bool shouldLoadData;

  const WeatherInfoPage({
    super.key,
    required this.city,
    this.onRefresh,
    this.shouldLoadData = true,
  });

  @override
  ConsumerState<WeatherInfoPage> createState() => _WeatherInfoPageState();
}

class _WeatherInfoPageState extends ConsumerState<WeatherInfoPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  String? _errorMessage;
  
  // 天气数据
  QweatherNow? _currentWeather;
  QweatherMinutelyResponse? _minutelyData;
  List<QweatherDaily>? _dailyForecast;
  List<QweatherWarning>? _warnings;
  List<QweatherHourly>? _hourlyForecast;


  // 展开状态
  bool _isExpanded = false;

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

  // 24小时预报滚动控制器
  late ScrollController _hourlyScrollController;

  @override
  bool get wantKeepAlive => true; // 保持页面状态

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _hourlyScrollController = ScrollController();
    if (widget.shouldLoadData) {
      _loadAllWeatherData();
    }
  }



  @override
  void didUpdateWidget(WeatherInfoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果onRefresh回调发生变化，需要重新绑定
    if (widget.onRefresh != oldWidget.onRefresh) {
      // 这里可以添加额外的处理逻辑
    }
  }

  /// 初始化动画控制器
  void _initializeAnimations() {
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
        _getHourlyForecast(location),
      ]);

      if (mounted) {
        final nowResponse = futures[0] as QweatherNowResponse;
        final minutelyResponse = futures[1] as QweatherMinutelyResponse;
        final dailyResponse = futures[2] as QweatherDailyResponse?;
        final warningResponse = futures[3] as QweatherWarningResponse?;
        final hourlyResponse = futures[4] as QweatherHourlyResponse?;

        setState(() {
          _currentWeather = nowResponse.now;
          _minutelyData = minutelyResponse;
          _dailyForecast = dailyResponse?.daily;
          // 使用真实的预警数据
          _warnings = warningResponse?.warning;
          _hourlyForecast = hourlyResponse?.hourly;
          _isLoading = false;
        });
        
        // 启动入场动画
        _fadeController.forward();
        _slideController.forward();
        _weatherCardController.forward();
        
        // 滚动到当前时间对应的位置
        _scrollToCurrentHour();
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

  /// 获取24小时逐小时预报数据
  Future<QweatherHourlyResponse?> _getHourlyForecast(String location) async {
    try {
      return await QweatherApiService.getHourlyForecast(location);
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

  /// 刷新天气数据（供外部调用）
  void refreshWeatherData() => _loadAllWeatherData();

  /// 处理外部刷新请求（供父组件调用）
  void handleExternalRefresh() {
    _loadAllWeatherData();
    // 如果有onRefresh回调，也调用它
    widget.onRefresh?.call();
  }

  /// 滚动到当前时间对应的位置
  void _scrollToCurrentHour() {
    if (_hourlyForecast == null || _hourlyForecast!.isEmpty) return;
    
    // 延迟执行，确保ListView已经构建完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hourlyScrollController.hasClients) return;
      
      final now = DateTime.now();
      int currentHourIndex = -1;
      
      // 查找当前时间对应的索引
      for (int i = 0; i < _hourlyForecast!.length; i++) {
        final hourly = _hourlyForecast![i];
        if (hourly.fxTime != null) {
          try {
            final hourlyTime = DateTime.parse(hourly.fxTime!);
            // 如果找到当前小时或者下一个小时，就定位到这里
            if (hourlyTime.hour == now.hour || 
                (hourlyTime.isAfter(now) && currentHourIndex == -1)) {
              currentHourIndex = i;
              break;
            }
          } catch (e) {
            // 忽略解析错误
          }
        }
      }
      
      // 如果找到了对应的索引，滚动到中间位置
      if (currentHourIndex >= 0) {
        // 计算滚动位置，让当前时间项显示在中间
        const itemHeight = 44.0; // 每个item的高度（包括margin）
        final scrollOffset = (currentHourIndex * itemHeight) - 
                           (_hourlyScrollController.position.viewportDimension / 2) + 
                           (itemHeight / 2);
        
        _hourlyScrollController.animateTo(
          scrollOffset.clamp(0.0, _hourlyScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _weatherCardController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _hourlyScrollController.dispose();
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
    final colors = WeatherUtils.getWeatherGradientColors(_currentWeather?.icon);
    
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



  /// 构建浮动装饰元素
  Widget _buildFloatingDecoration(int index) => AnimatedBuilder(
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

  /// 构建城市标题
  Widget _buildCityHeader() => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 定位图标（仅当前位置显示）
            if (widget.city.code == 'current_location') ...[
              const Icon(
                Icons.my_location,
                color: Colors.white,
                size: 24,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black26,
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
            // 城市名称（只显示简化名称）
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
              // 预警信息
              _buildWarningSection(),
              const SizedBox(height: 30),
              // 7天预报
              _buildDailyForecastSection(),
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
          padding: const EdgeInsets.all(25),
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
              // 主要天气信息布局调整
              SizedBox(
                height: 250, // 增加固定高度以容纳更多内容
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 左侧：天气图标、温度、描述
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // 天气图标
                              AnimatedBuilder(
                                animation: _floatingAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _floatingAnimation.value * 0.3),
                                    child: WeatherUtils.getWeatherIcon(_currentWeather?.icon, 45, defaultColor: Colors.white),
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                              // 温度和描述
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_currentWeather?.temp ?? '--'}°',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w300,
                                        height: 1.0,
                                      ),
                                    ),
                                    Text(
                                      _currentWeather?.text ?? '未知',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // 分钟级降水预警提示（标注②）- 自适应高度
                          _buildMinutelyRainAlert(),
                          const Expanded(
                            child: SizedBox(),
                          ),
                          // 展开/折叠按钮（标注③）- 移到预警提示后面
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _isExpanded = !_isExpanded),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _isExpanded ? '收起详情' : '查看详情',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      AnimatedRotation(
                                        turns: _isExpanded ? 0.5 : 0,
                                        duration: const Duration(milliseconds: 300),
                                        child: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    // 右侧：24小时逐小时预报（标注①）- 占满卡片最大高度
                    Expanded(
                      flex: 3,
                      child: _buildHourlyForecastSection(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 详细信息（可展开）
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isExpanded ? null : 0,
                child: _isExpanded
                    ? Column(
                        children: [
                          const SizedBox(height: 20),
                          // 第一行：体感温度、湿度、风速、气压
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
                              _buildWeatherDetail(
                                '气压',
                                '${_currentWeather?.pressure ?? '--'}hPa',
                                Icons.speed,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // 第二行：能见度、风向、风力、降水量
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildWeatherDetail(
                                '能见度',
                                '${_currentWeather?.vis ?? '--'}km',
                                Icons.visibility,
                              ),
                              _buildWeatherDetail(
                                '风向',
                                _currentWeather?.windDir ?? '--',
                                Icons.navigation,
                              ),
                              _buildWeatherDetail(
                                '风力',
                                '${_currentWeather?.windScale ?? '--'}级',
                                Icons.waves,
                              ),
                              _buildWeatherDetail(
                                '降水量',
                                '${_currentWeather?.precip ?? '--'}mm',
                                Icons.grain,
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
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

  /// 构建预警信息区域
  /// 当warning列表为空时不显示，不为空时遍历列表一一显示
  Widget _buildWarningSection() {
    // 如果预警列表为空，则不显示任何内容
    if (_warnings == null || _warnings!.isEmpty) {
      return const SizedBox.shrink();
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
        // 遍历预警列表，每行显示警告图标和text字段
        ..._warnings!.map((warning) => _buildWarningItem(warning)),
      ],
    );
  }

  /// 构建预警信息项
  /// 每行警告图标开头，后面跟着text字段
  Widget _buildWarningItem(QweatherWarning warning) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WeatherUtils.getWarningColor(warning.severityColor).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: WeatherUtils.getWarningColor(warning.severityColor).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 警告图标
            Icon(
              Icons.warning_amber_rounded,
              color: WeatherUtils.getWarningColor(warning.severityColor),
              size: 20,
            ),
            const SizedBox(width: 12),
            // text字段内容
            Expanded(
              child: Text(
                warning.text ?? '暂无预警详情',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );



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
    final dayName = WeatherUtils.getDayName(date);
    
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
          WeatherUtils.getWeatherIcon(day.iconDay, 24, defaultColor: Colors.white),
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





  /// 构建更新时间
  Widget _buildUpdateTime() => Center(
        child: Text(
          '更新时间: ${WeatherUtils.formatUpdateTime(_currentWeather?.obsTime)}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
      );





  /// 构建分钟级降水预警提示（标注②）- 自适应高度
  Widget _buildMinutelyRainAlert() {
    final summary = _minutelyData?.summary;
    if (summary == null || summary.isEmpty || summary == '暂无降雨信息') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '未来2小时无降雨 ☀️',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.water_drop,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              summary,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建24小时逐小时预报区域（标注①）- 占满卡片最大高度
  Widget _buildHourlyForecastSection() {
    if (_hourlyForecast == null || _hourlyForecast!.isEmpty) {
      return Container(
        height: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: const Center(
          child: Text(
            '暂无逐小时预报',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      );
    }

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⏰ 24小时预报',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: _hourlyScrollController,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: _hourlyForecast!.take(24).length,
              itemBuilder: (context, index) {
                final hourly = _hourlyForecast![index];
                return _buildHourlyForecastItem(hourly);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个逐小时预报项 - 垂直布局，修复宽度越界
  Widget _buildHourlyForecastItem(QweatherHourly hourly) {
    final time = WeatherUtils.formatHourlyTime(hourly.fxTime);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // 时间
          SizedBox(
            width: 40,
            child: Text(
              time,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 天气图标
          WeatherUtils.getWeatherIcon(hourly.icon, 18, defaultColor: Colors.white),
          const Spacer(),
          // 温度
          Text(
            '${hourly.temp ?? '--'}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }






} 