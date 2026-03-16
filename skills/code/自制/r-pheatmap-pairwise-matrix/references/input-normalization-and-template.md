# Input Normalization And Template

## Supported Input Shapes

### Square matrix

```r
mat <- read.table("fst.csv", header = TRUE, sep = ",", row.names = 1, check.names = FALSE)
```

### Tidy-long table

```r
long_df <- read.table("fst_long.csv", header = TRUE, sep = ",", check.names = FALSE)
# expected shape like: sample1, sample2, value
```

### Tidy-wide data frame

```r
wide_df <- read.table("fst_wide.csv", header = TRUE, sep = ",", check.names = FALSE)
# expected shape: first column contains row sample names
```

## Normalization Recipes

### Matrix to numeric square matrix

```r
mat <- as.matrix(mat)
storage.mode(mat) <- "numeric"

if (nrow(mat) != ncol(mat)) {
  stop("Input matrix must be square.")
}

if (is.null(rownames(mat)) || is.null(colnames(mat))) {
  stop("Matrix must have both row names and column names.")
}

if (anyDuplicated(rownames(mat)) || anyDuplicated(colnames(mat))) {
  stop("Sample names must be unique in both rows and columns.")
}

common_samples <- intersect(rownames(mat), colnames(mat))
if (length(common_samples) != nrow(mat) || length(common_samples) != ncol(mat)) {
  stop("Row names and column names must describe the same sample set.")
}

mat <- mat[common_samples, common_samples, drop = FALSE]
```

### Tidy-long to square matrix

```r
library(reshape2)

mat <- acast(long_df, sample1 ~ sample2, value.var = "value")
mat <- as.matrix(mat)
storage.mode(mat) <- "numeric"

if (!identical(sort(rownames(mat)), sort(colnames(mat)))) {
  stop("The long table must expand to the same sample set on rows and columns.")
}

ordered_samples <- intersect(rownames(mat), colnames(mat))
mat <- mat[ordered_samples, ordered_samples, drop = FALSE]
```

If the user uses different column names, rewrite the formula instead of guessing.

### Tidy-wide to square matrix

```r
rownames(wide_df) <- wide_df[[1]]
mat <- as.matrix(wide_df[, -1, drop = FALSE])
storage.mode(mat) <- "numeric"

if (!identical(sort(rownames(mat)), sort(colnames(mat)))) {
  stop("Wide input must contain the same sample set in row names and column names.")
}

ordered_samples <- intersect(rownames(mat), colnames(mat))
mat <- mat[ordered_samples, ordered_samples, drop = FALSE]
```

## Group Annotation Recipe

```r
group <- read.table("group.csv", header = TRUE, sep = ",", row.names = 1, check.names = FALSE)

if (ncol(group) < 1) {
  stop("Group table must contain at least one annotation column.")
}

common_samples <- intersect(colnames(mat), rownames(group))
if (length(common_samples) == 0) {
  stop("No overlapping samples between matrix and group table.")
}

mat <- mat[common_samples, common_samples, drop = FALSE]
group <- group[common_samples, , drop = FALSE]

if (!identical(rownames(group), colnames(mat))) {
  stop("Group rows must align with matrix sample order.")
}
```

Use:

```r
annotation_col = group,
annotation_row = group
```

when the same grouping applies to both rows and columns.

## Minimal R Template

```r
library(pheatmap)
library(reshape2)

mat <- read.table("fst.csv", header = TRUE, sep = ",", row.names = 1, check.names = FALSE)
mat <- as.matrix(mat)
storage.mode(mat) <- "numeric"

if (nrow(mat) != ncol(mat)) {
  stop("Input matrix must be square.")
}

ordered_samples <- intersect(rownames(mat), colnames(mat))
if (length(ordered_samples) != nrow(mat) || length(ordered_samples) != ncol(mat)) {
  stop("Row names and column names must describe the same sample set.")
}
mat <- mat[ordered_samples, ordered_samples, drop = FALSE]

group <- read.table("group.csv", header = TRUE, sep = ",", row.names = 1, check.names = FALSE)
group <- group[colnames(mat), , drop = FALSE]

if (!identical(rownames(group), colnames(mat))) {
  stop("Group table does not align with matrix samples.")
}

heat_cols <- colorRampPalette(c(
  "#20364F", "#31646C", "#4E9280", "#96B89B", "#DCDFD2",
  "#ECD9CF", "#D49C87", "#B86265", "#8B345E", "#50184E"
))(10000)

pdf("pairwise_matrix_heatmap.pdf", width = 8, height = 8)
pheatmap(
  mat,
  cluster_cols = TRUE,
  cluster_rows = TRUE,
  angle_col = 45,
  fontsize = 8,
  fontsize_row = 8,
  fontsize_col = 6,
  annotation_col = group,
  annotation_row = group,
  cellwidth = 8,
  cellheight = 8,
  main = "PairwiseMatrix",
  color = heat_cols
)
dev.off()

png("pairwise_matrix_heatmap.png", width = 2400, height = 2400, res = 300)
pheatmap(
  mat,
  cluster_cols = TRUE,
  cluster_rows = TRUE,
  angle_col = 45,
  fontsize = 8,
  fontsize_row = 8,
  fontsize_col = 6,
  annotation_col = group,
  annotation_row = group,
  cellwidth = 8,
  cellheight = 8,
  main = "PairwiseMatrix",
  color = heat_cols
)
dev.off()
```

If no group table is provided, remove `annotation_col` and `annotation_row`.

## Prompting Rules

- Do not invent column names. If the user does not provide them, state the assumption explicitly.
- Prefer a complete script over partial snippets.
- If the user already has an R object such as `mat` or `long_df`, rewrite the template around that object instead of forcing file input.
- Do not add extra packages or extra layers unless the user asks for them.
- Mention dropped samples or retained `NA` values when alignment or reshaping changes the plotting matrix.
