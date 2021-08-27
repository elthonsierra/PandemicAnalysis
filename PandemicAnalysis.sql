USE PandemicAnalysis;

--Looking the total cases vs population
--Shows countries with the higest death count compared to population

SELECT location, MAX(total_cases) AS HighestCasesNumbers, MAX((total_deaths/population))*100 AS DeathsPerPopulation
FROM PandemicAnalysis..Infections
WHERE continent IS NOT null
GROUP BY location
ORDER BY HighestCasesNumbers DESC;

--Showing the continents with highest death counts

SELECT location, MAX(total_cases) AS HighestCasesNumbers
FROM PandemicAnalysis..Infections
WHERE continent IS null
GROUP BY location
ORDER BY HighestCasesNumbers DESC;

--What is the total cases, total deaths and total percent of deaths in the World?

SELECT SUM(new_cases) AS "TotalCases", SUM(new_deaths) AS "TotalDeaths", (SUM(new_deaths)/Sum(new_cases))*100 AS "DeathPercent"
FROM PandemicAnalysis..Infections
WHERE continent IS NOT null;

--Let's see what we got in the Vaccination Table

SELECT * FROM PandemicAnalysis..Vaccinations;

-- What's the percent of population vaccinated by country?

SELECT location, population, MAX(total_vaccinations) AS "TotalVaccinations", MAX((new_vaccinations/population))*100 AS "%ofPopulationVaccinated"
FROM PandemicAnalysis..Vaccinations
GROUP BY location, population
ORDER BY "%ofPopulationVaccinated" DESC;

--What's the trend in Population Vaccinated over time for each country?

SELECT 
	location, date, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS "RollingPopulationVaccinated"
		FROM 
		PandemicAnalysis..Vaccinations
	WHERE
		continent IS NOT NULL
	ORDER BY
		location, date
	;

--What's the trend in the Percent of Population Vaccinated over time for each country?
--For this query I'll need to use a CTE.
--A CTE is a temporary named result set. It means Common Table Expression.
--When a CTE include references to itself it is called Recursive CTE.

WITH RollingPopVaccinated (location, date, population, new_vaccinations, RollingPopulationVaccinated)
AS
(
SELECT 
	location, date,population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS "RollingPopulationVaccinated"
		FROM 
		PandemicAnalysis..Vaccinations
	WHERE
		continent IS NOT NULL
)
SELECT 
	*, (RollingPopulationVaccinated/Population)*100 AS "%RollingPopVaccinated"
	FROM 
	RollingPopVaccinated
ORDER BY location, date
;

--Now let's CREATE A TEMP TABLE with the data above

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent VARCHAR (255),
Location VARCHAR (255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPopulationVaccinated NUMERIC
)

INSERT INTO PercentPopulationVaccinated
SELECT 
	Continent, Location, Date, Population, New_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS "RollingPopulationVaccinated"
		FROM 
		PandemicAnalysis..Vaccinations
	WHERE
		continent IS NOT NULL

SELECT 
	*, (RollingPopulationVaccinated/Population)*100 AS "%RollingPopVaccinated"
	FROM 
	PercentPopulationVaccinated
ORDER BY location, date
;

--Let's now create views for data visualization in the next phase.

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	Continent, Location, Date, Population, New_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS "RollingPopulationVaccinated"
		FROM 
		PandemicAnalysis..Vaccinations
	WHERE
		continent IS NOT NULL;

--Let's have a look into the View
SELECT
	*
	FROM
		PercentPopulationVaccinated;

--Quick template for Change the field type
ALTER TABLE PandemicAnalysis..Vaccinations
ALTER COLUMN new_vaccinations FLOAT;



