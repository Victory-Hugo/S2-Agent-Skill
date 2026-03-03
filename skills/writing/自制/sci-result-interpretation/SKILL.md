---
name: sci-result-interpretation
description: 面向科研写作的结果解读技能。根据用户提供的图表、统计检验和模型输出，生成详细的 Methods and Materials、Results、Discussion 三章节双语内容（中文在前，英文在后），并提供完整性与风格检查。用于“解读图表统计结果”“补全详细方法学”“撰写结果与讨论”等场景。仅负责生成科学内容，不用于纯润色、语句打磨或文风美化；若仅需表达优化，请切换 paper-narrative-polish。
---


## 目标定位

生成科学内容，不做表达层润色。

1. 产出详细 `Methods and Materials`。
2. 逐项解读 `Results`，并给出证据边界内的 `Discussion`。
3. 输出中英镜像内容与结构化检查文件，便于后续交给 `paper-narrative-polish` 润色。

## When To Use

在以下场景使用本技能：

1. 用户要求解读图表、统计检验或模型输出。
2. 用户要求补写或细化方法学细节（数据来源、纳排标准、参数、统计方法、软件版本、复现路径）。
3. 用户要求形成完整的 `Methods and Materials + Results + Discussion` 草稿。

## When Not To Use

在以下场景不要使用本技能：

1. 仅需要措辞优化、语法润色、句式精炼、语气统一。
2. 已有完整 M/R/D 内容，仅需文风提升或期刊语气打磨。

上述场景应使用 `paper-narrative-polish`。

## Input Contract

收集并确认以下输入；缺失时记录到 `Missing/Blocked Items`，并先完成可执行部分。

1. `guidance`
   用户目标、研究问题、目标期刊偏好、特殊限制。
2. `background`
   研究背景、实验设计、分组定义、关键变量。
3. `results`
   待解读结果（图、表、统计检验、模型输出）。
4. `paths`
   数据目录、代码路径、结果目录、复现相关路径。
5. `references_optional` (optional)
   用户提供的参考文献列表。
6. `analysis_skill_docs` (optional)
   分析专用技能文档路径，如 PCA/生存分析等。
7. `target_style` (optional)
   默认 `SCI`；用户显式指定时覆盖表达层风格规则。

## Non-Negotiable Defaults

1. 章节固定为 `Methods and Materials`、`Results`、`Discussion`。
2. 每个章节固定为 `中文块 -> 英文块`。
3. 默认深度为详细解读：结果现象、统计证据、机制解释、局限性都要覆盖。
4. 不得编造数据、流程、参数或引用。
5. 仅使用用户提供文献；缺失时标注 `[Citation Needed: ...]`。

## Execution Order

1. 读取 `guidance`、`background`、`paths`。
2. 读取 `results` 并建立 `Result ID` 索引。
3. 若存在 `analysis_skill_docs`，建立分析技能映射并注入必需要素。
4. 先写 `Methods and Materials`，再按 `Result ID` 写 `Results`，最后写 `Discussion`。
5. 执行完整性检查与风格检查；失败则回补并复检。

## Build Result Inventory First

在写正文前，创建结果索引并编号。

| Result ID | Source File/Figure/Table | Analysis Type | CN Draft | EN Draft | Coverage | Notes |
|---|---|---|---|---|---|---|
| R01 | ... | ... | Pending/Done | Pending/Done | Missing/Complete | ... |

执行规则：

1. 每个可识别结果对象单独占一行。
2. `Coverage` 初始为 `Missing`，双语解读完成后改为 `Complete`。
3. 未进入索引的结果视为漏项，不允许结束任务。

## Fuse Analysis-Specific Skills

若 `analysis_skill_docs` 非空，执行融合流程：

1. 提取每个文档的适用分析类型、必需解释字段和禁止项。
2. 将每个 `Result ID` 映射到最匹配的分析技能。
3. 冲突优先级：分析解释要求优先，写作框架要求次之。
4. 无匹配时回退到本技能通用高深度框架。

匹配记录表：

| Result ID | Analysis Type | Detection Signals | Matched Skill Doc | Skill Match Score | Required Elements | Status | Uncertainty Note |
|---|---|---|---|---|---|---|---|
| R01 | PCA | label: PCA; term: PC1/PC2 | PCA-interpretation.md | 88 | Explained variance, separation, loadings | Applied | None |

## Write Detailed Methods and Materials

方法学必须“详细可复述”，至少覆盖以下子模块。

