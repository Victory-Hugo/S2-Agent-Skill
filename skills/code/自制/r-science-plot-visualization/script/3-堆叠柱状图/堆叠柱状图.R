library(tidyverse)
library(tidyplots)

example_data <- tidyplots::energy

example_data |>
  tidyplot(x = year, y = energy, color = energy_source) |>
  add_barstack_absolute()

example_data |>
  tidyplot(x = year, y = energy, color = energy_source) |>
  add_barstack_relative()
