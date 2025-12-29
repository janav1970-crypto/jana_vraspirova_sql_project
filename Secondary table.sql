CREATE TABLE t_jana_vraspirova_project_SQL_secondary_final AS
SELECT
    e.year,
    e.gdp,
    c.currency_code AS gdp_currency
FROM
    economies AS e
LEFT JOIN
    countries AS c ON c.country = e.country
WHERE
    e.country = 'Czech Republic'
    AND e.year BETWEEN 2005 AND 2018
ORDER BY
    e.year ASC;

