/*Pas 7*/ /*¡¡CAL REVISAR!!*/
DELIMITER $$

CREATE EVENT DuplicateTablesEvent
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-01-05 23:00:00'
ENDS '2025-12-28 23:00:00'
DO
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE tableName VARCHAR(255);
    DECLARE cur CURSOR FOR 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = DATABASE();
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO tableName;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET @query = CONCAT('CREATE TABLE ', tableName, '_', DATE_FORMAT(NOW(), '%Y%m%d'), ' LIKE ', tableName);
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET @query = CONCAT('INSERT INTO ', tableName, '_', DATE_FORMAT(NOW(), '%Y%m%d'), ' SELECT * FROM ', tableName);
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;