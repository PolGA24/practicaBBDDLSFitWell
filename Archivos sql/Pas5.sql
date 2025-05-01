/*Pas 5*/
/* Procedure que detecti i afegeixi nous registres no existents a MD_activitat*/

DELIMITER $$
DROP PROCEDURE IF EXISTS afegir_MD_activitat$$
CREATE PROCEDURE afegir_MD_activitat()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE activitat_nom VARCHAR(50);
    DECLARE activitat_descripcio VARCHAR(500);
    
    DECLARE cur CURSOR FOR SELECT tipus_activitat FROM activitats_net WHERE tipus_activitat NOT IN (SELECT tipus_activitat FROM MD_activitat);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO activitat_nom;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET activitat_descripcio = CONCAT('Descripció de ', activitat_nom);

        INSERT INTO MD_activitat (nom, descripcio) VALUES (activitat_nom, activitat_descripcio);
    END LOOP;