# 代码一
library(venn)         #韦恩图（venn 包，适用样本数 2-7）
library(VennDiagram) 

# 读取数据文件
venn_dat <- read.delim('韦恩图.csv',sep = ',') # 每一列是一个集合,可以是一列数字，也可以是一列字符
number_set <- 2 #todo 输入共有多少列，即多少种集合

# 动态生成venn_list
venn_list <- lapply(1:number_set, function(i) venn_dat[,i])    # 使用lapply动态生成列表
names(venn_list) <- colnames(venn_dat)[1:number_set]           # 动态获取对应数量的列名
venn_list = purrr::map(venn_list,na.omit)      # 删除列表中每个向量中的NA

#作图
# 直接用 ilabels = "counts" 自动显示每个区域的计数
# 如已有打开的设备先关闭，否则跳过
if (!is.null(dev.list())) dev.off()
pdf("venn_plot1.pdf", width = 10, height = 10) # 保存为PDF文件
venn(
  x       = venn_list,
  zcolor  = 'style',       # 预设配色
  opacity = 0.3,           # 透明度
  box     = FALSE,         # 不要外框
  ilabels = "counts",      # ★ 自动统计并显示数字 ★
  ilcs    = 1.0,           # 数字大小，可根据需要调整
  sncs    = 1.0,            # 集合名称大小
  plotsize = 15
)
# 保存图形
dev.off() # 关闭图形设备


#?venn
# 更多参数 ?venn查看

# 查看交集详情,并导出结果
inter <- get.venn.partitions(venn_list)
for (i in 1:nrow(inter)) inter[i,'values'] <- paste(inter[[i,'..values..']], collapse = '|')
inter <- subset(inter, select = -..values.. )
inter <- subset(inter, select = -..set.. )

