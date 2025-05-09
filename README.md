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
  │   └── app_lifecycle.dart   # 应用生命周期管理
  ├── common/                  # 通用组件
  │   ├── widgets/             # 通用UI组件
  │   └── extensions/          # Dart扩展方法
  ├── config/                  # 配置文件
  │   ├── app_config.dart      # 应用配置
  │   ├── routes.dart          # 路由配置
  │   └── theme.dart           # 主题配置
  ├── core/                    # 核心功能
  │   ├── constants/           # 常量定义
  │   ├── network/             # 网络相关
  │   │   ├── api_client.dart  # API客户端
  │   │   ├── interceptors/    # 网络拦截器
  │   │   └── endpoints.dart   # API端点
  │   └── utils/               # 工具类
  ├── data/                    # 数据层
  │   ├── models/              # 数据模型
  │   ├── repositories/        # 仓库层
  │   └── datasources/         # 数据源
  │       ├── local/           # 本地数据源
  │       └── remote/          # 远程数据源
  ├── features/                # 功能模块
  │   ├── feed/                # 信息流功能
  │   │   ├── data/            # 数据层
  │   │   ├── providers/       # 状态提供者
  │   │   └── ui/              # UI层
  │   │       ├── pages/       # 页面
  │   │       ├── screens/     # 屏幕
  │   │       └── widgets/     # 组件
  │   ├── todo/                # 待办事项功能
  │   │   ├── data/            # 数据层
  │   │   ├── providers/       # 状态提供者
  │   │   └── ui/              # UI层
  │   ├── tools/               # 工具集合功能
  │   │   ├── data/            # 数据层
  │   │   ├── providers/       # 状态提供者
  │   │   └── ui/              # UI层
  │   └── profile/             # 个人资料功能
  │       ├── data/            # 数据层
  │       ├── providers/       # 状态提供者
  │       └── ui/              # UI层
  ├── i18n/                    # 国际化资源
  │   └── translations/        # 翻译文件
  ├── router/                  # 路由配置
  │   ├── router.dart          # 路由定义
  │   └── routes.dart          # 路由常量
  ├── providers/               # 全局状态提供者
  └── main.dart                # 应用入口文件

assets/                        # 资源文件夹
  ├── images/                  # 图片资源
  ├── icons/                   # 图标资源
  └── fonts/                   # 字体资源

test/                          # 测试目录
  ├── unit/                    # 单元测试
  ├── widget/                  # 组件测试
  └── integration/             # 集成测试
``` 