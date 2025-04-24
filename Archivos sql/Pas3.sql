/*Pas 3*/

/* Creació de la taula */
DROP TABLE IF EXISTS control_carregues;
CREATE TABLE control_carregues (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom_fitxer VARCHAR(255) NOT NULL,
    files_inserides INT NOT NULL,
    data_carrega DATETIME DEFAULT CURRENT_TIMESTAMP
);

/* Modificar el procedure de càrrega */
DELIMITER $$

DROP PROCEDURE IF EXISTS cargar_activitats_net$$
CREATE PROCEDURE cargar_activitats_net(nom_fitxer VARCHAR(255))
BEGIN
    DECLARE num_files INT;

    -- Inserir dades a activitats_net
    INSERT INTO activitats_net (
        id_usuari, data_activitat, hora_inici, durada_minuts,
        tipus_activitat, calories, dispositiu, fin_de_semana
    )
    SELECT id_usuari, data_activitat, hora_inici, durada_minuts,
           tipus_activitat, calories, dispositiu,
           CASE 
               WHEN DAYOFWEEK(data_activitat) IN (1, 7) THEN TRUE
               ELSE FALSE
           END
    FROM activitats_raw;

    -- Comptar files inserides
    SET num_files = ROW_COUNT();

    -- Actualitzar taula de control
    INSERT INTO control_carregues (nom_fitxer, files_inserides)
    VALUES (nom_fitxer, num_files);
END $$

DELIMITER ;


/* Procedure per exportar la taula control_carregues a CSV */
DELIMITER $$

DROP PROCEDURE IF EXISTS exportar_control_carregues$$
CREATE PROCEDURE exportar_control_carregues()
BEGIN
    SELECT * 
    INTO OUTFILE '/ruta/on/guardar/control_carregues.csv'
    FIELDS TERMINATED BY ';'
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    FROM control_carregues;
END $$

DELIMITER ;
