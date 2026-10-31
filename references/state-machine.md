# 质量闭环状态机

本参考用于需要跨阶段恢复、并行执行、独立验收或外部副作用的 M/L 任务。简单任务沿用直接执行路径，不为了形式创建完整状态机。

## 节点状态

| 状态 | 含义 | 允许的下一步 |
|---|---|---|
| `pending` | 已登记但前置条件未满足 | `ready`、`superseded` |
| `ready` | 输入、权限和前置条件已满足 | `running`、`blocked`、`awaiting_user` |
| `running` | 执行者正在执行 | `verifying`、`blocked`、`unknown`、`cancelled` |
| `verifying` | 等待独立检查或正在检查 | `passed`、`failed`、`blocked`、`unknown` |
| `passed` | 声明范围内证据满足关闭条件 | 下一节点的 `pending/ready`、`superseded` |
| `failed` | 已确认行为不满足验收或执行失败 | `ready`、`blocked`、`superseded` |
| `blocked` | 缺少输入、权限、依赖或环境条件 | `ready`、`awaiting_user`、`superseded` |
| `awaiting_user` | 越过用户决策边界，等待明确选择 | `ready`、`superseded` |
| `unknown` | 中断、超时或外部副作用结果不明 | `verifying`、`failed`、`blocked` |
| `cancelled` | 经授权停止，不能自动恢复执行 | `superseded` |
| `superseded` | 目标、范围或契约变化后不再适用 | 仅保留历史依据 |

`passed` 只表示当前范围和当前版本通过。范围、契约、权限、数据来源、代码/产物版本或验证环境变化时，受影响节点进入 `superseded` 或重新 `verifying`，不能继续引用旧的通过状态。

## 转换记录

每次有意义的状态变化，在现有规划台账中保留足够信息：

```text
node_id:
previous_state:
new_state:
reason:
actor_or_owner:
scope_or_contract_version:
evidence_refs:
next_action:
```

这不是要求为每个工具调用写日志。`progress.md` 保留当前唯一快照；`changelog.md` 记录有实质结果的阶段变化；详细转换和原始证据留在执行文档中。

## 恢复规则

1. 恢复时先读取 `progress.md` 的当前快照、最近交接锚点、实际产物和未结事项。
2. 若上次处于 `running`、`verifying` 或 `unknown`，先核对外部状态、文件差异、构建产物和副作用，再决定继续或回退。
3. 不能用聊天中的“已经完成”推进状态；没有可核验的执行文档或证据时，依赖该结果的范围保持未验证。
4. 只回退受变化影响的最早门禁；没有变化的已通过范围继续沿用。
5. 用户改变目标或范围时，记录新决定，更新 `task_plan.md` 的当前范围，重新计算受影响节点，不覆盖旧结论。

## 并行与单一记录者

并行节点必须提前写明输入、输出、共享资源、冲突处理和合并责任。执行者先在所属文档保存完整结果，主记录者按稳定交接锚点合并 `progress.md`；多个执行者不能直接竞争写同一个当前快照。

节点关闭条件同时满足以下各项：

```text
当前范围有效
AND 必要验收项已有结果
AND 证据对应当前源码/产物版本
AND Checker 已独立验证
AND 没有未处置 Blocker
```

否则使用 `Passed for limited scope`、`partial`、`blocked` 或 `unverified` 等准确状态，不向上包装为完整通过。
