# 04 - Color Schemes (Expanded)

来源：
- 官方索引：https://jbengler.github.io/tidyplots/reference/index.html
- 文章：https://jbengler.github.io/tidyplots/articles/Color-schemes.html
- Notion 页面《Tidyplots 配色方案》：https://www.notion.so/2de164434e4981a29177f21b62d75d2f

## 三类配色

1. 离散（categorical）：`colors_discrete_*`
2. 连续（continuous）：`colors_continuous_*`
3. 发散（diverging）：`colors_diverging_*`

## 完整配色对象列表（来自官方 index）

### Discrete

- `colors_discrete_friendly`
- `colors_discrete_seaside`
- `colors_discrete_apple`
- `colors_discrete_friendly_long`
- `colors_discrete_okabeito`
- `colors_discrete_ibm`
- `colors_discrete_metro`
- `colors_discrete_candy`
- `colors_discrete_alger`
- `colors_discrete_rainbow`

### Continuous

- `colors_continuous_viridis`
- `colors_continuous_magma`
- `colors_continuous_inferno`
- `colors_continuous_plasma`
- `colors_continuous_cividis`
- `colors_continuous_rocket`
- `colors_continuous_mako`
- `colors_continuous_turbo`
- `colors_continuous_bluepinkyellow`

### Diverging

- `colors_diverging_blue2red`
- `colors_diverging_blue2brown`
- `colors_diverging_BuRd`
- `colors_diverging_BuYlRd`
- `colors_diverging_spectral`
- `colors_diverging_icefire`

### Custom

- `new_color_scheme()`

## 使用模式

### 1) 离散颜色映射

```r
energy |>
  tidyplot(year, energy, color = energy_source) |>
  add_barstack_absolute() |>
  adjust_colors(colors_discrete_friendly)
```

### 2) 连续热图映射

```r
climate |>
  tidyplot(x = month, y = year, color = max_temperature) |>
  add_heatmap() |>
  adjust_colors(new_colors = colors_continuous_inferno)
```

### 3) 发散热图映射

```r
gene_expression |>
  tidyplot(x = sample, y = external_gene_name, color = expression) |>
  add_heatmap(scale = "row") |>
  adjust_colors(new_colors = colors_diverging_blue2red)
```

### 4) 自定义配色

```r
my_colors <- new_color_scheme(
  c("#ECA669", "#E06681", "#8087E2", "#E2D269"),
  name = "my_custom_color_scheme"
)

energy |>
  tidyplot(year, energy, color = energy_source) |>
  add_barstack_absolute() |>
  adjust_colors(new_colors = my_colors)
```

## 选型建议

- 通用分类图优先：`colors_discrete_friendly`
- 类别较多时：`colors_discrete_friendly_long`
- 热图默认稳妥：`colors_continuous_viridis`
- 强对比表达：`colors_continuous_inferno` / `colors_continuous_turbo`
- 围绕基线变化（上调/下调）：`colors_diverging_blue2red`

## 常见问题

1. 颜色数量与类别不一致：
- tidyplots 会自动插值或抽样；如需固定映射，传入命名向量。

2. 颜色太淡且不想透出背景：
- 优先调 `saturation`（适用函数如 `add_mean_bar()`、`add_violin()`、`add_boxplot()`），再考虑 `alpha`。

3. 版本差异：
- 如索引中的配色对象在本地不可用，请先检查 `packageVersion("tidyplots")`。
