# DRIVERS STATS

	## DRIVERS WINS
    
    
SELECT 
    R.driverId, 
    D.full_name, 
    COUNT(R.constructorId) AS Race_win
FROM
    results R
        INNER JOIN
    drivers D ON R.driverId = D.driverId
WHERE
    position = 1
GROUP BY 
	R.driverId ,
    D.full_name;


	## PODIUM FINISHES
    
    
SELECT 
	R.driverId,
    D.full_name,
    COUNT(R.driverId) AS Race_win
FROM results R INNER JOIN drivers D ON R.driverId = D.driverId
WHERE position >= 1 AND position <=3
GROUP BY 
	R.driverId,
    D.full_name;


	## DRIVERS WIN RATE 
    
    
WITH CTE AS 
(
SELECT 
	R.driverId,
    D.full_name,
    COUNT(R.driverId) AS Race_win
FROM results R INNER JOIN drivers D ON R.driverId = D.driverId
WHERE position = 1
GROUP BY R.driverId,D.full_name
),
CTE1 AS 
(
SELECT 
	R.driverId,
    D.full_name, 
    COUNT(R.driverId) as Total_Race_Entered 
FROM results R INNER JOIN drivers D ON R.driverId = D.driverId
GROUP BY 
	R.driverId,
    D.full_name
)
SELECT CTE.driverId,CTE.full_name,CTE.Race_win,CTE1.Total_Race_Entered,CTE.Race_win/CTE1.Total_Race_Entered AS Win_rate
FROM CTE INNER JOIN CTE1 ON CTE.driverId = CTE1.driverId ;


	## CONSTRUCTORS BEST DRIVER 
    
    
WITH DriverWins AS (
    SELECT 
        C.name AS constructor_name,
        D.full_name AS driver_full_name,
        COUNT(R.position) AS win_count,
        ROW_NUMBER() OVER (PARTITION BY C.name ORDER BY COUNT(R.position) DESC) AS ranks
    FROM 
        drivers D 
    INNER JOIN 
        results R 
        ON D.driverId = R.driverId 
    INNER JOIN 
        constructors C 
        ON R.constructorId = C.constructorId
    WHERE 
        R.position = 1
    GROUP BY 
        C.name,
        D.full_name
)
SELECT 
    constructor_name,
    driver_full_name,
    win_count
FROM 
    DriverWins
WHERE 
    ranks = 1;
   
   
	## DRIVERS CHAMPIONSHIP
    
    
WITH DriverPoints AS (
    SELECT 
        S.year,
        D.full_name,
        C.name,
        SUM(T.points) AS total_season_point
    FROM 
        seasons S 
        INNER JOIN races R ON S.year = R.year 
        INNER JOIN results T ON R.raceId = T.raceId 
        INNER JOIN drivers D ON D.driverId = T.driverId 
        INNER JOIN constructors C ON T.constructorId = C.constructorId
    GROUP BY 
        S.year, 
        D.full_name,
        C.name
)
SELECT 
    DP.year,
    DP.full_name,
    DP.name,
    DP.total_season_point
FROM 
    DriverPoints DP
    INNER JOIN (
        SELECT 
            year, 
            MAX(total_season_point) AS max_points
        FROM 
            DriverPoints
        GROUP BY 
            year
    ) MP ON DP.year = MP.year AND DP.total_season_point = MP.max_points
ORDER BY 
    DP.year;
    
    
# CONSTRUCTORS STATS
	
    ## CONSTRUCTORS WINS
    
SELECT 
	R.constructorId,
    C.name,
    COUNT(R.constructorId) AS Race_win
FROM results R INNER JOIN constructors C ON R.constructorId = C.constructorId
WHERE position = 1
GROUP BY 
	constructorId;


	## PODIUM FINISHES
SELECT 
	R.constructorId,
    C.name,
    COUNT(R.constructorId) AS Race_win
FROM results R INNER JOIN constructors C ON R.constructorId = C.constructorId
WHERE position >= 1 AND position <=3
GROUP BY 
	constructorId;


	## CONSTRUCTORS WIN RATE 
WITH CTE AS 
(
SELECT 
	R.constructorId,
    C.name,
    COUNT(R.constructorId) AS Race_win
FROM results R INNER JOIN constructors C ON R.constructorId = C.constructorId
WHERE position = 1
GROUP BY 
	constructorId
),
CTE1 AS 
(
SELECT 
	R.constructorId,
    C.name, 
    COUNT(R.constructorId) as Total_Race_Entered 
FROM results R INNER JOIN constructors C ON R.constructorId = C.constructorId
GROUP BY 
	constructorId
)
SELECT 
	CTE.constructorId,
    CTE.name,
    CTE.Race_win,
    CTE1.Total_Race_Entered,
    CTE.Race_win/CTE1.Total_Race_Entered AS Win_rate
