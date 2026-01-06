---Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

WITH food_trends AS (
    SELECT 
        year_of_price,
        food_category_name,
        AVG(price_of_food) AS avg_price
    FROM t_jana_vraspirova_project_SQL_primary_final
    WHERE year_of_price IS NOT NULL AND price_of_food IS NOT NULL
    GROUP BY year_of_price, food_category_name
),
average_yearly_price_increase AS (
    SELECT
        year_of_price,
        ROUND(AVG((avg_price - prev_price) / prev_price * 100), 2) AS average_food_increase_pct
    FROM (
        SELECT 
            year_of_price,
            avg_price,
            LAG(avg_price) OVER (PARTITION BY food_category_name ORDER BY year_of_price) AS prev_price
        FROM food_trends
    ) AS food_lagged
    WHERE prev_price IS NOT NULL
    GROUP BY year_of_price
),
salary_trends AS (
       SELECT 
        year_of_payroll,
        industry,
        AVG(salary) AS avg_salary
    FROM t_jana_vraspirova_project_SQL_primary_final
    WHERE year_of_payroll IS NOT NULL AND salary IS NOT NULL
    GROUP BY year_of_payroll, industry
),
average_yearly_salary_increase AS (
    SELECT
        year_of_payroll,
        ROUND(AVG((avg_salary - prev_salary) / prev_salary * 100), 2) AS average_salary_increase_pct
    FROM (
        SELECT 
            year_of_payroll,
            avg_salary,
            LAG(avg_salary) OVER (PARTITION BY industry ORDER BY year_of_payroll) AS prev_salary
        FROM salary_trends
    ) AS salary_lagged
    WHERE prev_salary IS NOT NULL
    GROUP BY year_of_payroll
),
gdp_growth AS (
    SELECT 
        year,
        ROUND(((gdp - prev_gdp) / prev_gdp * 100)::NUMERIC, 2) AS yearly_gdp_growth_pct
    FROM (
        SELECT 
            year, gdp, 
            LAG(gdp) OVER (ORDER BY year) AS prev_gdp
        FROM t_jana_vraspirova_project_SQL_secondary_final 
        WHERE "country" = 'Czech Republic' AND gdp IS NOT NULL
    ) AS gdp_prev
    WHERE prev_gdp IS NOT NULL
),
combined_data AS (
    SELECT
        g.year,
        g.yearly_gdp_growth_pct,
        p.average_food_increase_pct,
        s.average_salary_increase_pct,
        LEAD(p.average_food_increase_pct) OVER (ORDER BY g.year) AS food_increase_next_year,
        LEAD(s.average_salary_increase_pct) OVER (ORDER BY g.year) AS salary_increase_next_year
    FROM gdp_growth AS g
    JOIN average_yearly_price_increase AS p ON g.year = p.year_of_price
    JOIN average_yearly_salary_increase AS s ON g.year = s.year_of_payroll
)
SELECT
    ROUND(CORR(yearly_gdp_growth_pct, average_food_increase_pct)::NUMERIC, 2) AS corr_gdp_food_this_year,
    ROUND(CORR(yearly_gdp_growth_pct, average_salary_increase_pct)::NUMERIC, 2) AS corr_gdp_salary_this_year,
    ROUND(CORR(yearly_gdp_growth_pct, food_increase_next_year)::NUMERIC, 2) AS corr_gdp_food_next_year,
    ROUND(CORR(yearly_gdp_growth_pct, salary_increase_next_year)::NUMERIC, 2) AS corr_gdp_salary_next_year
FROM combined_data;

