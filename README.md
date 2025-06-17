# 惜命 (Precious Life)

"惜命"应用旨在帮助用户更好地规划时间、获取有价值的信息并提供实用工具，从而珍惜生命、提高生活质量。

## 项目描述

本项目基于Flutter框架开发，实现全平台（iOS、Android、Web、Windows、Mac、Linux）支持，使用Riverpod进行状态管理，Go Router进行路由管理。

核心功能包括：
- 任务管理（Todo）
- 信息流（Feed）
- 工具库（Tools）
- 个人资料（Profile）

## 技术栈

- **前端框架**：Flutter 3.22.0
- **编程语言**：Dart 3.1.0+
- **状态管理**：flutter_riverpod ^2.3.6
- **路由管理**：go_router ^12.1.1
- **JSON序列化**：json_serializable ^6.7.1、freezed ^2.4.1
- **网络请求**：dio ^5.3.2
- **本地存储**：shared_preferences ^2.2.0
- **数据库**：sqflite ^2.3.0（离线数据）、drift ^2.14.0（类型安全的SQL）
- **国际化**：flutter_localizations
- **UI组件**：cached_network_image ^3.2.3、flutter_svg ^2.0.9
- **工具库**：uuid ^4.0.0、intl ^0.19.0
- **应用图标**：flutter_launcher_icons ^0.13.1

## 开始使用

### 环境要求

- Flutter SDK: 3.22.0 或更高
- Dart SDK: 3.1.0 或更高

### 安装

1. 克隆仓库:
```
git clone https://github.com/yourusername/precious_life.git
cd precious_life
```

2. 安装依赖:
```
flutter pub get
```

3. 生成必要的代码:
```
flutter pub run build_runner build --delete-conflicting-outputs
```

4. 生成应用图标 (不更换图标的话只需要执行一次):
```
dart run flutter_launcher_icons:generate
```

### 运行

在模拟器或真机上运行应用:
```
flutter run
```

## 项目结构

```
lib/
  ├── app/                     # 应用级配置
  │   ├── app.dart             # 应用根组件
  │   ├── di/                  # 依赖注入配置
  │   └── routes/              # 路由配置
  │       ├── app_router.dart  # 路由定义
  │       └── route_constants.dart # 路由常量
  ├── config/                  # 配置文件
  │   ├── app_config.dart      # 应用配置
  │   ├── color_style.dart     # 颜色配置
  │   ├── text_style.dart      # 文字样式配置
  │   └── theme/               # 主题配置
  │       ├── app_theme.dart   # 主题定义
  │       └── theme_provider.dart # 主题状态管理
  ├── core/                    # 核心功能
  │   ├── constants/           # 常量定义
  │   │   ├── app_constants.dart # 应用常量
  │   │   └── api_constants.dart # API常量
  │   ├── network/             # 网络相关
  │   │   ├── api_client.dart  # 基础API客户端
  │   │   ├── api_exception.dart # 网络异常处理
  │   │   └── api/             # 具体API实现
  │   │       ├── qweather/    # 和风天气API
  │   │       └── tianditu/    # 天地图API
  │   ├── database/            # 数据库相关
  │   │   ├── database.dart    # 数据库主文件
  │   │   ├── database.g.dart  # 生成的数据库代码
  │   │   ├── tables/          # 数据表定义
  │   │   │   ├── todo_table.dart
  │   │   │   ├── weather_table.dart
  │   │   │   └── settings_table.dart
  │   │   └── dao/             # 数据访问对象
  │   │       ├── todo_dao.dart
  │   │       ├── weather_dao.dart
  │   │       └── settings_dao.dart
  │   └── utils/               # 工具类
  │       ├── cp_date.dart     # 日期工具
  │       ├── cp_location.dart # 定位工具
  │       ├── cp_log.dart      # 日志工具
  │       ├── cp_screen.dart   # 屏幕工具
  │       ├── cp_storage.dart  # 存储工具（简单数据）
  │       ├── cp_string.dart   # 字符串工具
  │       └── cp_weather.dart  # 天气工具
  ├── data/                    # 数据层
  │   ├── datasources/         # 数据源
  │   │   ├── local/           # 本地数据源
  │   │   │   ├── database_datasource.dart # 数据库数据源
  │   │   │   └── storage_datasource.dart  # 简单存储数据源
  │   │   └── remote/          # 远程数据源
  │   │       ├── weather_remote_datasource.dart
  │   │       └── location_remote_datasource.dart
  │   ├── models/              # 数据模型（跨域共享）
  │   │   ├── common/          # 通用模型
  │   │   ├── weather/         # 天气相关模型
  │   │   └── location/        # 位置相关模型
  │   └── repositories/        # 仓库层（数据访问统一接口）
  │       ├── todo_repository.dart
  │       ├── weather_repository.dart
  │       ├── location_repository.dart
  │       └── settings_repository.dart
  ├── features/                # 功能模块
  │   ├── home/                # 首页模块
  │   │   ├── data/            # 模块特定数据层
  │   │   │   ├── models/      # 模块特定模型
  │   │   │   └── repos/       # 模块特定仓库
  │   │   └── ui/              # UI层
  │   │       ├── pages/       # 页面
  │   │       ├── providers/   # 状态提供者
  │   │       └── widgets/     # 组件
  │   ├── todo/                # 待办事项模块
  │   │   ├── data/            # 模块特定数据层
  │   │   │   └── models/      # 状态模型
  │   │   └── ui/              # UI层
  │   │       ├── models/      # UI层模型
  │   │       ├── pages/       # 页面
  │   │       ├── providers/   # 状态提供者
  │   │       └── widgets/     # 组件
  │   ├── feed/                # 信息流模块
  │   │   ├── data/            # 模块特定数据层
  │   │   ├── providers/       # 状态提供者
  │   │   └── ui/              # UI层
  │   └── tools/               # 工具集合模块
  │       └── ui/              # UI层
  ├── shared/                  # 共享组件
  │   ├── widgets/             # 通用UI组件
  │   │   ├── loading_status_widget.dart
  │   │   └── theme_switch_button.dart
  │   ├── extensions/          # Dart扩展方法
  │   └── mixins/              # 混入类
  └── main.dart                # 应用入口文件

assets/                        # 资源文件夹
  ├── data/                    # 数据文件
  │   └── cities.txt           # 城市数据
  └── images/                  # 图片资源
      ├── bg.png
      └── icon.png

test/                          # 测试目录
  ├── unit/                    # 单元测试
  ├── widget/                  # 组件测试
  └── integration/             # 集成测试
```

## 数据层架构说明

### 三层数据架构

1. **DataSource（数据源层）**：负责具体的数据获取（API、数据库、缓存）
2. **Repository（仓库层）**：统一的数据访问接口，协调多个数据源
3. **UI Layer（UI层）**：通过Repository获取数据，使用Riverpod管理状态

### 数据库设计

- 使用 `drift` 作为主要ORM，提供类型安全的SQL操作
- 使用 `sqflite` 作为底层数据库引擎
- 支持数据迁移和版本管理
- 分表设计：todos、weather_cache、user_settings等

### 存储策略

- **简单配置数据**：使用SharedPreferences（如主题、API Key等）
- **结构化数据**：使用SQLite数据库（如待办事项、天气缓存等）
- **临时数据**：使用内存缓存
- **大文件**：使用文件系统