# 05 - Function Index (Complete)

来源：
- 官方索引（主）：https://jbengler.github.io/tidyplots/reference/index.html
- Notion 页面《Tidyplots 函数索引》：https://www.notion.so/2de164434e498143b264fb651f6df980

版本说明：
- 官方索引页面当前显示版本：`0.4.0.9000`
- 本地环境此前检测版本：`0.3.1`
- 若出现函数名/参数差异，优先以本地 `?function_name` 和 `packageVersion("tidyplots")` 为准。

## Create

- `tidyplot()`

## Add

### Data points & amounts

- Data points:
- `add_data_points()`
- `add_data_points_jitter()`
- `add_data_points_beeswarm()`
- Count:
- `add_count_bar()`
- `add_count_dash()`
- `add_count_dot()`
- `add_count_value()`
- `add_count_line()`
- `add_count_area()`
- Sum:
- `add_sum_bar()`
- `add_sum_dash()`
- `add_sum_dot()`
- `add_sum_value()`
- `add_sum_line()`
- `add_sum_area()`
- Heatmap / line / area:
- `add_heatmap()`
- `add_line()`
- `add_area()`

### Central tendency

- Mean:
- `add_mean_bar()`
- `add_mean_dash()`
- `add_mean_dot()`
- `add_mean_value()`
- `add_mean_line()`
- `add_mean_area()`
- Median:
- `add_median_bar()`
- `add_median_dash()`
- `add_median_dot()`
- `add_median_value()`
- `add_median_line()`
- `add_median_area()`
- Curve fit:
- `add_curve_fit()`

### Distribution & uncertainty

- `add_histogram()`
- `add_boxplot()`
- `add_violin()`
- Error bars:
- `add_sem_errorbar()`
- `add_range_errorbar()`
- `add_sd_errorbar()`
- `add_ci95_errorbar()`
- Ribbons:
- `add_sem_ribbon()`
- `add_range_ribbon()`
- `add_sd_ribbon()`
- `add_ci95_ribbon()`
- `add_ellipse()`

### Proportion

- `add_barstack_absolute()`
- `add_barstack_relative()`
- `add_areastack_absolute()`
- `add_areastack_relative()`
- `add_pie()`
- `add_donut()`

### Statistical testing

- `add_test_pvalue()`
- `add_test_asterisks()`

### Annotation

- `add_title()`
- `add_caption()`
- `add_data_labels()`
- `add_data_labels_repel()`
- `add_reference_lines()`
- `add_annotation_text()`
- `add_annotation_rectangle()`
- `add_annotation_line()`

## Remove

- Legend:
- `remove_legend()`
- `remove_legend_title()`
- Padding:
- `remove_padding()`
- Title/caption:
- `remove_title()`
- `remove_caption()`
- X-axis:
- `remove_x_axis()`
- `remove_x_axis_line()`
- `remove_x_axis_ticks()`
- `remove_x_axis_labels()`
- `remove_x_axis_title()`
- Y-axis:
- `remove_y_axis()`
- `remove_y_axis_line()`
- `remove_y_axis_ticks()`
- `remove_y_axis_labels()`
- `remove_y_axis_title()`

## Adjust

### Components & properties

- `adjust_colors()`
- `adjust_font()`
- `adjust_legend_title()`
- `adjust_legend_position()`
- `adjust_title()`
- `adjust_x_axis_title()`
- `adjust_y_axis_title()`
- `adjust_caption()`
- `adjust_size()`
- `adjust_padding()`
- `adjust_x_axis()`
- `adjust_y_axis()`

### Axis and color levels

- Rename:
- `rename_x_axis_levels()`
- `rename_y_axis_levels()`
- `rename_color_levels()`
- Reorder:
- `reorder_x_axis_levels()`
- `reorder_y_axis_levels()`
- `reorder_color_levels()`
- Sort:
- `sort_x_axis_levels()`
- `sort_y_axis_levels()`
- `sort_color_levels()`
- Reverse:
- `reverse_x_axis_levels()`
- `reverse_y_axis_levels()`
- `reverse_color_levels()`

兼容提醒：旧资料常见 `*_labels()` 命名。优先使用 `*_levels()`。

## Themes

- `theme_tidyplot()`
- `theme_ggplot2()`
- `theme_minimal_xy()`
- `theme_minimal_x()`
- `theme_minimal_y()`
- `adjust_theme_details()`
- `tidyplots_options()`

## Color schemes

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

## Split

- `split_plot()`

关键规则：`split_plot()` 必须在绘图序列最后调用，之后只能接 `save_plot()`。

## Output

- `view_plot()`
- `save_plot()`

## Helpers

- `add()`
- `all_rows()`
- `filter_rows()`
- `max_rows()`
- `min_rows()`
- `first_rows()`
- `last_rows()`
- `sample_rows()`
- `flip_plot()`（superseded）
- `format_p_value()`

## Data

- `animals`
- `climate`
- `dinosaurs`
- `distributions`
- `energy`
- `energy_week`
- `eu_countries`
- `gene_expression`
- `spendings`
- `study`
- `time_course`
- `pca`
