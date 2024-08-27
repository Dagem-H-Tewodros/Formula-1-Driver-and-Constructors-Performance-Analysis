

-- Check if an index exists and create it if it doesn't
DELIMITER //
#Index Creation
CREATE PROCEDURE create_index_if_not_exists(
    IN table_name VARCHAR(64),
    IN index_name VARCHAR(64),
    IN index_definition VARCHAR(255)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = table_name AND INDEX_NAME = index_name
    ) THEN
        SET @query = CONCAT('CREATE INDEX ', index_name, ' ON ', table_name, '(', index_definition, ')');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END //

DELIMITER ;
