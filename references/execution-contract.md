# 执行契约

本参考规定质量闭环中各角色的责任和节点的最小契约。它不替代项目权限、工程规则或实际工具的安全控制；权限存在不等于本任务已经获得授权。

## 角色边界

| 角色 | 负责 | 不负责 |
|---|---|---|
| 主记录者/编排者 | 读取准入、选择门禁、路由节点、合并交接、推进台账状态 | 把执行者自报当作独立验收 |
| Worker | 在节点范围内执行、保存产物、报告结果和副作用 | 修改目标、扩大范围、宣布交付完成 |
| Checker | 以新鲜上下文核验声明范围和证据 | 代替执行者修复全部缺陷或扩大审查范围 |
| 用户 | 确认目标、范围、产品取舍、权限和不可逆风险 | 为普通工程实现逐项选择内部方案 |
| 外部系统 | 提供实际状态或产生副作用 | 被模型文字假定为已成功 |

## 节点契约

每个需要独立恢复或验收的节点至少声明：

```text
node_id:
goal:
inputs_and_preconditions:
allowed_scope_and_tools:
expected_outputs:
owned_paths_or_resources:
side_effect_class: read / reversible_write / idempotent_write / reconcilable_write / non_retriable_write
evidence_required:
retry_condition_and_budget:
stop_or_escalation_condition:
owner:
```

`expected_outputs` 描述产物，`evidence_required` 描述如何证明产物正确；两者不能混用。节点的完成状态由执行结果和独立验证共同决定。

## 失败与重试

先归类再行动：

- 可查证的临时故障：有限重试，并记录新的结果；
- 确定性实现缺陷：返回执行节点，修复后进入验证；
- 契约或目标变化：返回受影响的最早门禁；
- 权限不足或需要不可逆选择：进入 `awaiting_user`；
- 外部副作用结果不明：进入 `unknown`，先核对实际状态；
- 同类失败没有新增证据：暂停原样重试，先做诊断。

同一个节点只能有一个负责它的重试预算，避免 Worker、工具和外部客户端各自重试造成倍增。涉及外部写入时，优先使用既有幂等键、唯一业务标识或状态查询；没有安全重试条件时停止，不凭模型判断“应该没有成功”。

## 并行交接

并行前声明任务之间的依赖和冲突集合。每个 Worker 使用自己的执行文档和产物入口；合并前由主记录者核对版本、资源冲突和验收覆盖。合并成功不等于功能验收通过，仍需运行对应 Checker。
