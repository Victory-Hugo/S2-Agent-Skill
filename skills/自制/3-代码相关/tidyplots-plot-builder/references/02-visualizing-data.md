# 02 - Visualizing Data (Expanded)

来源：
- 文章：https://jbengler.github.io/tidyplots/articles/Visualizing-data.html
- 官方索引：https://jbengler.github.io/tidyplots/reference/index.html
- Notion 页面《Tidyplots 可视化数据》：https://www.notion.so/2de164434e49812fad2ed448a1c2c7a7

## 图形任务到函数族映射

- 原始点：`add_data_points()` `add_data_points_jitter()` `add_data_points_beeswarm()`
- 计数：`add_count_*()`
- 求和：`add_sum_*()`
- 热图：`add_heatmap()`
- 集中趋势：`add_mean_*()` `add_median_*()`
- 趋势拟合：`add_curve_fit()`
- 分布：`add_histogram()` `add_boxplot()` `add_violin()`
- 不确定性：`add_*_errorbar()` `add_*_ribbon()`
- 比例结构：`add_barstack_*()` `add_areastack_*()` `add_pie()` `add_donut()`
- 统计比较：`add_test_pvalue()` `add_test_asterisks()`
- 注释标注：`add_title()` `add_caption()` `add_data_labels_*()` `add_reference_lines()`

## 数据点与过绘制

```r
animals |>
  tidyplot(x = weight, y = size) |>
  add_data_points(alpha = 0.4)
```

可替代策略：
- `white_border = TRUE`
- `shape = 1`
- `add_data_points_jitter()`
- `add_data_points_beeswarm()`

## 汇总量（count / sum）

```r
spendings |>
  tidyplot(x = category) |>
  add_count_bar()
```

```r
spendings |>
  tidyplot(x = category, y = amount, color = category) |>
  add_sum_bar() |>
  adjust_x_axis(rotate_labels = TRUE)
```

补充：
- 线与面积表达：`add_count_line()` `add_count_area()` `add_sum_line()` `add_sum_area()`

## 热图

```r
gene_expression |>
  tidyplot(x = sample, y = external_gene_name, color = expression) |>
  add_heatmap(scale = "row") |>
  adjust_size(height = 100)
```

关键参数：
- `scale = "row"`：行标准化（row z-score）
- `rasterize = TRUE`：大图层栅格化（详见高级绘图）

## 集中趋势、离散度与不确定性

```r
time_course |>
  tidyplot(x = day, y = score, color = treatment) |>
  add_mean_line() |>
  add_mean_dot() |>
  add_sem_errorbar(width = 2)
```

可替换：
- Error bar：`add_range_errorbar()` `add_sd_errorbar()` `add_ci95_errorbar()`
- Ribbon：`add_sem_ribbon()` `add_range_ribbon()` `add_sd_ribbon()` `add_ci95_ribbon()`

## 分布图

```r
study |>
  tidyplot(x = treatment, y = score, color = treatment) |>
  add_violin() |>
  add_data_points_beeswarm()
```

```r
study |>
  tidyplot(x = treatment, y = score, color = treatment) |>
  add_boxplot()
```

```r
energy |>
  tidyplot(x = energy) |>
  add_histogram()
```

## 比例图

```r
energy |>
  tidyplot(x = year, y = energy, color = energy_type) |>
  add_barstack_relative()
```

```r
energy |>
  tidyplot(y = energy, color = energy_type) |>
  add_donut()
```

补充：`add_areastack_absolute()` `add_areastack_relative()`。

## 统计比较

```r
study |>
  tidyplot(x = dose, y = score, color = group) |>
  add_mean_dash() |>
  add_sem_errorbar() |>
  add_data_points() |>
  add_test_pvalue(method = "wilcoxon", p.adjust.method = "BH")
```

高频参数：
- `method`：`"t.test"` / `"wilcoxon"`
- `p.adjust.method`：`"none"` / `"BH"`
- `ref.group`：指定对照组
- `hide.ns`：隐藏不显著
- `hide_info`：隐藏统计说明

## 注释与标签

- `add_title()` `add_caption()`
- `add_data_labels()` `add_data_labels_repel()`
- `add_reference_lines()`
- `add_annotation_text()` `add_annotation_rectangle()` `add_annotation_line()`

## 官方参考

- Visualizing data：https://jbengler.github.io/tidyplots/articles/Visualizing-data.html
- Function index：https://jbengler.github.io/tidyplots/reference/index.html
- `add_test_pvalue()`：https://jbengler.github.io/tidyplots/reference/add_test_pvalue.html
