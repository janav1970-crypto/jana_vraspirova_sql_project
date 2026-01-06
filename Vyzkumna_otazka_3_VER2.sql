--Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

WITH yearly_averages AS (
    SELECT
        year_of_price,
        food_category_name,
        AVG(price_of_food) AS avg_annual_price
    FROM t_jana_vraspirova_project_SQL_primary_final
    WHERE year_of_price IS NOT NULL 
      AND food_category_name IS NOT NULL
      AND price_of_food IS NOT NULL
    GROUP BY year_of_price, food_category_name
),
price_changes AS (
    SELECT
        food_category_name,
        avg_annual_price,
        LAG(avg_annual_price) OVER (
            PARTITION BY food_category_name 
            ORDER BY year_of_price
        ) AS prev_year_price
    FROM yearly_averages
)
SELECT
    food_category_name,
    ROUND(
        AVG((avg_annual_price - prev_year_price) / prev_year_price * 100)::NUMERIC, 
        2
    ) AS average_yearly_price_increase_pct
FROM price_changes
WHERE prev_year_price IS NOT NULL
GROUP BY food_category_name
ORDER BY average_yearly_price_increase_pct ASC;