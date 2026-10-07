#!/usr/bin/env Rscript

library(ggplot2)
library(gridExtra)
library(readxl)

#* =====全局配置=====

figure_width <- 7                       #* PDF 宽度，单位为英寸
figure_height_per_column <- 3.5         #* 每个统计列占用的 PDF 高度，单位为英寸
font_family <- "Arial"                  #* PDF 中嵌入的可编辑字体
bar_label_fontsize <- 6                 #* 柱顶数字字号，单位为 pt
pie_label_fontsize <- 6                 #* 饼图标签字号，单位为 pt
pie_start_angle <- 140                  #* 饼图起始角度，与原 Python 脚本一致
pie_label_distance <- 1.1               #* 饼图标签相对圆心的距离
pie_label_x <- 0.5 + pie_label_distance #* 将相对距离换算为极坐标半径位置
custom_colors <- c(
  "#D55E00", "#E39400", "#E0C318", "#7AB241",
  "#7AB241", "#009E73", "#2AA9AD", "#56B4E9",
  "#40AECB", "#238DC8", "#2B93CD", "#0072B2"
)

#* =====解析命令行参数=====

# 设置命令行参数默认值
args <- commandArgs(trailingOnly = TRUE)
input_file <- NA_character_
input_sep <- "\\t"
top_n <- 30L
columns_text <- NA_character_
output_dir <- "."

# 显示帮助信息
if (length(args) == 0L || any(args %in% c("-h", "--help"))) {
  cat(
    "生成类别统计的柱状图和饼图\n\n",
    "用法:\n",
    "  Rscript 1-统计柱状图饼图.R -i FILE -s SEP -n N -c COL1,COL2 -o DIR\n\n",
    "参数:\n",
    "  -i, --input       输入文件路径（支持 .csv、.txt、.xlsx、.xls）\n",
    "  -s, --sep         输入文件分隔符（默认为 \\t）\n",
    "  -n, --top-n       每列保留的高频类别数（默认为 30）\n",
    "  -c, --columns     需要绘制的列名，多个列名用逗号分隔\n",
    "  -o, --output-dir  输出目录（默认为当前目录）\n",
    sep = ""
  )
  quit(status = 0L)
}

# 逐项读取命令行参数
i <- 1L
while (i <= length(args)) {
  arg <- args[[i]]

  if (arg %in% c("-i", "--input")) {
    if (i == length(args)) stop("参数缺少取值：", arg, call. = FALSE)
    input_file <- args[[i + 1L]]
    i <- i + 2L
  } else if (arg %in% c("-s", "--sep")) {
    if (i == length(args)) stop("参数缺少取值：", arg, call. = FALSE)
    input_sep <- args[[i + 1L]]
    i <- i + 2L
  } else if (arg %in% c("-n", "--top-n")) {
    if (i == length(args)) stop("参数缺少取值：", arg, call. = FALSE)
    top_n <- suppressWarnings(as.integer(args[[i + 1L]]))
    i <- i + 2L
  } else if (arg %in% c("-c", "--columns")) {
    if (i == length(args)) stop("参数缺少取值：", arg, call. = FALSE)
    columns_text <- args[[i + 1L]]
    i <- i + 2L
  } else if (arg %in% c("-o", "--output-dir")) {
    if (i == length(args)) stop("参数缺少取值：", arg, call. = FALSE)
    output_dir <- args[[i + 1L]]
    i <- i + 2L
  } else {
    stop("无法识别的参数：", arg, call. = FALSE)
  }
}

# 检查必需参数和 Top-N
if (is.na(input_file)) stop("必须提供 -i/--input。", call. = FALSE)
if (is.na(columns_text)) stop("必须提供 -c/--columns。", call. = FALSE)
if (is.na(top_n) || top_n < 1L) stop("-n/--top-n 必须是正整数。", call. = FALSE)
if (!file.exists(input_file)) stop("输入文件不存在：", input_file, call. = FALSE)

# 转换常用转义分隔符
if (identical(input_sep, "\\t")) input_sep <- "\t"
if (identical(input_sep, "\\n")) input_sep <- "\n"

#* =====读取和检查数据=====

# 按文件扩展名读取数据
suffix <- tolower(tools::file_ext(input_file))
if (suffix %in% c("csv", "txt")) {
  dat1 <- read.table(
    input_file,
    header = TRUE,               #* 第一行作为列名
    sep = input_sep,              #* 使用命令行指定的分隔符
    quote = "\"",
    comment.char = "",
    check.names = FALSE,          #* 保留原始列名
    stringsAsFactors = FALSE
  )
} else if (suffix %in% c("xlsx", "xls")) {
  dat1 <- as.data.frame(read_excel(input_file), check.names = FALSE)
} else {
  stop("不支持的文件格式：.", suffix, call. = FALSE)
}

# 拆分并清理待统计列名
columns <- trimws(strsplit(columns_text, ",", fixed = TRUE)[[1]])
columns <- columns[nzchar(columns)]
if (length(columns) == 0L) stop("-c/--columns 至少需要一个列名。", call. = FALSE)

# 检查输入数据是否包含全部目标列
missing_columns <- setdiff(columns, names(dat1))
if (length(missing_columns) > 0L) {
  stop("以下列在输入文件中不存在：", paste(missing_columns, collapse = ", "), call. = FALSE)
}

# 创建输出目录
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
if (!dir.exists(output_dir)) stop("无法创建输出目录：", output_dir, call. = FALSE)

#* =====统计并绘图=====

# 初始化组合图列表
plot_list <- vector("list", length(columns) * 2L)

