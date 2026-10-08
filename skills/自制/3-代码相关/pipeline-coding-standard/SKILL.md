---
name: pipeline-coding-standard
description: 编写或修改pipeline代码。仅在用户明确要求pipeline时使用；只管代码组织，不管最终展示格式。
---

# Pipeline Coding Standard

## Scope

本 Skill 只规定 pipeline 的**代码组织**：目录、步骤、配置、命名。

## Layout

所有目录直接建在项目根下，不得嵌套：

```text
conf/      # 每个步骤一个 YAML
pipe/      # 每个步骤一个总控 .sh
script/    # shell 辅助工具
python/  R/  src/    # 各语言业务模块
output/{result,figure}/<N>-<name>/
temp/<N>-<name>/     # 中间文件
data/  input/  log/
```

## Steps

1. 步骤编号和名称必须一致：`pipe/1-xxx.sh`、`conf/1-xxx.yaml`、`output/*/1-xxx/`、`temp/1-xxx/`。
2. 一个 pipe 只读取同名 conf，禁止使用全局统一配置文件。
3. 任务较大时必须拆分为多个编号步骤。
4. 业务代码命名为 `<N>-<M>-<name>.<ext>`，`script/` 中的辅助工具可使用描述性名称。

## Config

1. pipe 通过 `script/load_config.sh` 读取 conf，再以命名 CLI 参数传给模块。
2. 模块禁止自行读取 YAML，也禁止硬编码路径、软件路径、环境路径和线程数。
3. conf 至少包含 `paths`（输入、输出、temp）、`tools`（软件和环境路径）和 `runtime`（`jobs`、`overwrite`）。

## Output

1. `output/result/` 默认输出 TSV。这是**机器可读的完整精度数据**，不做四位有效数字取整。
2. `output/figure/` 中每张图配一个同名 TSV，包含出图所用的全部数据，同样保留完整精度。只需要输出pdf格式的图，png、svg、jpg等格式不需要。
3. 所有中间文件放在项目根下的 `temp/<N>-<name>/`，禁止使用项目外目录。

## Debugging

调试、试运行、预分析和临时脚本，一律在项目根下的 `temp/<N>-<name>/` 中进行。原因：`/tmp`、`$HOME` 和 Agent 自带的 scratchpad 目录在重启后可能丢失，会导致调试过程和中间结果全部消失。禁止在 `/tmp`、`$HOME`、`$HOME/tmp`、`$HOME/temp`、Agent scratchpad 等项目外目录中调试或存放临时文件。调试结论确认后，再把正式代码移入 `pipe/`、`python/`、`R/` 等目录，`temp/` 中的内容不作为最终交付物。

## Code

一个文件只用一种语言，shell 中不得嵌入 Python 或 R 片段。

## Workflow

- **新建项目**：运行 `bash scripts/init_pipeline_layout.sh <target_dir>` 复制模板，再补充各步骤。
- **重构旧脚本**：配置迁入 conf，流程控制迁入 pipe，业务逻辑迁入对应语言目录。
