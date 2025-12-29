--Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?


WITH time_bounds AS (
    -- Calculate the first and last year once to avoid repeating subqueries
    SELECT 
        MIN(year_of_price) AS first_year, 
        MAX(year_of_price) AS last_year 
    FROM t_jana_vraspirova_project_SQL_primary_final
),
salary_food_stats AS (
    SELECT
        cpap.year_of_price,
        cpap.food_category_name,
        cpap.price_unit,
        -- We aggregate the price just in case there are multiple records per year/category
        AVG(cpap.price_of_food) AS avg_price_of_food,
        -- Calculating both average and median salary
        ROUND(AVG(cpap.salary)::NUMERIC) AS average_salary,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cpap.salary)::NUMERIC) AS median_salary
    FROM
        t_jana_vraspirova_project_SQL_primary_final AS cpap
    JOIN time_bounds tb ON cpap.year_of_price = tb.first_year OR cpap.year_of_price = tb.last_year
    WHERE
        cpap.food_category_name IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
    GROUP BY
        cpap.year_of_price,
        cpap.food_category_name,
        cpap.price_unit
)
SELECT
    year_of_price,
    food_category_name,
    price_unit,
    avg_price_of_food,
    -- Purchasing power for Average Salary
    average_salary,
    ROUND(average_salary / avg_price_of_food::NUMERIC, 0) AS qty_per_avg_salary,
    -- Purchasing power for Median Salary
    median_salary,
    ROUND(median_salary / avg_price_of_food::NUMERIC, 0) AS qty_per_median_salary
FROM
    salary_food_stats
ORDER BY
    year_of_price ASC,
    food_category_name ASC;