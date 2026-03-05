#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

cat("== tidyplots environment check ==\n")
cat(sprintf("R version: %s\n", R.version.string))

required_packages <- c("tidyplots", "tidyverse")
missing_packages <- character(0)

for (pkg in required_packages) {
  installed <- requireNamespace(pkg, quietly = TRUE)
  if (installed) {
    ver <- as.character(utils::packageVersion(pkg))
    cat(sprintf("[OK] %s (%s)\n", pkg, ver))
  } else {
    cat(sprintf("[MISSING] %s\n", pkg))
    missing_packages <- c(missing_packages, pkg)
  }
}

if (length(missing_packages) > 0) {
  cat("\nInstall missing packages with:\n")
  for (pkg in missing_packages) {
    cat(sprintf("install.packages(\"%s\")\n", pkg))
  }
  quit(status = 1)
}

cat("\nAll required packages are available.\n")
quit(status = 0)
