--Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

WITH price_of_food_comparisons AS (
    SELECT
        year_of_price,
        food_category_name,
        -- Aggregate first to ensure 1 price per category per year
        AVG(price_of_food) AS avg_price
    FROM t_jana_vraspirova_project_SQL_primary_final
    WHERE year_of_price IS NOT NULL AND price_of_food IS NOT NULL
    GROUP BY year_of_price, food_category_name
),
yearly_price_change AS (
    SELECT
        year_of_price,
        -- Compare this year's avg to last year's avg
        (avg_price - LAG(avg_price) OVER (PARTITION BY food_category_name ORDER BY year_of_price)) 
        / LAG(avg_price) OVER (PARTITION BY food_category_name ORDER BY year_of_price) * 100 AS yearly_price_difference_pct
    FROM price_of_food_comparisons
),
average_yearly_price_increase AS (
    SELECT
        year_of_price,
        ROUND(AVG(yearly_price_difference_pct)::NUMERIC, 2) AS average_yearly_price_increase_pct
    FROM yearly_price_change
    WHERE yearly_price_difference_pct IS NOT NULL
    GROUP BY year_of_price
),
price_of_salaries_comparisons AS (
    SELECT
        year_of_payroll,
        industry,
        -- Aggregate first to ensure 1 salary per industry per year
        AVG(salary) AS avg_salary
    FROM t_jana_vraspirova_project_SQL_primary_final
    WHERE year_of_payroll IS NOT NULL AND salary IS NOT NULL
    GROUP BY year_of_payroll, industry
),
yearly_salary_change AS (
    SELECT
        year_of_payroll,
        (avg_salary - LAG(avg_salary) OVER (PARTITION BY industry ORDER BY year_of_payroll)) 
        / LAG(avg_salary) OVER (PARTITION BY industry ORDER BY year_of_payroll) * 100 AS yearly_salary_difference_pct
    FROM price_of_salaries_comparisons
),
average_yearly_salary_increase AS (
    SELECT
        year_of_payroll,
        ROUND(AVG(yearly_salary_difference_pct)::NUMERIC, 2) AS avg_salary_increase_pct
    FROM yearly_salary_change
    WHERE yearly_salary_difference_pct IS NOT NULL
    GROUP BY year_of_payroll
)
SELECT
    p.year_of_price AS year,
    p.average_yearly_price_increase_pct AS average_food_price_increase_pct,
    s.avg_salary_increase_pct AS average_salary_increase_pct,
    ROUND((p.average_yearly_price_increase_pct - s.avg_salary_increase_pct)::NUMERIC, 2) AS price_vs_salary_difference_pct
FROM
    average_yearly_price_increase AS p
INNER JOIN
    average_yearly_salary_increase AS s
    ON p.year_of_price = s.year_of_payroll
ORDER BY
    price_vs_salary_difference_pct DESC;
