#Functions
	##1. Function to Calculate Retirement Rate

DELIMITER //

CREATE FUNCTION fn_retirement_rate(circuit_id INT) 
RETURNS DECIMAL(5, 2)
BEGIN
    DECLARE retirement_rate DECIMAL(5, 2);
    
    SELECT COUNT(CASE WHEN RE.statusId > 1 THEN 1 END) / COUNT(*)
    INTO retirement_rate
    FROM circuits CI
    INNER JOIN races R ON CI.circuitId = R.circuitId
    INNER JOIN results RE ON R.raceId = RE.raceId
    WHERE CI.circuitId = circuit_id;

    RETURN retirement_rate;
END //

DELIMITER ;

	##2. Function to Get Fastest Lap Time by Season

DELIMITER //

CREATE FUNCTION fn_fastest_lap_time_by_season(race_id INT) 
RETURNS TIME
BEGIN
    DECLARE fastest_lap_time TIME;
    
    SELECT MIN(time)
    INTO fastest_lap_time
    FROM lap_times
    WHERE raceId = race_id;

    RETURN fastest_lap_time;
END //

DELIMITER ;

