# Gotree 任务映射

按用户意图选命令，而不是按子命令名字机械回忆。默认先检查输入树，再执行变换，再做验证。

## 看树 / 自检

### 快速统计与定根判断

- 适用场景：刚拿到一棵树，先看 tip 数、edge 数、枝长和是否已定根。
- 推荐前置检查：无；这是默认第一步。
- 最常用命令模板：
  ```bash
  gotree stats -i tree.nw
  gotree stats rooted -i tree.nw
  gotree stats edges -i tree.nw | head
  ```
- 操作后验证命令：
  ```bash
  gotree draw text -i tree.nw -w 80
  ```
- 常见误区提醒：不要在没确认 rooted/support/branch length 是否被正确解析前直接 reroot、collapse 或 compare。

### 查看 tip 或节点标签

- 适用场景：准备做 `prune`、`rename`、`reroot outgroup` 前，先确认标签名是否精确匹配。
- 推荐前置检查：先 `gotree stats tips -i tree.nw` 或 `gotree draw text`。
- 最常用命令模板：
  ```bash
  gotree labels --tips -i tree.nw
  gotree labels --internal --tips -i tree.nw
  ```
- 操作后验证命令：
  ```bash
  gotree labels --tips -i tree.nw | head
  ```
- 常见误区提醒：Gotree 匹配的是树中的真实标签；空格、引号、前后缀不一致都会导致删不掉或定不了根。

## 格式转换

### Newick / NEXUS / PhyloXML 互转

- 适用场景：软件互通、下游工具只接受特定树格式。
- 推荐前置检查：先确认输入格式，必要时显式加 `--format`。
- 最常用命令模板：
  ```bash
  gotree reformat nexus -i tree.nw -o tree.nex
  gotree reformat newick --format nexus -i tree.nex -o tree.nw
  gotree reformat phyloxml -i tree.nw -o tree.xml
  ```
- 操作后验证命令：
  ```bash
  gotree stats --format nexus -i tree.nex
  gotree stats --format phyloxml -i tree.xml
  ```
- 常见误区提醒：多树文件在格式转换后仍然可能是多树文件，不要默认得到单树。

## 画图与导出

### 终端 ASCII 预览

- 适用场景：快速看拓扑，判断是否需要 reroot、prune、collapse。
- 推荐前置检查：`gotree stats -i tree.nw`
- 最常用命令模板：
  ```bash
  gotree draw text -i tree.nw -w 80
  ```
- 操作后验证命令：
  ```bash
  gotree labels --tips -i tree.nw | head
  ```
- 常见误区提醒：ASCII 图是显示层，不适合凭肉眼判断所有枝长和支持度细节。

### 导出 SVG / PNG / Cytoscape.js HTML

- 适用场景：做汇报、嵌入网页、下游可视化审阅。
- 推荐前置检查：先确认是否需要显示 tip label、node label、support。
- 最常用命令模板：
  ```bash
  gotree draw svg -i tree.nw -w 1200 -H 1200 -o tree.svg
  gotree draw png -i tree.nw -w 1200 -H 1200 -o tree.png
  gotree draw cyjs -i tree.nw -o tree.html
  ```
- 操作后验证命令：
  ```bash
  gotree draw text -i tree.nw -w 80
  ```
- 常见误区提醒：`draw` 只是导出显示结果，不会修改树；若只是想换左右顺序，要考虑 `rotate`，不是重定根。

## 重定根 / 去根

### 中点定根

- 适用场景：没有明确外群，想给无根树找一个中点根。
- 推荐前置检查：`gotree stats rooted -i tree.nw`
- 最常用命令模板：
  ```bash
  gotree reroot midpoint -i tree.nw -o rooted.nw
  ```
- 操作后验证命令：
  ```bash
  gotree stats rooted -i rooted.nw
  gotree draw text -i rooted.nw -w 80
  ```
- 常见误区提醒：中点定根依赖枝长；如果枝长缺失或不可信，中点定根的生物学解释要谨慎。

### 用外群定根

- 适用场景：已知一个或一组外群样本。
- 推荐前置检查：先确认外群 labels 是否准确，必要时先 `gotree labels --tips`。
- 最常用命令模板：
  ```bash
  gotree reroot outgroup -i tree.nw -o rooted.nw Outgroup1
  gotree reroot outgroup -i tree.nw -o rooted.nw -l outgroup.txt
  gotree reroot outgroup -i tree.nw -o rooted.nw -l outgroup.txt --strict
  ```
