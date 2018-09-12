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
