--Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

WITH price_of_food_comparisons AS (
    SELECT
        papr.year_of_price,
        papr.food_category_name,
        papr.price_of_food,
            LAG(papr.price_of_food, 1) OVER (
            PARTITION BY papr.food_category_name
            ORDER BY papr.year_of_price
        ) AS price_previous_year
    FROM t_jana_vraspirova_project_SQL_primary_final AS papr
    WHERE
        papr.year_of_price IS NOT NULL
        AND papr.food_category_name IS NOT NULL
        AND papr.price_of_food IS NOT NULL
    GROUP BY
        papr.year_of_price,
        papr.food_category_name,
        papr.price_of_food
)
, yearly_price_change AS (
    SELECT
        pc.food_category_name,
                round ((pc.price_of_food - pc.price_previous_year) / pc.price_previous_year * 100, 2) AS yearly_price_difference_pct
    FROM
        price_of_food_comparisons AS pc
    WHERE
        pc.price_previous_year IS NOT NULL 
)
SELECT
    ypc.food_category_name,
    round(AVG(ypc.yearly_price_difference_pct), 2) AS average_yearly_price_increase_pct
FROM
    yearly_price_change AS ypc
GROUP BY
    ypc.food_category_name
ORDER BY
    average_yearly_price_increase_pct ASC; 



