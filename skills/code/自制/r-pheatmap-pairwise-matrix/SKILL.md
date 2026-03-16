---
name: r-pheatmap-pairwise-matrix
description: 使用pheatmap包生成R代码以进行配对矩阵可视化。当用户明确要求生成R的pheatmap热图，针对配对矩阵，并在输入矩阵以矩阵形式、tidylong表或tidywide数据框传输，以及可能添加行和列的样本-组别标注时，请使用此类代码。
---

# R Pheatmap Pairwise Matrix

## Overview

Generate two outputs for pairwise-matrix heatmap requests:

1. Produce runnable R code that uses `pheatmap` and exports both `pdf` and `png`.
2. Produce or explain the normalized matrix object that can be plotted directly.

Use this skill only when the request explicitly locks onto all three conditions:

1. R language
2. `pheatmap`
3. Pairwise matrix heatmap or equivalent wording

Do not use this skill for generic heatmaps, `ComplexHeatmap`, `ggplot2` heatmaps, non-pairwise matrices, or non-R workflows.

Read [references/input-normalization-and-template.md](references/input-normalization-and-template.md) when you need concrete normalization recipes or a minimal reliable script template.

## Workflow

1. Confirm the trigger matches `R` + `pheatmap` + pairwise matrix.
2. Identify the input shape:
   - square matrix
   - tidy-long table, usually two sample columns plus one value column
   - tidy-wide data frame, usually first column as row identifier and remaining columns as matrix values
3. Normalize the input into a numeric square matrix with identical row and column sample sets in the same order.
4. Check whether sample-group annotation is provided.
5. Align the annotation table to the normalized matrix if present.
6. Generate a full R script that exports `pdf` and `png`, preferring `pdf()` / `png()` with `dev.off()`.
7. If key details are missing or invalid, state the exact problem and ask for the missing structure instead of inventing columns, sample names, or values.

## Input Handling Rules

### Matrix input

- Require a square matrix.
- Require row names and column names to represent the same sample set.
- Convert values to numeric if possible.
- Reorder rows or columns so row names and column names match exactly before plotting.

### Tidy-long input

- Expect two sample identifier columns and one numeric value column.
- Do not invent column names. If names are unclear, state the assumption or ask for confirmation.
- Use `reshape2::acast()` or an equivalent reshape to create the square matrix.
- Preserve `NA` when pairwise combinations are missing. Mention that the user may need to fill or impute missing entries if the heatmap should be complete.

### Tidy-wide input

- Treat the first column as the row-name column unless the user specifies another structure.
- Convert the remaining columns into a numeric matrix with `as.matrix()`.
- Ensure row names and column names refer to the same sample set.

### Group annotation input

- Treat the group table as optional.
- Require row names to be sample names.
- Require at least one annotation column.
- If matrix samples and group samples are not identical, align by intersection and explicitly state which samples were dropped.
- Use the aligned table for both `annotation_col` and `annotation_row` when the same grouping applies to rows and columns.

## Output Contract

When responding with this skill, always produce the following structure:

1. A short explanation of the detected input form and how it is normalized.
2. A code block that creates the matrix object ready for plotting.
3. A complete R script code block that:
   - reads the input file or adapts existing R objects
   - optionally reads and aligns the group table
   - defines the plotting palette
   - writes a `pdf`
   - writes a `png`
   - calls `pheatmap(...)`
4. A short note about alignment issues, assumptions, or required fixes when the input is incomplete or invalid.

If no group annotation is provided, do not include `annotation_row` or `annotation_col`.

If the user does not provide a title, default to `"PairwiseMatrix"`. If the example is clearly an Fst matrix, default to `"FstMatrix"`.

## Default Plot Settings

Treat these as editable defaults, not hard-coded mandatory values:

- `cluster_rows = TRUE`
- `cluster_cols = TRUE`
- `angle_col = 45`
- `fontsize = 8`
- `fontsize_row = 8`
- `fontsize_col = 6`
- `cellwidth = 8`
- `cellheight = 8`
- use the supplied 10-color continuous palette as the default gradient

Only include `display_numbers` when the numeric scale and thresholds are meaningful for the user data.

Do not force `cutree_rows` or `cutree_cols`. Add them only when the user explicitly wants cluster cuts or a fixed cluster count.

## Failure Modes

Handle these cases explicitly in the response:

- the input is not square and cannot be reliably normalized into a square pairwise matrix
- sample names are duplicated
- the group table has no row names or cannot be matched to matrix samples
- value columns are read as character and cannot be safely converted to numeric
- row and column sample orders differ and require reordering
- diagonal values are missing or clearly inconsistent with the expected pairwise-matrix meaning

## Response Quality Rules

- Prefer a full script over isolated code fragments.
- Do not assume hidden file names, column names, or object names without saying so.
- If the user provides an in-memory R object instead of a file, adapt the script to that object and do not force `read.table()`.
- Keep package usage minimal unless the user asks for additional formatting or statistics.
- Keep the response centered on practical plotting output, not generic explanations of heatmaps.
