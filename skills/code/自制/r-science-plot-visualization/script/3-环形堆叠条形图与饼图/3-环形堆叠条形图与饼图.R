#!/usr/bin/env Rscript

library(ggplot2)
library(ggforce)
library(dplyr)
library(scales)

#* =====配置路径与可编辑字体=====
script_arg <- grep("^--file=", commandArgs(), value = TRUE)
script_dir <- if (length(script_arg) > 0) {
  dirname(normalizePath(sub("^--file=", "", script_arg[[1]])))
} else {
  getwd()
}
DATA_FILE <- file.path(script_dir, "3-环形堆叠条形图与饼图.tsv")
OUTPUT_FILE <- file.path(script_dir, "3-环形堆叠条形图与饼图.png")
PDF_FILE <- file.path(script_dir, "3-环形堆叠条形图与饼图.pdf")
grDevices::pdfFonts(Arial = grDevices::Type1Font(
  "Arial",
  metrics = c(file.path(script_dir, "fonts", c(
    "Arial.afm", "Arial-Bold.afm", "Arial-Italic.afm", "Arial-BoldItalic.afm"
  )), "Symbol.afm")
))

TITLE <- "2030-BTH"
UNIT <- "Energy"

# ------------------------------------------------------------
# 1. Read tidy-long TSV
# ------------------------------------------------------------

dat <- read.delim(
  DATA_FILE,
  sep = "\t",
  header = TRUE,
  stringsAsFactors = FALSE,
  check.names = FALSE
)
print(knitr::kable(head(dat)))

dat <- dat %>%
  mutate(
    value = as.numeric(value),
    sector_order = as.integer(sector_order),
    fuel_order = as.integer(fuel_order)
  )

ring_dat <- dat %>%
  filter(dataset == "ring")

pie_dat <- dat %>%
  filter(dataset == "pie")

fuel_info <- dat %>%
  distinct(fuel, color_hex, fuel_order) %>%
  arrange(fuel_order)

fuel_levels <- fuel_info$fuel

cols <- setNames(
  fuel_info$color_hex,
  fuel_info$fuel
)

sector_info <- ring_dat %>%
  distinct(sector, sector_order) %>%
  arrange(sector_order)

sector_levels <- sector_info$sector

# ------------------------------------------------------------
# 2. Prepare outer stacked rings
# ------------------------------------------------------------

sector_sum <- ring_dat %>%
  group_by(sector) %>%
  summarise(
    total = sum(value),
    .groups = "drop"
  )

max_scale <- ceiling(max(sector_sum$total) / 10) * 10
max_angle <- 3 * pi / 2

ring_info <- sector_info %>%
  mutate(
    ring_id = row_number(),
    r0 = 2.0 + (ring_id - 1) * 0.55,
    r = 2.40 + (ring_id - 1) * 0.55
  )

bar_plot <- ring_dat %>%
  mutate(
    fuel = factor(
      fuel,
      levels = fuel_levels
    )
  ) %>%
  left_join(
    ring_info,
    by = c("sector", "sector_order")
  ) %>%
  arrange(
    ring_id,
    fuel_order
  ) %>%
  group_by(sector) %>%
  mutate(
    cumulative = cumsum(value),
    previous = lag(
      cumulative,
      default = 0
    ),
    start = previous / max_scale * max_angle,
    end = cumulative / max_scale * max_angle
  ) %>%
  ungroup()

# ------------------------------------------------------------
# 3. Prepare center pie
# ------------------------------------------------------------

pie_plot <- pie_dat %>%
  arrange(fuel_order) %>%
  mutate(
    proportion = value / sum(value),
    cumulative = cumsum(proportion),
    previous = lag(
      cumulative,
      default = 0
    ),
    start = previous * 2 * pi,
    end = cumulative * 2 * pi,
    mid = (start + end) / 2,
    label = percent(
      proportion,
      accuracy = 1
    )
  )

top3 <- pie_plot %>%
  slice_max(
    value,
    n = 3,
    with_ties = FALSE
  ) %>%
  pull(fuel)

pie_plot <- pie_plot %>%
  mutate(
    show_label = ifelse(
      fuel %in% top3,
      label,
      ""
    ),
    label_x = 1.05 * sin(mid),
    label_y = 1.05 * cos(mid)
  )

# ------------------------------------------------------------
# 4. Outer scale
# ------------------------------------------------------------