FROM CTE INNER JOIN CTE1 ON CTE.constructorId = CTE1.constructorId ;


	## CONSTRUCTORS BEST DRIVER 
WITH DriverWins AS (
    SELECT 
        C.name AS constructor_name,
        D.full_name AS driver_full_name,
        COUNT(R.position) AS win_count,
        ROW_NUMBER() OVER (PARTITION BY C.name ORDER BY COUNT(R.position) DESC) AS ranks
    FROM 
        drivers D 
    INNER JOIN 
        results R 
        ON D.driverId = R.driverId 
    INNER JOIN 
        constructors C 
        ON R.constructorId = C.constructorId
    WHERE 
        R.position = 1
    GROUP BY 
        C.name,
        D.full_name
)
SELECT 
    constructor_name,
    driver_full_name,
    win_count
FROM 
    DriverWins
WHERE 
    ranks = 1;
   
   
   
	## DRIVERS CHAMPIONSHIP
    
    
WITH DriverPoints AS (
    SELECT 
        S.year,
        D.full_name,
        C.name,
        SUM(T.points) AS total_season_point
    FROM 
        seasons S 
        INNER JOIN races R ON S.year = R.year 
        INNER JOIN results T ON R.raceId = T.raceId 
        INNER JOIN drivers D ON D.driverId = T.driverId 
        INNER JOIN constructors C ON T.constructorId = C.constructorId
    GROUP BY 
        S.year, D.full_name,C.name
)
SELECT 
    DP.year,
    DP.full_name,
    DP.name,
    DP.total_season_point
FROM 
    DriverPoints DP
    INNER JOIN (
        SELECT 
            year, 
            MAX(total_season_point) AS max_points
        FROM 
            DriverPoints
        GROUP BY 
            year
    ) MP ON DP.year = MP.year AND DP.total_season_point = MP.max_points
ORDER BY 
    DP.year;


	##CONSTRUCTORS CHAMPIONSHIP


WITH ConstructorPoints AS (
    SELECT 
        S.year, 
        C.name, 
        SUM(T.points) AS total_season_point
    FROM 
        seasons S 
        INNER JOIN races R ON S.year = R.year 
        INNER JOIN results T ON R.raceId = T.raceId 
        INNER JOIN drivers D ON D.driverId = T.driverId 
        INNER JOIN constructors C ON T.constructorId = C.constructorId
    WHERE 
        S.year >= 1958
    GROUP BY 
        S.year, 
        C.name
)
SELECT 
    CP.year, 
    CP.name, 
    CP.total_season_point
FROM 
    ConstructorPoints CP
WHERE 
    CP.total_season_point = (
        SELECT MAX(total_season_point)
        FROM ConstructorPoints CP2
        WHERE CP2.year = CP.year
    )
ORDER BY 
    CP.year;
    
    
 # Explatory Queries

	## Most Challenging Circuits (Based on Retirement Rate)
		-- This query identifies circuits with the highest retirement rates.
SELECT CI.name,
       COUNT(CASE WHEN RE.statusId > 1 THEN 1 END) / COUNT(*) AS retirement_rate
FROM circuits CI
INNER JOIN races R ON CI.circuitId = R.circuitId
INNER JOIN results RE ON R.raceId = RE.raceId
GROUP BY CI.name
ORDER BY retirement_rate DESC;

	## Driver vs. Constructor Analysis
		-- This query identifies drivers who contributed the most points to their constructors.
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

	## Fastest Lap Times by Season
		-- This query identifies the fastest lap times for each season.
WITH FastestLaps AS (
    SELECT raceId, 
           MIN(time) AS fastest_lap_time
    FROM lap_times
    GROUP BY raceId
)
SELECT DISTINCT(R.name) AS race_name,
       R.year,
       D.firstname,
       D.surname,
       FL.fastest_lap_time
FROM FastestLaps FL
INNER JOIN lap_times LT ON FL.raceId = LT.raceId AND FL.fastest_lap_time = LT.time
INNER JOIN drivers D ON LT.driverId = D.driverId
INNER JOIN races R ON LT.raceId = R.raceId
ORDER BY R.year, FL.fastest_lap_time;

	## Historical Performance Comparisons
		-- This query compares the performance of legendary drivers across different years.
SELECT DISTINCT(D.firstname),
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