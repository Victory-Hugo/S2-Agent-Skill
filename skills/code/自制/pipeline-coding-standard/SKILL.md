---
name: pipeline-coding-standard
description: 规范科研和数据处理流水线项目的代码组织方式。用于新建或重构 bash/shell 主控加 Python/R/C++ 模块的分析流程、审查项目结构是否合规、或把单文件脚本改造成总控脚本加独立模块脚本模式。要求统一目录为 conf、pipe、script、python、src，禁止在单个文件内混写多种语言，禁止在模块中硬编码绝对路径和运行参数，要求总控脚本从 conf/Config.json 读取配置并通过命名 CLI 参数向模块传递。仅适用于科研/分析流水线；不要用于普通单文件小工具、Web 前端、通用库开发或 Notebook 探索分析。
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
  - Config.json
- pipe/
- script/
- python/
- src/
```

目录职责固定如下：

- `pipe/`：总控脚本。负责读取配置、检查依赖、建目录、组织流程、调用模块。
- `script/`：shell 辅助脚本。只放辅助命令，不承载业务算法。
- `python/`：只放 Python 模块。
- `src/`：放 R、C++ 或其他非 Python 模块。
- `conf/`：统一配置入口，固定使用 `conf/Config.json`。

### 2. 单文件单语言

一种文件只允许一种语言。禁止在 shell/bash/bat 文件中嵌入 Python、R 或其他语言片段。

禁止模式包括但不限于：

- `python <<'EOF'`
- `Rscript <<'EOF'`
- `cat <<'EOF' | python`
- 任何 here-doc 包装的跨语言执行片段

### 3. 参数与配置

总控脚本必须从 `conf/Config.json` 读取配置，再通过命名 CLI 参数把参数传给模块。默认参数风格如下：

```bash
python3 python/example_step.py \
  --input "$INPUT_DIR" \
  --output "$OUTPUT_FILE" \
  --ref "$REFERENCE" \
  --jobs "$JOBS"
```

模块不得自行读取 `conf/Config.json` 作为默认工作方式，除非该模块被明确设计为配置解析器。业务模块必须从总控接收参数，不得依赖全局变量、环境变量或隐式工作目录状态。

### 4. 禁止硬编码

禁止在模块文件中硬编码以下内容：

- 绝对路径，例如 `/mnt/...`、`C:\...`
- 输入输出文件路径
- 参考文件路径
- 线程数、阈值等运行参数
- 假定外部目录结构的常量

允许硬编码的内容仅限：

- 参数名
- 合法默认值的占位示例
- 不依赖具体环境的常规常量

## 工作方式

### 新建项目时

1. 先使用 `scripts/init_pipeline_layout.sh <target_dir>` 复制模板项目。
2. 再根据任务替换 `conf/Config.json` 示例字段。
3. 在 `python/` 或 `src/` 中补充模块。
4. 只在 `pipe/` 中组织流程，不把算法实现写入主控脚本。

### 重构旧脚本时

1. 先识别当前脚本中的配置、流程控制、业务算法。
2. 把配置迁移到 `conf/Config.json`。
3. 把流程控制迁移到 `pipe/`。
4. 把业务逻辑拆分到 `python/` 或 `src/`。
5. 删除跨语言混写和模块硬编码。

## 模式参考

参考 `/mnt/f/onedrive/文档（科研）/脚本/Download/1-fasta-nucmer/2-nucmer运行/1-mtDNA/script/1-nucmer.sh` 的总控思路：

- 由 shell 统一调度流程
- 明确输入、输出和依赖工具
- 模块脚本只做单一步骤

但本 skill 要求把脚本头部集中硬编码变量升级为：

- `conf/Config.json` 统一配置
- 总控脚本读取配置
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