outer_r <- max(ring_info$r)

tick_values <- seq(
  0,
  max_scale,
  length.out = 5
)

tick_df <- data.frame(
  value = tick_values
) %>%
  mutate(
    angle = value / max_scale * max_angle,
    x1 = (outer_r + 0.05) * sin(angle),
    y1 = (outer_r + 0.05) * cos(angle),
    x2 = (outer_r + 0.20) * sin(angle),
    y2 = (outer_r + 0.20) * cos(angle),
    lx = (outer_r + 0.42) * sin(angle),
    ly = (outer_r + 0.42) * cos(angle)
  )

# Arc line as an ordinary path
arc_line <- data.frame(
  angle = seq(
    0,
    max_angle,
    length.out = 500
  )
) %>%
  mutate(
    x = (outer_r + 0.18) * sin(angle),
    y = (outer_r + 0.18) * cos(angle)
  )

sector_labels <- ring_info %>%
  mutate(
    x = 0.15,
    y = (r0 + r) / 2
  )

# ------------------------------------------------------------
# 5. Plot
# ------------------------------------------------------------

p <- ggplot() +

  # Outer stacked rings
  geom_arc_bar(
    data = bar_plot,
    aes(
      x0 = 0,
      y0 = 0,
      r0 = r0,
      r = r,
      start = start,
      end = end,
      fill = fuel
    ),
    colour = NA
  ) +

  # Center pie
  geom_arc_bar(
    data = pie_plot,
    aes(
      x0 = 0,
      y0 = 0,
      r0 = 0,
      r = 1.65,
      start = start,
      end = end,
      fill = fuel
    ),
    colour = "white",
    linewidth = 0.5
  ) +

  # Pie labels
  geom_text(
    data = pie_plot %>%
      filter(show_label != ""),
    aes(
      x = label_x,
      y = label_y,
      label = show_label
    ),
    size = 4.8,
    fontface = "plain"
  ) +

  # Start boundary
  annotate(
    "segment",
    x = 0,
    y = 1.65,
    xend = 0,
    yend = outer_r,
    linewidth = 0.45
  ) +

  # End boundary at 270 degrees
  annotate(
    "segment",
    x = -1.65,
    y = 0,
    xend = -outer_r,
    yend = 0,
    linewidth = 0.45
  ) +

  # Outer arc
  geom_path(
    data = arc_line,
    aes(
      x = x,
      y = y
    ),
    linewidth = 0.45
  ) +

  # Tick marks
  geom_segment(
    data = tick_df,
    aes(
      x = x1,
      y = y1,
      xend = x2,
      yend = y2
    ),
    linewidth = 0.45
  ) +

  geom_text(
    data = tick_df,
    aes(
      x = lx,
      y = ly,
      label = value
    ),
    size = 3.8,
    fontface = "plain"
  ) +

  # Ring labels
  geom_text(
    data = sector_labels,
    aes(
      x = x,
      y = y,
      label = sector
    ),
    hjust = 0,
    size = 3.5,
    fontface = "plain"
  ) +

  # Unit
  annotate(
    "text",
    x = -(outer_r + 0.95),
    y = 0.45,
    label = UNIT,
    size = 3.8,
    fontface = "plain"
  ) +

  scale_fill_manual(
    values = cols,
    breaks = fuel_levels
  ) +

  coord_fixed(
    xlim = c(-6.4, 6.4),
    ylim = c(-6.1, 6.6),
    clip = "off"
  ) +

  labs(
    title = TITLE,
    fill = NULL
  ) +

  theme_void(base_family = "Arial") +

  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 20,
      face = "plain",
      margin = margin(b = 10)
    ),
    legend.position = "inside",
    legend.position.inside = c(0.13, 0.80),
    legend.text = element_text(
      size = 10
    ),
    plot.margin = margin(
      15,
      15,
      15,
      15
    )
  )

if (interactive()) print(p)

ggsave(
  OUTPUT_FILE,
  p,
  width = 8,
  height = 8,
  dpi = 300,
  bg = "white"
)

# 导出每个标签可独立编辑的 PDF
grDevices::pdf(PDF_FILE, width = 8, height = 8, family = "Arial", useDingbats = FALSE)
print(p)
device_status <- grDevices::dev.off()
message("Saved: ", PDF_FILE)

message(
  "Saved: ",
  OUTPUT_FILE
)
