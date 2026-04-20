# Fittin

Fittin 是一个基于 Flutter 的力量训练应用，重点是低摩擦训练记录、结构化训练模板、双语体验，以及偏 premium / mobile-first 的训练交互。

这个仓库是当前产品原型的主代码库。产品需求、行为约束和迭代方向由 `openspec/specs/` 中的 OpenSpec 文档驱动，Flutter 代码则是这些规格在当前时刻的实现结果。

## 项目定位

Fittin 不是传统的“表单型健身记录器”，而是更接近一个专注的训练控制台：

- 更少打字，更依赖点击、滑动和大触控目标
- 强调“今日训练”“当前动作”“当前组”的视觉层级
- 支持可复用的力量训练模板与规则驱动训练逻辑
- 中英双语体验在同一套 UI 中保持清晰

## 当前能力范围

项目当前已经覆盖并在应用中体现的能力包括：

- 首页 Dashboard 与 “Today’s Workout” 入口
- 多动作训练日的进行中训练流程
- 训练计划库，含内置模板和自定义模板
- 应用内训练模板编辑器
- 进步分析与训练数据展示
- 中英文语言切换
- 本地优先持久化
- Supabase 认证与用户云同步基础能力
- 分享 / 导出相关基础设施

当前主规格可在 `openspec/specs/` 中查看，例如：

- `today-workout-gateway`
- `multi-exercise-session`
- `plan-template-editor`
- `plan-rule-engine`
- `progress-analytics`
- `user-account-authentication`
- `user-cloud-sync`
- `premium-minimal-frontend-redesign`

## 技术栈

- Flutter
- Dart
- Riverpod
- Isar
- Freezed
- JSON Serializable
- Supabase
- OpenSpec

## 目录结构

```text
lib/
  main.dart
  src/
    application/   # Provider、应用服务、bootstrap
    data/          # 本地数据库、远端仓库、seed 数据
    domain/        # 训练模型、规则引擎、业务逻辑
    presentation/  # 页面、组件、主题、本地化

test/              # application / data / domain / presentation 测试
assets/            # 训练模板 JSON、指南 markdown 等资源
supabase/          # 本地 Supabase 配置与迁移
openspec/
  config.yaml
  specs/           # 主规格（当前产品契约）
  changes/         # 进行中或已归档的变更
```

## 内置训练内容

当前项目内置了至少以下训练模板：

- GZCLP
- Jacked & Tan 2.0

这些模板可以作为本地内置计划直接使用，也可以作为自定义计划的起点。

## 本地开发

### 1. 环境要求

- Flutter SDK
- Xcode（macOS 开发）
- CocoaPods
- Supabase CLI（如需本地后端）

如果你的 shell 还没有配置 Flutter，可将下面这行加入 `~/.zshrc`：

```bash
export PATH="/usr/local/share/flutter/bin:$PATH"
```

然后执行：

```bash
source ~/.zshrc
flutter --version
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 启动本地 Supabase

项目已包含本地 Supabase 配置与迁移文件，目录在 `supabase/`。

启动：

```bash
supabase start
```

查看状态：

```bash
supabase status
```

本地开发环境通常会输出：

- Project URL，例如 `http://127.0.0.1:55321`
- Studio 地址，例如 `http://127.0.0.1:55323`
- 本地数据库连接串
- Publishable key / Secret key

当前项目会优先使用显式传入的 `SUPABASE_URL` / `SUPABASE_ANON_KEY`；如果未提供，则仅会在本地 Supabase 开发环境实际可达时自动回退连接。Android APK 构建不再尝试自动连接仓库本机的 `127.0.0.1` Supabase；请为 APK 显式传入这两个 `dart-define`。

### 4. 运行应用

macOS：

```bash
flutter run -d macos
```

如果只做构建验证：

```bash
flutter build macos
```

### 5. 运行测试

运行全部测试：

```bash
flutter test
```

运行指定测试：

```bash
flutter test test/data/sync_service_test.dart
flutter test test/application/sync_provider_test.dart
flutter test test/presentation/plan_editor_screen_test.dart
```

## Web 公网发布

如果你要把 Flutter Web 客户端发布到公网子域名，例如 `fittin.yimelo.cc`，请查看：

- `docs/web-public-deployment.md`

这份文档覆盖：

- release 构建命令
- `SUPABASE_URL` / `SUPABASE_ANON_KEY` 注入方式
- 本机 Caddy 静态托管
- Cloudflare Tunnel ingress 形状
- smoke checks 与回滚步骤

常用的一键更新命令：

```bash
tool/update_public_web.sh
```

这个脚本也会在构建前自动执行 `tool/fix_isar_web_schema_ids.dart`，避免 Web 构建被 Isar 生成文件中的超大整数常量卡住。

## OpenSpec 是什么

OpenSpec 是这个仓库的规格驱动开发工作流。可以把它理解为：

- `openspec/specs/` 是当前产品契约
- `openspec/changes/<change>/` 是一轮变更的工作区
- 代码实现应该跟随 spec 变化，而不是先写完代码再补文档

在这个仓库里，OpenSpec 不只是“写需求文档”，而是完整地串起：

