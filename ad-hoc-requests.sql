SELECT p.product_name as List_of_products
FROM dim_products as p
LEFT JOIN fact_events as e
     ON p.product_code = e.product_code
WHERE e.base_price > 500 AND
      e.promo_type = 'BOGOF';       