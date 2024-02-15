-- Extracting list of products where base price is less than
-- 500 and that are fratured promo type of 'BOGOF'.

SELECT p.product_name as List_of_products
FROM dim_products as p
LEFT JOIN fact_events as e
     ON p.product_code = e.product_code
WHERE e.base_price > 500 AND
      e.promo_type = 'BOGOF';
      
-- Extracting the total number of stores in each city where
-- city are in descending prder of store count.

SELECT city,
       COUNT(store_id) as stores
FROM dim_stores
GROUP BY city
ORDER BY stores desc;

-- Generated a report that displays campaign along with the
-- total revenue before and after the promotion.
SELECT
    c.campaign_name,
    SUM(e.base_price * e.`quantity_sold(before_promo)`) / 1000000 AS total_revenue_before_promo,
    SUM(e.base_price * e.`quantity_sold(after_promo)`) / 1000000 AS total_revenue_after_promo
FROM
    dim_campaigns c
JOIN
    fact_events e ON c.campaign_id = e.campaign_id
GROUP BY
    c.campaign_name;