1. 提出变更
2. 明确设计
3. 拆分任务
4. 实现代码
5. 验证结果
6. 同步主 specs
7. 归档 change

## OpenSpec 安装

如果本机还没有 OpenSpec CLI，可以先看是否已安装：

```bash
openspec --help
```

如果命令不存在，请按 OpenSpec 官方方式安装。安装完成后，确认：

```bash
openspec --version
openspec --help
```

当前 CLI 常用能力包括：

- `openspec init`
- `openspec list`
- `openspec status`
- `openspec show`
- `openspec validate`
- `openspec archive`
- `openspec instructions`

## OpenSpec 工作流

下面是一套适合这个仓库的推荐工作流。

### 1. 查看当前 specs 和 changes

查看进行中的 change：

```bash
openspec list --json
```

查看某个 change 的状态：

```bash
openspec status --change "<change-name>" --json
```

查看主 specs：

```bash
openspec list --specs
```

### 2. 创建一个新 change

当你准备做一个新功能、重构或行为修改时，不建议直接改代码。先建立变更：

```bash
openspec new
```

或者使用相关子命令建立 change proposal。创建完成后，通常会在：

```text
openspec/changes/<change-name>/
```

看到这类文件：

- `proposal.md`
- `design.md`
- `tasks.md`
- `specs/<capability>/spec.md`

### 3. 编写 proposal

`proposal.md` 主要回答：

- 为什么要做这次变更
- 变更目标是什么
- 不做什么
- 影响范围是什么

proposal 不是实现细节，而是给团队和未来自己一个范围定义。

### 4. 编写 design

`design.md` 主要回答：

- 架构和数据流怎么变
- 为什么选这个方案
- 风险在哪里
- 如何迁移、如何回滚

当需求跨越 UI、状态管理、数据层、后端同步时，设计文档尤其重要。

### 5. 更新 delta specs

如果这次 change 会修改产品行为，需要在：

```text
openspec/changes/<change-name>/specs/<capability>/spec.md
```

里写 delta spec。

常见格式包括：

- `## ADDED Requirements`
- `## MODIFIED Requirements`
- `## REMOVED Requirements`
- `## RENAMED Requirements`

这些 delta specs 不是主规格本身，而是“这次 change 想怎么修改主规格”。

### 6. 拆任务

在 `tasks.md` 中把实现拆成可执行项，例如：

- 数据模型变更
- Provider / service 改造
- 页面改造
- 测试补齐
- 验证项

完成后将：

```text
- [ ]
```

改成：

```text
- [x]
```

### 7. 按 specs 实现代码

实现时建议始终以主 specs + 当前 change 的 delta specs 为准。

推荐顺序：

1. 先读 `proposal.md`
2. 再读 `design.md`
3. 再读 delta specs
4. 最后按 `tasks.md` 实现

可用下面的命令辅助：

```bash
openspec instructions apply --change "<change-name>" --json
```

这个命令会告诉你当前 change 的上下文文件、已完成任务、剩余任务。

### 8. 验证实现

代码完成后，至少要做两类验证：

- 规格验证：需求是否被实现
- 工程验证：测试 / 构建是否通过

OpenSpec 侧：

```bash
openspec validate
```

Flutter 侧：

```bash
flutter test
flutter build macos
```

### 9. 同步主 specs

当 change 中的 delta specs 已经代表了最终产品行为，需要把它们同步回主 specs：

```text
openspec/specs/
```

你可以手动同步，也可以使用仓库里约定的 OpenSpec sync 工作流。同步完成后，主 specs 才真正代表“当前系统应该是什么样”。

### 10. 归档 change

确认以下条件后再 archive：

- proposal / design / tasks / delta specs 都完成
- 任务已全部完成
- 主 specs 已同步
- 测试和构建通过

归档：

```bash
openspec archive <change-name>
```

归档后 change 会移动到：

```text
openspec/changes/archive/YYYY-MM-DD-<change-name>/
```

## 这个仓库里的 OpenSpec 实践建议

结合 Fittin 当前代码库，比较推荐这样使用 OpenSpec：

- 涉及产品行为变化时，一定先改 specs 再改代码
- 涉及同步、认证、数据库 schema、模板编辑器时，一定补 `design.md`
- UI 改动不要只写“页面改了”，要把用户能做什么、不能做什么写成 requirement + scenario
- `tasks.md` 里务必把“测试”和“验证”列成明确任务
- archive 前务必把 delta specs 同步回主 specs

## 常用命令速查

```bash
# 查看帮助
openspec --help

# 查看当前 change
openspec list --json

# 查看 specs
openspec list --specs

# 查看 change 状态
openspec status --change "<change-name>" --json

# 查看创建 / 实现说明
openspec instructions apply --change "<change-name>" --json

# 校验
openspec validate

# 归档
openspec archive <change-name>
```

## 当前状态说明

Fittin 目前仍然处于持续演进中：

- 部分 specs 已经完全落地
- 部分 specs 代表正在进行中的产品方向
- 代码实现和 OpenSpec 主规格应尽量保持同步

如果你要开始一个新功能，最好的切入点通常不是 `lib/`，而是先看：

```text
openspec/specs/
```

再决定是否需要新建一个 change。
