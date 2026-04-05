---
name: pipeline-coding-standard
description: 编写或者修改代码至符合规范科研和数据处理的流水线(pipeline)。仅适用于科研、分析pipeline；不要用于普通单文件小工具、Web 前端、通用库开发或 Notebook 探索分析。
---

# Pipeline Coding Standard

## 概述

使用这个 skill 组织或重构科研/分析流水线项目。默认采用 1 个总控脚本加多个模块脚本的结构，强调目录职责清晰、配置集中、参数显式传递、模块无硬编码。

## 核心要求

### 1. 项目组织

优先使用以下目录结构：

```text
主目录/
- conf/
  - Config.yaml
- pipe/
- script/
- python/
- output/
- src/
```

目录职责固定如下：

- `pipe/`：总控脚本。负责读取配置、检查依赖、建目录、组织流程、调用模块。
- `script/`：shell 辅助脚本。只放辅助命令，不承载业务算法。
- `python/`：只放 Python 模块。
- `output/`：统一输出目录。
- `src/`：放 R、C++ 或其他非 Python 模块。
- `conf/`：统一配置入口，固定使用 `conf/Config.yaml`。

### 2. 单文件单语言

一种文件只允许一种语言。禁止在 shell/bash/bat 文件中嵌入 Python、R 或其他语言片段。

禁止模式包括但不限于：

- `python <<'EOF'`
- `Rscript <<'EOF'`
- `cat <<'EOF' | python`
- 任何 here-doc 包装的跨语言执行片段

### 3. 参数与配置

总控脚本必须从 `conf/Config.yaml` 读取配置，再通过命名 CLI 参数把参数传给模块。模板默认使用简单 YAML 子集，并通过 `source script/load_config.sh conf/Config.yaml` 把配置加载为 shell 变量。所有软件相关设置也必须进入 YAML，包括但不限于 `python3`、`Rscript`、第三方二进制、`conda` 可执行文件路径、`conda` 环境名、`conda` 环境前缀。shell 只负责读取这些变量并执行，不允许在脚本里再写死软件安装位置或环境位置。

编写 `conf/Config.yaml` 时必须满足以下格式要求：

- 必须添加块级注释和关键字段行尾注释，说明 section 用途与字段含义。
- 必须按职责分层，优先拆成 `project`、`paths`、`tools`、`runtime` 这类 section；有步骤专属输出时，再在 `paths` 下继续分组命名。
- 路径字段必须清楚区分“项目根目录”“输入文件”“通用目录”“步骤输出目录”，不要把所有路径堆在一个 section。
- 工具字段必须集中放入 `tools`，避免把解释器、二进制、环境前缀散落到其他 section。
- 运行参数例如线程数、阈值、批次大小、是否跳步等，必须集中放入 `runtime` 或其他语义明确的参数 section。
- 默认优先使用相对于 `project.base_dir` 的相对路径；如果必须使用绝对路径，也要在注释中明确其角色。

推荐模板风格如下，保留这种“标题注释 + section 注释 + 行尾注释”的层次，不要照搬具体字段名到不相关项目：

```yaml
# =====================================================================
# <流程名称> — 配置文件
# 所有路径均支持：绝对路径 / 相对路径（相对于 base_dir）
# =====================================================================

project:
  base_dir: "/abs/path/to/project"      # 项目根目录
  input_table: "data/input/sample.tsv"  # 主输入文件或主元数据表

# --------------------------------------------------------------------- #
# 目录结构：相对路径默认相对于 project.base_dir                         #
# --------------------------------------------------------------------- #
paths:
  python_dir: "python"             # Python 模块目录
  src_dir: "src"                   # R/C++/其他模块目录
  helper_dir: "script"             # shell 辅助脚本目录
  data_dir: "data"                 # 原始数据与资源目录
  tmp_dir: "tmp"                   # 临时目录
  log_dir: "log"                   # 日志目录
  output_dir: "output"             # 输出根目录
  output_step1_data: "output/1/data"  # 步骤 1 输出目录
  output_step2_data: "output/2/data"  # 步骤 2 输出目录

# --------------------------------------------------------------------- #
# 工具路径：集中管理解释器、二进制和环境                                 #
# --------------------------------------------------------------------- #
tools:
  conda_bin: "/path/to/conda"          # conda 可执行文件
  python_bin: "/path/to/python3"       # Python 解释器
  python_env_prefix: "/path/to/env"    # conda 环境前缀
  rscript_bin: "/usr/bin/Rscript"      # Rscript 路径

# --------------------------------------------------------------------- #
# 运行参数：统一放线程数、阈值、开关等                                   #
# --------------------------------------------------------------------- #
runtime:
  jobs: 8                  # 并行线程数
  min_depth: 10            # 示例阈值参数
  overwrite: false         # 是否覆盖已有输出
```

