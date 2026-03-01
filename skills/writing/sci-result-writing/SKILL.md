---
name: sci-analysis-paper-writer
description: 根据用户提供的分析结果、上下文信息撰写符合SCI论文要求的方法材料（Methods and Materials）、结果（Results）、讨论（Discussion）章节（中英双语，先中文后英文）。完成后执行完整性检查与写作风格校验。用于“根据分析结果写论文/解读图表统计结果/撰写SCI结果与讨论”等任务；若用户提供分析专用SKILL文档（如PCA解读规范），必须与本技能融合执行。
---

# SCI Analysis to Paper Writer

## Input Contract

收集并确认以下输入；缺失时先在 `Missing/Blocked Items` 记录，再继续可执行部分：

1. `guidance`
   用户目标、研究问题、目标期刊偏好、特殊约束。
2. `paths`
   数据目录、代码路径、结果目录。
3. `background`
   研究背景、实验设计、分组定义、关键变量。
4. `results`
   所有待解读结果（图、表、统计检验、模型输出）。
5. `references_optional`
   用户提供文献列表（可为空）。
6. `target_style` (optional)
   默认值为 `SCI`；用户明确指定其他风格时覆盖默认。
7. `analysis_skill_docs` (optional)
   分析专用技能路径列表，如 `PCA-解读.md` 或其他 `SKILL.md`。

派生并维护以下内部判定字段（文档内契约）：

1. `analysis_type_detection_signals`
   每个 `Result ID` 的分析类型识别信号，按优先级记录证据来源。
2. `skill_match_score`
   每个 `Result ID` 与候选分析专用技能的匹配分数（0-100）。
3. `non_overridable_scientific_constraints`
   不可被 `target_style` 覆盖的科学写作底线约束集合。

## Non-Negotiable Defaults

1. 默认章节结构：`Methods and Materials + Results + Discussion`。
2. 默认双语排版：每个章节均按 `中文块 -> 英文块` 输出。
3. 默认深度：高深度（结果现象、统计证据、机制解释、局限性均需覆盖）。
4. 默认引用策略：仅使用用户提供文献；缺失时标注 `[Citation Needed: ...]`，不得编造引用。
5. 默认风格：SCI；仅在用户明确指定时切换风格。
6. 完整性硬门禁：所有结果必须逐项解读后才能结束。

## Execution Order

严格按以下顺序执行：

1. 读取用户指引与上下文（`guidance`, `paths`, `background`）。
2. 若存在 `analysis_skill_docs`，逐个读取并提取分析类型与必需解读要素。
3. 读取分析结果（`results`）并建立结果索引。
4. 逐项撰写 `Methods and Materials`、`Results`、`Discussion`（中英双语）。
5. 执行双重终检：完整性检查 + 风格检查。
6. 若任一检查失败，先列缺失项，再自动回补，随后复检。

## Build Result Inventory First

在写正文前，先创建结果索引表并编号 `Result ID`：

| Result ID | Source File/Figure/Table | Analysis Type | CN Draft | EN Draft | Coverage | Notes |
|---|---|---|---|---|---|---|
| R01 | ... | ... | Pending/Done | Pending/Done | Missing/Complete | ... |

执行规则：

1. 每个可识别结果对象（图/表/统计输出）占一行。
2. `Coverage` 初始标记 `Missing`，完成双语解读后改为 `Complete`。
3. 任何未进入索引的结果视为漏项，不允许结束任务。

## Fuse Analysis-Specific Skills

若 `analysis_skill_docs` 非空，执行融合流程：

1. 为每个文档提取：
   - 适用分析类型（如 PCA、差异分析、生存分析）。
   - 该分析的必需解释字段（例如 PCA 的方差贡献率、组间分离模式、载荷主导变量）。
   - 禁止项与质量标准（若文档定义）。
2. 将 `Result ID` 映射到分析类型，建立融合映射表：

