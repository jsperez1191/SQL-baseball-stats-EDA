# MLB Batter Stats Schema

A PostgreSQL table schema for storing season-level MLB batter performance and Statcast metrics.

## Overview

This repository defines `stats.stats`, a table designed to hold one row per player per season, combining traditional plate-discipline rates with modern Statcast quality-of-contact metrics (barrel rate, hard-hit rate, exit velocity, etc.).

## Column Reference

| Column | Type | Description |
|---|---|---|
| `last_first` | text | Player name, formatted as "Last, First" |
| `player_id` | int | Unique player identifier (e.g. MLBAM ID) |
| `year` | int | Season year |
| `pa` | int | Plate appearances |
| `k_percent` | double | Strikeout rate (% of PAs ending in a strikeout) |
| `bb_percent` | double | Walk rate (% of PAs ending in a walk) |
| `woba` | double | Weighted On-Base Average — a run-value-weighted version of OBP |
| `xwoba` | double | Expected wOBA — modeled from exit velocity and launch angle, strips out defense/luck |
| `sweet_spot_percent` | double | % of batted balls hit at a launch angle between 8–32° |
| `barrel_batted_rate` | double | % of batted balls classified as "barrels" (optimal exit velo + launch angle combo) |
| `hard_hit_percent` | double | % of batted balls hit 95+ mph |
| `avg_best_speed` | double | Average exit velocity of a player's hardest-hit balls |
| `avg_hyper_speed` | double | Average Hawk-Eye "hyperspeed" — an adjusted exit velocity metric |
| `whiff_percent` | double | % of swings that miss entirely |
| `swing_percent` | double | % of pitches swung at |

> Note: source data is sometimes exported with a comma in the name column
> (`last_name, first_name`). Rename it to `last_first` after loading:
> ```sql
> ALTER TABLE stats.stats
> RENAME COLUMN `last_name, first_name` TO last_first;
> ```

## Example Queries

**Top 10 by expected wOBA in a given season:**
```sql
select last_first, year, xwoba
from stats.stats
where year = 2025
order by xwoba desc
limit 10;
```

**Players who outperform their expected wOBA (over-performers):**
```sql
select last_first, year, woba, xwoba, (woba - xwoba) as woba_diff
from stats.stats
where year = 2025
order by woba_diff desc
limit 10;
```

**Contact quality leaders (barrel rate + hard-hit rate):**
```sql
select last_first, year, barrel_batted_rate, hard_hit_percent
from stats.stats
where year = 2025 and pa >= 200
order by barrel_batted_rate desc
limit 10;
```

## Key Findings

- **Barrel rate predicts production**: bucketing players into barrel-rate quartiles shows a clear, monotonic relationship with average wOBA.
- **Strikeout rate is a weak predictor**: bucketing by k_percent (`<15%`, `15-20%`, `20-25%`, `25%+`) shows no clear drop in average wOBA at higher strikeout rates.
- **Luck (wOBA − xwOBA) varies widely**: the biggest overperformer is Wilson Jr. (+0.41), the biggest underperformer is Soto (−0.069).
