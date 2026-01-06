CREATE TABLE t_jana_vraspirova_project_sql_secondary_final AS
SELECT
	e.YEAR,
	c.country,
	e.gdp,
	e.gini,
	e.population
FROM
	economies AS e
JOIN
	countries AS c ON e.country = c.country
WHERE
	c.continent = 'Europe'
	AND e.YEAR BETWEEN 2005 AND 2018
	AND e.gini IS NOT NULL
	AND e.gdp IS NOT NULL
ORDER BY 
	e.country,
	e.YEAR ASC;







