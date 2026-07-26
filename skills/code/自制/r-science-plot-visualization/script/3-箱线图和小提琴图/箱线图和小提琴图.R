library(tidyverse)
library(tidyplots)

example_data <- tidyplots::study 
# 箱线图
example_data |>
  tidyplot(x = treatment, y = score, color = treatment) |>
  add_boxplot() |>
  add_data_points_beeswarm() |>
  save_plot('boxplot.pdf')

example_data |> 
  tidyplot(x = treatment, y = score, color = treatment) |> 
  add_boxplot() |> 
  add_test_pvalue(ref.group = 1)

# 小提琴图
example_data |>
  tidyplot(x = treatment, y = score, color = treatment) |>
  add_violin() |>
  add_data_points_beeswarm()

example_data |> 
  tidyplot(x = treatment, y = score, color = treatment) |> 
  add_violin() |>
  add_test_pvalue(ref.group = 1)

# 小提琴图 + 箱线图

example_data |>
  tidyplot(x = treatment, y = score, color = treatment) |>
  add_violin() |>
  add_data_points(alpha = 0.5) |> # 样本量大的情况下建议打开 rasterize = TRUE, rasterize_dpi = 600
  add_boxplot() |>
  add_data_points_beeswarm()

example_data |> 
  tidyplot(x = treatment, y = score, color = treatment) |> 
  add_violin() |>
  add_data_points(alpha = 0.5) |> # 样本量大的情况下建议打开 rasterize = TRUE, rasterize_dpi = 600
  add_boxplot() |>
  add_test_pvalue(ref.group = 1)


example_data_2 <- tidyplots::gene_expression

example_data_2 |> 
  filter(external_gene_name %in% c("Apol6", "Col5a3", "Bsn", "Fam96b", "Mrps14", "Tma7")) |> 
  tidyplot(x = sample_type, y = expression, color = condition) |> 
  add_violin() |> 
  add_data_points_beeswarm(white_border = TRUE) |> 
  adjust_x_axis_title("") |> 
  remove_legend() |> 
  add_test_asterisks(hide_info = TRUE, bracket.nudge.y = 0.3) |> 
  adjust_colors(colors_discrete_ibm) |> 
  adjust_y_axis_title("Gene expression") |> 
  adjust_size(width = 35, height = 25) |> 
  split_plot(by = external_gene_name, ncol = 2)
