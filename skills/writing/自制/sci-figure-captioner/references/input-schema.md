# 输入模式说明（Input Schema）

本文件定义 `sci-figure-captioner` 的输入字段、最低要求和推荐组合，用于稳定生成可审阅的 SCI 图注。

## 1. 字段定义

### 1.1 必需字段

1. `figure_image`
- 含义：待撰写图注的 SCI 插图（单图或多面板拼图）。
- 要求：图像可读，关键标注尽量清晰。

### 1.2 强烈建议字段

1. `figure_code`
- 含义：生成该图的代码（Python/R/Matlab 等）。
- 作用：确认坐标、分组、误差线定义、统计注释来源。

2. `source_data`
- 含义：作图原始或整理后的数据表。
- 作用：确认数值范围、单位、样本量定义。

3. `stats_info`
- 含义：统计方法信息。
- 建议内容：检验方法、多重校正、阈值、显著性符号规则。

4. `methods_context`
- 含义：与图对应的方法学信息。
- 建议内容：实验条件、处理剂量、时间点、成像参数、比例尺信息。

5. `panel_map`
- 含义：面板标签与实验含义映射。
- 示例：`A=实验流程，B=代表图像，C=定量统计`。

### 1.3 可选字段

1. `journal_target`
- 含义：目标期刊或风格要求。
- 作用：微调语气和格式（不改变事实）。

2. `abbreviation_list`
- 含义：作者已定义的缩写表。
- 作用：避免术语不一致。

3. `claim_boundary`
- 含义：结论强度边界（探索性/验证性）。
- 作用：控制图注措辞强度。

## 2. 输入质量分级

1. 最小可用输入
- `figure_image`
- 预期结果：可生成结构完整图注，但缺失信息较多。

2. 推荐输入
- `figure_image` + (`figure_code` 或 `source_data` 或 `stats_info`)
- 预期结果：图注可读性与可信度显著提升。

3. 高质量输入
- `figure_image` + `figure_code` + `source_data` + `stats_info` + `panel_map` + `methods_context`
- 预期结果：图注可达投稿前内部审校质量。

## 3. 三类标准输入示例

### 3.1 示例一：仅图像

```text
figure_image: Figure2.png
```

说明：可输出双语草稿，并在“缺失信息与假设声明”中列出统计与方法缺失项。

### 3.2 示例二：多面板图像

```text
figure_image: Figure3_composite.png
panel_map:
  A: 模型示意
  B: 代表性免疫荧光图
  C: 荧光强度定量
```

说明：可稳定生成 A/B/C 面板化图注，若无统计细节则不得编造 P 值。

### 3.3 示例三：图像 + 代码 + 数据 + 统计

```text
figure_image: Figure4.png
figure_code: plot_figure4.py
source_data: figure4_data.csv
stats_info:
  test: Two-sided Student's t-test
  correction: none
  alpha: 0.05
  symbol_rule: * p<0.05, ** p<0.01
methods_context:
  model: 小鼠皮下移植瘤模型
  treatment: DrugX 10 mg/kg, q.d., 14 days
```

说明：可生成高完整度双语图注，并在质控清单中给出较高通过率。

## 4. 缺失信息回填清单（建议对用户追问）

1. 每个面板的实验对象和分组名称。
2. 样本量 `n` 的定义（生物学重复/技术重复/样本总数）。
3. 统计检验名称与单双侧设置。
4. 误差线含义（SD/SEM/CI）。
5. 单位与比例尺信息。
6. 缩写标准写法。
