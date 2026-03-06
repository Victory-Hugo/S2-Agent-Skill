# Gotree 工作流模板

以下模板以“先检查，再变换，再验证”为固定顺序。按需替换文件名、阈值和 layout 参数。

## 1. 读取并快速自检树

- 输入假设：`tree.nw` 是本地单棵 Newick 树。
- 完整命令：
  ```bash
  gotree stats -i tree.nw
  gotree draw text -i tree.nw -w 80
  ```
- 输出结果说明：第一条命令给出节点数、tip 数、枝长和 rooted 状态；第二条命令给出 ASCII 树用于快速肉眼检查。
- 何时应该改参数：树很大时把 `-w` 调大；若输入不是 Newick，显式加 `--format nexus` 或其他格式。
- 验证动作：
  ```bash
  gotree stats rooted -i tree.nw
  ```

## 2. Newick 转 Nexus，再输出可视化

- 输入假设：`tree.nw` 是可解析的 Newick 树，希望转成 NEXUS 并附带一个 SVG 图。
- 完整命令：
  ```bash
  gotree reformat nexus -i tree.nw -o tree.nex
  gotree draw svg -i tree.nw -w 1200 -H 1200 -o tree.svg
  ```
- 输出结果说明：得到 `tree.nex` 和 `tree.svg`；格式转换与可视化相互独立。
- 何时应该改参数：如果图太密，增大 `-w` 和 `-H`；如果想要径向布局，加 `-r`。
- 验证动作：
  ```bash
  gotree stats --format nexus -i tree.nex
  ```

## 3. 用单个外群定根，并验证 rooted 状态

- 输入假设：`tree.nw` 未定根，`Outgroup1` 是树中存在的单个外群 tip。
- 完整命令：
  ```bash
  gotree reroot outgroup -i tree.nw -o rooted.nw Outgroup1
  gotree stats rooted -i rooted.nw
  ```
- 输出结果说明：`rooted.nw` 应为按外群重定根后的树；第二条命令确认 rooted 状态。
- 何时应该改参数：如果想在定根后移除外群，加 `--remove-outgroup`；如果输入不是文件，也可用 stdin。
- 验证动作：
  ```bash
  gotree draw text -i rooted.nw -w 80
  ```

## 4. 用外群列表定根，必要时移除外群

- 输入假设：`outgroup.txt` 每行一个 tip 名，且外群应为单系。
- 完整命令：
  ```bash
  gotree reroot outgroup -i tree.nw -o rooted_strict.nw -l outgroup.txt --strict
  gotree reroot outgroup -i tree.nw -o rooted_drop_outgroup.nw -l outgroup.txt --remove-outgroup
  ```
- 输出结果说明：第一条在外群非单系时直接失败；第二条在定根后删除外群。
- 何时应该改参数：如果只想容忍非单系并给 warning，去掉 `--strict`；如果不想删外群，去掉 `--remove-outgroup`。
- 验证动作：
  ```bash
  gotree stats rooted -i rooted_strict.nw
  gotree labels --tips -i rooted_drop_outgroup.nw
  ```

## 5. 按名单删除或仅保留 tips

- 输入假设：`remove.txt` 或 `keep.txt` 每行一个 tip 名。
- 完整命令：
  ```bash
  gotree prune -i tree.nw -f remove.txt -o pruned.nw
  gotree prune -i tree.nw -r -f keep.txt -o kept.nw
  ```
- 输出结果说明：`pruned.nw` 删除名单中的 tips；`kept.nw` 只保留名单中的 tips。
- 何时应该改参数：如果不是从文件读名单，也可以直接把 tips 写在命令行最后；若按另一棵树的 tip 集合裁剪，可用 `-c other_tree.nw`。
- 验证动作：
  ```bash
  gotree labels --tips -i pruned.nw
  gotree labels --tips -i kept.nw
  ```

## 6. 批量重命名 tips 后导出

- 输入假设：`map.txt` 为两列制表符，格式为 `旧名<TAB>新名`。
- 完整命令：
  ```bash
  gotree rename -i tree.nw -m map.txt -o renamed.nw
  ```
- 输出结果说明：得到使用新标签的 `renamed.nw`。
- 何时应该改参数：如果只是想做下游展示，重命名前先统一命名规范，避免再引入空格和特殊字符。
- 验证动作：
  ```bash
  gotree labels --tips -i renamed.nw | head
  gotree draw text -i renamed.nw -w 80
  ```

## 7. 折叠低支持度或短枝前后对照

- 输入假设：原树中存在支持度和/或枝长信息。
- 完整命令：
  ```bash
  gotree collapse support -i tree.nw -s 0.8 -o collapsed_support.nw
  gotree collapse length -i tree.nw -l 0.001 -o collapsed_length.nw
  ```
- 输出结果说明：得到按支持度或按短枝阈值折叠后的新树。
- 何时应该改参数：阈值应随数据集规模与构树方法调整；若支持度没有被正确解析，先不要直接 `collapse support`。
- 验证动作：
  ```bash
  gotree stats edges -i tree.nw | head
  gotree draw text -i collapsed_support.nw -w 80
  gotree draw text -i collapsed_length.nw -w 80
  ```

## 8. 两棵树比较并导出 patristic 距离矩阵

- 输入假设：`tree1.nw` 与 `tree2.nw` 的 tip 命名体系一致，且 `tree1.nw` 有可信枝长。
- 完整命令：
  ```bash
  gotree compare trees -i tree1.nw -c tree2.nw --rf
  gotree compare trees -i tree1.nw -c tree2.nw --binary
  gotree matrix -i tree1.nw > tree1.dist.tsv
  ```
- 输出结果说明：前两条给出 RF 距离或二元一致性判断；第三条导出 patristic distance matrix。
- 何时应该改参数：若要比较带枝长的差异，用 `--weighted`；若要比较 tip 集合，改用 `compare tips`。
- 验证动作：
  ```bash
  head tree1.dist.tsv
  gotree stats edges -i tree1.nw | head
  ```
