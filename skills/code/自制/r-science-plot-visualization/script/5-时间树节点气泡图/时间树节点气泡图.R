library(treeio)
library(ape)
library(tidyverse)
library(scales)
library(ggrepel)
library(ggnewscale)

#* =====configuration=====
# 设置项目路径和输入输出文件
script_arg <- commandArgs(trailingOnly = FALSE)
script_file <- sub("^--file=", "", script_arg[grepl("^--file=", script_arg)])
project_dir <- normalizePath(file.path(dirname(script_file), ".."), mustWork = TRUE)
tree_path <- "1-tree.tree"
tip_metadata <- "2-meta.tsv"
dir_output <- "output"

# 设置树解析参数
branch_length_unit <- "years" #* 可选 years 或 kya
period_breaks <- c(0, 3000, 5000, 10000, 11700, 19000, 26500, Inf) #* 年代分箱边界，单位为年
period_labels <- c("0-3k", "3-5k", "5-10k", "10-11.7k", "11.7-19k", "LGM_19-26.5k", ">26.5k") #* 年代分箱标签

# 设置绘图筛选参数
min_tree_tips <- 2 #* 一棵树至少包含的 tip 数；正式分析建议设为 50
min_descendant_tips <- 2 #* 一个内部节点至少包含的后代 tip 数；正式分析建议设为 20
majority_threshold <- 0.5 #* 地区主导节点的最低占比
annotation_max_age_kya <- 10 #* 只标注该年代以内的节点，单位为 kya

# 设置图片输出参数
figure_width_mm <- 200 #* 图片宽度，单位为 mm
figure_height_mm <- 140 #* 图片高度，单位为 mm
figure_dpi <- 300 #* PNG 分辨率

# 设置地区顺序、别名和显式配色
china_region_levels <- c(
  "East_China", "North_China", "Central_China", "South_China",
  "Southwest_China", "Northeast_China", "Northwest_China"
)
region_aliases <- c(
  Southwest = "Southwest_China",
  Northeast = "Northeast_China",
  Northwest = "Northwest_China"
)
region_colors <- c(
  East_China = "#0072b2",
  North_China = "#56b4e9",
  Central_China = "#009e73",
  South_China = "#f0e442",
  Southwest_China = "#e69f00",
  Northeast_China = "#d55e00",
  Northwest_China = "#8ecae6"
)
period_levels <- rev(period_labels)
period_colors <- c(
  ">26.5k" = "#0b0405",
  "LGM_19-26.5k" = "#3e4d93",
  "11.7-19k" = "#366b9f",
  "10-11.7k" = "#36a4ab",
  "5-10k" = "#60ceac",
  "3-5k" = "#84d8b0",
  "0-3k" = "#def5e5"
)
time_ref_kya <- c(26.5, 21, 19, 11.7, 10, 5, 3) #* 时间轴参考线位置
time_reference_colour <- "#8c8c8c" #* 时间轴参考线颜色
recent_window_colour <- "#f0e442" #* 最近 5 kya 背景颜色

#* =====validation=====
# 创建输出目录
dir.create(dir_output, recursive = TRUE, showWarnings = FALSE)

# 检查固定参数
if (!branch_length_unit %in% c("years", "kya")) {
  stop("branch_length_unit 必须是 'years' 或 'kya'。")
}
if (length(period_labels) != length(period_breaks) - 1) {
  stop("period_labels 必须比 period_breaks 少 1 个元素。")
}
if (!file.exists(tip_metadata)) {
  stop("找不到 metadata 文件：", tip_metadata)
}

# 查找输入树文件
tree_suffix_pattern <- "\\.(tre|tree|trees|nwk|newick|nex|nexus)$"
if (file.exists(tree_path) && !dir.exists(tree_path)) {
  tree_files <- tree_path
} else {
  tree_files <- list.files(
    tree_path,
    pattern = tree_suffix_pattern, #* 只读取支持的树文件
    full.names = TRUE,
    ignore.case = TRUE
  )
}
tree_files <- sort(tree_files)
if (length(tree_files) == 0) {
  stop("input/ 中没有 BEAST 或 Newick 树文件。")
}

