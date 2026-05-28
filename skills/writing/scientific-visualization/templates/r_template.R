# Minimal R template for scientific figures.
# Default rules:
# - Figure text is English.
# - Font is Arial.
# - Font size is 6 pt.
# - Use ggplot2 and theme_classic().
# - Save with ggsave().

library(ggplot2)

# Example data. Replace with user data.
df <- data.frame(
  Group = c("Control", "Control", "Treatment", "Treatment"),
  Value = c(1.0, 1.2, 1.8, 2.1)
)

p <- ggplot(df, aes(x = Group, y = Value)) +
  geom_boxplot(outlier.shape = NA) +
  geom_point(size = 0.8) +
  labs(x = "Group", y = "Value") +
  theme_classic(base_family = "Arial", base_size = 6) +
  theme(
    text = element_text(family = "Arial", size = 6),
    axis.title = element_text(size = 6),
    axis.text = element_text(size = 6),
    legend.title = element_text(size = 6),
    legend.text = element_text(size = 6),
    strip.text = element_text(size = 6)
  )

# Preferred editable vector output.
ggsave(
  filename = "figure_r.pdf",
  plot = p,
  width = 3.5,
  height = 2.6,
  units = "in",
  device = cairo_pdf
)

# Optional raster preview.
ggsave(
  filename = "figure_r.png",
  plot = p,
  width = 3.5,
  height = 2.6,
  units = "in",
  dpi = 300
)
