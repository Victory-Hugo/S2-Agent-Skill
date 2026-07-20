############################################################
# 0. 环境准备
############################################################
# 加载所需 R 包（确保已安装）
library(linkET)     # 相关性计算 + 可视化（qcorrplot, correlate, geom_couple 等）
library(ggplot2)    # 基础绘图系统
library(dplyr)      # 数据整理（mutate、管道等）
library(cols4all)   # 调色板
library(RColorBrewer) # 额外色板
library(ggtext)       # 更丰富的主题元素

############################################################
# 1. 读取数据
############################################################
# 假设两个文件：
#   1-Frequency.csv : 生物学指标 / 单倍群频率等（auto_data）
#   2-Geographic.csv: 环境/地理变量（haplo_data）
# 行名 = 群体/样本，列名 = 指标或变量名

auto_data <- read.csv(
  "1-Frequency.csv",
  row.names    = 1,    # 第一列作为行名
  header       = TRUE, # 第一行是表头
  sep          = ",",
  check.names  = FALSE # 不自动改列名（保留原始格式，如含有空格或特殊字符）
)

haplo_data <- read.csv(
  "2-Geographic.csv",
  row.names    = 1,
  header       = TRUE,
  sep          = ",",
  check.names  = FALSE
)

############################################################
# 2. 计算相关性矩阵并导出
############################################################

# 2.1 环境变量自身之间的 Pearson 相关（env vs env）
cor_auto  <- correlate(haplo_data, method = "pearson")
corr_auto <- as_md_tbl(cor_auto)   # 转成 linkET 用的整洁格式

write.csv(
  corr_auto,
  file      = "pearson_correlate.csv",
  row.names = TRUE
)

# 2.2 生物学指标 vs 环境变量 的 Pearson 相关（bio vs env）
#     行：bio 指标，列：环境变量，r / p 为对应相关和显著性
cor_auto_haplo  <- correlate(auto_data, haplo_data, method = "pearson")
corr_auto_haplo <- as_md_tbl(cor_auto_haplo)

write.csv(
  corr_auto_haplo,
  file      = "pearson_result.csv",
  row.names = TRUE
)

############################################################
# 3. 为连线准备分组变量（方向、显著性、强度）
############################################################

# corr_auto_haplo 的典型结构：
#   x, y, r, p  等列
# 这里我们按三种逻辑对 r 和 p 做离散分组，方便映射到颜色/线宽/线型：
#   r_sign: 正/负相关
#   p_sign: 显著/不显著
#   r_abs : 相关系数绝对值的强弱等级

r_p_data_plot <- corr_auto_haplo %>%
  mutate(
    # 3.1 相关系数符号：Negative / Positive
    r_sign = cut(
      r,                             # 要分组的变量：相关系数 r
      breaks = c(-Inf, 0, Inf),      # 分割点：(-Inf, 0] 和 (0, Inf)
      labels = c("Negative", "Positive") # 对应标签：负相关 / 正相关
    ),

    # 3.2 p 值显著性分组：P<0.05 / P>=0.05
    p_sign = cut(
      p,                             # 要分组的变量：p 值
      breaks = c(0, 0.05, Inf),      # 分割点：[0, 0.05) 和 [0.05, Inf)
      labels = c("P<0.05", "P>=0.05"),
      include.lowest = TRUE,         # 包含最小值（0）
      right = FALSE                  # 区间左闭右开 [a, b)
    ),

    # 3.3 |r| 的大小分级：<0.25 / 0.25-0.5 / 0.5-1
    r_abs = cut(
      abs(r),                        # 取绝对值，区分强弱而不看方向
      breaks = c(0, 0.25, 0.5, 1),   # 分割点：[0,0.25), [0.25,0.5), [0.5,1]
      labels = c("<0.25", "0.25-0.5", "0.5-1"),
      include.lowest = TRUE,
      right = FALSE
    )
  )

