---
name: sci-excel-table-generator
description: 生成 SCI 规范的 Excel 三线表。当用户要求准备 SCI 表格、附表或 Supplementary Table、Table S时使用。
---

# SCI Excel Table Generator

当用户要求准备 SCI 表格、附表或 Supplementary Table 时，默认应用以下规则。

## Output

1. 优先输出 `.xlsx`，默认仅生成 **1 个 Excel 文件**。
2. 一个文件可包含多个 sheet，sheet 数量尽可能少。
3. 每个 sheet 对应一个 Supplementary Table：
   - Sheet 1 → Table S1
   - Sheet 2 → Table S2
4. 同一分析的不同部分尽量放在同一 sheet，并标记为 Table S1A、S1B、S1C。

## Data Integrity

1. **禁止擅自删除、筛选、截断或汇总替代原始结果。**
2. 分析产生多少结果，就完整输出多少结果。例如 PCA 有 10 个主成分，则保留全部 10 个。
3. 多群体分析必须保留各群体详细结果，不得仅输出均值、中位数等汇总值。
4. 如需汇总，汇总与完整结果必须同时保留，可分别作为 Table S1A 和 Table S1B。
5. 输出前后检查记录数、群体数、维度数及主要分析结果是否完整一致。

## Formatting

默认生成 SCI 三线表：
- 顶线：medium
- 表头下线：thin
- 底线：medium
- 无竖线、无内部网格线、隐藏 Excel 默认网格线
- 标题合并居中
- 表头加粗、居中、自动换行
- 自动调整列宽
- 不使用装饰性色块或复杂配色

## Software

生成前自动检查 R 和 Python 环境。

优先使用：
1. R `openxlsx2`
2. Python `openpyxl` 或 `xlsxwriter`

缺少所需包时自动安装后继续执行，无需用户干预。

## Core Principle

**完整结果优先，汇总不能替代详细结果，默认输出一个规范的 SCI 三线表 Excel 文件。**
