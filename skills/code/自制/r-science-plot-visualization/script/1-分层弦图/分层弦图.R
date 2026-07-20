# 分层弦图（hierarchical edge bundling）示例

library(tidyverse)
library(igraph)
library(ggraph)
library(ggforce)

nodes <- readr::read_csv("nodes.csv", show_col_types = FALSE)
links <- readr::read_csv("links.csv", show_col_types = FALSE)

# 排序并构图
nodes_ordered <- nodes %>%
  arrange(group, country) %>%
  mutate(name = factor(country, levels = country))

g <- graph_from_data_frame(
  d = links %>% select(from, to, value, Country),
  vertices = nodes_ordered %>% select(name, group, size),
  directed = FALSE
)

# 组的角度范围
n_total <- gorder(g)
idx_tbl <- tibble(
  name = V(g)$name,
  idx = seq_len(n_total)
) %>%
  left_join(as_tibble(vertex_attr(g)), by = "name")

group_span <- idx_tbl %>%
  group_by(group) %>%
  summarise(start = min(idx), end = max(idx), .groups = "drop") %>%
  mutate(
    start_angle = 2 * pi * (start - 1) / n_total,
    end_angle = 2 * pi * end / n_total
  )

# 布局、半径与色带
lay <- create_layout(g, layout = "linear", circular = TRUE)
rad_est <- mean(sqrt(lay$x^2 + lay$y^2))

r_nodes <- rad_est
group_gap_deg <- 8
gap_rad <- group_gap_deg * pi / 180

group_span_gap <- group_span %>%
  mutate(
    start_angle2 = start_angle + gap_rad / 2,
    end_angle2 = end_angle - gap_rad / 2,
    end_angle2 = ifelse(end_angle2 <= start_angle2, start_angle2 + 0.005, end_angle2)
  )

# 颜色
base_cols <- c("#55C0BE", "#F1A340", "#5B8FD9", "#E36A77", "#5DBFE9", "#F4A99B")
group_levels <- sort(unique(nodes_ordered$group))
group_cols <- grDevices::colorRampPalette(base_cols)(length(group_levels)) %>%
  setNames(group_levels)
edge_cols <- group_cols

# 文本位置
band_clearance <- 0.16
band_thickness <- 0.06
label_clearance <- 0.08

r_band0 <- r_nodes + band_clearance
r_band1 <- r_band0 + band_thickness
r_label <- r_band1 + label_clearance

lab_df <- as_tibble(lay) %>%
  mutate(
    name = V(g)$name,
    scale = r_label / sqrt(x^2 + y^2),
    x_lab = x * scale,
    y_lab = y * scale,
    angle = -((as.numeric(factor(name, levels = levels(nodes_ordered$name))) - 0.5) / gorder(g)) * 360
  )

ggraph(lay) +
  geom_edge_arc2(aes(width = value, colour = Country), alpha = 0.65, lineend = "round") +
  scale_edge_width(range = c(0.2, 2.8), guide = "none") +
  scale_edge_colour_manual(values = edge_cols, name = "Country") +
  ggforce::geom_arc_bar(
    data = group_span_gap,
    aes(x0 = 0, y0 = 0, r0 = r_band0, r = r_band1, start = start_angle2, end = end_angle2, fill = group),
    color = NA, alpha = 0.5, inherit.aes = FALSE
  ) +
  scale_fill_manual(values = group_cols, guide = "none") +
  geom_node_point(aes(x = x, y = y, colour = group, size = size), show.legend = FALSE, alpha = 0.95) +
  scale_colour_manual(values = group_cols) +
  scale_size(range = c(4, 10)) +
  geom_text(
    data = lab_df,
    aes(x = x_lab, y = y_lab, label = name, angle = angle, color = group),
    hjust = 0, vjust = 0.5, size = 3.5
  ) +
  coord_equal() +
  theme_void() +
  guides(colour = "none") +
  theme(plot.margin = margin(15, 15, 15, 15), panel.background = element_rect(fill = "white", colour = NA))
