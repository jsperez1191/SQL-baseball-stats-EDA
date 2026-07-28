
**WORK IN PROGRESS**

# SQL-baseball-stats-EDA

-- changing column with a comma to normal column name for future

ALTER TABLE stats.stats
RENAME COLUMN `last_name, first_name` TO last_first;

/**
Sanity check:
no duplicates shown with 154 unique IDs
clean data no missing values
*/
 
SELECT COUNT(*) AS n_players,
COUNT(DISTINCT player_id) AS n_unique_ids,
MIN(year),
MAX(year)
FROM stats.stats;

/**
PA ranges 336-492 with an average of 411
*/

SELECT MIN(pa),
MAX(pa),
ROUND(AVG(pa), 1) AS avg_pa
FROM stats.stats;

/**
Biggest overperformers vs their expected stats. Wilson Jr (+0.41)
Underperformers Soto (-0.069)
*/

SELECT last_first as player,
woba,
xwoba,
ROUND(woba-xwoba, 3) AS luck
FROM stats.stats
ORDER BY luck DESC;

/**
Clear relation between avg_barrel and avg_woba
barrel rate predicts production
*/

SELECT quartile,
COUNT(*) AS n,
ROUND(AVG(barrel_batted_rate), 2) AS avg_barrel,
ROUND(AVG(woba), 3) AS avg_woba
FROM (SELECT barrel_batted_rate,
    woba,
    NTILE(4)
    OVER (ORDER BY barrel_batted_rate) AS quartile
    FROM stats.stats) as bbrwq
GROUP BY quartile
ORDER BY quartile;

/**
Shows that strikeout percentage does not predict lower production
*/

SELECT CASE WHEN k_percent < 15 THEN '<15%'
WHEN k_percent < 20 THEN '15-20%'
WHEN k_percent < 25 THEN '20-25%'
ELSE '25%+' END AS k_bucket,
COUNT(*) AS n,
ROUND(AVG(woba), 3) AS avg_woba
FROM stats.stats
GROUP BY k_bucket
ORDER BY k_bucket;
