"""
ajd -- visual style for the writing system.

Grayscale broadsheet aesthetic matching the ajd.typ document template
(Charter / Avenir Next, A4 geometry).

Works with both matplotlib and plotnine:

    import ajd
    fig, ax = ajd.figure()
    ax.plot(x, y)
    ajd.save(fig, "my_chart")   # writes ../images/my_chart.svg

    from plotnine import ggplot, aes, geom_point
    p = ggplot(df, aes("x", "y")) + geom_point()
    ajd.save(p, "my_chart")     # same destination
"""

import pathlib

import matplotlib.pyplot as plt
from plotnine import element_blank, element_line, element_rect, element_text, theme

# -- Paths --------------------------------------------------------------------

_HERE = pathlib.Path(__file__).resolve().parent
STYLE = _HERE.parent / "style" / "ajd.mplstyle"
IMAGES = _HERE.parent / "images"

# Apply the style on import so every script gets it automatically.
plt.style.use(str(STYLE))


# -- Palette ------------------------------------------------------------------
# Grayscale values with enough separation to stay distinguishable.

BLACK = "#333333"
DARK = "#444444"
MID_DARK = "#666666"
MID = "#888888"
MID_LIGHT = "#AAAAAA"
LIGHT = "#BBBBBB"

PALETTE = [DARK, MID, LIGHT, MID_DARK, MID_LIGHT, BLACK]

# -- Geometry -----------------------------------------------------------------
# US Letter content width: 8.5in - 2*20mm margins = 215.9mm - 40mm ≈ 6.93in

PAGE_WIDTH = 6.93
PAGE_HALF = PAGE_WIDTH / 2
GOLDEN = 0.618


# -- Helpers ------------------------------------------------------------------


def figure(width=PAGE_WIDTH, ratio=GOLDEN, **kwargs):
    """Create a figure sized for the document column width."""
    return plt.subplots(figsize=(width, width * ratio), **kwargs)


def half_figure(ratio=GOLDEN, **kwargs):
    """Create a figure sized for half the column width (side-by-side use)."""
    return plt.subplots(figsize=(PAGE_HALF, PAGE_HALF * ratio), **kwargs)


def save(obj, name, fmt="svg", width=PAGE_WIDTH, ratio=GOLDEN):
    """Save a matplotlib figure or plotnine ggplot to the images directory."""
    IMAGES.mkdir(exist_ok=True)
    path = IMAGES / f"{name}.{fmt}"
    try:
        # plotnine ggplot
        obj.save(path, width=width, height=width * ratio, dpi=300, verbose=False)
    except AttributeError:
        # matplotlib figure
        obj.savefig(path)
        plt.close(obj)
    print(path)


# -- plotnine theme -----------------------------------------------------------
# Broadsheet: heavy baseline, horizontal rules, no left spine, no y ticks.

THEME = theme(
    plot_title=element_text(family="IBM Plex Sans", weight="bold", size=12),
    axis_title=element_text(family="IBM Plex Serif", size=9, color="#444444"),
    axis_text=element_text(family="IBM Plex Serif", color="#666666"),
    legend_title=element_text(family="IBM Plex Sans", size=9),
    legend_text=element_text(family="IBM Plex Serif", size=8.5),
    panel_background=element_rect(fill="none", color="none"),
    panel_grid_major_y=element_line(color="#CCCCCC", size=0.4),
    panel_grid_major_x=element_blank(),
    axis_line_x=element_line(color="#222222", size=0.8),
    axis_line_y=element_blank(),
    axis_ticks_major_y=element_blank(),
    axis_ticks_major_x=element_line(color="#222222", size=0.5),
)


def text_color(values, low="#F0F0F0", high="#333333", threshold=0.55):
    """Return dark or white text color for each value based on its fill.

    Use with a grayscale gradient heatmap. Pass the same low/high endpoints
    as your scale_fill_gradient. Values above the threshold fraction of the
    range get white text; the rest get dark text.
    """
    import numpy as np

    arr = np.asarray(values, dtype=float)
    lo, hi = arr.min(), arr.max()
    if hi == lo:
        return ["#333333"] * len(arr)
    normalized = (arr - lo) / (hi - lo)
    return ["white" if v > threshold else "#333333" for v in normalized]


def title(ax, text):
    """Set a title using the sans-serif heading font (matplotlib only)."""
    ax.set_title(text, fontfamily="sans-serif", fontweight="bold")