- 操作后验证命令：
  ```bash
  gotree stats rooted -i rooted.nw
  gotree draw text -i rooted.nw -w 80
  ```
- 常见误区提醒：外群非单系时，默认会基于其 LCA 重定根并给出警告；需要强制失败时用 `--strict`。

### 去根

- 适用场景：下游软件要求无根树，或想消除现有根信息。
- 推荐前置检查：`gotree stats rooted -i tree.nw`
- 最常用命令模板：
  ```bash
  gotree unroot -i rooted.nw -o unrooted.nw
  ```
- 操作后验证命令：
  ```bash
  gotree stats rooted -i unrooted.nw
  ```
- 常见误区提醒：`unroot` 会改变树的定根状态；不要把它当成单纯显示调整。

## Tip 与拓扑编辑

### 删除或保留指定 tips

- 适用场景：删污染样本、做子集分析、保留特定物种。
- 推荐前置检查：先导出 tip 列表，确认文件一行一个 tip。
- 最常用命令模板：
  ```bash
  gotree prune -i tree.nw -f remove.txt -o pruned.nw
  gotree prune -i tree.nw -r -f keep.txt -o kept.nw
  ```
- 操作后验证命令：
  ```bash
  gotree labels --tips -i pruned.nw
  gotree stats -i pruned.nw
  ```
- 常见误区提醒：`prune` 真正改变 tip 集合；如果只是想简化显示而不删除样本，优先考虑 `collapse`。

### 重命名 tips 或节点

- 适用场景：统一命名、去掉特殊字符、把样本编码替换成可读名。
- 推荐前置检查：映射文件需用制表符分隔旧名和新名。
- 最常用命令模板：
  ```bash
  gotree rename -i tree.nw -m map.txt -o renamed.nw
  ```
- 操作后验证命令：
  ```bash
  gotree labels --tips -i renamed.nw | head
  ```
- 常见误区提醒：重命名前先统一命名规范；跨软件时空格和特殊字符容易引出新问题。

### 提取子树 / 嫁接 / 合并

- 适用场景：按内部节点名抽子树；把一棵树接到另一棵树的某个 tip 上；或把两棵定根树接到新根下。
- 推荐前置检查：确认内部节点是否真的有 label；`merge` 前确认两棵树都已定根。
- 最常用命令模板：
  ```bash
  gotree subtree -i tree.nhx -n "^Mammal.*" -o mammal.nw
  gotree graft -i t1.nw -c t2.nw -l TipX -o grafted.nw
  gotree merge -i t1_rooted.nw -c t2_rooted.nw -o merged.nw
  ```
- 操作后验证命令：
  ```bash
  gotree draw text -i mammal.nw -w 80
  gotree stats -i grafted.nw
  gotree stats rooted -i merged.nw
  ```
- 常见误区提醒：`subtree` 按节点名匹配，不是按 tip 名匹配；`merge` 需要的是已定根树。

## 枝长 / 支持度 / 折叠

### 修改枝长

- 适用场景：清空、缩放、四舍五入、设置最小枝长、切断超长枝。
- 推荐前置检查：`gotree stats edges -i tree.nw | head`
- 最常用命令模板：
  ```bash
  gotree brlen clear -i tree.nw -o no_brlen.nw
  gotree brlen scale -i tree.nw -f 0.5 -o scaled.nw
  gotree brlen round -i tree.nw -p 6 -o rounded.nw
  gotree brlen setmin -i tree.nw -l 1e-6 -c 1e-6 -o minlen.nw
  gotree brlen cut -i tree.nw -l 0.5 -o cut.nw
  ```
- 操作后验证命令：
  ```bash
  gotree stats edges -i scaled.nw | head
  ```
- 常见误区提醒：枝长变换会影响中点定根、距离矩阵和部分比较结果。

### 修改支持度

- 适用场景：清空、缩放、四舍五入、整理支持度字段。
- 推荐前置检查：必须先 `gotree stats edges -i tree.nw | head`
- 最常用命令模板：
  ```bash
  gotree support clear -i tree.nw -o no_support.nw
  gotree support scale -i tree.nw -f 100 -o support_100.nw
  gotree support round -i tree.nw -p 2 -o support_round.nw
  ```
- 操作后验证命令：
  ```bash
  gotree stats edges -i support_round.nw | head
  ```
