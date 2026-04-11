---
name: r-style
description: 编写、生成、修改、补充、优化 R 代码时使用此 skill。凡是用户请求涉及 R 语言脚本、R 分析代码、R 可视化代码、R 数据处理代码，或者用户说"用 R 写"、"R 代码"、"写个 R 脚本"时，必须遵循本 skill 的风格规范。
---

# R 代码风格规范（脚本式、分析导向）

本规范来源于 `/mnt/c/Users/Administrator/Desktop/example.R`，适用于所有 R 分析脚本的编写与修改。

---

## 规则 1：线性步进，不封装函数

代码从上到下顺序执行，用编号变量逐层叠加，不封装进函数。

**正确：**
```r
# 绘制基础树
p <- ggtree(tree, layout = "fan", open.angle = 10, size = 0.5)

# 星状点图层
p2 <- p +
  geom_fruit(data = dat1, geom = geom_star, ...)

# 第一层离散热图
p3 <- p2 +
  new_scale_fill() +
  geom_fruit(data = dat2, geom = geom_tile, ...)

p3
```

**错误：**
```r
# 不要封装成函数
plot_tree <- function(tree, dat1, dat2) {
  p <- ggtree(tree, ...)
  p2 <- p + geom_fruit(...)
  p3 <- p2 + geom_fruit(...)
  return(p3)
}
plot_tree(tree, dat1, dat2)
```

---

## 规则 2：`#*` 行内注释解释参数含义

在参数行末尾用 `#*` 注释说明该参数的作用，特别是 `aes()` 映射和关键数值参数。

**正确：**
```r
mapping = aes(
  y = ID,        #* y 轴对应 ID 列
  fill = Location, #* 填充颜色对应 Location 列
  size = Length,   #* 点大小对应 Length 列
  starshape = Group #* 形状对应 Group 列
),
position = "identity", #* 点位置
starstroke = 0.5,      #* 星形边框粗细
color = "#FFFFFF"      #* 星形边框颜色
```

**错误：**
```r
# 不要在代码块外用大段文字解释参数，直接在参数后加 #* 注释
mapping = aes(y = ID, fill = Location, size = Length)
# 上面 y 对应 ID 列，fill 对应 Location 列，size 对应 Length 列
```

---

## 规则 3：`#* =====节段名=====` 分隔功能区块

当脚本包含多个独立功能区块时，用 `#* =====名称=====` 作为节段分隔符。

**正确：**
```r
#* =====taxalink=====
library(tidyverse)
df_taxa <- read_csv("taxa.csv")
ggtree(tree, ...) + geom_taxalink(...)
```

**错误：**
```r
# ---- taxalink ----
# 或
# ==== taxalink ====
# 或
# ############ taxalink ############
```

---

## 规则 4：`#` 普通注释用中文说"做什么"

在代码块前用普通 `#` 注释简洁说明该步骤做什么，用中文，动词开头。

**正确：**
```r
# 读取注释数据
dat1 <- read.csv(tippoint1)

# 绘制基础树
p <- ggtree(tree, layout = "fan", open.angle = 10, size = 0.5)

# 条形图层
p5 <- p4 +
  geom_fruit(...)
```

**错误：**
```r
# This reads annotation data
dat1 <- read.csv(tippoint1)

# Initialize the base tree plot object with fan layout
p <- ggtree(tree, layout = "fan", open.angle = 10, size = 0.5)
```

---

## 规则 5：先读数据后直接操作，不封装读取逻辑

数据读取后立即用 `knitr::kable(head(...))` 预览，然后直接操作数据，不封装读取函数。

**正确：**
```r
# 读取注释数据
dat1 <- read.csv(tippoint1)
knitr::kable(head(dat1))
dat2 <- read.csv(ring1)
knitr::kable(head(dat2))
dat3 <- read.csv(ring2)
knitr::kable(head(dat3))
```

**错误：**
```r
# 不要封装读取逻辑
load_data <- function(path1, path2, path3) {
  list(
    dat1 = read.csv(path1),
    dat2 = read.csv(path2),
    dat3 = read.csv(path3)
  )
}
data_list <- load_data(tippoint1, ring1, ring2)
```

---

## 规则 6：变量命名约定

- **图层变量**：`p`（初始图）、`p2`、`p3`、`p4`、`p5`…（逐层叠加）
- **数据框变量**：`dat1`、`dat2`、`dat3`…（按读取顺序编号）
- **多词变量**：下划线分隔，如 `df_META`、`melt_simple`、`trfile`、`tippoint1`

**正确：**
```r
p  <- ggtree(tree, ...)
p2 <- p + geom_fruit(data = dat1, ...)
p3 <- p2 + new_scale_fill() + geom_fruit(data = dat2, ...)

dat1 <- read.csv(tippoint1)
dat2 <- read.csv(ring1)
df_META <- read.csv("meta.csv")
```

**错误：**
```r
base_plot    <- ggtree(tree, ...)
plot_layer1  <- base_plot + geom_fruit(...)
annotation_data <- read.csv(tippoint1)
```

---

## 规则 7：`library()` 集中在顶部，每行一个，不加注释

所有包加载语句放在脚本最顶部，每个包单独一行，不添加任何注释说明用途。

**正确：**
```r
library(ggtree)
library(ggtreeExtra)
library(tidyverse)
library(ggstar)
library(ggridges)
library(ggnewscale)
library(treeio)
```

**错误：**
```r
library(ggtree)      # 系统发育树绘制
library(tidyverse)   # 数据处理和 ggplot2

# 或者分散在代码各处
dat1 <- read.csv(...)
library(ggplot2)  # 临时加载
```

---

## 输出格式规范

1. **直接给代码**，不在代码块外写大量解释段落
2. **不生成 `main()` 函数**或 `tryCatch` 包裹（除非用户明确要求）
3. **不使用 `invisible()` 或函数返回值**，直接让最终图形对象打印输出
4. 代码从第一行到最后一行**顺序可执行**，无依赖跳跃
5. 需要说明时，用 `#` 或 `#*` 注释写在代码中，而不是代码块外的 Markdown 文字
