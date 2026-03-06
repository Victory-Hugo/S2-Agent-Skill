---
name: gotree-phylogenetic-tree
description: 使用 Gotree 命令行对系统发育树进行读取、检查、重定根、修剪、重命名、格式转换、支持度与枝长处理、折叠、比较、绘图、距离矩阵导出、随机树生成与远程下载上传。适用于 Newick、NEXUS、PhyloXML、Nextstrain/Augur v2 树文件的批处理、管道式工作流和终端自动化；涉及多序列比对请改用 goalign，涉及 Python 树分析请按需使用 biopython 或 scikit-bio。
---

# Gotree

面向 Gotree CLI 的系统发育树操作技能，用于把树文件当作可流水线处理的数据来检查、变换、比较和导出。

## 快速工作规则

- 先做输入检查，再做变换。
- 默认先跑 `gotree stats`；如果需要判断定根状态、支持度、tip 集合或边信息，再补 `gotree stats rooted`、`gotree stats edges`、`gotree stats tips`、`gotree labels`。
- 优先使用 STDIN/STDOUT 和 pipe，除非用户明确要求把中间结果落盘。
- 用户未说明格式时，默认按 `newick` 处理，但要先核对扩展名和文件内容；必要时显式加 `--format`。
- 涉及多树文件时，先确认是否需要 `gotree divide` 或 `gotree sample`，不要默认把多树文件当单树处理。
- 支持度解析异常时，先用 `gotree stats edges` 看支持度是否被正确识别，再决定是否使用 `support` 或 `comment` 相关命令。

## 任务分流

- 常见需求与命令对应关系：看 [references/task-map.md](references/task-map.md)
- 可直接复用的命令链与工作流模板：看 [references/workflows.md](references/workflows.md)
- 格式、输入源、全局参数和易错点：看 [references/io-and-pitfalls.md](references/io-and-pitfalls.md)

## 执行策略

- 明确输入文件、输出文件、是否覆盖原文件；如果用户没说，默认写新文件而不是原地破坏。
- 回答中给出可直接复制的完整命令，不只给子命令名。
- 对破坏性操作明确说明后果，尤其是 `prune`、`collapse`、`unroot`、`reroot outgroup --remove-outgroup`。
- 对高风险操作附带验证步骤，至少覆盖 reroot、support 处理、多树文件处理和批量 tip 编辑。
- 如果用户目标不明确，先澄清是“删除 tips 还是只保留 tips”，以及“要改拓扑还是只改显示顺序”。
- 如果命令结果需要继续下游分析，优先给出可串联的 pipeline；如果需要审阅中间结果，建议用 `tee` 或中间文件。

## 工具边界

- 多序列比对不是 Gotree 的职责，转用 `goalign`。
- 如果用户要在 Python 中对树对象做程序化分析，而不是调用 CLI，优先考虑 `biopython` 或 `scikit-bio`。
- 如果用户明确要开发基于 Gotree 的 Go 程序，只提示官方 `docs/api/` 和仓库源码路径，不在这个 skill 里系统展开 Go API 教程。
