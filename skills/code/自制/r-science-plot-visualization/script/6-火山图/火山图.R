#* =====加载分析包=====
library(ggplot2)
library(ggrepel)
library(dplyr)
library(knitr)

#* =====设置输入输出=====
# 获取脚本所在目录；使用 Rscript 运行时，输入数据和图片均定位到脚本同级目录
command_args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", command_args, value = TRUE)
script_dir <- if (length(file_arg) > 0) {
  dirname(normalizePath(sub("^--file=", "", file_arg[1])))
} else {
  getwd()
}

input_file <- file.path(script_dir, "airway_deseq2_results.tsv")

if (!file.exists(input_file)) {
  stop("缺少输入文件：", input_file)
}

#* =====读取并整理差异分析结果=====
# 数据来源：airway RNA-seq 数据集的 DESeq2 差异分析结果
# 原始结果：https://github.com/jmzeng1314/GEO/tree/master/airway_RNAseq
# 基因符号：https://www.ensembl.org/biomart/martview
dat1 <- read.delim(
  input_file,
  sep = "\t",
  header = TRUE,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

# 预览输入数据
knitr::kable(head(dat1))

# 检查绘图所需字段，避免输入表结构不匹配
required_columns <- c("gene_id", "gene_symbol", "log2FoldChange", "pvalue", "padj")
missing_columns <- setdiff(required_columns, colnames(dat1))

if (length(missing_columns) > 0) {
  stop("输入文件缺少字段：", paste(missing_columns, collapse = ", "))
}

# 过滤无法绘图的记录，并计算显著性和上下调分组
dat2 <- dat1 %>%
  filter(
    !is.na(log2FoldChange),
    is.finite(log2FoldChange),
    !is.na(padj),
    padj > 0
  ) %>%
  mutate(
    neg_log10_padj = -log10(padj),
    change = case_when(
      log2FoldChange > 1 & padj < 0.05 ~ "Up",
      log2FoldChange < -1 & padj < 0.05 ~ "Down",
      TRUE ~ "Stable"
    ),
    change = factor(change, levels = c("Down", "Stable", "Up"))
  )

# 分别按校正后 P 值选取最显著的 5 个上调和下调基因
dat3 <- dat2 %>%
  filter(change == "Up") %>%
  arrange(padj) %>%
  slice_head(n = 5)

dat4 <- dat2 %>%
  filter(change == "Down") %>%
  arrange(padj) %>%
  slice_head(n = 5)

top_label <- bind_rows(dat3, dat4)
knitr::kable(top_label)

#* =====绘制基础火山图=====
p <- ggplot(
  dat2,
  aes(x = log2FoldChange, y = neg_log10_padj, color = change)
) +
  geom_point(size = 1.5, alpha = 0.6) +
  scale_color_manual(
    values = c(
      "Up" = "#E41A1C",
      "Down" = "#377EB8",
      "Stable" = "grey70"
    )
  ) +
  geom_vline(
    xintercept = c(-1, 1),
    linetype = "dashed",
    color = "grey40"
  ) +
  geom_hline(
    yintercept = -log10(0.05),
    linetype = "dashed",
    color = "grey40"
  ) +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(
    x = "log2 Fold Change",
    y = "-log10(adjusted p-value)",
    color = "Regulation",
    title = "Dexamethasone vs Control (airway dataset)"
  )

print(p)
ggsave(
  filename = file.path(script_dir, "volcano_plot.pdf"),
  plot = p,
  width = 8,
  height = 6,
  dpi = 600
)

#* =====绘制带 Top 5 基因标签的火山图=====
p2 <- ggplot(
  dat2,
  aes(x = log2FoldChange, y = neg_log10_padj, color = change)
) +
  geom_point(size = 3, alpha = 0.7, stroke = 0.2, shape = 16) +
  scale_color_manual(
    values = c(
      "Up" = "#e94234",
      "Down" = "#269846",
      "Stable" = "#d3d3d3"
    ),
    breaks = c("Up", "Down")
  ) +
  geom_vline(
    xintercept = c(-1, 1),
    linetype = "dashed",
    color = "grey30",
    linewidth = 0.5
  ) +
  geom_hline(
    yintercept = -log10(0.05),
    linetype = "dashed",
    color = "grey30",
    linewidth = 0.5
  ) +
  geom_text_repel(
    data = top_label,
    aes(label = gene_symbol),
    size = 4,
    fontface = "bold",
    color = "black",
    box.padding = 0.5,
    point.padding = 0.3,
    max.overlaps = 30,
    segment.color = "grey50",
    segment.size = 0.3,
    show.legend = FALSE
  ) +
  coord_cartesian(xlim = c(-10, 10)) +
  theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.title = element_text(size = 14, face = "bold"),
    axis.text = element_text(size = 12),
    legend.position = "right",
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 11),
    panel.grid.major = element_line(color = "grey95", linewidth = 0.3),
    panel.grid.minor = element_blank()
  ) +
  labs(
    x = expression("log"[2] ~ "Fold Change"),
    y = expression("-log"[10] ~ "(adjusted p-value)"),
    color = "Regulation",
    title = "Dexamethasone vs Control (airway dataset)"
  )

print(p2)
ggsave(
  filename = file.path(script_dir, "volcano_plot_2.pdf"),
  plot = p2,
  width = 8,
  height = 6,
  dpi = 600
)

