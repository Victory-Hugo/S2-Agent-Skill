---
name: aDNA-downloader
description: 下载古代 DNA 数据并按指定 Excel 模板整理 metadata。
---

# 古代 DNA 数据收集与下载 Agent

根据用户提供的文献、PDF、补充材料、数据库编号、链接或关键词，收集**当前研究本身产生**的古代 DNA 样本基础信息和原始测序数据，按模板输出可追溯结果。

## 输入与输出

输入：文献、PDF、补充材料、accession、链接或关键词。

输出目录：

```
output/
├── meta/时间戳.xlsx          # 由模板复制而来
└── data/                     # 数据文件、清单、命令、失败说明
    ├── file_manifest.tsv
    ├── download_commands.sh
    └── download_skipped.tsv  # 未下载时记录
```

## 检索与下载 API 优先原则

直接爬取出版社网页（PDF、正文图表、补充材料）常触发人机验证，应优先走官方 API/程序化接口，仅在 API 均无结果时才尝试直接访问网页，且需在记录中注明可能遇到验证码、访问受限。

### 密钥与联系邮箱

- NCBI 邮箱与 API key 存放于 `key/1-NCBI-API.key`（第一行邮箱，第二行 api_key）。该目录已加入 `.gitignore`，禁止提交到版本库或写入报告正文。
- Crossref、Unpaywall 调用一律带上 `key/1-NCBI-API.key` 中的邮箱（或用户提供的其他联系邮箱）作为 `mailto` / `email` 参数，并在 User-Agent 中注明工具名与该邮箱，以进入 polite pool / 避免被拒绝。

### 检索顺序（按数据类型）

1. **已知 DOI 查元数据**：`https://api.crossref.org/works/{DOI}?mailto=<邮箱>`。
2. **查合法开放获取全文**：`https://api.unpaywall.org/v2/{DOI}?email=<邮箱>`，取 `best_oa_location`/`oa_locations` 中的直链（机构库、Zenodo、Figshare、作者稿等）。
3. **生物医学文献 / PMC 全文包（含图表、补充材料）**：
   - 检索：`https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi`、`efetch.fcgi`、`esummary.fcgi`，带 `api_key`、`email`、`tool` 参数。
   - PMC 开放全文包（含正文图表 JATS XML 及可用补充材料）：`https://www.ncbi.nlm.nih.gov/pmc/utils/oa/oa.fcgi?id=<PMCID>`，下载返回的 `.tar.gz`。
   - 无 api_key 时限速 ≤3 次/秒；带 api_key 时 ≤10 次/秒，禁止超过。
4. **正文图表资源（Figure、JATS XML 中的表格、PDF 中的图）**：优先从 PMC 全文包 JATS XML 或出版社 TDM/Crossref `link` 字段中的 XML/PDF 直链获取；缺失时才尝试出版社页面直接抓图。
5. **补充材料文件（xlsx/csv/docx/zip、Supplementary Table/Figure、Figshare/Zenodo 数据）**：
   - 依次尝试：Unpaywall 命中的仓库页面（Zenodo/Figshare/Dryad 等）→ Crossref 元数据中的 `relation`/`link` 字段 → Europe PMC `supplementaryFiles` 接口（见下）→ 出版社自有 ESM 服务器（见下）。
   - **Europe PMC 补充材料接口**（PMC OA 包被验证拦截时的首选替代）：`https://www.ebi.ac.uk/europepmc/webservices/rest/{PMCID}/supplementaryFiles`，返回 zip，通常能绕过 PMC 网页版的人机验证/PoW 挑战，直接拿到图片、SI 说明文档等。
   - **⚠️ 完整性核查（重要，勿漏项）**：Europe PMC / PMC OA 包只包含"存档到 PMC 的部分"（通常是正文图 + SI 说明 PDF/DOCX），**不等于出版社官网列出的全部附件**。数据类大表格（如 Supplementary Table，尤其是 xlsx）出版社常单独托管，不进入 PMC 存档。取得 PMC/Europe PMC 补充材料包后，必须再核对出版社文章页列出的附件清单（数量、文件名、格式），确认两边条目一一对应；有出入（尤其缺少 xlsx/csv 等数据表）时，按下方"出版社 ESM 直链模式"补齐，不能默认 PMC 包已是全集。
   - **出版社 ESM 直链模式**（用于核对/补齐缺失附件，直接请求即可，通常无需人机验证）：
     - **Springer/Nature**：文章页 `https://www.nature.com/articles/{文章ID}`（需带 `mailto:` User-Agent，`curl -sL` 跟随重定向）中搜索 `MediaObjects`/`MOESM` 关键词，可枚举出全部 `MOESM1, MOESM2, …` 附件及其中文描述（如 "Supplementary Tables"）；直链形如 `https://static-content.springer.com/esm/art%3A{URL编码DOI}/MediaObjects/{文章内部ID}_MOESM{N}_ESM.{ext}`。
     - **PLOS**：文章页或 API 中搜索 `journals.plos.org/.../file?id=10.1371/...s{NNN}`，附件命名通常为 `S1 Table`、`S2 Fig` 等。
     - **Wiley**：搜索 `onlinelibrary.wiley.com/action/downloadSupplement`。
     - **Elsevier/Cell Press**：搜索 `ars.els-cdn.com`（Crossref `link` 字段有时也会给出）。
     - 其他出版社未知模式时，直接 `curl -sL` 抓文章页 HTML，用关键词 `supplementary|ESM|MediaObjects|S1_|Table_S|\.xlsx|\.csv` 搜索，而非凭经验猜测跳过。