#* =====style=====
# 设置统一绘图主题
theme_set(
  theme_classic(base_family = "sans", base_size = 8) +
    theme(
      plot.title = element_text(face = "bold", size = 10),
      plot.subtitle = element_text(size = 7, colour = "grey30"),
      axis.title = element_text(size = 8),
      axis.text = element_text(size = 7, colour = "black"),
      legend.title = element_text(size = 8),
      legend.text = element_text(size = 7),
      legend.key.size = unit(3, "mm"),
      plot.margin = margin(5, 5, 5, 5)
    )
)

#* =====read_metadata=====
# 读取并规范化 tip metadata
dat1 <- read_tsv(tip_metadata, col_types = cols(.default = col_character()))
knitr::kable(head(dat1))

if (!"region" %in% names(dat1)) {
  stop("tip_metadata.tsv 必须包含 region 列。")
}
if (!any(c("tip_name", "sample_id", "ID") %in% names(dat1))) {
  stop("tip_metadata.tsv 必须包含 tip_name、sample_id 或 ID 中的至少一列。")
}
if (!"tip_name" %in% names(dat1)) dat1$tip_name <- ""
if (!"sample_id" %in% names(dat1)) dat1$sample_id <- ""
if (!"ID" %in% names(dat1)) dat1$ID <- ""
if (!"population" %in% names(dat1) && "Population" %in% names(dat1)) dat1$population <- dat1$Population
if (!"population" %in% names(dat1)) dat1$population <- "Unassigned"
if (!"haplogroup" %in% names(dat1) && "Haplogroup" %in% names(dat1)) dat1$haplogroup <- dat1$Haplogroup
if (!"haplogroup" %in% names(dat1)) dat1$haplogroup <- ""

# 替换地区别名并标记未知地区
alias_index <- match(dat1$region, names(region_aliases))
dat1$region[!is.na(alias_index)] <- unname(region_aliases[alias_index[!is.na(alias_index)]])
dat1 <- dat1 %>%
  mutate(
    region = if_else(region %in% china_region_levels, region, "Others"),
    population = if_else(is.na(population) | population == "", "Unassigned", population),
    haplogroup = replace_na(haplogroup, "")
  )

#* =====parse_trees=====
# 初始化跨树结果
tree_rows <- list()
node_rows <- list()
tip_rows <- list()
tree_row_index <- 0
node_row_index <- 0
tip_row_index <- 0

