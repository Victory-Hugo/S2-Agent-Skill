---
name: pipeline-coding-standard
description: 编写或者修改代码至符合规范科研和数据处理的流水线(pipeline)。仅适用于科研、分析pipeline；不要用于普通单文件小工具、Web 前端、通用库开发或 Notebook 探索分析。
---

# Pipeline Coding Standard

## 核心要求

### 1. 项目目录结构

所有标准目录必须直接建立在项目根下，禁止嵌套在其他子目录中。

```text
<project_root>/
  conf/       # 每个步骤一个 YAML
  pipe/       # 每个步骤一个总控 .sh
  script/     # shell 辅助工具
  python/     # Python 模块
  src/        # C++ 等其他语言模块
  R/          # R 脚本
  output/
    result/   # 表格、矩阵、统计结果、下游数据
    figure/   # 图片及同名 TSV
    report/   # 可选 Markdown 报告
  temp/       # 按步骤存放中间文件
  data/       # 原始数据
  input/      # 输入文件
  log/        # 日志
```

### 2. 步骤严格一一对应

每个步骤的编号和名称必须完全一致：

```text
pipe/1-data_preprocessing.sh
conf/1-data_preprocessing.yaml
output/result/1-data_preprocessing/
output/figure/1-data_preprocessing/
output/report/1-data_preprocessing/
temp/1-data_preprocessing/
```

- 一个 pipe 脚本只能读取与之同名的 conf YAML，禁止跨步骤共享配置文件
- 禁止使用单一 `conf/Config.yaml` 统管所有步骤
- 任务规模大时必须主动拆分为多个编号步骤，不得将所有逻辑写入单个脚本

### 3. 文件命名

业务代码必须使用“数字前缀-功能名”：

```text
pipe/<N>-<name>.sh
python/<N>-<M>-<name>.py
src/<N>-<M>-<name>.<ext>
```

`script/` 中的非业务辅助工具可使用描述性名称，如 `load_config.sh`。

### 4. 输出目录

```text
output/result/<N>-<name>/
output/figure/<N>-<name>/
output/report/<N>-<name>/
temp/<N>-<name>/
```

- `output/result/` 中的表格默认使用 tidy long 长表；仅当用户明确要求或下游工具必须使用宽表时才使用宽表
- `output/figure/` 中每张图必须伴有同名 `.tsv`，该 TSV 默认也是 tidy long 长表并包含直接用于出图的全部数据列
- 报告不是强制产物；但 `output/report/` 内若有文件，只允许 `.md`
- 预分析、试运行、临时分析产生的所有中间文件必须放入项目根下对应的 `temp/<N>-<name>/`
- 禁止在 `$HOME/temp`、`$HOME/tmp`、`/tmp` 等项目外临时目录中进行分析或存放中间文件

```text
output/figure/1-process/
  1-1-volcano_plot.pdf
  1-1-volcano_plot.tsv
```

### 5. 单文件单语言

禁止在 shell 文件中嵌入 Python、R 或其他语言片段。

### 6. 配置规范

每个 `conf/<N>-<name>.yaml` 按职责分层：

```yaml
project:
  base_dir: "."

paths:
  input: "input/sample.tsv"
  output_result: "output/result/1-<name>"
  output_figure: "output/figure/1-<name>"
  output_report: "output/report/1-<name>"
  temp: "temp/1-<name>"

tools:
  python_bin: "/path/to/python3"
  conda_bin: "/path/to/conda"
  python_env_prefix: "/path/to/env"

runtime:
  jobs: 8
  overwrite: false
```

配置由同名 pipe 通过 `script/load_config.sh` 加载，再以命名 CLI 参数传给模块；模块禁止自行读取 YAML。

```bash
"$PYTHON_BIN" python/1-1-data_preprocessing.py \
  --input  "$INPUT" \
  --output "$OUTPUT_RESULT" \
  --jobs   "$JOBS"
```

### 7. 禁止硬编码

模块中禁止硬编码绝对路径、输入输出路径、软件路径、环境路径和线程数；这些值必须来自对应步骤的 conf YAML。

## 工作流程

**新建项目**：运行 `bash scripts/init_pipeline_layout.sh <target_dir>` 复制模板，再补充各步骤代码。

**重构旧脚本**：配置迁入 conf，流程控制迁入 pipe，业务逻辑迁入对应语言目录，并按本规范重组输出。