6. **上述 API 均未命中，或出版社 ESM 直链也拿不到时**：允许尝试直接访问出版社页面完整渲染版本，但须在 `download_skipped.tsv` 或复核记录中注明"API 未命中，尝试直接访问"及最终结果（含遇到人机验证/PoW 挑战的情况，以及已尝试过的具体接口列表，避免下次重复踩坑）。

### 限速与容错

- 对同一域名的请求做基本限速（Crossref/Unpaywall 建议顺序请求，不并发轰炸）和失败退避（如遇 429，等待后重试，不重复硬闯）。
- 对已查询过的 DOI/PMCID 结果可在当次任务内复用，避免重复请求。

### 补充材料清单核对（工作流硬性步骤）

在写入 `Citation_short` sheet 前，必须先列出"出版社官网声明的附件总数与类型"（从文章页 Supplementary Information 区块解析，如 "Supplementary Information / Reporting Summary / Supplementary Tables / Peer Review File" 各几份、什么格式），再与已下载/已获取的文件逐一核对是否齐全，在 `Citation_short` 中如实记录：
- 出版社声明的附件清单（编号、文件名、格式、内容简介）；
- 每项是否已获取、通过哪个接口获取、未获取的原因；
- 若数据类附件（xlsx/csv 等 Supplementary Table）缺失，禁止仅凭 PDF 版 Supplementary Information 就判定"已完整收集"，须明确标注待补齐。

## 核心原则

1. **模板不可变**：必须复制 `template/古代DNA收集模板-AI-agent.xlsx` 后再写入；保留字段、顺序、格式、公式、数据验证、下拉框、隐藏 sheet、命名区域，以及模板 sheet 第二行原始注释行。禁止用 `pandas.to_excel()` 等方式覆盖结构。
2. **任务范围**：除非用户明确说明"仅收集基础信息"或"仅下载原始数据"，**默认同时完成两项**。
3. **数据范围**：只处理当前研究产生的数据，禁止纳入引用的其他研究、参考、比较或对照数据。
4. **来源优先级**：用户主动提供 PDF/补充材料时，基础信息必须优先从中提取；仅当用户资料缺失或无法确认时才查外部来源；冲突时以用户资料为准，并在复核记录注明。
5. **禁止编造与留空**：具体缺失值、必填/选填、格式要求以模板第二行注释为准；下拉字段的允许值以模板数据验证列表为准（`openpyxl` 写入不会触发 Excel 校验，禁止凭经验写同义词、缩写、翻译或新类别），缺失时记录复核原因。
6. **特殊字段**：
   - 样本来自中国时，省份使用 `assets/1-中国省份规范名称.tsv` 中的 `省份英文名称_标准`。
   - 国家`Country`列需要使用 `assets/2-全球国家标准简称.tsv` 中的 `国家(英文标准)`。
   - `Latitude` / `Longitude` 禁止填 `Unknown` 或留空；若原文无坐标，**自行搜索**遗址经纬度并在复核记录注明来源。

## Genetic_ID 规则（单一权威定义）

`Genetic_ID` 是**文件级遗传数据 ID**，对应 BAM / CRAM / FASTA / FASTQ / VCF / BCF / BED / EIGENSTRAT 等原始数据文件。

### 提取优先级

1. 研究发布的数据文件名主体（去目录路径，保留可唯一识别 ID）。
2. 数据库清单中的 submitted / fastq / bam / analysis file name 或 FTP 文件名。
3. 数据库仅给 run accession 且 FASTQ 由 run 生成时，使用实际 FASTQ 文件名主体（如 `SRRxxxxxxx_1`、`SRRxxxxxxx_2`），并在 `Citation_short` 注明推导依据。
4. 仍无法确认时，写 `UNRESOLVED_FILE_ID__<Run_accession或样本号>`，记录已检索的数据库、字段、链接、失败原因，并标记人工复核。

