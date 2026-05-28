# Pipeline Coding Standard Reference

## 目录职责

| 目录 | 职责 | 允许内容 | 禁止内容 |
| --- | --- | --- | --- |
| `conf/` | 步骤级配置入口 | 每步骤一个 `N-<name>.yaml` | 单一 `Config.yaml` 统管所有步骤 |
| `pipe/` | 总控脚本 | 流程编排、建目录、依赖检查、模块调用 | 业务算法实现 |
| `script/` | 辅助脚本 | 环境检查、配置加载等非业务工具 | Python/R/C++ 业务逻辑 |
| `python/` | Python 模块 | `.py` 脚本或模块 | 其他语言 |
| `src/` | 非 Python 模块 | R、C++、其他语言模块 | Python 主模块 |
| `output/` | 结果输出 | 按步骤和结果类型组织的结果文件 | 临时文件、无编号散乱输出 |
| `temp/` | 临时文件 | 按步骤组织的中间文件和缓存 | 最终结果 |

## 项目根目录约束

调用此 skill 时所在目录即为项目根目录。所有标准目录（conf/, pipe/, output/, data/, input/, temp/, python/, src/, script/, log/）必须直接建立在项目根目录下，禁止嵌套在任何子目录中。

**正例**（在 `~/project1/` 下使用 skill）：

```text
~/project1/conf/
~/project1/pipe/
~/project1/output/
```

**反例**：

```text
~/project1/files/conf/      ← 嵌套在子目录中，违规
~/project1/analysis/pipe/   ← 嵌套在子目录中，违规
```

## pipe → conf → output 一一对应

每个流程步骤的三个组成部分编号和名称必须完全一致：

```text
pipe/N-<name>.sh
conf/N-<name>.yaml
output/N-<name>/
  1-table/
  2-figure/
  3-report/
```

- 禁止一个 pipe 脚本读取多个 conf 文件
- 禁止多个 pipe 共享同一 conf 文件
- 禁止使用单一 `conf/Config.yaml` 统管所有步骤
- 任务规模大时必须拆分为多个编号步骤，不得把所有逻辑写入单个脚本

## 文件命名规范

```text
pipe/<N>-<name>.sh
python/<N>-<M>-<name>.py
src/<N>-<M>-<name>.<ext>
```

正例：

```text
pipe/1-data_preprocessing.sh
python/1-1-data_preprocessing.py
python/1-2-feature_engineering.py
src/2-1-statistical_modeling.R
```

反例：

```text
pipe/run_pipeline.sh
python/main.py
conf/Config.yaml
```

## 输出目录规范

```text
output/
  1-data_preprocessing/
    1-table/      ← 表格、矩阵、统计结果、下游可读数据
    2-figure/     ← 图片（必须伴有同名 TSV）
    3-report/     ← 报告、摘要、可读说明文档
temp/
  1-data_preprocessing/  ← 中间文件、缓存和可删除临时产物
```

禁止使用 `output/1/data/`、`output/result/`、`output/tmp/` 这类含义不清或结果类型混杂的目录。

## 2-figure/ 图文伴随规则

`2-figure/` 下每个图文件必须在同目录下有同名 `.tsv` 文件，默认采用 long table 格式，包含直接用于重新出图的全部数据列。

```text
output/1-data_preprocessing/2-figure/
  volcano_plot.pdf
  volcano_plot.tsv    ← 必须同时输出，long table 格式
  heatmap.png
  heatmap.tsv         ← 必须同时输出，long table 格式
```

禁止只输出图而不输出对应数据文件。

## 配置规范

每个步骤的 conf YAML 按职责分层：

- `project`：基础路径（`base_dir`）和主输入文件
- `paths`：输出目录、临时目录、参考文件路径（相对于 `base_dir`）
- `tools`：解释器、第三方二进制、conda 相关路径
- `runtime`：线程数、阈值、开关类参数

```yaml
# 1-data_preprocessing — 配置文件

project:
  base_dir: "."
  input_table: "input/sample.tsv"

paths:
  output_table: "output/1-data_preprocessing/1-table"
  output_figure: "output/1-data_preprocessing/2-figure"
  output_report: "output/1-data_preprocessing/3-report"
  temp: "temp/1-data_preprocessing"

tools:
  python_bin: "/path/to/python3"
  conda_bin: "/path/to/conda"
  python_env_prefix: "/path/to/env"
  rscript_bin: "/usr/bin/Rscript"

runtime:
  jobs: 8
  overwrite: false
```

shell 加载器仅支持"section → key"两层嵌套映射、标量值、两空格缩进、行尾注释，不支持列表、锚点或更深层级。

## 模块接口

- **Python**：使用 `argparse`，不从环境变量或全局状态隐式读取业务参数。
- **R**：使用 `commandArgs(trailingOnly = TRUE)` 或明确的 CLI 参数解析器。
- **C++**：使用 `argc/argv` 或明确的 CLI 参数解析器。

模块调用示例：

```bash
"$PYTHON_BIN" python/1-1-data_preprocessing.py \
  --input  "$INPUT_TABLE" \
  --output "$OUTPUT_TABLE" \
  --jobs   "$JOBS"
```

## 禁止模式

| 类型 | 反例 |
| --- | --- |
| 跨语言混写 | `python <<'EOF'` / `Rscript <<'EOF'` |
| 模块硬编码路径 | `REFERENCE = "/mnt/g/project/ref.fa"` |
| shell 硬编码工具 | `python3 script.py` / `/usr/bin/Rscript script.R` |
| 共享配置 | `conf/Config.yaml` 被多个 pipe 读取 |
| 无图数据输出 | 2-figure/ 下只有图文件，无同名 TSV |
| 目录嵌套 | 在子目录下建 conf/、pipe/ 等标准目录 |

## 模板说明

`assets/project-template/` 提供最小工程模板，包含：

```text
project-template/
  conf/1-data_preprocessing.yaml
  pipe/1-data_preprocessing.sh
  script/check_env.sh
  script/load_config.sh
  python/1-1-data_preprocessing.py
  output/1-data_preprocessing/1-table/
  output/1-data_preprocessing/2-figure/
  output/1-data_preprocessing/3-report/
  temp/1-data_preprocessing/
  src/.keep
```

初始化：

```bash
bash scripts/init_pipeline_layout.sh /path/to/new-project
```

每新增一个 pipe 步骤，需同步新建对应编号的 `conf/N-<name>.yaml`。
