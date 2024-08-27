	#VIEWS 
		## 1.View for Most Challenging Circuits

CREATE OR REPLACE VIEW vw_most_challenging_circuits AS
SELECT CI.name,
       COUNT(CASE WHEN RE.statusId > 1 THEN 1 END) / COUNT(*) AS retirement_rate
FROM circuits CI
INNER JOIN races R ON CI.circuitId = R.circuitId
INNER JOIN results RE ON R.raceId = RE.raceId
GROUP BY CI.name
ORDER BY retirement_rate DESC;
		
        ## 2.View for Driver vs. Constructor Analysis

CREATE OR REPLACE VIEW vw_driver_vs_constructor AS
SELECT C.name AS constructor_name,
       D.firstname,
       D.surname,
       SUM(R.points) AS total_constructor_points
FROM drivers D
INNER JOIN results R ON D.driverId = R.driverId
INNER JOIN constructors C ON R.constructorId = C.constructorId
GROUP BY C.name, D.firstname, D.surname
HAVING SUM(R.points) > 0
ORDER BY C.name, total_constructor_points DESC;

		## 3.View for Fastest Lap Times by Season

CREATE OR REPLACE VIEW vw_fastest_lap_times_by_season AS
WITH FastestLaps AS (
    SELECT raceId, 
           MIN(time) AS fastest_lap_time
    FROM lap_times
    GROUP BY raceId
)
SELECT DISTINCT R.name AS race_name,
       R.year,
       D.firstname,
       D.surname,
       FL.fastest_lap_time
FROM FastestLaps FL
INNER JOIN lap_times LT ON FL.raceId = LT.raceId AND FL.fastest_lap_time = LT.time
INNER JOIN drivers D ON LT.driverId = D.driverId
INNER JOIN races R ON LT.raceId = R.raceId
ORDER BY R.year, FL.fastest_lap_time;

		## 4.View for Historical Performance Comparisons
	
CREATE OR REPLACE VIEW vw_legendary_driver_performance AS
SELECT DISTINCT D.firstname,
                D.surname,
                R.year,
                SUM(RE.points) AS total_points
FROM results RE
INNER JOIN drivers D ON RE.driverId = D.driverId
INNER JOIN races R ON RE.raceId = R.raceId
WHERE D.surname IN ('Hamilton', 'Schumacher', 'Verstappen', 'Vettel', 'Prost', 'Senna', 'Alonso', 'Mansell', 'Stewart', 'Lauda', 'Clark')
GROUP BY D.firstname, D.surname, R.year
HAVING total_points > 10
ORDER BY R.year, total_points DESC;