### 检索强制性

**即使用户说"不必下载"，也必须检索数据库记录、文件清单、run table、manifest 或 data availability 来确认文件级 ID。"不下载"仅指不取回大文件，不允许跳过 ID 核验。**

### 多文件处理

- 成对 FASTQ：填两个文件主体，英文 `;` 分隔；或按模板粒度拆多行，并在复核记录注明。
- 多 lane / library / run：保留全部可追溯 ID，禁止合并为样本号。
- `Run_accession`、`BioSample_accession`、`BioProject_accession`、`Library_ID` 只作辅助字段，仅当它们就是实际文件名主体时方可作为 `Genetic_ID`。

### file_manifest 强制记录

写入 `Genetic_ID` 前必须先在 `output/data/file_manifest.tsv` 建立记录，至少包含：
`Genetic_ID`、`Master_ID`、`Library_ID`、`Run_accession`、`Source_database`、`Origin_data_class`、`file_name_original`、`file_url_or_accession`、`database_record_checked`、`download_status`、`review_note`。

每条 `总表` 记录的 `Genetic_ID` 必须能在 `file_manifest`、实际下载文件、下载命令或失败说明中找到一一对应证据。

## 工作流程

### 1. 初始化

创建 `output/meta/` 和 `output/data/`，复制模板生成 `output/meta/时间戳.xlsx`。

### 2. 读取模板结构

读取 `模板` sheet 的字段名、字段顺序、第二行说明、格式、公式、数据验证、下拉框、隐藏 sheet、命名区域，确保后续写入不破坏这些元素。

### 3. 收集基础信息

#### 检索顺序

用户已提供 PDF / 补充材料时：

1. 补充材料附表（附表 1、2、3…）
2. 文章 PDF 表格（表 1、2、3…）
3. 补充材料正文、方法、图表注释
4. 文章 PDF 正文、方法、结果、数据可用性声明
5. 用户资料中的 accession、链接、对照表

用户未提供或上述资料无法确认字段时，再查外部数据库、网页等。

#### 写入要求

- 标准化信息写入 `总表`，每条记录可追溯。
- 每篇文献 / 数据来源新建一个 `Citation_short` sheet，保存原始表格、数据库记录、链接、accession、文件信息、原文描述、复核与排除记录。
- 来自用户资料的信息必须记录文件名、页码、表号、附表名、行号、列名等定位信息。
- 每个字段记录：是否检索、是否命中、提取字段、原始字段名、原文值、标准化值、未命中原因、是否来自用户资料、是否需复核。

### 4. 处理原始遗传数据

先按 [Genetic_ID 规则](#genetic_id-规则单一权威定义) 完成文件级 ID 检索，再按以下模式输出：

- **下载模式**：用户指定格式优先；未指定时 BAM / CRAM 优先，其次 FASTQ / FASTA / 其他；保存到 `output/data/`。
- **不下载模式**：仍必须输出 `file_manifest.tsv`、`download_commands.sh` 或 `download_skipped.tsv`，包含文件级 ID、文件名、URL / accession、来源数据库、检索时间、未下载原因。
- **下载失败**：保存 accession、文件级 ID、命令和失败说明。

### 5. 质量检查

完成前逐项核对：

- [ ] Excel 文件存在且包含 `总表`
- [ ] 模板第二行注释、字段、格式、公式、数据验证、隐藏内容均保留
- [ ] 下拉框字段全部为模板允许值
- [ ] 无空白字段
- [ ] `Genetic_ID` 均对应文件、清单、命令或失败说明
- [ ] 即便不下载，也已完成数据库检索确认 `Genetic_ID`
- [ ] 未把 `Master_ID`、`Skeletal_ID`、`Library_ID`、`Run_accession`、`BioSample_accession`、`BioProject_accession` 错填为 `Genetic_ID`
- [ ] `file_manifest` 含每条 `总表` 记录的文件级证据
- [ ] 已排除非当前研究的引用 / 对照数据
- [ ] 用户未限定范围时，基础信息和原始数据均已处理
- [ ] 用户提供资料已优先使用，外部补充均记录原因与复核说明
- [ ] `Latitude` / `Longitude` 无空白、无 `Unknown`

## 最终报告

仅列出：

- Excel 文件路径
- 数据目录路径
- 已处理文献 / 数据来源数
- 已整理记录数
- 已下载、未下载、受限、失败的数据数
- 已排除的非当前研究数据数
- 需人工复核的字段或问题
- 用户提供资料使用情况
- 外部来源补充使用情况
