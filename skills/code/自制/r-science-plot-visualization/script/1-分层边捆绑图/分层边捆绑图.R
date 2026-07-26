library(ggraph)
library(igraph)
library(tidyverse)

#* =====配置=====
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(script_arg)) {
  dirname(normalizePath(sub("^--file=", "", script_arg[[1]])))
} else {
  getwd()
}

#* =====构建层级结构=====
# 设置随机种子以保证结果可复现
set.seed(1234)

# 创建表示个体层级结构的数据框
d1 <- data.frame(
  from = "origin",
  to = paste("group", seq_len(10), sep = "")
)
d2 <- data.frame(
  from = rep(d1$to, each = 10),
  to = paste("subgroup", seq_len(100), sep = "_")
)
edges <- rbind(d1, d2)

# 创建表示叶节点之间连接关系的数据框
all_leaves <- paste("subgroup", seq_len(100), sep = "_")
connect <- rbind(
  data.frame(
    from = sample(all_leaves, 100, replace = TRUE),
    to = sample(all_leaves, 100, replace = TRUE)
  ),
  data.frame(
    from = sample(head(all_leaves), 30, replace = TRUE),
    to = sample(tail(all_leaves), 30, replace = TRUE)
  ),
  data.frame(
    from = sample(all_leaves[25:30], 30, replace = TRUE),
    to = sample(all_leaves[55:60], 30, replace = TRUE)
  ),
  data.frame(
    from = sample(all_leaves[75:80], 30, replace = TRUE),
    to = sample(all_leaves[55:60], 30, replace = TRUE)
  )
)
connect$value <- runif(nrow(connect))

# 创建节点数据框，每行对应层级结构中的一个对象
vertices <- data.frame(
  name = unique(c(as.character(edges$from), as.character(edges$to))),
  value = runif(111)
)

# 添加每个节点所属的分组，用于后续着色
vertices$group <- edges$from[match(vertices$name, edges$to)]

#* =====计算标签位置=====
# 计算叶节点标签的角度
vertices$id <- NA
my_leaves <- which(is.na(match(vertices$name, edges$from)))
n_leaves <- length(my_leaves)
vertices$id[my_leaves] <- seq_len(n_leaves)
vertices$angle <- 90 - 360 * vertices$id / n_leaves

# 根据标签位于图形左侧还是右侧设置水平对齐方式
vertices$hjust <- ifelse(vertices$angle < -90, 1, 0)

# 翻转左侧标签的角度以便阅读
vertices$angle <- ifelse(
  vertices$angle < -90,
  vertices$angle + 180,
  vertices$angle
)

#* =====创建图结构=====
# 创建图对象
my_graph <- igraph::graph_from_data_frame(edges, vertices = vertices)

# 将连接关系中的叶节点名称转换为节点索引
from <- match(connect$from, vertices$name)
to <- match(connect$to, vertices$name)

# 定义显式配色
group_colors <- c(
  "#0072b2", "#56b4e9", "#009e73", "#f0e442", "#e69f00",
  "#d55e00", "#8ecae6", "#219ebc", "#023047", "#ffb703"
)
edge_colors <- c(
  "#0b0405", "#30203e", "#3e4d93", "#366b9f", "#3488a6",
  "#36a4ab", "#49c1ad", "#60ceac", "#84d8b0", "#c4e9cf", "#def5e5"
)

#* =====绘制分层边捆绑图=====
# 绘制基础分层边捆绑图
p <- ggraph(my_graph, layout = "dendrogram", circular = TRUE) +
  geom_node_point(aes(filter = leaf, x = x * 1.05, y = y * 1.05)) +
  geom_conn_bundle(
    data = get_con(from = from, to = to),
    alpha = 0.2,
    colour = "#56b4e9",
    width = 0.9
  ) +
  geom_node_text(
    aes(
      x = x * 1.1,
      y = y * 1.1,
      filter = leaf,
      label = name,
      angle = angle,
      hjust = hjust
    ),
    size = 1.5,
    alpha = 1
  ) +
  theme_void() +
  theme(
    legend.position = "none",
    plot.margin = grid::unit(c(0, 0, 0, 0), "cm")
  ) +
  expand_limits(x = c(-1.2, 1.2), y = c(-1.2, 1.2)) +
  coord_fixed(ratio = 1)

# 绘制带连线渐变、分组颜色和节点大小的最终图形
p2 <- ggraph(my_graph, layout = "dendrogram", circular = TRUE) +
  geom_conn_bundle(
    data = get_con(from = from, to = to),
    aes(colour = after_stat(index)),
    alpha = 0.2,
    width = 0.9
  ) +
  scale_edge_colour_gradientn(colours = edge_colors) +
  geom_node_text(
    aes(
      x = x * 1.15,
      y = y * 1.15,
      filter = leaf,
      label = name,
      angle = angle,
      hjust = hjust,
      colour = group
    ),
    size = 2,
    alpha = 1
  ) +
  geom_node_point(
    aes(
      filter = leaf,
      x = x * 1.07,
      y = y * 1.07,
      colour = group,
      size = value
    ),
    alpha = 0.2
  ) +
  scale_colour_manual(values = group_colors) +
  scale_size_continuous(range = c(0.1, 10)) +
  theme_void() +
  theme(
    legend.position = "none",
    plot.margin = grid::unit(c(0, 0, 0, 0), "cm")
  ) +
  expand_limits(x = c(-1.3, 1.3), y = c(-1.3, 1.3)) +
  coord_fixed(ratio = 1, clip = "off")

#* =====保存最终图形=====
# 使用等宽等高画布保存最终图形，避免圆形被压扁
ggsave(
  filename = file.path(script_dir, "分层边捆绑图.pdf"),
  plot = p2,
  width = 10,
  height = 10,
  units = "in",
  dpi = 300,
  bg = "white"
)

p2
