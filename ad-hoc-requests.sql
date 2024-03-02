-- Extracting list of products where base price is greater than
-- 500 and that are fratured promo type of 'BOGOF'.

SELECT DISTINCT p.product_name as List_of_products
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

-- Derived a report that calculates incremental Sold Quantity (ISU%)
-- for each category during the Diwali Campaign and rankings for the
-- categories based on their ISU%.
    
WITH DiwaliCampaign AS (
    SELECT
        c.campaign_id,
        c.campaign_name,
        e.product_code,
        e.`quantity_sold(before_promo)`,
        e.`quantity_sold(after_promo)`,
        p.category
    FROM
        dim_campaigns c
    JOIN
        fact_events e ON c.campaign_id = e.campaign_id
    JOIN
        dim_products p ON e.product_code = p.product_code
    WHERE
        c.campaign_name = 'Diwali'
)

SELECT
    category,
    ROUND(SUM(ISU_percentage), 2) AS ISU_percentage,
    RANK() OVER (ORDER BY SUM(ISU_percentage) DESC) AS rank_order
FROM (
    SELECT
        category,
        100 * SUM(Diwali.`quantity_sold(after_promo)` - Diwali.`quantity_sold(before_promo)`) /
        SUM(Diwali.`quantity_sold(before_promo)`) AS ISU_percentage
    FROM
        DiwaliCampaign Diwali
    GROUP BY
        category
) AS ISU
GROUP BY
    category
ORDER BY
    rank_order;

-- Created a report that features top 5 products, ranked by incremental
-- revenue percentage (IR%) across all campaigns (Diwali and Sankranti).    

WITH Campaign AS (
    SELECT
        p.product_name,
        c.campaign_name,
        e.product_code,
        e.`quantity_sold(before_promo)`,
        e.`quantity_sold(after_promo)`,
        p.category,
        e.base_price
    FROM
        dim_campaigns c
    JOIN
        fact_events e ON c.campaign_id = e.campaign_id
    JOIN
        dim_products p ON e.product_code = p.product_code
    WHERE
        c.campaign_name IN ('Diwali', 'Sankranti')
)

SELECT
    product_name,
    category,
    ROUND(100 * SUM(base_price * (`quantity_sold(after_promo)` - `quantity_sold(before_promo)`)) / 
    SUM(base_price * `quantity_sold(before_promo)`), 2) AS ir_percentage
FROM
    Campaign
GROUP BY
    product_name, category
ORDER BY
    ir_percentage DESC
LIMIT 5;