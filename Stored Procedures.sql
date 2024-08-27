#Stored Procedures
	## 1.Procedure to Update Lap Times
    
DELIMITER //

CREATE PROCEDURE sp_update_lap_times()
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred during lap time update' AS Error;
    END;

    CALL create_index_if_not_exists('lap_times', 'idx_lap_times_time', 'time');

    UPDATE lap_times
    SET time = CASE
        WHEN CHAR_LENGTH(time) <= 8 THEN STR_TO_DATE(time, '%i:%s.%f')
        WHEN CHAR_LENGTH(time) = 9 THEN STR_TO_DATE(time, '%i:%s.%f')
        ELSE STR_TO_DATE(time, '%H:%i:%s.%f')
    END
    WHERE time IS NOT NULL AND time != '';

    ALTER TABLE `f1_analysis`.`lap_times`
    CHANGE COLUMN `time` `time` TIME NULL DEFAULT NULL;
END //

DELIMITER ;

	## 2.Procedure to Update Pit Stop Durations

DELIMITER //

CREATE PROCEDURE sp_update_pit_stop_durations()
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred during pit stop duration update' AS Error;
    END;

    CALL create_index_if_not_exists('pit_stops', 'idx_pit_stops_duration', 'duration');

    UPDATE pit_stops
    SET duration = CASE
        WHEN duration LIKE '%.%' THEN
            SEC_TO_TIME(FLOOR(duration)) + INTERVAL MOD(FLOOR(duration * 1000), 1000) MICROSECOND
        WHEN duration LIKE '%:%:%' THEN
            SEC_TO_TIME(SUBSTRING_INDEX(duration, ':', 1) * 60
            + SUBSTRING_INDEX(SUBSTRING_INDEX(duration, ':', -2), ':', 1)
            + SUBSTRING_INDEX(duration, ':', -1) / 1000)
            + INTERVAL MOD(SUBSTRING_INDEX(duration, ':', -1) * 1000, 1000) MICROSECOND
        ELSE NULL
    END
    WHERE duration IS NOT NULL AND duration != '';

    ALTER TABLE `f1_analysis`.`pit_stops`
    CHANGE COLUMN `duration` `duration` TIME NULL DEFAULT NULL;
END //

DELIMITER ;

	## 3.Procedure to Update Qualifying Times

DELIMITER //

CREATE PROCEDURE sp_update_qualifying_times()
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred during qualifying times update' AS Error;
    END;

    CALL create_index_if_not_exists('qualifying', 'idx_qualifying_q1', 'q1');
    CALL create_index_if_not_exists('qualifying', 'idx_qualifying_q2', 'q2');
    CALL create_index_if_not_exists('qualifying', 'idx_qualifying_q3', 'q3');

    UPDATE qualifying
    SET q1 = CASE WHEN LENGTH(q1) = 2 THEN '00:00.000' ELSE q1 END,
        q2 = CASE WHEN LENGTH(q2) = 2 THEN '00:00.000' ELSE q2 END,
        q3 = CASE WHEN LENGTH(q3) = 2 THEN '00:00.000' ELSE q3 END;

    UPDATE qualifying
    SET q1 = CASE
        WHEN LENGTH(q1) = 8 THEN STR_TO_DATE(q1, '%i:%s.%f')
        WHEN LENGTH(q1) = 9 THEN STR_TO_DATE(q1, '%i:%s.%f')
        ELSE STR_TO_DATE('00:00.000', '%i:%s.%f')
    END,
    q2 = CASE
        WHEN LENGTH(q2) = 8 THEN STR_TO_DATE(q2, '%i:%s.%f')
        WHEN LENGTH(q2) = 9 THEN STR_TO_DATE(q2, '%i:%s.%f')
        ELSE STR_TO_DATE('00:00.000', '%i:%s.%f')
    END,
    q3 = CASE
        WHEN LENGTH(q3) = 8 THEN STR_TO_DATE(q3, '%i:%s.%f')
        WHEN LENGTH(q3) = 9 THEN STR_TO_DATE(q3, '%i:%s.%f')
        ELSE STR_TO_DATE('00:00.000', '%i:%s.%f')
    END
    WHERE q1 IS NOT NULL AND q1 != '' AND q2 IS NOT NULL AND q2 != '' AND q3 IS NOT NULL AND q3 != '';

    ALTER TABLE `f1_analysis`.`qualifying`
    CHANGE COLUMN `q1` `q1` TIME NULL DEFAULT NULL,
    CHANGE COLUMN `q2` `q2` TIME NULL DEFAULT NULL,
    CHANGE COLUMN `q3` `q3` TIME NULL DEFAULT NULL;
END //

DELIMITER ;