1. 数据来源与研究对象：数据来源、时间范围、纳入排除标准。
2. 样本与分组：样本量、分组依据、关键协变量定义。
3. 预处理与质量控制：清洗规则、缺失处理、异常值策略、QC阈值。
4. 分析流程与参数：算法、模型、参数设置、超参数选择逻辑。
5. 统计方法：检验方法、显著性阈值、多重校正策略、效应量指标。
6. 软件与计算环境：软件/包版本、运行环境、关键命令或模块。
7. 复现路径：代码与结果路径、可复现步骤摘要；缺失时显式声明。

要求：

1. 先中文后英文。
2. 中英文语义等价，术语一致。
3. 参数或流程信息缺失时必须声明，不得臆造。

## Write Results (Per Result ID)

对每个 `Result ID` 单独成段，不得合并遗漏。每项至少包含：

1. 结果现象：主要模式、趋势、方向。
2. 统计证据：效应方向/量级 + P 值、区间或模型指标。
3. 分析专用解释：若匹配到专用技能，注入必需解释字段。
4. 领域解释：在证据支持范围内给出机制或生物学含义。
5. 局限说明：偏倚来源、样本限制、方法边界。

完成中文后生成英文镜像段落。

## Write Discussion

讨论必须与结果逐项对应并进行综合：

1. 归纳关键发现，不重复堆砌原始数字。
2. 解释潜在机制与理论意义，避免超出证据边界。
3. 比较不同结果间一致性与差异性。
4. 说明局限性、外推边界与潜在偏倚。
5. 提出谨慎可执行的后续研究建议。

要求先中文后英文，结构保持镜像。

## Style Validation (Default: SCI)

输出 `Style Validation Report`，检查：

1. 学术语体是否客观克制。
2. 关键主张是否有数据或统计支撑。
3. `Results` 与 `Discussion` 是否分层清晰。
4. 中英文术语、缩写、变量名是否一致。
5. 三大章节与双语是否齐全。

若用户指定非 SCI 风格，仅替换表达层规则，不可覆盖科学底线。

## Non-Overridable Scientific Constraints

无论 `target_style` 为何，都必须满足：

1. 关键结论必须有证据支撑。
2. 禁止超出证据范围外推。
3. 禁止编造数据、流程、引用。
4. 中英文术语与变量命名一致。
5. 缺失信息必须显式声明。

## Completeness Gate (Hard Stop)

结束前必须通过以下检查：

1. `Result ID` 全覆盖：全部结果完成中英文解读。
2. 内容要素全覆盖：每条结果均含现象、证据、解释、局限。
3. 章节全覆盖：`Methods and Materials`、`Results`、`Discussion` 全部齐全且双语齐全。
4. 融合检查：匹配到分析技能的结果均已应用专用要求。

失败时必须列缺失项、补写、复检。

## Handoff To paper-narrative-polish

当用户要求“解读 + 润色”时，顺序固定：

1. 先运行本技能生成科学内容。
2. 再将 `结果解读.md` 作为输入交给 `paper-narrative-polish` 做表达优化。

交接时不得改写事实、数字含义和统计结论方向。

## Final Delivery Format (Markdown)

固定输出两个文件：

### `结果解读.md`

1. `方法与材料 (中文)`
2. `Methods and Materials (EN)`
3. `结果 (中文)`
4. `Results (EN)`
5. `讨论 (中文)`
6. `Discussion (EN)`

### `结果解读-完整性检查.md`

1. `Skill Fusion Log`
2. `Style Validation Report`
3. `Completeness Checklist`
4. `Missing/Blocked Items`（无则写 `None`）

## Structured Validation Artifacts

`Completeness Checklist`：

| Result ID | CN Complete | EN Complete | Evidence Present | Mechanism Present | Limitation Present | Skill Fusion Applied | Final Status |
|---|---|---|---|---|---|---|---|
| R01 | Yes/No | Yes/No | Yes/No | Yes/No | Yes/No | Yes/No | Pass/Fail |

`Missing/Blocked Items`：

| Item ID | Category | Missing/Blocked Detail | Impacted Sections | Required Action | Owner | Status |
|---|---|---|---|---|---|---|
| M01 | Data/Stat/Reference/Path/Other | ... | Methods/Results/Discussion | ... | User/Agent | Open/In-Progress/Resolved |

结束条件：

1. `Completeness Checklist` 全部 `Pass`。
2. `Missing/Blocked Items` 全部 `Resolved` 或为 `None`。