# 逐棵读取树并计算内部节点属性
for (tree_file in tree_files) {
  tree_id <- tools::file_path_sans_ext(basename(tree_file))
  tree_extension <- tolower(tools::file_ext(tree_file))

  if (tree_extension == "trees") {
    tree_object <- treeio::read.beast(tree_file)
  } else if (tree_extension %in% c("nex", "nexus")) {
    tree_object <- treeio::read.nexus(tree_file)
  } else {
    tree_object <- treeio::read.newick(tree_file)
  }
  if (inherits(tree_object, "treedata")) tree_object <- ape::as.phylo(tree_object)
  if (inherits(tree_object, "multiPhylo")) tree_object <- tree_object[[1]]
  if (!inherits(tree_object, "phylo")) stop("无法解析树文件：", tree_file)

  n_tips <- length(tree_object$tip.label)
  if (n_tips == 0) stop("树文件不包含 tip：", tree_file)
  n_nodes <- tree_object$Nnode
  all_nodes <- seq_len(n_tips + n_nodes)
  branch_scale <- if_else(branch_length_unit == "kya", 1000, 1)
  edge_length <- replace_na(tree_object$edge.length, 0) * branch_scale

  # 匹配每个 tip 的 metadata
  tree_tip_rows <- vector("list", n_tips)
  for (tip_index in seq_len(n_tips)) {
    tip_name_value <- tree_object$tip.label[tip_index]
    has_separator <- grepl("_", tip_name_value, fixed = TRUE)
    sample_id_value <- if_else(has_separator, sub("_[^_]*$", "", tip_name_value), tip_name_value)
    tree_haplogroup <- if_else(has_separator, sub("^.*_", "", tip_name_value), "")

    metadata_index <- match(tip_name_value, dat1$tip_name)
    if (is.na(metadata_index)) metadata_index <- match(sample_id_value, dat1$sample_id)
    if (is.na(metadata_index)) metadata_index <- match(sample_id_value, dat1$ID)
    metadata_matched <- !is.na(metadata_index)

    plot_region <- if_else(metadata_matched, dat1$region[metadata_index], "Others")
    population_value <- if_else(metadata_matched, dat1$population[metadata_index], "Unassigned")
    metadata_haplogroup <- if_else(metadata_matched, dat1$haplogroup[metadata_index], "")
    haplogroup_value <- if_else(metadata_haplogroup != "", metadata_haplogroup, tree_haplogroup)
    if (haplogroup_value == "") haplogroup_value <- "Unassigned"

    tree_tip_rows[[tip_index]] <- tibble(
      tree = tree_id,
      tip_index = tip_index,
      tip_name = tip_name_value,
      sample_id = sample_id_value,
      tree_tip_haplogroup = haplogroup_value,
      metadata_status = if_else(metadata_matched, "matched", "missing"),
      plot_region = plot_region,
      population = population_value
    )
  }
  dat2 <- bind_rows(tree_tip_rows)

  # 自底向上累计每个节点的后代 tip 和节点年龄
  descendant_tip_indices <- vector("list", length(all_nodes))
  node_age_years <- rep(0, length(all_nodes))
  for (tip_index in seq_len(n_tips)) descendant_tip_indices[[tip_index]] <- tip_index

  postorder_edges <- reorder.phylo(tree_object, order = "postorder")$edge
  postorder_parents <- unique(postorder_edges[, 1])
  for (parent_node in postorder_parents) {
    parent_edges <- which(tree_object$edge[, 1] == parent_node)
    child_nodes <- tree_object$edge[parent_edges, 2]
    descendant_tip_indices[[parent_node]] <- unlist(descendant_tip_indices[child_nodes], use.names = FALSE)
    node_age_years[parent_node] <- max(edge_length[parent_edges] + node_age_years[child_nodes])
  }

  # 汇总树级统计
  root_node <- setdiff(tree_object$edge[, 1], tree_object$edge[, 2])[1]
  tree_row_index <- tree_row_index + 1
  tree_rows[[tree_row_index]] <- tibble(
    tree = tree_id,
    tree_file = tree_file,
    tips = n_tips,
    internal_nodes = n_nodes,
    total_nodes = n_tips + n_nodes,
    root_age_years = node_age_years[root_node],
    root_age_kya = node_age_years[root_node] / 1000,
    metadata_matched_tips = sum(dat2$metadata_status == "matched"),
    metadata_missing_tips = sum(dat2$metadata_status == "missing"),
    tips_with_geo7 = sum(dat2$plot_region %in% china_region_levels),
    tips_without_geo7 = sum(!dat2$plot_region %in% china_region_levels),
    tips_with_plot_region = sum(dat2$plot_region != "Others")
  )

  # 按树的前序顺序输出内部节点
  preorder_edges <- reorder.phylo(tree_object, order = "cladewise")$edge
  preorder_nodes <- unique(preorder_edges[, 1])
  for (internal_index in seq_along(preorder_nodes)) {
    node_number <- preorder_nodes[internal_index]
    descendant_index <- descendant_tip_indices[[node_number]]
    node_regions <- dat2$plot_region[descendant_index]
    node_populations <- dat2$population[descendant_index]
    node_haplogroups <- sort(unique(dat2$tree_tip_haplogroup[descendant_index]))

    region_counts <- sort(table(node_regions), decreasing = TRUE)
    population_counts <- sort(table(node_populations), decreasing = TRUE)
    dominant_region <- names(region_counts)[1]
    dominant_population <- names(population_counts)[1]

    valid_haplogroups <- node_haplogroups[!node_haplogroups %in% c("", "Unassigned")]
    node_haplogroup <- tree_id
    if (length(valid_haplogroups) > 0) {
      node_haplogroup <- valid_haplogroups[1]
      if (length(valid_haplogroups) > 1) {
        for (haplogroup_value in valid_haplogroups[-1]) {
          prefix_length <- 0
          max_prefix_length <- min(nchar(node_haplogroup), nchar(haplogroup_value))
          if (max_prefix_length > 0) {
            for (character_index in seq_len(max_prefix_length)) {
              if (substr(node_haplogroup, character_index, character_index) != substr(haplogroup_value, character_index, character_index)) break
              prefix_length <- character_index
            }
          }
          node_haplogroup <- substr(node_haplogroup, 1, prefix_length)
          if (node_haplogroup == "") {
            node_haplogroup <- tree_id
            break
          }
        }
      }
    }

    age_years_value <- node_age_years[node_number]
    period_index <- findInterval(age_years_value, period_breaks, rightmost.closed = FALSE, all.inside = TRUE)
    node_row_index <- node_row_index + 1
    node_rows[[node_row_index]] <- tibble(
      tree = tree_id,
      node_id = paste0(tree_id, "_N", internal_index),
      node_haplogroup = node_haplogroup,
      age_years = age_years_value,
      age_kya = age_years_value / 1000,
      period = period_labels[period_index],
      descendant_tips = length(descendant_index),
      region_assigned_tips = sum(node_regions != "Others"),
      region_diversity = length(unique(node_regions[node_regions != "Others"])),
      dominant_region = dominant_region,
      dominant_region_n = unname(region_counts[1]),
      dominant_region_fraction = unname(region_counts[1]) / length(node_regions),
      dominant_population = dominant_population,
      dominant_population_n = unname(population_counts[1]),
      dominant_population_fraction = unname(population_counts[1]) / length(node_populations)
    )
  }

  tip_row_index <- tip_row_index + 1
  tip_rows[[tip_row_index]] <- select(dat2, -tip_index)
}

