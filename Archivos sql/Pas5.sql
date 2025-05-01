/*Pas 5*/
/* Procedure que detecti i afegeixi nous registres no existents a MD_activitat*/

DELIMITER $$
DROP PROCEDURE IF EXISTS afegir_MD_activitat$$
CREATE PROCEDURE afegir_MD_activitat()
BEGIN

    DECLARE done INT DEFAULT FALSE;
    DECLARE activitat_nom VARCHAR(50);
    DECLARE activitat_descripcio VARCHAR(500);

    -- Cursor per obtenir activitats úniques no existents al catàleg, netejades
    DECLARE cur CURSOR FOR
        SELECT DISTINCT
            LOWER(COALESCE(NULLIF(tipus_activitat, ''), 'activitat_desconeguda'))
        FROM activitats_raw
        WHERE LOWER(COALESCE(NULLIF(tipus_activitat, ''), 'activitat_desconeguda')) 
              NOT IN (SELECT nom FROM MD_activitat);

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    loop_activitats: LOOP
        FETCH cur INTO activitat_nom;
        IF done THEN
            LEAVE loop_activitats;
        END IF;

        SET activitat_descripcio = CONCAT('Descripcio per defecte de: ', activitat_nom);

        INSERT INTO MD_activitat (nom, descripcio)
        VALUES (activitat_nom, activitat_descripcio);
    END LOOP;

    CLOSE cur;
END $$
DELIMITER ;
