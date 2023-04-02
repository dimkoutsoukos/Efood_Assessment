
-- creating CTE's to get the data needed

-- count the orders per city and per customer

WITH orders_per_city AS
(
  SELECT city, user_id, COUNT(*) AS orders
  FROM `main_assessment.orders`
  GROUP BY city, user_id

)

-- short the customers for each city, starting with those with the most orders, descending, and then assigning numbers to each customer, starting from 1
, top_per_city AS
(
  SELECT *, ROW_NUMBER() 
  OVER (PARTITION BY city 
  ORDER BY city, orders DESC) AS row_num
  FROM orders_per_city
)

-- selecting the top 10 customers for each city and then summing the number of orders they have made
, count_top AS
(
  SELECT city, SUM(orders) AS count_top
  FROM top_per_city
  WHERE row_num <= 10
  GROUP BY city
  
)

-- counting the total orders made in each city
, orders_by_city AS 
(
  SELECT city, COUNT(*) AS count_total
  FROM `main_assessment.orders`
  GROUP BY city
)


-- Using the main query to calculate the percentage of the orders that the top 10 customers have contributed to each city and sorting the results starting from the lowest percentage
-- Note that some cities have less than 10 customers, so the percentage is 1.0 (100%)
SELECT count_top.city, count_top.count_top/orders_by_city.count_total AS top_ten_perc
FROM count_top
LEFT JOIN orders_by_city ON orders_by_city.city = count_top.city
ORDER BY top_ten_perc
