--Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?


WITH filtered_years AS (
    SELECT MIN(year_of_price) as first_yr, MAX(year_of_price) as last_yr
    FROM t_jana_vraspirova_project_SQL_primary_final
),
base_data AS (
    SELECT 
        year_of_price,
        food_category_name,
        price_unit,
        price_of_food,
        salary
    FROM t_jana_vraspirova_project_SQL_primary_final
    WHERE year_of_price IN (SELECT first_yr FROM filtered_years UNION SELECT last_yr FROM filtered_years)
      AND food_category_name IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
),
aggregated_stats AS (
    SELECT
        year_of_price,
        food_category_name,
        price_unit,
        AVG(price_of_food) AS avg_price_of_food,
        ROUND(AVG(salary)::NUMERIC) AS average_salary,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)::NUMERIC) AS median_salary
    FROM base_data
    GROUP BY year_of_price, food_category_name, price_unit
)
SELECT
    year_of_price,
    food_category_name,
    price_unit,
    avg_price_of_food,
    average_salary,
    ROUND(average_salary / avg_price_of_food::NUMERIC, 0) AS qty_per_avg_salary,
    median_salary,
    ROUND(median_salary / avg_price_of_food::NUMERIC, 0) AS qty_per_median_salary
FROM aggregated_stats
ORDER BY year_of_price ASC, food_category_name ASC;