默认参数风格如下：

```bash
python3 python/example_step.py \
  --input "$INPUT_DIR" \
  --output "$OUTPUT_FILE" \
  --ref "$REFERENCE" \
  --jobs "$JOBS"
```

模块不得自行读取 `conf/Config.yaml` 作为默认工作方式，除非该模块被明确设计为配置解析器。业务模块必须从总控接收参数，不得依赖全局变量、环境变量或隐式工作目录状态。

涉及环境切换时，推荐也按同一原则写成配置驱动，例如：

```bash
"$CONDA_BIN" run -p "$ALIGN_ENV_PREFIX" python "$PYTHON_STEP" \
  --input "$INPUT_DIR" \
  --output "$OUTPUT_FILE"
```

或：

```bash
"$CONDA_BIN" run -n "$ALIGN_ENV_NAME" "$SAMTOOLS_BIN" sort \
  -@ "$JOBS" \
  -o "$OUTPUT_BAM" \
  "$INPUT_BAM"
```

这里的 `CONDA_BIN`、`ALIGN_ENV_PREFIX`、`ALIGN_ENV_NAME`、`SAMTOOLS_BIN` 都必须来自 `conf/Config.yaml`，不能在 shell 中写成固定绝对路径。

模板内置的 shell 加载器只支持以下 YAML 范围：

- 顶层 section 加二级 key 的嵌套映射
- 标量值，例如字符串、数字、布尔占位值
- 两空格缩进
- 行尾注释

因此，推荐保持在“section -> key”或“section -> 分组命名 key”的简单层次，不要写需要数组解析的结构。

如果配置复杂到需要列表、多行字符串、锚点或更深层级，应改用更明确的配置方案，不要假装 shell 解析了完整 YAML。

### 4. 禁止硬编码

禁止在模块文件中硬编码以下内容：

- 绝对路径，例如 `/mnt/...`、`C:\...`
- 输入输出文件路径
- 参考文件路径
- 软件可执行文件路径
- conda 可执行文件路径
- conda 环境名或环境前缀
- 线程数、阈值等运行参数
- 假定外部目录结构的常量

禁止在 shell 总控或辅助脚本中硬编码以下内容：

- `python`、`python3`、`Rscript`、`perl`、`java`、`samtools`、`bwa`、`blastn` 等软件路径
- `conda`、`mamba`、`micromamba` 的安装路径
- 环境激活脚本路径
- 具体环境目录，例如 `/path/to/miniconda3/envs/xxx`

允许硬编码的内容仅限：

- 参数名
- 合法默认值的占位示例
- 不依赖具体环境的常规常量

## 工作方式

### 新建项目时

1. 先使用 `scripts/init_pipeline_layout.sh <target_dir>` 复制模板项目。
2. 再根据任务替换 `conf/Config.yaml` 示例字段。
3. 在 `python/` 或 `src/` 中补充模块。
4. 只在 `pipe/` 中组织流程，不把算法实现写入主控脚本。

### 重构旧脚本时

1. 先识别当前脚本中的配置、流程控制、业务算法。
2. 把配置迁移到 `conf/Config.yaml`。
3. 把流程控制迁移到 `pipe/`。
4. 把业务逻辑拆分到 `python/` 或 `src/`。
5. 删除跨语言混写和模块硬编码。

## 模式参考

参考 `/mnt/f/onedrive/文档（科研）/脚本/Download/1-fasta-nucmer/2-nucmer运行/1-mtDNA/script/1-nucmer.sh` 的总控思路：

- 由 shell 统一调度流程
- 明确输入、输出和依赖工具
- 模块脚本只做单一步骤

但本 skill 要求把脚本头部集中硬编码变量升级为：

- `conf/Config.yaml` 统一配置
- 总控脚本通过 shell 加载器读取配置
- 通过命名 CLI 参数调用模块

## 附带资源

- 详细规范：读取 `references/standards.md`
- 项目模板：使用 `assets/project-template/`
- 初始化脚本：运行 `bash scripts/init_pipeline_layout.sh <target_dir>`

## 不适用场景

以下场景不要使用这个 skill：

- 普通单文件 Python 或 shell 小工具
- 纯 Python 包或通用库开发
- Web 前端或服务端框架项目
- Jupyter Notebook 探索分析