- 常见误区提醒：不同软件把支持度存在 node label 或 comment；先看解析结果，再决定清 comment 还是改 support。

### 按长度或支持度折叠

- 适用场景：简化树、折叠短枝、折叠低支持分支。
- 推荐前置检查：先看枝长和支持度是否存在且可信。
- 最常用命令模板：
  ```bash
  gotree collapse length -i tree.nw -l 0.001 -o collapsed_len.nw
  gotree collapse support -i tree.nw -s 0.8 -o collapsed_sup.nw
  ```
- 操作后验证命令：
  ```bash
  gotree draw text -i collapsed_len.nw -w 80
  gotree draw text -i collapsed_sup.nw -w 80
  ```
- 常见误区提醒：`collapse` 不是删除 tip；它通常把分支折成多分叉或简化拓扑显示。

## 比较与距离

### 比较 tip 集合、树拓扑或边

- 适用场景：看两棵树是否包含同一批样本、是否拓扑一致、哪些边相同。
- 推荐前置检查：先确认两棵树的 tip 命名系统一致。
- 最常用命令模板：
  ```bash
  gotree compare tips -i tree1.nw -c tree2.nw
  gotree compare trees -i tree1.nw -c tree2.nw --rf
  gotree compare trees -i tree1.nw -c tree2.nw --binary
  gotree compare edges -i tree1.nw -c tree2.nw
  ```
- 操作后验证命令：
  ```bash
  gotree labels --tips -i tree1.nw | head
  gotree labels --tips -i tree2.nw | head
  ```
- 常见误区提醒：如果两棵树的样本命名不一致，RF 距离和边比较的解释会失真。

### 导出 patristic 距离矩阵

- 适用场景：想把树转成样本间距离表，供聚类、可视化或统计分析使用。
- 推荐前置检查：确认枝长是否存在，因为 patristic matrix 依赖枝长。
- 最常用命令模板：
  ```bash
  gotree matrix -i tree.nw > dist.tsv
  ```
- 操作后验证命令：
  ```bash
  head dist.tsv
  gotree stats edges -i tree.nw | head
  ```
- 常见误区提醒：没有可信枝长时，距离矩阵的数值解释通常不可靠。

## 多树处理

### 拆分或抽样多树文件

- 适用场景：NEXUS 或 multi-Newick 含多棵树，需要逐棵处理或随机抽样。
- 推荐前置检查：先确认输入文件是否真的是多树文件。
- 最常用命令模板：
  ```bash
  gotree divide -i trees.nw -o split_prefix
  gotree sample -i trees.nw -n 100 -o sampled.nw
  ```
- 操作后验证命令：
  ```bash
  gotree stats -i sampled.nw
  ```
- 常见误区提醒：很多“格式转换失败”其实是把多树文件误当单树文件导致的。

## 生成与扰动

### 生成随机树或做拓扑扰动

- 适用场景：教学演示、方法测试、置换检验、局部拓扑扰动。
- 推荐前置检查：如需可重复结果，固定 `--seed`。
- 最常用命令模板：
  ```bash
  gotree generate yuletree -l 50 -o yule.nw
  gotree generate uniformtree -l 100 -n 10 | gotree stats
  gotree shuffletips -i tree.nw -o shuffled.nw
  gotree nni -i tree.nw -o nni_neighbors.nw
  gotree rotate rand -i tree.nw -o rotated.nw
  gotree resolve -i tree.nw -o resolved.nw
  ```
- 操作后验证命令：
  ```bash
  gotree draw text -i yule.nw -w 80
  gotree compare tips -i tree.nw -c rotated.nw
  ```
- 常见误区提醒：`rotate` 只改显示顺序，不改拓扑；`resolve` 会把多分叉解析为二叉并加入 0 长度枝。

## 远程 I/O 与服务器交互

### 从远程源读取树或下载/上传

- 适用场景：树在 URL、iTOL、TreeBase 或服务器端。
- 推荐前置检查：先确认远程标识符和权限；上传前确认目标平台要求。
- 最常用命令模板：
  ```bash
  gotree stats -i http://example.org/tree.nw
  gotree stats -i itol://1234567890
  gotree stats -i treebase://S12345
  gotree download itol [options]
  gotree upload itol [options]
  ```
- 操作后验证命令：
  ```bash
  gotree draw text -i http://example.org/tree.nw -w 80
  ```
- 常见误区提醒：远程输入能直接参与 pipeline，但网络失败和权限错误需要和树格式错误区分开来。
