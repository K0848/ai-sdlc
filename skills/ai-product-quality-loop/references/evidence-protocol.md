# 证据协议

本参考规定门禁和节点如何使用证据。计划、代码存在、工具返回成功或执行者自报完成都不能单独关闭验收。

## 证据最小描述

每个用于关闭验收项的证据，都应能在执行文档或项目产物中回答：

```text
evidence_id:
acceptance_ids:
source_or_entrypoint:
artifact_or_code_version:
environment_and_dependencies:
input_and_observed_output:
observed_at:
produced_by:
verified_by:
proves:
does_not_prove:
limitations:
```

大型日志不复制进台账，只保留稳定入口、版本或摘要。截图只能证明截图中可见的状态；测试文件存在只能证明文件存在；命令退出码为 0 只能证明该命令在该环境完成，不能自动证明业务结果。

## 证据等级与检查结论

| 结论 | 含义 |
|---|---|
| `Pass` | 在声明范围、版本和条件下，证据满足该检查项 |
| `Finding` | 已有具体证据证明不满足、存在缺陷或出现矛盾 |
| `Unverified` | 入口、环境、数据、证据或独立核验不足，不能推断通过 |
| `Out of Scope` | 本轮明确不承诺，不能伪装成已验证 |

执行者证据和 Checker 结论分开记录。Checker 必须说明实际核验了什么、使用了哪个版本和入口、覆盖了哪些验收项、还留下哪些限制。

## 证据失效

以下变化至少需要重新核对受影响证据：

- 验收范围、目标或禁止结果变化；
- 接口、数据结构、权限或失败语义变化；
- 源码、构建产物、模型、工具或依赖版本变化；
- 测试数据、运行环境或外部服务状态变化；
- 发现结果与既有证据矛盾。

失效是局部的。没有受到变化影响的验收项继续引用有效证据，不要求全量重做。

## 放行谓词

限定范围内的放行应能还原为以下判断：

```text
scope_is_current
AND required_acceptance_has_results
AND evidence_matches_version_and_environment
AND checker_completed
AND no_open_blocker
AND required_external_side_effects_reconciled
```

任一项不成立时，门禁状态应为 `Passed for limited scope`、`Changes required` 或 `Review incomplete`，并明确下一步，不写成“已完成”。
