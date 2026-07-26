library(venn)
library(VennDiagram)

#* =====配置与检查=====
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(script_arg)) {
  dirname(normalizePath(sub("^--file=", "", script_arg[[1]])))
} else {
  getwd()
}
input_file <- file.path(script_dir, "韦恩图.csv")
if (!file.exists(input_file)) stop("缺少韦恩图.csv。", call. = FALSE)

#* =====读取与处理=====
dat1 <- read.csv(input_file, check.names = FALSE)
if (ncol(dat1) < 2L || ncol(dat1) > 7L) {
  stop("韦恩图.csv 必须包含 2–7 个集合列。", call. = FALSE)
}
venn_list <- lapply(dat1, \(x) unique(stats::na.omit(x[nzchar(x)])))

#* =====绘图与输出=====
grDevices::pdf(file.path(script_dir, "韦恩图.pdf"), width = 10, height = 10)
venn(
  x = venn_list,
  zcolor = "style",
  opacity = 0.3,
  box = FALSE,
  ilabels = "counts",
  ilcs = 1,
  sncs = 1,
  plotsize = 15
)
grDevices::dev.off()

# 导出交集明细
dat2 <- get.venn.partitions(venn_list)
dat2$values <- vapply(dat2$`..values..`, paste, character(1), collapse = "|")
dat2 <- subset(dat2, select = -c(`..values..`, `..set..`))
write.csv(
  dat2,
  file.path(script_dir, "韦恩图交集明细.csv"),
  row.names = FALSE
)
