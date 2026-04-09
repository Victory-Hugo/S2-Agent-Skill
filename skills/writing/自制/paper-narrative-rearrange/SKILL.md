---
name: paper-narrative-rearrange
description: 对科研文稿进行润色或语言重新组织。
---


## 目标定位

优化表达质量，同时确保成稿中的关键定量结论具备可追溯的证据交付。

1. 提升语法正确性与句式流畅度。
2. 统一中英文术语、缩写和科学指代。
3. 优化段落逻辑衔接与学术语气。
4. 为关键定量结论补齐可交付的 `Figure/` 与 `Table/` 证据产物，并在正文中紧随数字进行回指。

## When To Use

在以下场景使用本技能：

1. 已有初稿，需要语言重新组织到投稿风格。
2. 需要统一术语、修正语言问题、增强可读性。
3. 需要在不改事实前提下进行篇章精修。

## Input Contract

1. `source_text`（必填）
   待重新组织文本，可为原始段落或 `结果解读.md`。
2. `target_style` (optional)
   目标语气/期刊风格，默认 `SCI`。
3. `sections_to_rearrange` (optional)
   需重新组织章节范围；未指定时按全文处理。
4. `term_glossary_optional` (optional)
   术语对照、内部标识符映射规范、缩写表。
5. `length_constraints_optional` (optional)
   篇幅约束，仅允许在不改变事实含义前提下压缩或微扩写。
6. `evidence_inputs`（强烈建议提供；涉及关键数字时视为必填）
   支撑正文中关键定量结论的结果表、统计摘要、图件输入、现成图表文件或其路径。
7. `claim_to_evidence_map_optional` (optional)
   原文关键结论与证据对象之间的映射；若未提供，需在执行时自行建立。
8. `artifact_numbering_optional` (optional)
   已固定的 `Table 1/Fig. 2` 编号规则；未指定时按首次引用顺序编号。

## Preserve Constraints (Hard Rules)

重新组织过程必须保持以下不变：

1. 章节结构与标题层级。
2. 缩写、实体命名及其科学指代关系。
3. 数字集合与统计方向（除格式规范化外）。
4. 结论强度与证据边界。
5. 关键定量结论的证据归属关系。

附加硬性要求：

1. 变量名、文件路径、列名、字段名、脚本名、参数名及其他技术性内部标识符仅可用于内部核对，不得出现在最终输出文本中。
2. 若原文包含上述技术性内部标识符，最终输出必须改写为自然语言指代，同时保持事实含义不变。
3. 最终输出文本不得使用任何列表或表格格式（包括有序列表、无序列表、任务列表、Markdown 表格等），只能使用连续、流畅的自然语言段落进行阐述。
4. 最终输出文本中的每个关键数字性陈述后，必须紧跟期刊风格短引文，例如 `(Table 1; Fig. 2)`，且对应文件必须实际存在于交付目录中。

禁止行为：

1. 新增事实、补造数字、发明引用。
2. 改动统计结论方向或显著性表述含义。
3. 改写为不同章节结构或删除关键信息。
4. 在最终输出中保留或暴露变量名、文件路径、列名等技术性内部标识符。
5. 保留无法由已交付 `Figure` 或 `Table` 支撑的关键数字性结论。

## Execution Order

1. 解析输入并识别章节边界。
2. 建立术语与变量一致性映射。
3. 建立关键定量结论与证据对象的 `Evidence Inventory`。
4. 标记原文中的技术性内部标识符并转换为自然语言表达方案。
5. 生成、整理或重命名所需的 `Figure/` 与 `Table/` 交付文件。
6. 逐段重新组织：语法、措辞、逻辑衔接、句式精炼，并在关键数字后插入证据回指。
7. 执行“保持约束”检查、证据覆盖检查与风险标记。
8. 输出重新组织结果、检查报告及证据产物。

## Build Evidence Inventory First

在改写正文前，先为所有关键定量结论建立证据索引。

| Claim ID | Section | Key Numbers | Source Evidence | Artifact Type | Output File | Citation Form | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| C01 | Results | XXX,XXX; XX.X% | cohort_summary.tsv | Table | Table/Table1.tsv | Table 1 | Available/Needs Build/Blocked | ... |

执行规则：

