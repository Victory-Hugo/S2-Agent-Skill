"""Minimal Python template for scientific figures.

Default rules:
- Figure text is English.
- Font is Arial.
- Font size is 6 pt.
- PDF and SVG text should remain editable.
"""

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from aquarel import load_theme

# Install with: pip install aquarel
# sns.set_style("white")
theme = load_theme("boxy_light")
theme.apply()

plt.rcParams["font.sans-serif"] = ["Arial"]
plt.rcParams["font.size"] = 6
plt.rcParams["axes.labelsize"] = 6
plt.rcParams["xtick.labelsize"] = 6
plt.rcParams["ytick.labelsize"] = 6
plt.rcParams["legend.fontsize"] = 6
plt.rcParams["pdf.fonttype"] = 42
plt.rcParams["ps.fonttype"] = 42
plt.rcParams["svg.fonttype"] = "none"


def save_figure(fig, filename_base, width=3.5, height=2.6, dpi=300):
    """Save editable vector output and optional raster preview."""
    fig.set_size_inches(width, height)
    fig.savefig(f"{filename_base}.pdf", bbox_inches="tight")
    fig.savefig(f"{filename_base}.svg", bbox_inches="tight")
    fig.savefig(f"{filename_base}.png", dpi=dpi, bbox_inches="tight")


# Example data. Replace with user data.
df = pd.DataFrame({
    "Group": ["Control", "Control", "Treatment", "Treatment"],
    "Value": [1.0, 1.2, 1.8, 2.1],
})

fig, ax = plt.subplots(figsize=(3.5, 2.6))
sns.boxplot(data=df, x="Group", y="Value", ax=ax)
sns.stripplot(data=df, x="Group", y="Value", color="black", size=2, ax=ax)
ax.set_xlabel("Group")
ax.set_ylabel("Value")

save_figure(fig, "figure_python")
