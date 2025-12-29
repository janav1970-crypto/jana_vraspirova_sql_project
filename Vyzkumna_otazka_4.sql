--Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

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
        average_yearly_price_increase_pct ASC -- ORDER BY is generally fine in a CTE, but only affects how the data is handled *within* the CTE.
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
)
SELECT
    p.year_of_price AS year,
    p.average_yearly_price_increase_pct AS average_food_price_increase_pct,
    s.avg_salary_increase_pct AS average_salary_increase_pct,
    round(p.average_yearly_price_increase_pct - s.avg_salary_increase_pct, 2) AS price_vs_salary_difference_pct
FROM
    average_yearly_price_increase AS p
INNER JOIN
    average_yearly_salary_increase AS s
    ON p.year_of_price = s.year_of_payroll
ORDER BY
    price_vs_salary_difference_pct DESC;