# 合并并预览解析结果
dat3 <- bind_rows(tree_rows)
dat4 <- bind_rows(node_rows)
dat5 <- bind_rows(tip_rows)
dat6 <- dat5 %>%
  filter(plot_region %in% china_region_levels) %>%
  count(group = plot_region, name = "n_samples") %>%
  complete(group = china_region_levels, fill = list(n_samples = 0)) %>%
  mutate(group = factor(group, levels = china_region_levels)) %>%
  arrange(group) %>%
  mutate(group = as.character(group))
knitr::kable(head(dat3))
knitr::kable(head(dat4))
knitr::kable(head(dat5))
knitr::kable(dat6)

# 写出树解析结果
write_tsv(dat3, file.path(dir_output, "tree_summary.tsv"))
write_tsv(dat4, file.path(dir_output, "node_scatter.tsv"))
write_tsv(dat5, file.path(dir_output, "tip_metadata.tsv"))
write_tsv(dat6, file.path(dir_output, "region_sample_counts.tsv"))

#* =====process_plot_data=====
# 筛选可绘图树并计算三种纵轴指标
plot_tree_ids <- dat3 %>%
  filter(tips >= min_tree_tips) %>%
  pull(tree)

dat7 <- dat4 %>%
  filter(tree %in% plot_tree_ids, descendant_tips >= min_descendant_tips) %>%
  left_join(select(dat3, tree, tree_tips = tips), by = "tree") %>%
  left_join(rename(dat6, dominant_region = group), by = "dominant_region") %>%
  mutate(
    descendant_share = descendant_tips / tree_tips,
    period = factor(period, levels = period_levels),
    descendant_share_region = if_else(
      dominant_region %in% china_region_levels &
        dominant_region_fraction >= majority_threshold & n_samples > 0,
      descendant_tips / n_samples,
      NA_real_
    )
  ) %>%
  select(-n_samples)

