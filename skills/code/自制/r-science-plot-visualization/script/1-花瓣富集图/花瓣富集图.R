library(tidyverse)
library(ggraph)
library(tidygraph)
library(treemap)

#* =====配置=====
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(script_arg)) {
  dirname(normalizePath(sub("^--file=", "", script_arg[[1]])))
} else {
  getwd()
}

#* =====读取与处理=====
data("GNI2014", package = "treemap")

ROOT <- "world"             #? 根节点名称
LEAF_LEVEL2 <- "country"    #? 叶子节点层级名称
LEAF_LEVEL1 <- "continent"  #? 叶子节点层级名称
SIZE <- "population"        #? 叶子节点大小变量名称

GNI2014 <- as_tibble(GNI2014)

country_index <- c(LEAF_LEVEL1, LEAF_LEVEL2)

nodes_country <- map_dfr(seq_along(country_index), \(i) {
  node_columns <- country_index[seq_len(i)]

  GNI2014 |>
    group_by(across(all_of(node_columns))) |>
    summarise(
      node.size = sum(.data[[SIZE]]),
      node.level = country_index[[i]],
      node.count = n(),
      .groups = "drop"
    ) |>
    mutate(
      node.short_name = as.character(.data[[node_columns[[length(node_columns)]]]]),
      node.branch = as.character(.data[[node_columns[[1]]]])
    ) |>
    unite(node.name, all_of(node_columns), sep = "/")
})

nodes_country <- bind_rows(
  tibble(
    node.name = ROOT,
    node.size = sum(GNI2014[[SIZE]]),
    node.level = ROOT,
    node.count = 1L,
    node.short_name = ROOT,
    node.branch = ROOT
  ),
  nodes_country
) |>
  mutate(
    node.level = factor(node.level, levels = c(ROOT, country_index)),
    node.branch = if_else(is.na(node.branch), ROOT, node.branch),
    node.size   = replace_na(node.size, 0)
  )

edges_country <- map_dfr(seq(2, length(country_index)), \(i) {
  node_columns <- country_index[seq_len(i)]

  GNI2014 |>
    unite(
      from,
      all_of(node_columns[-length(node_columns)]),
      sep = "/",
      remove = FALSE
    ) |>
    unite(to, all_of(node_columns), sep = "/") |>
    select(from, to) |>
    mutate(across(c(from, to), as.character))
})

edges_country <- bind_rows(
  GNI2014 |>
    group_by(across(all_of(country_index[[1]]))) |>
    summarise(.groups = "drop") |>
    transmute(
      from = ROOT,
      to = as.character(.data[[country_index[[1]]]])
    ),
  edges_country
)

graph_country <- tbl_graph(nodes_country, edges_country)

#* =====配色=====
branches <- graph_country |>
  activate(nodes) |>
  as_tibble() |>
  pull(node.branch) |>
  unique() |>
  sort()

palette_cols <- c(
  "#E64B35FF", "#4DBBD5FF", "#00A087FF",
  "#3C5488FF", "#F39B7FFF", "#7E6148FF", "#35978f", "#8E44AD"
)[seq_along(branches)]

names(palette_cols) <- branches

#* =====绘图与输出=====
p <- graph_country |>
  ggraph(layout = "dendrogram", circular = TRUE) +
  geom_edge_diagonal(
    aes(edge_colour = node1.node.branch, filter = node1.node.level != ROOT),
    edge_alpha = 1 / 3
  ) +
  geom_node_point(aes(size = node.size, colour = node.branch), alpha = 1 / 3) +
  geom_node_text(
    aes(
      x = 1.0175 * x,
      y = 1.0175 * y,
      label = node.short_name,
      angle = -((-node_angle(x, y) + 90) %% 180) + 90,
      filter = leaf,
      colour = node.branch
    ),
    size = 3,
    hjust = "outward"
  ) +
  geom_node_text(
    aes(label = node.short_name, filter = !leaf, colour = node.branch),
    fontface = "bold",
    size = 3,
    family = "sans"
  ) +
  scale_size(range = c(0.5, 30)) +
  scale_color_manual(values = palette_cols) +
  scale_edge_colour_manual(values = palette_cols) +
  theme(
    panel.background = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    legend.position = "none"
  ) +
  coord_fixed() +
  coord_cartesian(xlim = c(-1.3, 1.3), ylim = c(-1.3, 1.3))

ggsave(p, filename = file.path(script_dir, "花瓣富集图.pdf"))
p