#* =====绘制显著性渐变火山图=====
p3 <- ggplot(dat2, aes(x = log2FoldChange, y = neg_log10_padj)) +
  geom_point(
    aes(color = neg_log10_padj),
    size = 5,
    alpha = 1
  ) +
  geom_point(
    data = top_label,
    aes(color = neg_log10_padj),
    size = 4,
    shape = 16,
    alpha = 1,
    show.legend = FALSE
  ) +
  scale_color_gradientn(
    colors = c("#0E2A85", "#52CFC0", "#FFE02E", "#F55E36", "#D12626"),
    name = "-log10(padj)"
  ) +
  geom_vline(
    xintercept = c(-1, 1),
    linetype = "dashed",
    color = "grey30",
    linewidth = 0.5
  ) +
  geom_hline(
    yintercept = -log10(0.05),
    linetype = "dashed",
    color = "grey30",
    linewidth = 0.5
  ) +
  geom_text_repel(
    data = top_label,
    aes(label = gene_symbol),
    size = 4,
    fontface = "bold",
    color = "black",
    box.padding = 0.5,
    max.overlaps = 30,
    show.legend = FALSE
  ) +
  coord_cartesian(xlim = c(-10, 10)) +
  theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    legend.position = "right"
  ) +
  labs(
    x = expression(log[2] ~ FoldChange),
    y = expression(-log[10] ~ (padj)),
    title = "Dexamethasone vs Control (airway dataset)"
  )

print(p3)
ggsave(
  filename = file.path(script_dir, "volcano_gradient.pdf"),
  plot = p3,
  width = 10,
  height = 8,
  dpi = 600
)

#* =====绘制自适应高级火山图=====
# 统计显著上调和下调基因数量
up_num <- sum(dat2$change == "Up")
down_num <- sum(dat2$change == "Down")

# 计算对称 X 轴范围和顶部标注位置
max_fc <- max(abs(dat2$log2FoldChange), na.rm = TRUE)
max_padj_score <- max(dat2$neg_log10_padj, na.rm = TRUE)
x_label <- max_fc * 0.65
y_num <- max_padj_score * 1.08
y_label <- max_padj_score * 1.16
y_upper <- max_padj_score * 1.24

fc_colors <- c("#2166AC", "#67A9CF", "#D9D9D9", "#F4A582", "#B2182B")

p4 <- ggplot(dat2, aes(x = log2FoldChange, y = neg_log10_padj)) +
  geom_point(
    aes(color = log2FoldChange, size = neg_log10_padj),
    alpha = 0.8
  ) +
  scale_color_gradientn(
    colors = fc_colors,
    limits = c(-max_fc, max_fc),
    name = "log2FC"
  ) +
  scale_size_continuous(
    range = c(0.3, 8),
    name = "-log10(padj)"
  ) +
  geom_vline(
    xintercept = c(-1, 1),
    linetype = "dashed",
    color = "black",
    linewidth = 0.6
  ) +
  geom_hline(
    yintercept = -log10(0.05),
    linetype = "dashed",
    color = "black",
    linewidth = 0.6
  ) +
  geom_point(
    data = top_label,
    aes(x = log2FoldChange, y = neg_log10_padj),
    inherit.aes = FALSE,
    color = "black",
    fill = "#EC5F5F",
    shape = 21,
    size = 7,
    stroke = 0.7
  ) +
  geom_text_repel(
    data = top_label,
    aes(label = gene_symbol),
    size = 4,
    color = "black",
    box.padding = 0.8,
    point.padding = 0.4,
    max.overlaps = 20,
    segment.color = "black",
    segment.size = 0.5,
    show.legend = FALSE
  ) +
  annotate(
    "text",
    x = -x_label,
    y = y_label,
    label = "Down",
    color = "#67A9CF",
    size = 4,
    fontface = "bold"
  ) +
  annotate(
    "text",
    x = -x_label,
    y = y_num,
    label = down_num,
    color = "#67A9CF",
    size = 4,
    fontface = "bold"
  ) +
  annotate(
    "text",
    x = x_label,
    y = y_label,
    label = "Up",
    color = "#F4A582",
    size = 4,
    fontface = "bold"
  ) +
  annotate(
    "text",
    x = x_label,
    y = y_num,
    label = up_num,
    color = "#F4A582",
    size = 4,
    fontface = "bold"
  ) +
  guides(
    size = guide_legend(order = 1),
    color = guide_colorbar(order = 2)
  ) +
  coord_cartesian(
    xlim = c(-max_fc, max_fc),
    ylim = c(0, y_upper)
  ) +
  theme_bw(base_size = 14) +
  theme(
    panel.grid = element_line(color = "grey90", linewidth = 0.3),
    legend.position = "right",
    legend.box = "vertical",
    axis.title = element_text(face = "bold"),
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold")
  ) +
  labs(
    x = "log2 Fold Change",
    y = "-log10(padj)",
    title = "Dexamethasone vs Control (airway dataset)"
  )

print(p4)
ggsave(
  filename = file.path(script_dir, "advanced_volcano_1.pdf"),
  plot = p4,
  width = 10,
  height = 8,
  dpi = 600
)

# 输出运行摘要并显示最终图形对象
message("有效基因数：", nrow(dat2))
message("显著上调基因数：", up_num)
message("显著下调基因数：", down_num)
p4
