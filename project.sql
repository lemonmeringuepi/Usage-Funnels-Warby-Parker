--1 explore df
SELECT *
FROM survey
LIMIT 10;

--2 check user response rate per question
SELECT question,
  COUNT(*) AS 'responses'
FROM SURVEY
GROUP BY 1
ORDER BY 1;

--3 calculate user retention rate per question on survey
SELECT 100.0 AS 'q1',
  ROUND(475.0/500 * 100, 1) AS 'q2',
  ROUND(380.0/475 * 100, 1) AS 'q3',
  ROUND(361.0/380 * 100, 1) AS 'q4',
  ROUND(270.0/361 * 100, 1) AS 'q5';

--4 explore dfs
SELECT *
FROM quiz
LIMIT 5;

SELECT *
FROM home_try_on
LIMIT 5;

SELECT *
FROM purchase
LIMIT 5;

--5, 6
--Model user funnel
WITH funnel AS (
  SELECT q.user_id,
    h.user_id IS NOT NULL AS 'is_home_try_on',
    h.number_of_pairs,
    p.user_id IS NOT NULL AS 'is_purchase'
  FROM quiz AS q
  LEFT JOIN home_try_on AS h
    ON q.user_id = h.user_id
  LEFT JOIN purchase AS p
    ON q.user_id = p.user_id
  )
SELECT COUNT(*) AS 'quiz',
  100.0 AS 'pct_quiz',
  SUM(is_home_try_on) AS 'home_try_on',
  ROUND(100.0 * SUM(is_home_try_on) / COUNT(*), 1) AS 'pct_home_try_on',
  SUM(is_purchase) AS 'purchase',
  ROUND(100.0 * SUM(is_purchase) / SUM(is_home_try_on), 1)  AS 'pct_purchase'
FROM funnel;

--Compare A-B test
WITH funnel AS (
  SELECT h.user_id,
    h.number_of_pairs,
    p.user_id IS NOT NULL AS 'is_purchase',
    p.price
  FROM home_try_on AS h
  LEFT JOIN purchase AS p
    ON h.user_id = p.user_id
  )
SELECT number_of_pairs,
  COUNT(*) AS 'participants',
  SUM(is_purchase) AS 'purchase',
  ROUND(AVG(price), 2) AS 'avg_spendings'
FROM funnel
GROUP BY 1;

--breakdown by style (gender)
WITH funnel AS (
  SELECT q.user_id,
    q.style,
    h.user_id IS NOT NULL AS 'is_home_try_on',
    h.number_of_pairs,
    p.user_id IS NOT NULL AS 'is_purchase',
    p.price
  FROM quiz AS q
  LEFT JOIN home_try_on AS h
    ON q.user_id = h.user_id
  LEFT JOIN purchase AS p
    ON q.user_id = p.user_id
  )
SELECT number_of_pairs,
  style,
  SUM(is_home_try_on) AS 'participants',
  SUM(is_purchase) AS 'purchase',
  ROUND(100.0 * SUM(is_purchase) / SUM(is_home_try_on), 2) AS 'pct_purchase',
  ROUND(AVG(price), 2) AS 'avg_spending'
FROM funnel
GROUP BY 1, 2;

-- check for most/least common survey responses
SELECT question,
  response,
  COUNT(*)
FROM survey
GROUP BY 1, 2
ORDER BY 1, 3;