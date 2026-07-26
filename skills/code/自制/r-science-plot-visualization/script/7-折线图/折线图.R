library(tidyverse)
library(tidyplots)

example_data <- tidyplots::time_course 

example_data |>
  tidyplot(x = day, y = score, color = treatment, dodge_width = 0) |>
  add_mean_line() 

example_data |>
  tidyplot(x = day, y = score, color = treatment, dodge_width = 0) |>
  add_mean_line() |>
  add_sem_ribbon()

example_data |>
  tidyplot(x = day, y = score, color = treatment, dodge_width = 0) |>
  add_mean_line() |>
  add_mean_dot(size = 1) |>
  add_sem_errorbar(width = 2)


