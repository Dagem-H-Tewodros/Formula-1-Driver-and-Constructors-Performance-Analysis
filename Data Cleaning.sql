	# DATA CLEANING

-- Convert lap times from text to TIME datatype
UPDATE lap_times
SET time = STR_TO_DATE(time, '%i:%s.%f')
WHERE CHAR_LENGTH(time) <= 8;  -- Handles format 'M:SS.sss'

UPDATE lap_times
SET time = STR_TO_DATE(time, '%i:%s.%f')
WHERE CHAR_LENGTH(time) = 9;  -- Handles format 'H:MM:SS.sss'

UPDATE lap_times
SET time = STR_TO_DATE(time, '%H:%i:%s.%f')
WHERE CHAR_LENGTH(time) > 9;  -- Handles formats longer than 'H:MM:SS.sss'

-- Change the 'time' column to TIME datatype in lap_times table
ALTER TABLE lap_times 
CHANGE COLUMN `time` `time` TIME NULL DEFAULT NULL;

-- Convert pit stop durations from text to TIME datatype
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
END;

-- Change the 'duration' column to TIME datatype in pit_stops table
ALTER TABLE pit_stops 
CHANGE COLUMN `duration` `duration` TIME NULL DEFAULT NULL;

-- Standardize qualification times and convert from text to TIME datatype
UPDATE qualifying
SET q1 = CASE 
        WHEN LENGTH(q1) = 2 THEN '00:00.000' 
        ELSE q1 
    END;
UPDATE qualifying
SET q2 = CASE 
        WHEN LENGTH(q2) = 2 THEN '00:00.000' 
        ELSE q2 
    END;
UPDATE qualifying
SET q3 = CASE 
        WHEN LENGTH(q3) = 2 THEN '00:00.000' 
        ELSE q3 
    END;

UPDATE qualifying
SET q1 = STR_TO_DATE(q1, "%i:%s.%f")
WHERE LENGTH(q1) = 8 OR LENGTH(q1) = 9;

UPDATE qualifying    
SET q2 = STR_TO_DATE(q2, "%i:%s.%f")
WHERE LENGTH(q2) = 8 OR LENGTH(q2) = 9;

UPDATE qualifying
SET q3 = STR_TO_DATE(q3, "%i:%s.%f")
WHERE LENGTH(q3) = 8 OR LENGTH(q3) = 9;

-- Change the 'q1', 'q2', and 'q3' columns to TIME datatype in qualifying table
ALTER TABLE qualifying 
CHANGE COLUMN `q1` `Q1` TIME NULL DEFAULT NULL,
CHANGE COLUMN `q2` `Q2` TIME NULL DEFAULT NULL,
CHANGE COLUMN `q3` `Q3` TIME NULL DEFAULT NULL;

-- Convert race start times and dates from text to TIME and DATE datatypes
UPDATE races
SET date = STR_TO_DATE(date, "%Y/%m/%d");

UPDATE races 
SET time = CASE 
        WHEN LENGTH(time) = 2 THEN '00:00:00'
        ELSE time 
    END;

UPDATE races
SET time = STR_TO_DATE(time, "%H:%i:%s")
WHERE LENGTH(time) = 8 OR LENGTH(time) = 9;

-- Change the 'date' and 'time' columns to DATE and TIME datatypes in races table
ALTER TABLE races 
CHANGE COLUMN `date` `date` DATE NULL DEFAULT NULL,
CHANGE COLUMN `time` `time` TIME NULL DEFAULT NULL;

-- Convert fastest lap times from text to TIME datatype in results table
UPDATE results 
SET fastestLapTime = CASE 
        WHEN LENGTH(fastestLapTime) = 2 THEN '00:00.000'
        ELSE fastestLapTime 
    END;

UPDATE results
SET fastestLapTime = STR_TO_DATE(fastestLapTime, "%i:%s.%f")
WHERE LENGTH(fastestLapTime) = 8 OR LENGTH(fastestLapTime) = 9;

-- Change the 'fastestLapTime' column to TIME datatype in results table
ALTER TABLE results 
CHANGE COLUMN `fastestLapTime` `fastestLapTime` TIME NULL DEFAULT NULL;

-- Convert fastest lap times from text to TIME datatype in sprint_results table
UPDATE sprint_results 
SET fastestLapTime = CASE 
        WHEN LENGTH(fastestLapTime) = 2 THEN '00:00.000'
        ELSE fastestLapTime 
    END;

UPDATE sprint_results
SET fastestLapTime = STR_TO_DATE(fastestLapTime, "%i:%s.%f")
WHERE LENGTH(fastestLapTime) = 8 OR LENGTH(fastestLapTime) = 9;

-- Change the 'fastestLapTime' column to TIME datatype in sprint_results table
ALTER TABLE sprint_results 
CHANGE COLUMN `fastestLapTime` `fastestLapTime` TIME NULL DEFAULT NULL;