1. 每个关键定量结论单独占一行；同一句中的多个核心数字可合并为一个 `Claim ID`。
2. `Artifact Type` 仅允许 `Table` 或 `Figure`。
3. `Citation Form` 默认使用正文短格式：`Table X`、`Fig. Y`，正文中组合写作 `(Table X; Fig. Y)`。
4. `Blocked` 项不得被静默跳过；必须进入检查报告并阻断最终完成。

## Rearrange Strategy

逐段执行以下动作：

1. 语法与标点修正。
2. 冗余表达压缩与长句拆分。
3. 逻辑衔接优化（转折、因果、递进、并列）。
4. 学术语气统一（客观、克制、可证据化表述）。
5. 中英文术语镜像与缩写一致化。
6. 将技术性内部标识符改写为读者可直接理解的自然语言指代，避免在成稿中出现原始标识符。
7. 对关键数字性陈述，在不改变原意的前提下紧随其后插入证据短引文，如 `(Table 1)`、`(Fig. 2)` 或 `(Table 1; Fig. 2)`。

## Evidence Output Contract

本技能与 `sci-result-interpretation` 共享同一证据交付契约。默认目录结构如下：

```text
示例/
├── 润色结果.md
├── 润色结果检查.md
├── Table/
│   ├── Table1.tsv
│   └── Table2.tsv
└── Figure/
    ├── Figure1.png
    └── Figure2.png
```

规则：

1. `Table` 文件默认使用 `.tsv`，每个文件只承载一个可直接支撑正文结论的表格对象。
2. `Figure` 文件默认使用 `.png`，每个文件只承载一个正文中被引用的图件对象。
3. 编号必须与正文中的 `(Table X; Fig. Y)` 完全一致。
4. 正文本身仍禁止插入 Markdown 表格或列表；所有表格内容必须外置到 `Table/` 目录。
5. 若已有现成图表，仅允许在不改变科学内容的前提下整理命名、编号和引用，不得伪造新结果。

## Risk Flags

若存在潜在问题，在检查报告中显式给出：

1. `术语不一致`
2. `证据表述过度`
3. `句义漂移风险`
4. `证据缺失阻断`
5. `编号/引用不一致`

必要时附简短修复建议。


## Final Delivery Format (Markdown)

固定输出以下交付物：

### `示例/润色结果.md`

1. `重新组织后文本 (中文)`
2. `Rearranged Text (EN)`

若输入包含章节结构，则保持原章节顺序与标题。
最终输出正文中禁止出现变量名、文件路径、列名、字段名、脚本名、参数名等技术性内部标识符。
最终输出正文不得包含列表与表格，必须以流畅连贯的叙述性语言呈现。
正文中的关键数字性陈述后必须给出短格式证据回指，例如 `(Table 1)`、`(Fig. 2)` 或 `(Table 1; Fig. 2)`。

### `示例/润色结果检查.md`

1. `Preserve Constraints Check`
2. `Terminology Consistency Check`
3. `Identifier Removal Check`
4. `Evidence Coverage Check`
5. `Artifact Manifest`
6. `Risk Flags`
7. `Unresolved Items`（无则写 `None`）

### `示例/Table/`

1. 每个被正文引用的表格必须以 `TableN.tsv` 形式交付。
2. 文件名编号与正文引文保持一致。

### `示例/Figure/`

1. 每个被正文引用的图件必须以 `FigureN.png` 形式交付。
2. 正文引用时使用 `Fig. N`，文件名保持 `FigureN.png`。

## Required Self-Check Before Finish

提交前必须逐项确认：

1. 是否引入了任何新事实或新数字。
2. 是否改变了统计方向、显著性含义或结论强度。
3. 是否保持了章节结构、标题和科学指代关系。
4. 最终输出中是否仍残留变量名、文件路径、列名、字段名或其他技术性内部标识符。
5. 是否存在中英文术语不一致。
6. 每个关键数字性陈述是否都已绑定 `Evidence Inventory` 中的有效 `Table` 或 `Figure`。
7. 正文中的 `(Table X; Fig. Y)` 是否与 `示例/Table/`、`示例/Figure/` 中的文件一一对应。
8. 是否已记录并解释所有风险标记与阻断项。

仅当以上检查全部通过时允许结束任务。
