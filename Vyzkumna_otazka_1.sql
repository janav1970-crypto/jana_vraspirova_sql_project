
--Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- Základní přehled

WITH salary_comparisons  AS (
	SELECT
    	papr.industry,
    	papr.year_of_payroll,
    	papr.salary,
    	LAG(papr.salary, 1) OVER (
        	PARTITION BY papr.industry
        	ORDER BY papr.year_of_payroll
    	) AS salary_previous_year,
    	CASE
       	 WHEN papr.salary > LAG(papr.salary, 1) OVER (PARTITION BY papr.industry ORDER BY papr.year_of_payroll) THEN 'Increase'
        	WHEN papr.salary < LAG(papr.salary, 1) OVER (PARTITION BY papr.industry ORDER BY papr.year_of_payroll) THEN 'Decrease'
        	ELSE 'Same / No Previous Data'
    	END AS year_over_year_salary_change
	FROM t_jana_vraspirova_project_SQL_primary_final AS papr)
SELECT 
	*
FROM salary_comparisons AS sc
WHERE sc.year_over_year_salary_change = 'Decrease'
ORDER BY 
sc. industry ASC, sc.year_of_payroll ASC
;

-- Které odvětví zažilo pokles mzdy nejčastěji

WITH salary_comparisons AS (
    SELECT
        papr.industry,
        papr.year_of_payroll,
        papr.salary,
        LAG(papr.salary, 1) OVER (
            PARTITION BY papr.industry
            ORDER BY papr.year_of_payroll
        ) AS salary_previous_year,
        CASE
            WHEN papr.salary > LAG(papr.salary, 1) OVER (PARTITION BY papr.industry ORDER BY papr.year_of_payroll) THEN 'Increase'
            WHEN papr.salary < LAG(papr.salary, 1) OVER (PARTITION BY papr.industry ORDER BY papr.year_of_payroll) THEN 'Decrease'
            ELSE 'Same / No Previous Data'
        END AS year_over_year_salary_change
    FROM t_jana_vraspirova_project_SQL_primary_final AS papr
)
SELECT 
    industry,
    COUNT(*) AS count_of_decreases
FROM salary_comparisons
WHERE year_over_year_salary_change = 'Decrease'
GROUP BY industry
ORDER BY count_of_decreases DESC
;

-- Které odvětví zažilo pokles mzdy v nejvíce následujících letech po sobě

WITH salary_comparisons AS (
    SELECT
        papr.industry,
        papr.year_of_payroll,
        CASE
            WHEN papr.salary < LAG(papr.salary) OVER (PARTITION BY papr.industry ORDER BY papr.year_of_payroll) THEN 1
            ELSE 0
        END AS is_decrease
    FROM t_jana_vraspirova_project_SQL_primary_final AS papr
),
consecutive_groups AS (
    SELECT
        industry,
        year_of_payroll,
        -- This logic creates a unique ID for each consecutive streak
        year_of_payroll - ROW_NUMBER() OVER (PARTITION BY industry ORDER BY year_of_payroll) AS streak_id
    FROM salary_comparisons
    WHERE is_decrease = 1
)
SELECT 
    industry,
    MIN(year_of_payroll) AS streak_start,
    MAX(year_of_payroll) AS streak_end,
    COUNT(*) + 1 AS years_affected, -- +1 because a decrease in 2021 implies a comparison to 2020
    COUNT(*) AS consecutive_decreases
FROM consecutive_groups
GROUP BY industry, streak_id
ORDER BY consecutive_decreases DESC;


