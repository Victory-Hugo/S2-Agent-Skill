# Evidence Execution Rules

本文件存放从 SKILL.md 移出的 Evidence Inventory 表格结构与执行规则，供静默执行阶段内部参考。

## Evidence Inventory 表格结构

在改写正文前，先为所有关键定量结论建立证据索引。

| Claim ID | Section | Key Numbers | Source Evidence | Artifact Type | Output File | Citation Form | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| C01 | Results | XXX,XXX; XX.X% | cohort_summary.tsv | Table | Table/Table1.tsv | Table 1 | Available/Needs Build/Blocked | ... |

## 执行规则

1. 每个关键定量结论单独占一行；同一句中的多个核心数字可合并为一个 `Claim ID`。
2. `Artifact Type` 仅允许 `Table` 或 `Figure`。
3. `Citation Form` 默认使用正文短格式：`Table X`、`Fig. Y`，正文中组合写作 `(Table X; Fig. Y)`。
4. `Blocked` 项不得被静默跳过；必须进入检查报告并阻断最终完成。

## 使用说明

此表格及规则仅用于内部核对，不得以任何形式出现在最终输出文本（润色结果.md）中。
