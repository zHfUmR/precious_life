# 惜命(Precious Life) 项目快速启动指南

## 环境配置

1. **安装Flutter SDK**
   - 访问 [Flutter官网](https://flutter.dev/docs/get-started/install) 下载并安装Flutter SDK
   - 确保Flutter SDK版本为3.22.0或更高
   - Dart SDK版本要求3.1.0或更高

2. **配置开发环境**
   - 配置IDE（推荐使用VS Code或Android Studio）
   - 安装Flutter和Dart插件

3. **验证安装**
   - 在终端/命令行运行`flutter doctor`
   - 确保所有检查项目通过或者解决显示的问题

## 运行项目

1. **获取依赖**
   ```bash
   flutter pub get
   ```

2. **首次运行前生成代码**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   
   此步骤用于生成freezed模型类和JSON序列化代码。

3. **运行应用**
   ```bash
   flutter run
   ```
   
   如果有多个设备连接，可以指定设备：
   ```bash
   flutter run -d <device_id>
   ```

## 项目结构说明

项目采用了模块化结构，主要包括：

- `lib/main.dart` - 应用入口点
- `lib/app/app.dart` - 应用根组件
- `lib/config/` - 配置文件目录（应用配置、路由配置、主题配置）
- `lib/router/router.dart` - 路由实现
- `lib/screens/` - 屏幕组件目录（包含主屏幕和相关组件）
- `lib/pages/` - 页面组件目录
- `lib/core/` - 核心功能（常量、网络、工具类）
- `lib/data/` - 数据层（模型、仓库、数据源）
- `lib/features/` - 功能模块目录
  - `todo/` - 任务管理功能
  - `feed/` - 信息流功能
  - `tools/` - 工具库功能
  - `profile/` - 个人资料功能

## 功能模块说明

项目目前包含以下功能模块：

1. **Todo (任务管理)**
   - 创建、编辑、删除任务
   - 任务分类和标签
   - 任务提醒

2. **Feed (信息流)**
   - 展示有价值的信息
   - 文章阅读和收藏
   - 信息分类

3. **Tools (工具库)**
   - 实用工具集合
   - 时间管理工具
   - 健康相关工具

4. **Profile (个人资料)**
   - 用户信息管理
   - 设置和偏好

## 开发指南

1. **添加新功能**
   - 在`features`目录下创建新的功能模块
   - 遵循现有的目录结构（data/providers/ui）
   - 更新路由配置

2. **状态管理**
   - 使用Riverpod进行状态管理
   - 在providers目录下定义相关Provider

3. **UI开发**
   - 遵循Material Design设计规范
   - 使用主题配置中定义的颜色和样式
   - 支持深色模式

4. **测试**
   - 编写单元测试和Widget测试
   - 在提交代码前运行测试确保质量

## 常见问题

1. **生成代码失败**
   - 确保已安装最新版本的build_runner
   - 尝试清除缓存：`flutter pub run build_runner clean`
   - 重新生成：`flutter pub run build_runner build --delete-conflicting-outputs`

2. **路由问题**
   - 检查config/routes.dart中的路由配置是否正确
   - 确保路由名称与使用处一致

3. **状态管理问题**
   - 检查Provider的定义和使用是否正确
   - 使用ProviderObserver调试状态变化 