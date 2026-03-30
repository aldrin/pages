"""Taxi trip metrics visualization for the README."""

import pandas as pd
from plotnine import (
    aes,
    element_text,
    geom_col,
    geom_text,
    ggplot,
    labs,
    scale_y_continuous,
    theme,
)

import ajd

df = pd.DataFrame({
    "borough": ["Manhattan", "Brooklyn", "Queens", "JFK", "LaGuardia", "Bronx", "Staten Is."],
    "trips": [312847, 87214, 64932, 43298, 28716, 12481, 1847],
})
df["borough"] = pd.Categorical(df["borough"], categories=df["borough"], ordered=True)

p = (
    ggplot(df, aes("borough", "trips"))
    + geom_col(fill=ajd.DARK, width=0.7)
    + geom_text(
        aes(label="trips"),
        format_string="{:,.0f}",
        va="bottom",
        size=5.5,
        color="#555555",
    )
    + scale_y_continuous(
        labels=lambda xs: [f"{x / 1000:.0f}k" for x in xs],
        expand=(0, 0, 0.12, 0),
    )
    + labs(x="", y="Trips")
    + ajd.THEME
    + theme(axis_text_x=element_text(rotation=45, ha="right", size=7))
)
ajd.save(p, "taxi-trips", width=ajd.PAGE_HALF)
