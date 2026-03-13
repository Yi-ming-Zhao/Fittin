## Context
力量训练的本质在于循序渐进地提升容量或强度（即 Progressive Overload）。目前市场上的应用大多采用固定的模板方式记录数据，对如 GZCLP, 5/3/1 等复杂的、基于表现进行计算的（Performance-based Progression）计划支持不佳。
本设计文档探讨构建 Fittin v2 的核心引擎——一个纯端侧、去中心化的规则系统，辅以 Isar 本地高速无模式数据库和 Flutter 极爽快的跨端交互，从而使得 App 能够在任意离线环境下运算复杂的计划逻辑。

## Goals / Non-Goals
**Goals:**
* 设计纯 Dart 实现的规则引擎 (Rule Engine)，根据上一次的训练结果推算出本次/下次计划的详情（组次数方案及训练量目标）。
* 将静态模板（Template）数据结构与用户正在进行的训练实例（Instance）分离，满足隔离用户进度不被模板破坏的需求。
* 选用适合在主线程异步加载的高性能本地存储介质（如 Isar），实现完全离线化体验。
* 明确定义供分享用的 JSON Schema 的序列化层结构。

**Non-Goals:**
* 任何形式的云端存储/云同步（当前版本纯采用本地应用模型）。
* 动作视频库及大容量多媒体资源的内置规划。

## Decisions

**1. 架构选型：完全本地化的纯 Dart 演算引擎引擎 (Pure Dart Engine)**
* **Rationale:** 由于计算逻辑可能十分复杂（如当主动作失败2次后触发辅助动作打8折退阶），将其交由独立且“无状态 (Stateless)“ 的纯 Dart 层处理，极大地便于编写单元测试，并且无需依赖 UI 组件即能获得 Next State 预期结果。

**2. 存储方案：选中 Isar 作为核心本地持久化工具**
* **Rationale:** Isar 提供超快的读写速度、强类型的 Dart API，并天生具备非常好的跨平台支持 (Android / iOS / MacOS) 和 JSON Map 操作支持。这避免了使用关系型数据库 (如 SQLite) 时由于嵌套模型 (JSON Tree) 带来的多重关联表联查问题。

**3. 数据实体拆分：Template (静态蓝图) 与 Instance (运行时)**
* **Rationale:** 用户分享计划本质上是传递了 JSON 表达的 Template，App 在解析后在底层将生成一份专属的 Instance 以记录用户进行的特定循环的当前位置和所有修改。这确保了即使用户更新或删除了本地 Template 数据，原有的进度状态机不被污染和打断。

**4. 零延迟的用户界面（Zero-Type UI）同步逻辑**
* **Rationale:** 通过 Riverpod / Provider 管理页面状态。引擎结算后的数据将直接装填到输入框，用户直接点击“完成”即可落库。不使用受控表单 (Controlled Form) 式交互，而使用滑动增加/减少的微调方式减少键盘呼出概率。

## Risks / Trade-offs

* **[Risk] 规则引擎设计过于复杂（Turing Complete 的风险）** → Mitigation: 限制条件（Conditions）与动作（Actions）可使用的高级语义和嵌套层级，初步仅支持诸如 “成功”、“失败”、“单次极限值提升”等强约束类型的触发器节点。
* **[Risk] Isar 强类型系统对自定义 JSON 灵活性的束缚** → Mitigation: 在 Isar 层保留一个 String/Map 类型字段，以 JSON 格式存储用户的 Progression Rules 具体规则细节，而仅在 Engine 层执行反序列化检查，以最大化模板自定义可能性。
