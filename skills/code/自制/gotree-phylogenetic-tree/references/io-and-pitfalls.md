# Gotree I/O 与易错点

## 支持的树格式

Gotree 直接处理以下格式：

- Newick
- NEXUS
- PhyloXML
- Nextstrain / Augur v2

用户未声明格式时，默认先按 `newick` 试，但要核对扩展名和文件内容；必要时显式给 `--format`。

## 输入来源

Gotree 不只读本地文件，也可以直接读取：

- 本地文件，如 `tree.nw`
- 标准输入 `stdin`
- `http://<URL>`
- `itol://<ID>`
- `treebase://<ID>`
- `.gz` 压缩输入

这意味着很多任务可以直接串成 pipeline，而不必先手工下载到本地。

## 全局参数

高频全局参数：

- `--format`：指定输入树格式
- `--seed`：设置随机种子，保证可重复
- `--threads`：设置线程数

如果任务涉及 `generate`、`shuffletips`、随机 `prune` 或其他随机行为，优先显式写 `--seed`。

## 管道约定

多数命令遵循统一约定：

- 不写 `-i` 或对应输入参数时，默认从 `stdin` 读
- 不写 `-o` 或对应输出参数时，默认写到 `stdout`

常见写法：

```bash
cat tree.nw | gotree stats
cat tree.nw | gotree draw text -w 80
gotree generate yuletree -l 50 | gotree draw svg -w 1200 -H 1200 -o tree.svg
```

如果需要保留中间产物，建议用 `tee` 或显式输出文件。

## `collapse` 与 `prune` 的区别

- `prune`：真正删除 tips，改变样本集合
- `collapse`：折叠分支或 clade，通常不等于删除样本

如果用户说“只想简化显示、不想删样本”，优先考虑 `collapse`，不要直接 `prune`。

## `rotate` 不改拓扑

`rotate` 只改变内部节点子节点的遍历顺序，也就是显示顺序；它不改变拓扑，不应被当成 reroot、merge 或 NNI 的替代品。

如果用户目标是“把某个 clade 放左边方便看图”，可以考虑 `rotate`；如果目标是“改变根位置”或“修改树关系”，则不应使用 `rotate`。

## `reroot outgroup` 的非单系外群

`gotree reroot outgroup` 默认在外群不是单系时不会立即失败，而是基于外群的 LCA 做 reroot，并给出 warning。

要点：

- 追求严格生物学约束时，加 `--strict`
- 定根后若要删外群，用 `--remove-outgroup`
- 做这类操作前，先确认外群 label 是否准确

## 支持度可能存于不同位置

不同软件导出的树，对支持度的存放方式并不一致：

- 有的在 internal node label
- 有的在 comment

因此不要假设 `collapse support` 或 `support scale` 一定直接有效。先执行：

```bash
gotree stats edges -i tree.nw | head
```

看支持度列是否正常，再决定是否处理 `support` 或先清理/转移 `comment`。

## Newick rooted 状态识别可能不稳

某些 Newick 树的 rooted 状态识别可能不稳定，尤其在跨软件导出后更常见。

实务建议：

- 先用 `gotree stats rooted -i tree.nw`
- 如果结果与预期不符，显式执行 `reroot midpoint` 或 `reroot outgroup`
- reroot 后再次检查 rooted 状态

不要只凭原始文件名中的“rooted”字样做判断。

## 多树文件要先降复杂度

NEXUS 和 multi-Newick 经常包含多棵树。很多 Gotree 命令支持多树输入，但任务目标往往是“只处理其中一部分”。

实务建议：

- 先确认输入是否为多树文件
- 需要逐棵处理时，用 `gotree divide`
- 只抽样一部分树时，用 `gotree sample`

这样可以避免把一个多树文件直接拿去做本来按单树设计的解释或验证。

## 不要硬编码版本字符串

当前环境中 `gotree version` 没有稳定返回版本字符串，因此在 skill 中不要写死任何版本号，也不要假设用户环境会输出相同版本信息。

如果任务明显依赖具体版本行为，优先让代理通过 `gotree -h` 或对应子命令帮助做现场确认。