# 逐列统计类别并构建柱状图和饼图
for (column_index in seq_along(columns)) {
  column_name <- columns[[column_index]]

  # 删除缺失值并将类别统一转换为文本
  values <- dat1[[column_name]]
  values <- as.character(values[!is.na(values)])
  category_order <- unique(values)
  category_counts <- tabulate(
    match(values, category_order),
    nbins = length(category_order)
  )
  count_order <- order(-category_counts, seq_along(category_counts))
  counts <- stats::setNames(
    category_counts[count_order],
    category_order[count_order]
  )

  if (length(counts) == 0L) {
    stop("列没有可用于绘图的非缺失值：", column_name, call. = FALSE)
  }

  # 将 Top-N 以外的低频类别合并为 Other
  was_collapsed <- length(counts) > top_n
  if (length(counts) > top_n) {
    other_count <- sum(counts[(top_n + 1L):length(counts)])
    counts <- c(counts[seq_len(top_n)], Other = other_count)
  }

  # 整理当前列的统计结果
  dat2 <- data.frame(
    category = names(counts),
    number = as.numeric(counts),
    stringsAsFactors = FALSE
  )
  dat2$category <- factor(dat2$category, levels = dat2$category)
  dat2$percentage <- dat2$number / sum(dat2$number)
  dat2$pie_label <- sprintf(
    "%s (%.1f%%)",
    as.character(dat2$category),
    dat2$percentage * 100
  )
  dat2$pie_y <- cumsum(dat2$number) - dat2$number / 2

  # 生成与原 Python 渐变锚点一致的类别颜色
  palette_values <- grDevices::colorRampPalette(custom_colors)(nrow(dat2))
  names(palette_values) <- as.character(dat2$category)

  # 导出当前列的分类数量
  txt_path <- file.path(output_dir, paste0(column_name, "_分类数量.txt"))
  dat3 <- data.frame(
    category = as.character(dat2$category),
    Number = dat2$number,
    stringsAsFactors = FALSE
  )
  names(dat3)[[1]] <- if (was_collapsed) "" else column_name
  write.table(
    dat3,
    file = txt_path,
    sep = "\t",                 #* 保持原 Python 脚本的制表符输出
    quote = FALSE,
    row.names = FALSE
  )

  # 绘制柱状图
  p <- ggplot(
    dat2,
    aes(
      x = category,              #* x 轴对应类别
      y = number,                #* y 轴对应类别数量
      fill = category            #* 柱体颜色对应类别
    )
  ) +
    geom_col(width = 0.8) +
    geom_text(
      aes(
        label = number,          #* 标注柱体数量
        color = category         #* 标识字颜色与柱体一致
      ),
      vjust = -0.25,
      size = bar_label_fontsize / ggplot2::.pt
    ) +
    scale_fill_manual(values = palette_values) +
    scale_color_manual(values = palette_values) +
    scale_y_continuous(
      expand = expansion(mult = c(0, 0.1)) #* 为柱顶数字预留空间
    ) +
    labs(
      x = NULL,
      y = "Number",
      title = paste0(column_name, " - Bar Plot")
    ) +
    theme_bw(base_family = font_family) +
    theme(
      panel.grid = element_blank(),
      legend.position = "none",
      axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
      plot.title = element_text(hjust = 0.5)
    )

  # 绘制饼图
  p2 <- ggplot(
    dat2,
    aes(
      x = 1,
      y = number,                #* 扇形角度对应类别数量
      fill = category            #* 扇形颜色对应类别
    )
  ) +
    geom_col(
      width = 1,
      color = NA,
      position = position_stack(reverse = TRUE) #* 保持扇形顺序与频数表一致
    ) +
    geom_text(
      aes(
        x = pie_label_x,         #* 标签位于饼图外缘
        y = pie_y,
        label = pie_label,       #* 标注类别和百分比
        color = category         #* 标识字颜色与扇形一致
      ),
      size = pie_label_fontsize / ggplot2::.pt
    ) +
    coord_polar(
      theta = "y",
      start = (180 - pie_start_angle) * pi / 180, #* 将 Matplotlib 角度换算为 ggplot2 角度
      direction = -1,              #* 与 Matplotlib 默认的逆时针方向一致
      clip = "off"
    ) +
    scale_x_continuous(limits = c(0.5, 1.75)) +
    scale_fill_manual(values = palette_values) +
    scale_color_manual(values = palette_values) +
    labs(title = paste0(column_name, " - Pie Chart")) +
    theme_void(base_family = font_family) +
    theme(
      legend.position = "none",
      plot.title = element_text(hjust = 0.5, size = 12),
      plot.margin = margin(5.5, 18, 5.5, 18)
    )

  # 按“柱状图在左、饼图在右”的顺序保存图形对象
  plot_list[[2L * column_index - 1L]] <- p
  plot_list[[2L * column_index]] <- p2
}

#* =====输出组合 PDF=====

# 设置组合 PDF 的输出路径
output_path <- file.path(
  output_dir,
  paste0("分类统计_", paste(columns, collapse = "-"), ".pdf")
)

# 先开启 Cairo 设备，使排版阶段也使用 PDF 中的 Arial 字体度量
grDevices::cairo_pdf(
  filename = output_path,
  width = figure_width,
  height = figure_height_per_column * length(columns),
  family = font_family,
  onefile = TRUE
)

# 组合全部统计列的柱状图和饼图
p3 <- arrangeGrob(
  grobs = plot_list,
  ncol = 2,                      #* 每行固定放置一个柱状图和一个饼图
  nrow = length(columns)
)
grid::grid.draw(p3)
device_status <- grDevices::dev.off()

# 输出运行摘要
cat("目前使用的颜色列表为:", paste(custom_colors, collapse = ", "), ";\n")
cat("如需要修改图表大小、字体系列等，请在 R 脚本顶部修改。\n")
cat("统计结果已保存到：", normalizePath(output_dir), "\n", sep = "")
