"""Matplotlib editable vector-font defaults for publication figures."""

from __future__ import annotations

import matplotlib.pyplot as plt


def enable_editable_vector_fonts(font_family: str = "Arial") -> None:
    """Configure matplotlib so exported vector files keep editable text."""
    plt.rcParams["font.sans-serif"] = [font_family]
    plt.rcParams["pdf.fonttype"] = 42
    plt.rcParams["ps.fonttype"] = 42
    plt.rcParams["svg.fonttype"] = "none"


def reset_font_defaults() -> None:
    """Reset matplotlib rcParams to library defaults."""
    plt.rcdefaults()


if __name__ == "__main__":
    enable_editable_vector_fonts()
    print("Applied matplotlib editable vector-font defaults.")