if (nrow(dat7) == 0) {
  stop("筛选后没有可绘制节点，请检查 min_tree_tips 和 min_descendant_tips。")
}

# 生成三张图各自的标注点
dat8 <- dat7 %>%
  filter(
    age_kya < annotation_max_age_kya,
    descendant_share < 0.95,
    dominant_region %in% china_region_levels,
    dominant_region_fraction >= majority_threshold
  ) %>%
  group_by(dominant_region) %>%
  slice_max(descendant_tips, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(
    label = paste0(node_haplogroup, "\n", comma(descendant_tips)),
    dominant_region = factor(dominant_region, levels = china_region_levels)
  )

dat9 <- dat7 %>%
  filter(
    age_kya < annotation_max_age_kya,
    dominant_region %in% china_region_levels,
    dominant_region_fraction >= majority_threshold
  ) %>%
  group_by(dominant_region) %>%
  slice_max(descendant_share, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(
    label = paste0(node_haplogroup, "\n", percent(descendant_share, accuracy = 0.1)),
    dominant_region = factor(dominant_region, levels = china_region_levels)
  )

dat10 <- dat7 %>%
  filter(
    age_kya < annotation_max_age_kya,
    dominant_region %in% china_region_levels,
    dominant_region_fraction >= majority_threshold,
    !is.na(descendant_share_region)
  ) %>%
  group_by(dominant_region) %>%
  slice_max(descendant_share_region, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(
    label = paste0(node_haplogroup, "\n", percent(descendant_share_region, accuracy = 0.1)),
    dominant_region = factor(dominant_region, levels = china_region_levels)
  )

dat11 <- dat7 %>%
  filter(!is.na(descendant_share_region)) %>%
  mutate(dominant_region = factor(dominant_region, levels = china_region_levels))

# 写出绘图数据
write_tsv(dat7, file.path(dir_output, "recent_expansion_signature.tsv"))
write_tsv(dat7, file.path(dir_output, "recent_expansion_signature_share.tsv"))
write_tsv(dat11, file.path(dir_output, "recent_expansion_signature_region_share.tsv"))

#* =====plot_count=====
# 绘制原始后代 tip 数版本
label_text_size <- 5.0 / ggplot2::.pt
p <- ggplot(dat7, aes(x = age_kya, y = descendant_tips)) +
  annotate("rect", xmin = 0, xmax = 5, ymin = min_descendant_tips, ymax = Inf, fill = recent_window_colour, alpha = 0.16) +
  geom_vline(xintercept = time_ref_kya, colour = time_reference_colour, linewidth = 0.16, linetype = "dotted") +
  geom_point(aes(colour = period, size = descendant_tips), alpha = 0.55, stroke = 0) +
  scale_colour_manual(values = period_colors, breaks = period_levels, name = "Node age", drop = FALSE) +
  ggnewscale::new_scale_colour() +
  geom_point(
    data = dat8,
    mapping = aes(x = age_kya, y = descendant_tips, fill = dominant_region, size = descendant_tips), #* 标注点颜色对应地区，大小对应后代 tip 数
    inherit.aes = FALSE,
    shape = 21,
    colour = "black",
    stroke = 0.6
  ) +
  ggrepel::geom_text_repel(
    data = dat8,
    mapping = aes(x = age_kya, y = descendant_tips, label = label, colour = dominant_region), #* 标注文本和颜色映射
    inherit.aes = FALSE,
    family = "sans",
    fontface = "bold",
    size = label_text_size,
    lineheight = 0.85,
    segment.size = 0.3,
    segment.color = "#222222",
    min.segment.length = 0,
    show.legend = FALSE,
    max.overlaps = Inf,
    box.padding = 0.4
  ) +
  scale_x_reverse(breaks = c(26.5, 21, 19, 11.7, 10, 5, 3, 0)) +
  scale_y_log10(labels = comma) +
  scale_size_continuous(range = c(0.3, 4.5), labels = comma, guide = "none") +
  scale_fill_manual(values = region_colors, breaks = china_region_levels, name = "Labelled region\n(>=50% majority)", drop = FALSE) +
  scale_colour_manual(values = region_colors, breaks = china_region_levels, guide = "none") +
  labs(
    x = "Node age (kya)",
    y = "Descendant tips (log scale)",
    title = "Recent expansion signature of lineages (count)",
    subtitle = "Coloured by age period; ringed/labelled points = each region's largest branch within the last 10 kya (>=50% regional majority only)"
  ) +
  guides(fill = guide_legend(override.aes = list(size = 3))) +
  theme(legend.position = "right")
ggsave(file.path(dir_output, "recent_expansion_signature.pdf"), p, width = figure_width_mm, height = figure_height_mm, units = "mm", device = cairo_pdf)
ggsave(file.path(dir_output, "recent_expansion_signature.png"), p, width = figure_width_mm, height = figure_height_mm, units = "mm", dpi = figure_dpi)

#* =====plot_subtree_share=====
# 绘制单倍群子树占比版本
min_share <- min(dat7$descendant_share, na.rm = TRUE)
p2 <- ggplot(dat7, aes(x = age_kya, y = descendant_share)) +
  annotate("rect", xmin = 0, xmax = 5, ymin = min_share, ymax = Inf, fill = recent_window_colour, alpha = 0.16) +
  geom_vline(xintercept = time_ref_kya, colour = time_reference_colour, linewidth = 0.16, linetype = "dotted") +
  geom_point(aes(colour = period, size = descendant_tips), alpha = 0.55, stroke = 0) +
  scale_colour_manual(values = period_colors, breaks = period_levels, name = "Node age", drop = FALSE) +
  ggnewscale::new_scale_colour() +
  geom_point(
    data = dat9,
    mapping = aes(x = age_kya, y = descendant_share, fill = dominant_region, size = descendant_tips), #* 标注点颜色对应地区，大小对应后代 tip 数
    inherit.aes = FALSE,
    shape = 21,
    colour = "black",
    stroke = 0.6
  ) +
  ggrepel::geom_text_repel(
    data = dat9,
    mapping = aes(x = age_kya, y = descendant_share, label = label, colour = dominant_region), #* 标注文本和颜色映射
    inherit.aes = FALSE,
    family = "sans",
    fontface = "bold",
    size = label_text_size,
    lineheight = 0.85,
    segment.size = 0.3,
    segment.color = "#222222",
    min.segment.length = 0,
    show.legend = FALSE,
    max.overlaps = Inf,
    box.padding = 0.4
  ) +
  scale_x_reverse(breaks = c(26.5, 21, 19, 11.7, 10, 5, 3, 0)) +
  scale_y_log10(labels = percent) +
  scale_size_continuous(range = c(0.3, 4.5), labels = comma, guide = "none") +
  scale_fill_manual(values = region_colors, breaks = china_region_levels, name = "Labelled region\n(>=50% majority)", drop = FALSE) +
  scale_colour_manual(values = region_colors, breaks = china_region_levels, guide = "none") +
  labs(
    x = "Node age (kya)",
    y = "Descendant tips (share of own haplogroup subtree, log scale)",
    title = "Recent expansion signature of lineages (subtree share)",
    subtitle = "Coloured by age period; ringed/labelled points = each region's highest-share branch within the last 10 kya (>=50% regional majority only)"
  ) +
  guides(fill = guide_legend(override.aes = list(size = 3))) +
  theme(legend.position = "right")
ggsave(file.path(dir_output, "recent_expansion_signature_share.pdf"), p2, width = figure_width_mm, height = figure_height_mm, units = "mm", device = cairo_pdf)
ggsave(file.path(dir_output, "recent_expansion_signature_share.png"), p2, width = figure_width_mm, height = figure_height_mm, units = "mm", dpi = figure_dpi)

#* =====plot_region_share=====
# 绘制地区人口占比版本
if (nrow(dat11) == 0) stop("没有满足地区主导阈值的节点，无法绘制地区人口占比图。")
min_share_region <- min(dat11$descendant_share_region, na.rm = TRUE)
p3 <- ggplot(dat11, aes(x = age_kya, y = descendant_share_region)) +
  annotate("rect", xmin = 0, xmax = 5, ymin = min_share_region, ymax = Inf, fill = recent_window_colour, alpha = 0.16) +
  geom_vline(xintercept = time_ref_kya, colour = time_reference_colour, linewidth = 0.16, linetype = "dotted") +
  geom_point(aes(colour = dominant_region, size = descendant_tips), alpha = 0.55, stroke = 0) +
  geom_point(
    data = dat10,
    mapping = aes(x = age_kya, y = descendant_share_region, fill = dominant_region, size = descendant_tips), #* 标注点颜色对应地区，大小对应后代 tip 数
    inherit.aes = FALSE,
    shape = 21,
    colour = "black",
    stroke = 0.6
  ) +
  ggrepel::geom_text_repel(
    data = dat10,
    mapping = aes(x = age_kya, y = descendant_share_region, label = label, colour = dominant_region), #* 标注文本和颜色映射
    inherit.aes = FALSE,
    family = "sans",
    fontface = "bold",
    size = label_text_size,
    lineheight = 0.85,
    segment.size = 0.3,
    segment.color = "#222222",
    min.segment.length = 0,
    show.legend = FALSE,
    max.overlaps = Inf,
    box.padding = 0.4
  ) +
  scale_x_reverse(breaks = c(26.5, 21, 19, 11.7, 10, 5, 3, 0)) +
  scale_y_log10(labels = percent) +
  scale_size_continuous(range = c(0.3, 4.5), labels = comma, guide = "none") +
  scale_colour_manual(values = region_colors, breaks = china_region_levels, name = "Dominant region\n(>=50% majority)", drop = FALSE) +
  scale_fill_manual(values = region_colors, breaks = china_region_levels, guide = "none") +
  labs(
    x = "Node age (kya)",
    y = "Descendant tips (share of dominant region's total samples, log scale)",
    title = "Recent expansion signature of lineages (regional population share)",
    subtitle = "Only nodes with a >=50% regional majority; ringed/labelled points = each region's highest-share branch within the last 10 kya"
  ) +
  guides(colour = guide_legend(override.aes = list(size = 2.4, alpha = 1))) +
  theme(legend.position = "right")
ggsave(file.path(dir_output, "recent_expansion_signature_region_share.pdf"), p3, width = figure_width_mm, height = figure_height_mm, units = "mm", device = cairo_pdf)
ggsave(file.path(dir_output, "recent_expansion_signature_region_share.png"), p3, width = figure_width_mm, height = figure_height_mm, units = "mm", dpi = figure_dpi)

#* =====report=====
# 写出运行摘要
write_tsv(
  tibble(
    input_tree_files = length(tree_files),
    tips = nrow(dat5),
    internal_nodes = nrow(dat4),
    metadata_matched_tips = sum(dat5$metadata_status == "matched")
  ),
  file.path(dir_output, "build_inputs_summary.tsv")
)
writeLines(
  c(
    "# Recent expansion signature",
    "",
    paste0("- Input tree files: ", length(tree_files)),
    paste0("- Input nodes after filtering: ", nrow(dat7)),
    paste0("- Regional-majority nodes in regional-share plot: ", nrow(dat11)),
    paste0("- Minimum tree tips: ", min_tree_tips),
    paste0("- Minimum descendant tips: ", min_descendant_tips),
    paste0("- Regional majority threshold: ", majority_threshold),
    "",
    "All tables and figures are written directly to output/."
  ),
  file.path(dir_output, "summary.md")
)

# 在交互式 R 会话中显示最终图形对象
if (interactive()) {
  print(p)
  print(p2)
  print(p3)
}
