ALTER TABLE demo
ALTER COLUMN individual_income_segment_code TYPE integer
USING nullif(individual_income_segment_code, '')::integer;

ALTER TABLE demo
ALTER COLUMN family_income_segment_code TYPE integer
USING nullif(family_income_segment_code, '')::integer;

UPDATE demo
SET individual_income_segment_code = -1
WHERE individual_income_segment_code IS NULL;

UPDATE demo
SET family_income_segment_code = -1
WHERE family_income_segment_code IS NULL;

UPDATE demo
SET marital_status = -1
WHERE marital_status IS NULL;

------------------------
-- Data Preparation
------------------------

-- Account Age
SELECT
	*,
	CASE WHEN ((s.diff_year < 20) OR (s.diff_year = 20 AND s.diff_month = 0 AND s.diff_day = 0)) THEN 1
      WHEN ((s.diff_year < 30) OR (s.diff_year = 30 AND s.diff_month = 0 AND s.diff_day = 0)) THEN 2
      WHEN ((s.diff_year < 40) OR (s.diff_year = 40 AND s.diff_month = 0 AND s.diff_day = 0)) THEN 3
      WHEN ((s.diff_year < 50) OR (s.diff_year = 50 AND s.diff_month = 0 AND s.diff_day = 0)) THEN 4
      ELSE 5
  END AS account_age
FROM demo, LATERAL (SELECT
								EXTRACT(YEAR FROM age(date '2018-07-06', account_start_date)) AS diff_year,
								EXTRACT(MONTH FROM age(date '2018-07-06', account_start_date)) AS diff_month,
								EXTRACT(DAY FROM age(date '2018-07-06', account_start_date)) AS diff_day
							) s;

-- Amount of purchasing by each category by credit card
SELECT
        y.user_id,
        COUNT (CASE category WHEN  'cat1' THEN 1 ELSE NULL END) as cat1,
        COUNT (CASE category WHEN  'cat2' THEN 1 ELSE NULL END) as cat2,
        COUNT (CASE category WHEN  'cat3' THEN 1 ELSE NULL END) as cat3,
        COUNT (CASE category WHEN  'cat4' THEN 1 ELSE NULL END) as cat4,
        COUNT (CASE category WHEN  'cat5' THEN 1 ELSE NULL END) as cat5,
        COUNT (CASE category WHEN  'cat6' THEN 1 ELSE NULL END) as cat6,
        COUNT (CASE category WHEN  'cat7' THEN 1 ELSE NULL END) as cat7,
        COUNT (CASE category WHEN  'cat8' THEN 1 ELSE NULL END) as cat8,
        COUNT (CASE category WHEN  'cat9' THEN 1 ELSE NULL END) as cat9,
        COUNT (CASE category WHEN 'cat10' THEN 1 ELSE NULL END) as cat10,
        COUNT (CASE category WHEN 'cat11' THEN 1 ELSE NULL END) as cat11,
        COUNT (CASE category WHEN 'cat12' THEN 1 ELSE NULL END) as cat12,
        COUNT (CASE category WHEN 'cat13' THEN 1 ELSE NULL END) as cat13,
        COUNT (CASE category WHEN 'cat14' THEN 1 ELSE NULL END) as cat14,
        COUNT (CASE category WHEN 'cat15' THEN 1 ELSE NULL END) as cat15,
        COUNT (CASE category WHEN 'cat16' THEN 1 ELSE NULL END) as cat16
FROM y_train y
JOIN cc_txn AS cc
ON y.user_id = cc.user_id
GROUP BY y.user_id