############################################################
# 4. 绘制环境变量相关性矩阵（上三角）——圆形标记
############################################################

# qcorrplot() 基于 linkET，输出一个 ggplot 对象：
#   - type = "upper"：只画上三角
#   - diag = FALSE  ：不画对角线
#   - grid_col      ：格子线的颜色
#   - grid_size     ：格子线粗细

p4 <- qcorrplot(
  cor_auto,
  grid_col  = "#113a60",
  grid_size = 0.2,
  type      = "upper",
  diag      = TRUE  #! 是否绘制对角线
) +
  linkET::geom_shaping(
    marker = "square",   # 方块形状
    colour = "grey80"  # 方块边框颜色
  ) +
  scale_fill_gradientn(
    colours = c("#20364F","#31646C","#4E9280","#96B89B",
                                "#DCDFD2","#ECD9CF","#D49C87","#B86265",
                                "#8B345E","#50184E"),
    limits  = c(-1, 1)
  )


# 先看一眼主热图
p4

############################################################
# 5. 在相关矩阵上添加显著性星号/标记
############################################################


p5 <- p4 +
  geom_mark(
    size       = 4,
    sep        = '\n',
    only_mark  = TRUE,
    sig_level  = c(0.05, 0.01, 0.001),
    sig_thres  = 0.05,
    colour     = "#000000"
  )
p5
############################################################
# 6. 添加 bio-env 相关的连线（geom_couple）
############################################################

# geom_couple() 用于在矩阵图上画“连接线”，比如：
#   行 = 环境变量，列 = 生物学指标（或反之）
# 映射：
#   - colour  : r_sign （正负相关） → 线的颜色
#   - size    : r_abs  （|r|大小）  → 线宽
#   - linetype: p_sign （显著性）  → 虚线 / 实线

p6 <- p5 +
  geom_couple(
    data = r_p_data_plot,
    aes(
      colour   = p_sign,   # 显著性控制颜色
      size     = r_abs,    # |r| 分级控制粗细
      linetype = p_sign    # 显著性控制线型
    ),
    nudge_x       = 0.12,           # 稍微偏移线段端点位置
    curvature     = nice_curvature(),   # 平滑弯曲度
    label.fontface = 1,    # 标签字体类型（普通）
    label.family   = "arial",
    label.size     = 2.5   # 标签字号（如果开启标签）
  )
p6
############################################################
# 7. 图形整体美化 + 图例设置
############################################################

p7 <- p6 +
  # 7.1 手动设置线宽（不同 |r| 的等级）
  scale_size_manual(
    values = c(
      "<0.25"    = 0.2,
      "0.25-0.5" = 0.5,
      "0.5-1"    = 2
    )
  ) +
  # 7.2 手动设置线颜色（显著性水平）
  scale_colour_manual(
    values = c(
      "P<0.05"  = "#c86a89",  
      "P>=0.05" = "#72c2b9"
    )
  ) +
  # 7.3 手动设置线型（显著 vs 不显著）
  scale_linetype_manual(
    values = c(
      "P<0.05"  = "solid",   # 显著：实线
      "P>=0.05" = "solid"    # 不显著：虚线 dotted 
    )
  ) +
  # 7.4 图例（guides）单独调教
  guides(
    # 填充色的颜色条
    fill = guide_colorbar(
      title     = "Pearson's r",
      order     = 3
    ),
    # 线型图例
    linetype = guide_legend(
      title        = NULL,
      override.aes = list(size = 5, linewidth = 0.6),
      order        = 1
    ),
    # 颜色图例
    colour = guide_legend(
      title        = NULL,
      override.aes = list(size = 5, linewidth = 0.6),
      order        = 2
    ),
    # 线宽图例（对应 |r|）
    size = guide_legend(
      title        = "|Pearson's r|",
      override.aes = list(colour = "grey35", size = 5),
      order        = 4
    )
  ) 

p7

