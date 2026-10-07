# R 可视化示例

## 离散色板辅助函数

```r
discrete_1 <- c("#0072b2", "#56b4e9", "#009e73", "#f0e442", "#e69f00", "#d55e00")
discrete_2 <- c("#8ecae6", "#219ebc", "#023047", "#ffb703", "#fb8500")

categorical_palette <- function(n) {
  if (n <= 6) {
    return(discrete_1[seq_len(n)])
  }
  if (n <= 11) {
    return(c(discrete_1, discrete_2[seq_len(n - 6)]))
  }
  warning("More than 11 categories reduce color discrimination.")
  grDevices::colorRampPalette(c(discrete_1, discrete_2))(n)
}
```

## ggplot2 分类图

```r
library(ggplot2)

palette <- categorical_palette(length(unique(df$group)))

ggplot(df, aes(group, value, fill = group)) +
  geom_col() +
  scale_fill_manual(values = palette)
```

## ggplot2 连续单色渐变

```r
library(ggplot2)

sequential <- c(
  "#0b0405", "#30203e", "#3e4d93", "#366b9f", "#3488a6",
  "#36a4ab", "#49c1ad", "#60ceac", "#84d8b0", "#c4e9cf", "#def5e5"
)

ggplot(df, aes(x, y, fill = score)) +
  geom_tile() +
  scale_fill_gradientn(colours = sequential)
```

## ggplot2 连续双色渐变

```r
library(ggplot2)

diverging <- c(
  "#5b53a4", "#456fb1", "#368cbb", "#4fa8af", "#69c3a5", "#8ad0a4",
  "#addda3", "#c9e99d", "#e6f598", "#fefdbc", "#fef0a6", "#fdc877",
  "#f88f52", "#e55848", "#bc2349", "#a20643"
)

ggplot(df, aes(x, y, fill = log2fc)) +
  geom_tile() +
  scale_fill_gradientn(colours = diverging, values = scales::rescale(seq(-3, 3, length.out = length(diverging))))
```

## ComplexHeatmap 示例

```r
library(ComplexHeatmap)
library(circlize)

col_fun <- circlize::colorRamp2(
  c(min(matrix), median(matrix), max(matrix)),
  c("#0b0405", "#49c1ad", "#def5e5")
)

Heatmap(matrix, col = col_fun)
```

## 连续分箱取色

```r
sample_evenly <- function(colors, n) {
  if (n <= 1) {
    return(colors[1])
  }
  idx <- round(seq(1, length(colors), length.out = n))
  colors[idx]
}

binned <- sample_evenly(sequential, 5)
```
