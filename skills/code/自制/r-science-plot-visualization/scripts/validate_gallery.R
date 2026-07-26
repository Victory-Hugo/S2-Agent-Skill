#!/usr/bin/env Rscript

#* =====定位图库=====
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(script_arg)) {
  dirname(normalizePath(sub("^--file=", "", script_arg[[1]])))
} else {
  getwd()
}
skill_dir <- normalizePath(file.path(script_dir, ".."))
catalog_file <- file.path(skill_dir, "references", "example-catalog.md")

#* =====检查索引=====
errors <- character()
catalog <- readLines(catalog_file, warn = FALSE)
matches <- regmatches(
  catalog,
  gregexpr("\\.\\./script/[^)]+\\.R", catalog, perl = TRUE)
)
indexed <- unique(sub("^\\.\\./", "", unlist(matches)))
script_files <- list.files(
  file.path(skill_dir, "script"),
  pattern = "\\.R$",
  recursive = TRUE,
  full.names = FALSE
)
scripts <- file.path("script", script_files)
missing_paths <- indexed[!file.exists(file.path(skill_dir, indexed))]
unindexed <- setdiff(scripts, indexed)
if (length(missing_paths)) errors <- c(errors, paste("索引路径不存在：", missing_paths))
if (length(unindexed)) errors <- c(errors, paste("脚本未进入索引：", unindexed))

#* =====检查语法与依赖=====
packages <- character()
for (relative_path in scripts) {
  script_file <- file.path(skill_dir, relative_path)
  parse_error <- tryCatch({
    parse(script_file)
    NULL
  }, error = conditionMessage)
  if (!is.null(parse_error)) {
    errors <- c(errors, paste(relative_path, parse_error, sep = "："))
  }

  code <- readLines(script_file, warn = FALSE)
  package_match <- regmatches(
    code,
    regexec("^\\s*(?:library|require)\\s*\\(\\s*['\"]?([^,'\")]+)", code)
  )
  packages <- c(packages, vapply(
    package_match[lengths(package_match) > 1L],
    `[[`,
    character(1),
    2L
  ))
}

packages <- sort(unique(packages))
missing_packages <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages)) {
  message("未安装（未自动安装）：", paste(missing_packages, collapse = ", "))
}

#* =====报告=====
if (length(errors)) {
  stop(paste(errors, collapse = "\n"), call. = FALSE)
}
cat("验证通过：", length(scripts), " 个脚本；", length(indexed), " 个索引。\n", sep = "")
