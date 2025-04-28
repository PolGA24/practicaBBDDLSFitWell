/*Pas 5*/
/* Procedure que detecti i afegeixi nous registres no existents a MD_activitat*/

DELIMITER $$
DROP PROCEDURE IF EXISTS insertar_noves_activitats$$
CREATE PROCEDURE insertar_noves_activitats()
BEGIN
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE v_id_activitat INT(11);
    DECLARE v_nom VARCHAR(50);
    DECLARE v_descripcio VARCHAR(500);
    DECLARE c_activitats CURSOR FOR SELECT id_activitat, nom, descripcio FROM md_activitat;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN c_activitats;
    activitats_loop: LOOP
        FETCH c_activitats INTO v_id_activitat, v_nom, v_descripcio;
        IF done THEN
            LEAVE activitats_loop;
        END IF;

        IF v_nom IS NULL OR v_nom = '' THEN
            SET v_nom = 'activitat desconeguda';
        END IF;

        IF v_descripcio IS NULL OR v_descripcio = '' THEN
            SET v_descripcio = 'sense descripció';
        END IF;

        SET v_nom = LOWER(v_nom);

        IF NOT EXISTS (SELECT 1 FROM MD_activitat WHERE id_activitat = v_id_activitat) THEN
            INSERT INTO MD_activitat (id_activitat, nom, descripcio)
            VALUES (v_id_activitat, v_nom, v_descripcio);
        END IF;

    END LOOP activitats_loop;
    CLOSE c_activitats;
END$$
DELIMITER ;
