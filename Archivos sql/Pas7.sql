-- PAS 7

CREATE DATABASE IF NOT EXISTS lsfitwell_backup;

SET GLOBAL event_scheduler = ON;

DELIMITER $$
DROP EVENT IF EXISTS event_backup_setmanal$$
CREATE EVENT event_backup_setmanal
ON SCHEDULE
    EVERY 1 WEEK
    STARTS '2025-01-05 23:00:00'
    ENDS '2025-12-28 23:00:00'
DO
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE nom_taula VARCHAR(64);
    DECLARE nom_nou_taula VARCHAR(128);
    DECLARE sql_copia TEXT;
    DECLARE data_sufix VARCHAR(8);

    SET data_sufix = DATE_FORMAT(CURDATE(), '%Y%m%d');

    DECLARE cur CURSOR FOR
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'lsfitwell';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    bucle_taules: LOOP
        FETCH cur INTO nom_taula;
        IF done THEN
            LEAVE bucle_taules;
        END IF;

        SET nom_nou_taula = CONCAT(nom_taula, '_', data_sufix);

        SET sql_copia = CONCAT(
            'CREATE TABLE lsfitwell_backup.', nom_nou_taula,
            ' AS SELECT * FROM lsfitwell.', nom_taula
        );
        PREPARE stmt FROM sql_copia;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;
END$$
DELIMITER ;
