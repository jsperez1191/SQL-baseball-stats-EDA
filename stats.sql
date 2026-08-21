CREATE TABLE player_stats (
    last_first VARCHAR(100),
    player_id INT,
    year INT,
    pa INT,
    k_percent DECIMAL(5,2),
    bb_percent DECIMAL(5,2),
    woba DECIMAL(5,3),
    xwoba DECIMAL(5,3),
    sweet_spot_percent DECIMAL(5,2),
    barrel_batted_rate DECIMAL(5,2),
    hard_hit_percent DECIMAL(5,2),
    avg_best_speed DECIMAL(10,7),
    avg_hyper_speed DECIMAL(10,7),
    whiff_percent DECIMAL(5,2),
    swing_percent DECIMAL(5,2)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

LOAD DATA LOCAL INFILE '/Users/juanperez/Downloads/stats_fixed.csv'
INTO TABLE player_stats
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'local_infile';

SELECT * FROM player_stats LIMIT 10;

-- top 10 qoba in season
SELECT last_first, year, xwoba
FROM player_stats
WHERE year = 2025
ORDER BY xwoba DESC
LIMIT 10;

-- players who outperformed woba
SELECT 
	last_first,
    year,
    woba,
    xwoba,
    (woba-xwoba) AS woba_diff
FROM player_stats
WHERE year = 2025 AND pa >= 200
ORDER BY woba_diff DESC
LIMIT 10;

-- contact quality leaders
SELECT
	last_first,
    year,
    barrel_batted_rate,
    hard_hit_percent
FROM player_stats
WHERE year = 2025 AND pa >= 200
ORDER BY barrel_batted_rate DESC
LIMIT 10;

SELECT * FROM player_stats LIMIT 10;

-- high strikeout percent doesnt correlate to lower average or lower walk percent
SELECT
    AVG(woba),
    AVG(bb_percent),
	CASE
		WHEN k_percent <= 15 THEN '<15%'
        WHEN k_percent BETWEEN 15 AND 20 THEN '15-20%'
        WHEN k_percent BETWEEN 20 AND 25 THEN '20-25%'
        ELSE '25%+' END AS k_percent_bucket
FROM player_stats
GROUP BY k_percent_bucket
ORDER BY k_percent_bucket;

-- average whiff_percent correlates with bat speed. harder the swings the more swing and miss rate
SELECT
	AVG(whiff_percent),
    CASE 
		WHEN avg_best_speed BETWEEN 90 AND 95 THEN '90-95'
		WHEN avg_best_speed BETWEEN 95 AND 100 THEN '95-100'
        WHEN avg_best_speed BETWEEN 100 AND 105 THEN '100-105'
		ELSE '105+' END AS best_speed
FROM player_stats
GROUP BY best_speed
ORDER BY AVG(whiff_percent);










