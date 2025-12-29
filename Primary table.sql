
CREATE TABLE t_jana_vraspirova_project_SQL_primary_final AS
WITH primary_czechia_payroll AS (
    SELECT
        cp.payroll_year AS year_of_payroll,
        cpib."name" AS industry,
        AVG(cp.value) AS salary,
        cpu."name" AS salary_unit,
        cpvt."name" AS salary_specification
    FROM czechia_payroll AS cp
    LEFT JOIN czechia_payroll_calculation AS cpc
        ON cpc.code = cp.calculation_code
    LEFT JOIN czechia_payroll_industry_branch AS cpib
        ON cpib.code = cp.industry_branch_code
    LEFT JOIN czechia_payroll_unit AS cpu
        ON cpu.code = cp.unit_code
    LEFT JOIN czechia_payroll_value_type AS cpvt
        ON cpvt.code = cp.value_type_code
    WHERE cp.value_type_code = 5958
      AND cp.calculation_code = 100
    GROUP BY
        cp.payroll_year,
        cpib."name",
        cpu."name",
        cpvt."name"
    ORDER BY
        year_of_payroll ASC,
        industry
),
primary_czechia_price AS (
    SELECT
        date_part('year', cp.date_from) AS year_of_price,
        cpc."name" AS food_category_name,
        ROUND(AVG(cp.value::NUMERIC), 2) AS price_of_food,
        cpc.price_unit,
        cpc.price_value AS price_for_unit_value
    FROM czechia_price AS cp
    LEFT JOIN czechia_price_category AS cpc
        ON cpc.code = cp.category_code
    GROUP BY
        date_part('year', cp.date_from),
        cpc."name",
        cpc.price_unit,
        cpc.price_value
    ORDER BY
       year_of_price ASC,
        food_category_name ASC
)
SELECT
    *
FROM primary_czechia_payroll AS pcpa
LEFT JOIN primary_czechia_price AS pcpr
    ON pcpa.year_of_payroll = pcpr.year_of_price
WHERE pcpa.industry IS NOT NULL;

