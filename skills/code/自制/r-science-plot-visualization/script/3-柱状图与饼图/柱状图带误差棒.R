library(tidyverse)
library(tidyplots)

example_data <- tidyplots::study 

example_data |>
  tidyplot(x = score, y = treatment, color = treatment) |>
  add_mean_bar(alpha = 0.3) |>
  add_sem_errorbar() |>
  add_data_points()

example_data |>
  tidyplot(x = group, y = score, color = dose) |>
  add_mean_bar(alpha = 0.3) |>
  add_sem_errorbar() |>
  add_data_points() |>
  add_test_asterisks(hide_info = TRUE)

example_data |> 
  tidyplot(x = treatment, y = score, color = treatment) |> 
  add_mean_bar(alpha = 0.4) |> 
  add_sem_errorbar() |> 
  add_data_points_beeswarm() |> 
  view_plot(title = "Default color scheme: 'friendly'") |> 
  view_plot(title = "Alternative color scheme: 'apple'")