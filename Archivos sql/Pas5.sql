/*Pas 5*/
/* Procedure que detecti i afegeixi nous registres no existents a MD_activitat*/
DELIMITER $$
DROP PROCEDURE IF EXISTS afegir_registres$$
CREATE PROCEDURE afegir_registres(
    IN vid_activitat INT,
    IN vnom_activitat VARCHAR(50)
)

BEGIN
    DECLARE vexisteix INT DEFAULT 0;

    SELECT COUNT(*) INTO vexisteix
    FROM MD_activitat
    WHERE id_activitat = vid_activitat;

    IF vexisteix = 0 THEN
        INSERT INTO MD_activitat (id_activitat, nom, descripcio)
        VALUES (vid_activitat, LOWER(vnom_activitat), CONCAT('Descripcio de ', LOWER(vnom_activitat)));
    END IF;
    
END $$
DELIMITER ;


DELIMITER $$
DROP TRIGGER IF EXISTS trg_afegir_registres$$
CREATE TRIGGER trg_afegir_registres
AFTER INSERT ON activitats_net
FOR EACH ROW

BEGIN
    CALL afegir_registres(NEW.id_activitat, NEW.tipus_activitat);
END $$
DELIMITER ;