| Result ID | Analysis Type | analysis_type_detection_signals | Matched Skill Doc | skill_match_score | Required Interpretation Elements | Status | Uncertainty Note |
|---|---|---|---|---|---|---|---|
| R01 | PCA | figure label: PCA; output term: PC1/PC2 | PCA-解读.md | 88 | Explained variance, clustering separation, loadings | Applied | None |

3. 冲突处理优先级固定为：
   - 分析内容优先：统计解释、机制要点、分析术语遵循分析专用技能。
   - 写作格式优先：章节组织、SCI语体、双语排版遵循本技能。
4. 若无匹配分析技能，回退到本技能通用高深度解读框架。
5. 若多个分析技能同时命中，优先选择分析类型匹配最精确者，并在 `Skill Fusion Log` 记录理由。

### Deterministic Matching Protocol

为保证匹配可执行且可复现，必须按以下规则计算并记录 `analysis_type_detection_signals` 与 `skill_match_score`：

1. 分析类型识别信号优先级（从高到低）：
   1. 结果文件名、图注、表头中的显式标签（如 `PCA`, `UMAP`, `DEG`, `Cox`）。
   2. 统计输出特征词（如 `PC1/PC2`, `log2FC`, `hazard ratio`）。
   3. 代码路径与脚本名信号（如 `pca.py`, `deseq2.R`）。
   4. 用户 `guidance` 中明示的分析类型。
2. 匹配评分阈值：
   1. `skill_match_score >= 70`：强匹配，直接应用对应分析专用技能。
   2. `40 <= skill_match_score <= 69`：弱匹配，记录不确定性，并应用“通用框架 + 已知专用要素”。
   3. `skill_match_score < 40`：不匹配，回退通用框架。
3. 并列冲突决策顺序（必须逐条比较）：
   1. 分析类型精确度（方法名精确匹配优先于大类匹配）。
   2. 要求覆盖度（必需字段覆盖更多者优先）。
   3. 来源可信度（用户明确提供路径者优先）。
   4. 若仍并列，指定一主一辅技能，并在 `Skill Fusion Log` 写明主辅依据。

## Write Methods and Materials

按用户上下文和结果来源生成方法章节，至少覆盖：

1. 数据来源与纳入排除逻辑。
2. 预处理与质量控制步骤。
3. 分析方法与参数设定。
4. 统计检验方法与显著性阈值。
5. 复现信息（代码路径、关键软件/版本；若缺失则显式声明）。

先写中文，再写英文；中英文信息内容需等价。

## Write Results (Per Result ID)

对每个 `Result ID` 单独成段解读，不得合并遗漏。每项至少包含：

1. 结果现象：观察到的主要模式与方向。
2. 证据强度：效应方向/量级 + 统计依据（P值、区间、模型指标等）。
3. 分析专用解释：若有匹配技能，注入其强制要素。
4. 生物学/机制或领域解释：在证据支持范围内推断。
5. 局限与替代解释：指出潜在偏倚、样本限制、方法边界。

完成中文后生成对应英文段落，保持语义一致与术语统一。

## Write Discussion

讨论章节必须与结果一一对应并进行综合：

1. 总结关键发现，不重复罗列原始数字。
2. 解释潜在机制与理论意义，避免超出证据边界。
3. 比较不同结果之间的一致性与差异性。
4. 明确研究局限、外推边界与潜在偏倚来源。
5. 给出谨慎、可执行的后续研究建议。

先中文后英文，保持结构镜像。

## Style Validation (Default: SCI)

在用户未指定其他风格时，执行 SCI 风格校验并输出 `Style Validation Report`。校验维度：

1. 学术语体：客观、克制、避免口语和夸张性措辞。
2. 证据表达：每个关键主张都要有对应数据/统计支撑。
3. 逻辑结构：结果描述与讨论推理清晰分层，不过度外推。
4. 术语一致性：中英文术语、缩写、变量名前后一致。
5. 章节完整性：`Methods and Materials`、`Results`、`Discussion` 全部存在且双语齐全。

