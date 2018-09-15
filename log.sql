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
							) s
ORDER BY user_id

-- Purchase
SELECT
  user_id,
  COUNT(*) FILTER (WHERE product = 'A' AND '[2018-05-03, 2018-07-01]'::daterange @> dt) AS amount_a_before,
  COUNT(*) FILTER (WHERE product = 'B' AND '[2018-05-03, 2018-07-01]'::daterange @> dt) AS amount_b_before,
  COUNT(*) FILTER (WHERE product = 'A' AND '[2018-07-02, 2018-07-06]'::daterange @> dt) AS amount_a_after,
  COUNT(*) FILTER (WHERE product = 'B' AND '[2018-07-02, 2018-07-06]'::daterange @> dt) AS amount_b_after
FROM purchase
GROUP BY user_id
ORDER BY user_id

-- Amount of purchasing by each category by debit card
SELECT
  user_id,
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
FROM dc_txn
GROUP BY user_id
ORDER BY user_id

-- Amount of purchasing by each category by credit card
SELECT
  user_id,
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
FROM cc_txn
GROUP BY user_id
ORDER BY user_id

-- Amount of ads getting during 3 May - 2 July, 2 July - 6 July
SELECT
  user_id,
  COUNT(*) FILTER (WHERE '[2018-05-03, 2018-07-01]'::daterange @> dt),
  COUNT(*) FILTER (WHERE '[2018-07-02, 2018-07-06]'::daterange @> dt)
FROM ad_log
GROUP BY user_id
ORDER BY user_id

-- Saving during each month (only 3 month before promotion)
-- month 5 - 7
SELECT
  user_id,
  SUM(balance) FILTER (WHERE month = 5) AS month_5,
  SUM(balance) FILTER (WHERE month = 6) AS month_6,
  SUM(balance) FILTER (WHERE month = 7) AS month_7
FROM sa_bal
GROUP BY user_id
ORDER BY user_id

-------------------------------------------------
---------- Summary Query ------------------------
-------------------------------------------------

SELECT
  y_train.user_id,
  account_age.account_start_date,
  account_age.birth_year,
  account_age.gender,
  account_age.marital_status,
  account_age.individual_income_segment_code,
  account_age.family_income_segment_code,
  account_age.account_age,
  COALESCE(purchase.amount_a_before, 0) AS amount_a_before,
  COALESCE(purchase.amount_b_before, 0) AS amount_b_before,
  COALESCE(purchase.amount_a_after, 0) AS amount_a_after,
  COALESCE(purchase.amount_b_after, 0) AS amount_b_after,
  COALESCE(purchase.amount_of_a_and_b, 0) AS amount_of_a_and_b,
  COALESCE(advertise.amount_ads_before, 0) AS amount_ads_before,
  COALESCE(advertise.amount_ads_after, 0) AS amount_ads_after,
  saving.month_5,
  saving.month_6,
  saving.month_7,
  COALESCE(debit.cat1, 0) AS d_cat1,
  COALESCE(debit.cat2, 0) AS d_cat2,
  COALESCE(debit.cat3, 0) AS d_cat3,
  COALESCE(debit.cat4, 0) AS d_cat4,
  COALESCE(debit.cat5, 0) AS d_cat5,
  COALESCE(debit.cat6, 0) AS d_cat6,
  COALESCE(debit.cat7, 0) AS d_cat7,
  COALESCE(debit.cat8, 0) AS d_cat8,
  COALESCE(debit.cat9, 0) AS d_cat9,
  COALESCE(debit.cat10, 0) AS d_cat10,
  COALESCE(debit.cat11, 0) AS d_cat11,
  COALESCE(debit.cat12, 0) AS d_cat12,
  COALESCE(debit.cat13, 0) AS d_cat13,
  COALESCE(debit.cat14, 0) AS d_cat14,
  COALESCE(debit.cat15, 0) AS d_cat15,
  COALESCE(debit.cat16, 0) AS d_cat16,
  COALESCE(credit.cat1, 0) AS c_cat1,
  COALESCE(credit.cat2, 0) AS c_cat2,
  COALESCE(credit.cat3, 0) AS c_cat3,
  COALESCE(credit.cat4, 0) AS c_cat4,
  COALESCE(credit.cat5, 0) AS c_cat5,
  COALESCE(credit.cat6, 0) AS c_cat6,
  COALESCE(credit.cat7, 0) AS c_cat7,
  COALESCE(credit.cat8, 0) AS c_cat8,
  COALESCE(credit.cat9, 0) AS c_cat9,
  COALESCE(credit.cat10, 0) AS c_cat10,
  COALESCE(credit.cat11, 0) AS c_cat11,
  COALESCE(credit.cat12, 0) AS c_cat12,
  COALESCE(credit.cat13, 0) AS c_cat13,
  COALESCE(credit.cat14, 0) AS c_cat14,
  COALESCE(credit.cat15, 0) AS c_cat15,
  COALESCE(credit.cat16, 0) AS c_cat16,
  COALESCE(logins.screen_1_before, 0) AS screen_1_before,
  COALESCE(logins.screen_2_before, 0) AS screen_2_before,
  COALESCE(logins.screen_1_after, 0) AS screen_1_after,
  COALESCE(logins.screen_2_after, 0) AS screen_2_after,
  y_train.label
