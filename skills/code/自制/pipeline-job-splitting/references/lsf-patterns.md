# LSF Patterns

## 适用范围

本文件给出 LSF 优先场景下的最小包装模式。默认目标是让每个子任务成为“一个独立、轻量、单核”的 `.lsf` 作业脚本。

## 默认资源规格

除非用户明确要求其他资源，默认使用：

- `#BSUB -n 1`
- `#BSUB -R "span[hosts=1]"`
- 默认队列由项目或用户指定
- 默认运行时间由项目或用户指定

## 最小 LSF 包装器模式

```bash
#!/bin/bash
#BSUB -J job_name
#BSUB -q normal
#BSUB -n 1
#BSUB -R "span[hosts=1]"
#BSUB -W 2000:00
#BSUB -o /path/to/logs/job_name.out
#BSUB -e /path/to/logs/job_name.err

set -euo pipefail

PIPELINE_ROOT="/abs/path/to/project"
CONF_FILE="/abs/path/to/task.conf"
RUN_SCRIPT="/abs/path/to/main_runner.sh"

bash "${RUN_SCRIPT}" "${CONF_FILE}"
```

## 命名规则

推荐以下固定命名：

- 批次目录：`batch_YYYYmmdd_HHMMSS`
- 子任务列表：`list_0000.txt`
- 子配置：`TaskName_0000.conf`
- 子调度脚本：`JobPrefix_0000.lsf`
- LSF 作业名：`JobPrefix_0000`

命名目标是：

- 稳定排序
- 易于人工检查
- 容易批量提交

## 手动提交模式

默认只生成，不自动提交。

单个提交：

```bash
bsub < JobPrefix_0000.lsf
```

批量提交：

```bash
for f in *.lsf; do bsub < "$f"; done
```

## 项目外 batch root 的规则

如果生成目录不在项目树内，例如：

- 项目在 `/share/home/...`
- 批次文件放在 `/data/home/...`

则生成的 `.lsf` 中必须写：

- 绝对 `PIPELINE_ROOT`
- 绝对 `CONF_FILE`
- 绝对 `RUN_SCRIPT`

不要使用：

```bash
PIPELINE_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
```

因为这只在批次目录位于项目内部时才可靠。

## 术语对照

- `job splitting`：任务拆分，把一个粗粒度任务拆成多个独立子任务。
- `fine-grained scheduling`：细粒度调度，以更小的调度单元提交作业。
- `high-throughput submission`：高吞吐作业提交，一次提交大量小任务。
- `scatter`：将一个任务集合打散成多个并行子任务。
- `scatter-gather`：先打散并行执行，再在后续步骤汇总结果。

