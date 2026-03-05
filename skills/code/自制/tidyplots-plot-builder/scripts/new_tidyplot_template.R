#!/usr/bin/env Rscript

parse_args <- function(argv) {
  if (length(argv) %% 2 != 0) {
    stop("Arguments must be provided as --key value pairs.")
  }
  out <- list()
  i <- 1
  while (i <= length(argv)) {
    key <- argv[[i]]
    val <- argv[[i + 1]]
    if (!startsWith(key, "--")) {
      stop(sprintf("Invalid argument key: %s", key))
    }
    key <- substring(key, 3)
    out[[key]] <- val
    i <- i + 2
  }
  out
}

require_arg <- function(lst, key) {
  if (is.null(lst[[key]]) || identical(lst[[key]], "")) {
    stop(sprintf("Missing required argument --%s", key))
  }
  lst[[key]]
}

build_template <- function(mode, dataset, x, y, color) {
  if (identical(color, "NULL")) {
    color <- NA_character_
  }
  if (identical(y, "NULL")) {
    y <- NA_character_
  }

  mode_choices <- c("scatter", "grouped-summary", "heatmap", "proportion", "stat-compare")
  if (!(mode %in% mode_choices)) {
    stop(sprintf("Unsupported mode: %s", mode))
  }

  map_line <- if (!is.na(y) && !is.na(color)) {
    sprintf("p <- df |> tidyplot(x = !!x_sym, y = !!y_sym, color = !!color_sym)")
  } else if (!is.na(y) && is.na(color)) {
    sprintf("p <- df |> tidyplot(x = !!x_sym, y = !!y_sym)")
  } else if (is.na(y) && !is.na(color)) {
    sprintf("p <- df |> tidyplot(x = !!x_sym, color = !!color_sym)")
  } else {
    sprintf("p <- df |> tidyplot(x = !!x_sym)")
  }

  layer_lines <- switch(
    mode,
    "scatter" = c(
      "p <- p |>",
      "  add_data_points()"
    ),
    "grouped-summary" = c(
      "p <- p |>",
      "  add_data_points_beeswarm() |>",
      "  add_mean_dash() |>",
      "  add_sem_errorbar()"
    ),
    "heatmap" = c(
      "p <- p |>",
      "  add_heatmap(scale = \"row\")"
    ),
    "proportion" = c(
      "p <- p |>",
      "  add_barstack_relative()"
    ),
    "stat-compare" = c(
      "p <- p |>",
      "  add_data_points() |>",
      "  add_mean_dash() |>",
      "  add_sem_errorbar() |>",
      "  add_test_pvalue(method = \"wilcoxon\", p.adjust.method = \"BH\")"
    )
  )

  c(
    "#!/usr/bin/env Rscript",
    "",
    "library(tidyplots)",
    "library(rlang)",
    "",
    sprintf("data_name <- \"%s\"", dataset),
    sprintf("x_col <- \"%s\"", x),
    sprintf("y_col <- \"%s\"", ifelse(is.na(y), "NULL", y)),
    sprintf("color_col <- \"%s\"", ifelse(is.na(color), "NULL", color)),
    "",
    "if (exists(data_name, envir = .GlobalEnv, inherits = FALSE)) {",
    "  df <- get(data_name, envir = .GlobalEnv)",
    "} else if (exists(data_name, envir = asNamespace(\"tidyplots\"), inherits = FALSE)) {",
    "  df <- get(data_name, envir = asNamespace(\"tidyplots\"))",
    "} else {",
    "  data_loaded <- tryCatch({",
    "    utils::data(list = data_name, package = \"tidyplots\", envir = environment())",
    "    exists(data_name, envir = environment(), inherits = FALSE)",
    "  }, error = function(e) FALSE)",
    "  if (data_loaded) {",
    "    df <- get(data_name, envir = environment())",
    "  } else {",
    "    stop(sprintf(\"Dataset '%s' not found in .GlobalEnv or tidyplots package data.\", data_name))",
    "  }",
    "}",
    "",
    "x_sym <- sym(x_col)",
    "y_sym <- if (identical(y_col, \"NULL\")) NULL else sym(y_col)",
    "color_sym <- if (identical(color_col, \"NULL\")) NULL else sym(color_col)",
    "",
    map_line,
    "",
    layer_lines,
    "",
    sprintf("p |> save_plot(\"%s_%s_output.pdf\")", mode, dataset)
  )
}

main <- function() {
  parsed <- parse_args(commandArgs(trailingOnly = TRUE))

  mode <- require_arg(parsed, "mode")
  dataset <- require_arg(parsed, "dataset")
  x <- require_arg(parsed, "x")
  y <- if (is.null(parsed$y)) "NULL" else parsed$y
  color <- if (is.null(parsed$color)) "NULL" else parsed$color
  output <- require_arg(parsed, "output")

  lines <- build_template(mode = mode, dataset = dataset, x = x, y = y, color = color)

  out_dir <- dirname(output)
  if (!dir.exists(out_dir)) {
    dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  }

  writeLines(lines, con = output, useBytes = TRUE)
  cat(sprintf("Template script written to: %s\n", output))
}

main()
