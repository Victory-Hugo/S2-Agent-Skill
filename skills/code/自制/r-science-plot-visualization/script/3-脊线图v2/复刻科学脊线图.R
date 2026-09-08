library(ggplot2)
library(ggridges)
library(dplyr)
library(readr)
library(knitr)

#* =====配置与检查=====
# 定位脚本目录，使输入和输出不依赖当前工作目录
command_args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", command_args, value = TRUE)

if (length(file_arg) > 0) {
  script_path <- sub("^--file=", "", file_arg[1])
  script_dir <- dirname(normalizePath(script_path))
} else {
  script_dir <- getwd()
}

# 设置固定输入和输出文件
input_file <- file.path(script_dir, "模拟数据.tsv")
output_png <- file.path(script_dir, "科学图形_复刻.png")
output_pdf <- file.path(script_dir, "科学图形_复刻.pdf")

#* =====读取数据=====
# 检查输入文件
if (!file.exists(input_file)) {
  stop("Input file not found: ", input_file, call. = FALSE)
}

# 读取模拟数据，要求包含 year 和 value 两列
df1 <- read_tsv(input_file, show_col_types = FALSE)

required_columns <- c("year", "value")
missing_columns <- setdiff(required_columns, names(df1))
if (length(missing_columns) > 0) {
  stop(
    "Missing input columns: ",
    paste(missing_columns, collapse = ", "),
    call. = FALSE
  )
}

# 预览数据
knitr::kable(head(df1))

#* =====处理数据=====
# 检查年份和数值列
if (any(!is.finite(df1$year)) || any(!is.finite(df1$value))) {
  stop("Columns 'year' and 'value' must contain finite numbers.", call. = FALSE)
}

# 设置从上到下由古至今的脊线顺序
year_levels <- sort(unique(df1$year), decreasing = TRUE)
df2 <- df1 %>%
  mutate(
    year_group = factor(year, levels = year_levels),
    year_label = case_when(
      year < 0 ~ paste0(abs(year), " BCE"),
      year == 0 ~ "1 CE",
      TRUE ~ paste0(year, " CE")
    )
  )

# 仅显示每 200 年和公元元年的左侧标签
axis_labels <- ifelse(
  year_levels %% 200 == 0 | year_levels == 0,
  ifelse(
    year_levels < 0,
    paste0(abs(year_levels), " BCE"),
    ifelse(year_levels == 0, "1 CE", paste0(year_levels, " CE"))
  ),
  ""
)

#* =====绘图=====
# 绘制基础脊线图
p <- ggplot(
  df2,
  aes(
    x = value,
    y = year_group,
    fill = after_stat(x)
  )
) +
  geom_hline(
    yintercept = seq_along(year_levels),
    linewidth = 0.28,
    colour = "#404040"
  ) +
  geom_density_ridges_gradient(
    scale = 5.4,
    rel_min_height = 0.001,
    bandwidth = 0.13,
    colour = "#343434",
    linewidth = 0.27,
    alpha = 0.88
  ) +
  geom_vline(
    xintercept = 0,
    colour = "#9b9b9b",
    linewidth = 0.45,
    linetype = "dashed"
  ) +
  geom_vline(
    xintercept = 1.5,
    colour = "#d9a6ae",
    linewidth = 0.45,
    linetype = "dashed"
  ) +
  annotate(
    "text",
    x = -0.34,
    y = length(year_levels) + 3.7,
    label = "Pre-industrial\nmean",
    colour = "#6f6868",
    family = "sans",
    size = 3.8,
    lineheight = 0.95
  ) +
  annotate(
    "text",
    x = 1.87,
    y = length(year_levels) + 3.7,
    label = "Post-1900\nmean",
    colour = "#d79ca7",
    family = "sans",
    size = 3.8,
    lineheight = 0.95
  ) +
  scale_fill_gradientn(
    colours = c(
      "#5c9fbc",
      "#96c4d6",
      "#c5dfe6",
      "#f7e9df",
      "#f1b195",
      "#de735c",
      "#b72d35",
      "#4f0017"
    ),
    values = scales::rescale(c(-1.5, -0.90, -0.30, 0.10, 0.60, 1.05, 1.50, 2.10)),
    limits = c(-1.5, 2.5),
    oob = scales::squish,
    guide = "none"
  ) +
  scale_x_continuous(
    limits = c(-1.65, 2.85),
    breaks = seq(-1.5, 2.5, by = 0.5),
    labels = scales::label_number(accuracy = 0.1),
    expand = expansion(mult = c(0, 0)),
    position = "top",
    sec.axis = dup_axis(name = "Global mean sea-level rate (mm/yr)")
  ) +
  scale_y_discrete(
    labels = axis_labels,
    expand = expansion(add = c(0.20, 9.2))
  ) +
  coord_cartesian(clip = "off") +
  labs(x = NULL, y = NULL) +
  theme_classic(base_family = "sans", base_size = 10.5) +
  theme(
    axis.line = element_blank(),
    axis.ticks.y = element_blank(),
    axis.ticks.x = element_line(colour = "#4a4a4a", linewidth = 0.5),
    axis.ticks.length = grid::unit(0.08, "in"),
    axis.text.x = element_text(colour = "#4a4a4a", size = 9.8),
    axis.text.y = element_text(
      colour = "#4a4a4a",
      size = 9.8,
      hjust = 1,
      margin = margin(r = 7)
    ),
    axis.title.x.bottom = element_text(
      colour = "#4a4a4a",
      size = 10.8,
      margin = margin(t = 8)
    ),
    panel.background = element_rect(fill = "white", colour = NA),
    plot.background = element_rect(fill = "white", colour = NA),
    plot.margin = margin(t = 5, r = 17, b = 5, l = 24)
  )

#* =====输出=====
# 输出高分辨率 PNG
ggsave(
  filename = output_png,
  plot = p,
  width = 7.41,
  height = 6.95,
  units = "in",
  dpi = 320,
  bg = "white"
)

# 输出文字可编辑的矢量 PDF
ggsave(
  filename = output_pdf,
  plot = p,
  device = cairo_pdf,
  width = 7.41,
  height = 6.95,
  units = "in",
  bg = "white"
)

# 在 RStudio 中显示图形，命令行运行时不额外打开默认图形设备
if (interactive()) {
  print(p)
}
