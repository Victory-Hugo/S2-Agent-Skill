library(pheatmap)

#* =====配置与检查=====
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(script_arg)) {
  dirname(normalizePath(sub("^--file=", "", script_arg[[1]])))
} else {
  getwd()
}
matrix_file <- file.path(script_dir, "fst.csv")
group_file <- file.path(script_dir, "group.csv")
if (!file.exists(matrix_file) || !file.exists(group_file)) {
  stop("缺少 fst.csv 或 group.csv。", call. = FALSE)
}

#* =====读取与处理=====
dat1 <- read.csv(matrix_file, row.names = 1, check.names = FALSE)
dat2 <- read.csv(group_file, row.names = 1, check.names = FALSE)
dat1 <- as.matrix(dat1)
storage.mode(dat1) <- "numeric"

if (nrow(dat1) != ncol(dat1) || !identical(rownames(dat1), colnames(dat1))) {
  stop("fst.csv 必须是行列名称一致的方阵。", call. = FALSE)
}
if (!all(rownames(dat1) %in% rownames(dat2))) {
  stop("group.csv 缺少部分矩阵样本。", call. = FALSE)
}
dat2 <- dat2[rownames(dat1), , drop = FALSE]

#* =====绘图与输出=====
grDevices::pdf(file.path(script_dir, "FstMatrix1.pdf"), width = 11, height = 8.5)
pheatmap(
  dat1,
  cluster_cols = TRUE,
  cluster_rows = TRUE,
  angle_col = 45,
  fontsize = 8,
  fontsize_row = 8,
  fontsize_col = 6,
  annotation_col = dat2,
  annotation_row = dat2,
  cellwidth = 8,
  cellheight = 8,
  cutree_cols = 4,
  cutree_rows = 4,
  main = "FstMatrix",
  color = colorRampPalette(c(
    "#20364F", "#31646C", "#4E9280", "#96B89B", "#DCDFD2",
    "#ECD9CF", "#D49C87", "#B86265", "#8B345E", "#50184E"
  ))(10000),
  display_numbers = ifelse(abs(dat1) > 50, "++", ifelse(abs(dat1) >= 40, "+", " "))
)
pheatmap(
  dat1,
  cluster_cols = TRUE,
  cluster_rows = TRUE,
  angle_col = 45,
  fontsize = 8,
  fontsize_row = 8,
  fontsize_col = 6,
  annotation_col = dat2,
  annotation_row = dat2,
  cellwidth = 8,
  cellheight = 8,
  cutree_cols = 4,
  cutree_rows = 4,
  main = "FstMatrix",
  color = colorRampPalette(c(
    "#023047", "#126883", "#279EBC", "#90C9E6",
    "#FC9E7F", "#F75B41", "#D52120"
  ))(10000),
  display_numbers = ifelse(abs(dat1) > 50, "++", ifelse(abs(dat1) >= 40, "+", " "))
)
grDevices::dev.off()
