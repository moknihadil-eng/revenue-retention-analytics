-- Cumulative repeat purchase within H elapsed days of first observed order.
-- Entire monthly cohort must be mature, including its last calendar day.
WITH firsts AS (
 SELECT customer_id, min(order_date) AS first_date FROM orders GROUP BY customer_id
), outcomes AS (
 SELECT f.customer_id, f.first_date, CAST(date_trunc('month', f.first_date) AS DATE) AS cohort,
 h.days, max(CASE WHEN o.order_number>=2 AND o.order_date<=f.first_date+h.days*INTERVAL '1 day' THEN 1 ELSE 0 END) AS returned
 FROM firsts f CROSS JOIN (VALUES (30),(60),(90)) h(days)
 JOIN orders o USING(customer_id)
 WHERE last_day(f.first_date)+h.days*INTERVAL '1 day' < (SELECT observation_end FROM settings)
 GROUP BY f.customer_id, f.first_date, cohort, h.days
)
SELECT cohort, days, count(*) AS customers, sum(returned) AS returning_customers,
 100.0*avg(returned) AS retention_pct
FROM outcomes GROUP BY cohort, days ORDER BY cohort, days;
