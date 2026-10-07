library(tidyverse)
library(tidyplots)

example_data <- tidyplots::study

example_data |>
  tidyplot(x = treatment, y = score, color = treatment) |>
  add_mean_dot(size = 2.5) |>
  add_mean_bar(width = 0.03) |>
  add_mean_value()