若用户显式指定其他风格：

1. 使用用户指定风格替换“表达风格规则”（语气、行文风格、段落呈现偏好）。
2. 不得覆盖 `non_overridable_scientific_constraints`。
3. 在 `Style Validation Report` 记录“已覆盖默认SCI风格层规则”的说明。

### Non-Overridable Scientific Constraints

无论 `target_style` 为何，必须始终满足以下科学底线：

1. 关键主张必须有数据或统计依据支持。
2. 禁止超出证据范围外推结论。
3. `Results` 与 `Discussion` 保持逻辑分层，不混写。
4. 中英文术语、缩写、变量名称一致。
5. 缺失信息必须显式声明，不得臆造数据、流程或引用。

发现不合规项时：

1. 输出问题清单（按章节与严重性标记）。
2. 自动修订后再次校验。
3. 仅在全部达标后进入最终交付。

当用户指定非 SCI 风格时，`Style Validation Report` 必须同时输出：

1. `Style-Specific Check`
2. `Scientific-Core Check`

## Completeness Gate (Hard Stop)

结束前必须执行并通过以下检查：

1. 索引覆盖检查：所有 `Result ID` 均已完成中英文解读。
2. 内容要素检查：每个结果段均包含现象、统计证据、机制/解释、局限。
3. 章节检查：三大章节齐全且中英文均齐全。
4. 融合检查：有匹配分析技能的结果均已应用专用要求。

若任一失败：

1. 输出结构化缺失表，并关联 `Result ID` 与受影响章节。
2. 补写缺失内容。
3. 更新 `Completeness Checklist` 对应行状态与证据字段。
4. 重复检查，直至全部通过。

## Final Delivery Format (Markdown)

按以下固定顺序输出：

1. `Methods and Materials (CN)`
2. `Methods and Materials (EN)`
3. `Results (CN)`（按 `Result ID` 子节）
4. `Results (EN)`（按 `Result ID` 子节）
5. `Discussion (CN)`
6. `Discussion (EN)`
7. `Skill Fusion Log`
8. `Style Validation Report`
9. `Completeness Checklist`
10. `Missing/Blocked Items`（无则写 `None`）

## Structured Validation Artifacts

在最终交付中，`Completeness Checklist` 与 `Missing/Blocked Items` 必须使用以下固定表格，不得用自由文本替代。

`Completeness Checklist` 表头：

| Result ID | CN Complete | EN Complete | Evidence Present | Mechanism Present | Limitation Present | Skill Fusion Applied | Final Status |
|---|---|---|---|---|---|---|---|
| R01 | Yes/No | Yes/No | Yes/No | Yes/No | Yes/No | Yes/No | Pass/Fail |

`Missing/Blocked Items` 表头：

| Item ID | Category | Missing/Blocked Detail | Impacted Sections | Required Action | Owner | Status |
|---|---|---|---|---|---|---|
| M01 | Data/Stat/Reference/Path/Other | ... | Methods/Results/Discussion | ... | User/Agent | Open/In-Progress/Resolved |

状态枚举与结束条件：

1. `Final Status` 仅允许 `Pass` 或 `Fail`。
2. `Status` 仅允许 `Open`、`In-Progress`、`Resolved`。
3. 仅当 `Completeness Checklist` 全部为 `Pass`，且 `Missing/Blocked Items` 全部为 `Resolved` 或 `None`，才允许结束任务。

## Required Self-Check Before Finish

结束前执行最终自检并显式报告：

1. `Result ID` 总数与已解读数是否一致。
2. 是否存在未引用或未解释的结果文件。
3. 是否存在无统计依据的关键结论。
4. 是否存在中英文内容不一致或术语不一致。
5. 是否存在未处理的风格校验问题。
6. 是否存在 `skill_match_score < 70` 且未记录不确定性说明。
7. 在用户自定义风格下，是否通过 `Scientific-Core Check`。

仅当上述全部为“通过”时，才允许结束任务。
