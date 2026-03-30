"""Heatmap of taxi trips by borough and time of day."""

import pandas as pd
from plotnine import (
    aes,
    element_blank,
    geom_text,
    geom_tile,
    ggplot,
    labs,
    scale_color_identity,
    scale_fill_gradient,
    scale_y_discrete,
    theme,
)

import ajd

boroughs = ["Manhattan", "Brooklyn", "Queens", "JFK", "LaGuardia", "Bronx"]
hours = ["6am", "9am", "12pm", "3pm", "6pm", "9pm", "12am"]

rows = [
    ("Bronx", "12am", 3861),
    ("Bronx", "12pm", 10488),
    ("Bronx", "3pm", 9364),
    ("Bronx", "6am", 6170),
    ("Bronx", "6pm", 16955),
    ("Bronx", "9am", 10801),
    ("Bronx", "9pm", 9864),
    ("Brooklyn", "12am", 8021),
    ("Brooklyn", "12pm", 24200),
    ("Brooklyn", "3pm", 19140),
    ("Brooklyn", "6am", 8900),
    ("Brooklyn", "6pm", 36494),
    ("Brooklyn", "9am", 28222),
    ("Brooklyn", "9pm", 21650),
    ("JFK", "12am", 14780),
    ("JFK", "12pm", 19113),
    ("JFK", "3pm", 25877),
    ("JFK", "6am", 14212),
    ("JFK", "6pm", 39019),
    ("JFK", "9am", 34366),
    ("JFK", "9pm", 31961),
    ("LaGuardia", "12am", 11230),
    ("LaGuardia", "12pm", 15330),
    ("LaGuardia", "3pm", 20213),
    ("LaGuardia", "6am", 9912),
    ("LaGuardia", "6pm", 35037),
    ("LaGuardia", "9am", 30018),
    ("LaGuardia", "9pm", 21982),
    ("Manhattan", "12am", 11334),
    ("Manhattan", "12pm", 35736),
    ("Manhattan", "3pm", 31588),
    ("Manhattan", "6am", 21779),
    ("Manhattan", "6pm", 45313),
    ("Manhattan", "9am", 50500),
    ("Manhattan", "9pm", 26102),
    ("Queens", "12am", 6265),
    ("Queens", "12pm", 13525),
    ("Queens", "3pm", 16188),
    ("Queens", "6am", 4999),
    ("Queens", "6pm", 23476),
    ("Queens", "9am", 16284),
    ("Queens", "9pm", 9871),
]

df = pd.DataFrame(rows, columns=["borough", "hour", "trips"])
df["borough"] = pd.Categorical(
    df["borough"], categories=boroughs[::-1], ordered=True
)
df["hour"] = pd.Categorical(df["hour"], categories=hours, ordered=True)
df["label_color"] = ajd.text_color(df["trips"])

p = (
    ggplot(df, aes("hour", "borough", fill="trips"))
    + geom_tile(color="white", size=1.5)
    + geom_text(
        aes(label="trips", color="label_color"),
        format_string="{:,.0f}",
        size=5,
        show_legend=False,
    )
    + scale_color_identity()
    + scale_fill_gradient(low="#F0F0F0", high="#333333", guide=None)
    + scale_y_discrete(expand=(0, 0))
    + labs(x="", y="")
    + ajd.THEME
    + theme(
        panel_grid_major_y=element_blank(),
        axis_line_x=element_blank(),
        axis_ticks_major_x=element_blank(),
    )
)
ajd.save(p, "heatmap", width=ajd.PAGE_HALF)
