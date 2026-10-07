# Log Contract

## Required Files

在项目根目录或脚本约定的工作目录下，固定使用以下文件：

- `log/.resume.lock`
- `log/success.log`
- `log/fail.log`

`log/` 是断点续跑的唯一状态目录。不要把断点状态分散到 `output/`、临时目录或结果目录。

## Record Formats

`success.log` 每行记录一个成功样本，格式固定为：

```text
sample_id<TAB>timestamp
```

示例：

```text
SRR001	2026-03-15T16:45:22+08:00
SRR002	2026-03-15T16:47:10+08:00
```

`fail.log` 每行记录一个失败样本，格式固定为：

```text
sample_id
```

示例：

```text
SRR003
SRR005
```

## Resume Truth Table

断点续跑时，只允许基于 `success.log` 第一列的样本 ID 做完成判定：

| 条件 | 下次运行动作 |
| --- | --- |
| 样本在 `success.log` 中 | 跳过 |
| 样本只在 `fail.log` 中 | 重跑 |
| 样本既不在 `success.log` 也不在 `fail.log` 中 | 运行 |
| 样本同时在 `success.log` 和 `fail.log` 中 | 跳过，成功优先 |

`fail.log` 仅用于记录失败历史和人工排查，不得作为“已处理完成”的依据。

## Forbidden Patterns

明确禁止以下模式：

- `if [ -f output/... ]`
- `if [ -s result.txt ]`
- `find output -name ...`
- `ls output/...`
- 通过目录中文件数量推断完成状态
- 通过结果文件大小、时间戳或存在性重建样本状态
- 把“有输出文件”视为“已完成”

只要逻辑是在扫描产出文件来判断样本是否做完，就属于违规实现。
