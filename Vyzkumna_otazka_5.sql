--Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

WITH price_of_food_comparisons AS (
   SELECT
        papr.year_of_price,
        papr.price_of_food,
        LAG(papr.price_of_food, 1) OVER (
            PARTITION BY papr.food_category_name
            ORDER BY papr.year_of_price
        ) AS price_previous_year
    FROM t_jana_vraspirova_project_SQL_primary_final AS papr
    WHERE
        papr.year_of_price IS NOT NULL
        AND papr.price_of_food IS NOT NULL
    GROUP BY
        papr.year_of_price,
        papr.price_of_food,
        papr.food_category_name
)
, yearly_price_change AS (
   SELECT
        pc.year_of_price,
        round ((pc.price_of_food - pc.price_previous_year) / pc.price_previous_year * 100, 2) AS yearly_price_difference_pct
    FROM
        price_of_food_comparisons AS pc
    WHERE
        pc.price_previous_year IS NOT NULL
)
, average_yearly_price_increase AS (
    SELECT
        ypc.year_of_price,
        round(AVG(ypc.yearly_price_difference_pct), 2) AS average_yearly_price_increase_pct
    FROM
        yearly_price_change AS ypc
    GROUP BY
        ypc.year_of_price
    ORDER BY
        average_yearly_price_increase_pct ASC
)
, price_of_salaries_comparisons AS (
   SELECT
        papr.year_of_payroll,
        papr.industry,
        papr.salary,
        LAG(papr.salary, 1) OVER (
            PARTITION BY papr.industry
            ORDER BY papr.year_of_payroll
        ) AS salary_previous_year
    FROM t_jana_vraspirova_project_SQL_primary_final AS papr
    WHERE
           	papr.year_of_payroll IS NOT NULL
        AND papr.industry IS NOT NULL
        AND papr.salary IS NOT NULL
    GROUP BY
     	papr.year_of_payroll,
        papr.industry,
        papr.salary
)
, yearly_salary_change AS (
    SELECT
       ps.year_of_payroll,
       round ((ps.salary - ps.salary_previous_year) / ps.salary_previous_year * 100, 2) AS yearly_salary_difference_pct
    FROM
        price_of_salaries_comparisons AS ps
    WHERE
        ps.salary_previous_year IS NOT NULL
)
, average_yearly_salary_increase AS (
   	SELECT
        ysc.year_of_payroll,
        round(AVG(ysc.yearly_salary_difference_pct), 2) AS avg_salary_increase_pct
    FROM
        yearly_salary_change AS ysc
    GROUP BY
         ysc.year_of_payroll
),gdp_calculations AS (      
    SELECT
        gdp.*,
        LAG(gdp.gdp, 1) OVER (
            ORDER BY gdp.year
        ) AS gdp_previous_year
    FROM 
        t_jana_vraspirova_project_SQL_secondary_final AS gdp
),gdp_growth AS (
SELECT 
    gc.*,
       round(
        CAST(
            ((gc.gdp - gc.gdp_previous_year) / gc.gdp_previous_year) * 100 
        AS NUMERIC), 
    2) AS yearly_gdp_growth_pct
FROM 
    gdp_calculations AS gc
WHERE 
    gc.gdp_previous_year IS NOT NULL
    ), combined_tables AS (
SELECT
    p.year_of_price AS year,
    p.average_yearly_price_increase_pct AS average_food_price_increase_pct,
    s.avg_salary_increase_pct AS average_salary_increase_pct,
    gg.yearly_gdp_growth_pct AS yearly_gdp_growth_pct
FROM
    average_yearly_price_increase AS p
JOIN
    average_yearly_salary_increase AS s
    ON p.year_of_price = s.year_of_payroll
JOIN
	gdp_growth AS gg
	ON gg.YEAR =  p.year_of_price
 ), CorrelationData AS (
    SELECT
        ct.year,
        ct.yearly_gdp_growth_pct,
        ct.average_food_price_increase_pct AS food_price_increase_this_year,
        ct.average_salary_increase_pct AS salary_increase_this_year,
        LEAD(ct.average_food_price_increase_pct, 1) OVER (ORDER BY year) AS food_price_increase_next_year,
        LEAD(ct.average_salary_increase_pct, 1) OVER (ORDER BY year) AS salary_increase_next_year
    FROM combined_tables AS ct
)
SELECT
    ROUND(CORR(cd.yearly_gdp_growth_pct, cd.food_price_increase_this_year)::NUMERIC, 2) AS corr_gdp_food_this_year,
    ROUND(CORR(cd.yearly_gdp_growth_pct, cd.salary_increase_this_year)::NUMERIC, 2) AS corr_gdp_salary_this_year,
    ROUND(CORR(cd.yearly_gdp_growth_pct, cd.food_price_increase_next_year)::NUMERIC, 2) AS corr_gdp_food_next_year,
    ROUND(CORR(cd.yearly_gdp_growth_pct, cd.salary_increase_next_year)::NUMERIC, 2) AS corr_gdp_salary_next_year
FROM CorrelationData AS cd;
   
