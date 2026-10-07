library(tidyverse)
library(tidyplots)

#* =====配置=====
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(script_arg)) {
  dirname(normalizePath(sub("^--file=", "", script_arg[[1]])))
} else {
  getwd()
}
input_file <- file.path(script_dir, "microbiota.csv")

#* =====检查=====
if (!file.exists(input_file)) stop("缺少输入文件：", input_file)

example_data <- tidyplots::energy


example_data |>
  tidyplot(x = year, y = energy, color = energy_source) |>
  add_areastack_absolute()


example_data |>
  tidyplot(x = year, y = energy, color = energy_source) |>
  add_areastack_relative()


example_data_2 <- 
  read_csv(input_file) |> 
  mutate(genus = fct_inorder(genus),
         sample = fct_reorder(sample, top, .desc = TRUE))

example_data_2 |>
  tidyplot(x = sample, y = rel_abundance, color = genus) |>
  add_areastack_absolute(alpha = 0.6) |>
  add_caption("Data source: Tamburini FB, et al. 2022. Nat Comm 13, 926.") |>
  adjust_theme_details(legend.key.height = unit(3.4, "mm")) |> 
  adjust_theme_details(legend.key.width = unit(3.4, "mm")) |> 
  adjust_x_axis_title("Sample") |> 
  adjust_y_axis_title("Relative abundance") |> 
  remove_x_axis_labels() |>
  remove_x_axis_ticks() |>
  remove_legend_title()
