---
name: pipeline-coding-standard
description: 编写或者修改代码至符合规范科研和数据处理的流水线(pipeline)。仅适用于科研、分析pipeline；不要用于普通单文件小工具、Web 前端、通用库开发或 Notebook 探索分析。
---

# Pipeline Coding Standard

## 核心要求

### 1. 项目目录结构

**所有标准目录必须直接建立在项目工作目录（项目根）下**，禁止嵌套在任何子目录中。

```text
<project_root>/          ← 调用此 skill 时所在的目录
  conf/                  ← 每个 pipe 步骤对应一个 YAML
  pipe/                  ← 总控脚本（每步骤一个 .sh）
  script/                ← shell 辅助工具
  python/                ← Python 模块
  src/                   ← C++ 等其他语言模块
  R/                     ← R 脚本
  output/                ← 按步骤组织的输出
  temp/                  ← 临时文件
  data/                  ← 原始数据
  input/                 ← 输入文件
  log/                   ← 日志
```

若用户在 `~/project1/` 下使用此 skill，则必须形成 `~/project1/conf/`、`~/project1/output/` 等，**绝对不能**在 `~/project1/files1/` 或任何子目录下再建这些标准目录。

### 2. pipe → conf → output 严格一一对应

每个流程步骤由三部分组成，编号和名称必须完全一致：

```text
pipe/1-data_preprocessing.sh       ← 总控脚本
conf/1-data_preprocessing.yaml     ← 该步骤专属配置
output/1-data_preprocessing/       ← 该步骤全部输出
  1-table/
  2-figure/
  3-report/
```

- 一个 pipe 脚本只能读取与之同名的 conf YAML，禁止跨步骤共享配置文件
- 禁止使用单一 `conf/Config.yaml` 统管所有步骤
- 若任务规模大，**必须主动拆分**为多个编号步骤（如 `1-process`, `2-visualization`, `3-report`），不得将所有逻辑写入单个脚本

多步骤示例：

```text
pipe/1-process.sh          conf/1-process.yaml          output/1-process/
pipe/2-visualization.sh    conf/2-visualization.yaml    output/2-visualization/
pipe/3-report.sh           conf/3-report.yaml           output/3-report/
```

### 3. 文件命名

所有承载业务步骤的代码文件必须使用"数字前缀-功能名"格式：

```text
pipe/<N>-<name>.sh
python/<N>-<M>-<name>.py
src/<N>-<M>-<name>.<ext>
```

`script/` 中仅用于环境检查、配置加载等非业务辅助工具时，可用描述性名称（如 `load_config.sh`、`check_env.sh`）。

### 4. 输出目录

```text
output/<N>-<name>/
  1-table/      ← 表格、矩阵、统计结果、下游可读数据
  2-figure/     ← 图片（每张图必须伴有同名 TSV）
  3-report/     ← 报告、摘要、可读说明文档
temp/<N>-<name>/  ← 中间文件和缓存
```

**2-figure/ 图文伴随规则**：`2-figure/` 下每个图文件必须在同目录下有同名 `.tsv` 文件，默认采用 long table 格式，包含直接用于出图的全部数据列。禁止只输出图而不输出对应数据文件。

```text
output/1-process/2-figure/
  volcano_plot.pdf
  volcano_plot.tsv    ← 必须同时输出
  heatmap.png
  heatmap.tsv         ← 必须同时输出
```

### 5. 单文件单语言

禁止在 shell 文件中嵌入 Python、R 或其他语言片段（`python <<'EOF'`、`Rscript <<'EOF'`、`cat <<'EOF' | python` 等）。

### 6. 配置规范

每个步骤的 `conf/<N>-<name>.yaml` 按职责分层：

```yaml
# <步骤名> — 配置文件

project:
  base_dir: "."                     # 项目根目录

paths:
  input: "input/sample.tsv"
  output_table: "output/1-<name>/1-table"
  output_figure: "output/1-<name>/2-figure"
  output_report: "output/1-<name>/3-report"
  temp: "temp/1-<name>"

tools:
  python_bin: "/path/to/python3"
  conda_bin: "/path/to/conda"
  python_env_prefix: "/path/to/env"

runtime:
  jobs: 8
  overwrite: false
```

配置通过 `source script/load_config.sh conf/<N>-<name>.yaml` 加载为 shell 变量，再通过命名 CLI 参数传给模块。模块禁止自行读取 YAML。

模块调用模式：

```bash
"$PYTHON_BIN" python/1-1-data_preprocessing.py \
  --input  "$INPUT" \
  --output "$OUTPUT_TABLE" \
  --jobs   "$JOBS"
```

### 7. 禁止硬编码

模块文件中禁止出现绝对路径、输入输出路径、软件路径、conda 路径、线程数等。shell 总控中禁止硬编码 `python3`、`Rscript`、`conda` 等工具路径。所有这些值必须来自对应步骤的 conf YAML。

## 工作流程

**新建项目**：运行 `bash scripts/init_pipeline_layout.sh <target_dir>` 复制模板，再按步骤补充 pipe/、conf/、python/ 或 src/ 中的脚本。

**重构旧脚本**：识别配置→迁移到 conf YAML；识别流程控制→迁移到 pipe；识别业务逻辑→迁移到 python/ 或 src/；重组输出目录；消除跨语言混写和硬编码。