FROM y_train
LEFT JOIN (
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
                ) s
) AS account_age USING (user_id)
LEFT JOIN (
  SELECT
    user_id,
    COUNT(*) FILTER (WHERE product = 'A' AND '[2018-05-03, 2018-07-01]'::daterange @> dt) AS amount_a_before,
    COUNT(*) FILTER (WHERE product = 'B' AND '[2018-05-03, 2018-07-01]'::daterange @> dt) AS amount_b_before,
    COUNT(*) FILTER (WHERE product = 'A' AND '[2018-07-02, 2018-07-06]'::daterange @> dt) AS amount_a_after,
    COUNT(*) FILTER (WHERE product = 'B' AND '[2018-07-02, 2018-07-06]'::daterange @> dt) AS amount_b_after,
    COUNT(*) AS amount_of_a_and_b
  FROM purchase
  GROUP BY user_id
) AS purchase USING (user_id)
LEFT JOIN (
  SELECT
    user_id,
    COUNT(*) FILTER (WHERE '[2018-05-03, 2018-07-01]'::daterange @> dt) AS amount_ads_before,
    COUNT(*) FILTER (WHERE '[2018-07-02, 2018-07-06]'::daterange @> dt) AS amount_ads_after
  FROM ad_log
  GROUP BY user_id
) AS advertise USING (user_id)
LEFT JOIN (
  SELECT
    user_id,
    SUM(balance) FILTER (WHERE month = 5) AS month_5,
    SUM(balance) FILTER (WHERE month = 6) AS month_6,
    SUM(balance) FILTER (WHERE month = 7) AS month_7
  FROM sa_bal
  GROUP BY user_id
) AS saving USING (user_id)
LEFT JOIN (
  SELECT
    user_id,
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
  FROM dc_txn
  GROUP BY user_id
) AS debit USING (user_id)
LEFT JOIN (
  SELECT
    user_id,
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
  FROM cc_txn
  GROUP BY user_id
) AS credit USING (user_id)
LEFT JOIN (
  SELECT
    user_id,
    SUM(login_cnt) FILTER (WHERE screen = 'screen1' AND '[2018-05-03, 2018-07-01]'::daterange @> dt) AS screen_1_before,
    SUM(login_cnt) FILTER (WHERE screen = 'screen2' AND '[2018-05-03, 2018-07-01]'::daterange @> dt) AS screen_2_before,
    SUM(login_cnt) FILTER (WHERE screen = 'screen1' AND '[2018-07-02, 2018-07-06]'::daterange @> dt) AS screen_1_after,
    SUM(login_cnt) FILTER (WHERE screen = 'screen2' AND '[2018-07-02, 2018-07-06]'::daterange @> dt) AS screen_2_after
  FROM events
  GROUP BY user_id
) AS logins USING (user_id)
