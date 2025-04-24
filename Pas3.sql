/*Pas 3*/

/* Creació de la taula */
CREATE TABLE control_carguas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_fichero VARCHAR(255) NOT NULL,
    archivos_introducidos INT NOT NULL,
    data_carga DATETIME DEFAULT CURRENT_TIMESTAMP
);

/* Modificar el procedure de càrrega */
DELIMITER $$

CREATE PROCEDURE cargar_actividades_net(nombre_fichero VARCHAR(255))
BEGIN
    DECLARE num_files INT;

    -- Inserim les dades a activitats_net
    INSERT INTO actividades_net (
        id_usuario, data_actividades, hora_inicio, duracion_minutos,
        tipos_actividades, calorias, dispositivos, fin_de_semana
    )
    SELECT id_usuario, data_actividades, hora_inicio, duracion_minutos,
            tipos_actividades, calorias, dispositivos,
            CASE 
                WHEN DAYOFWEEK(fechaa_actividad) IN (1, 7) THEN TRUE
                ELSE FALSE
            END AS fin_de_semana
    FROM activitats_raw;

    -- Comptem les files afegides
    SET num_files = ROW_COUNT();

    -- Inserim el registre a la taula de control
    INSERT INTO control_cargas (nombre_ficher, archivos_introducidos)
    VALUES (nombre_archivos, num_files);
END $$

DELIMITER ;

/* Procedure per exportar la taula control_carregues a CSV */

DELIMITER $$

CREATE PROCEDURE exportar_control_carregues()
BEGIN
    SELECT * 
    INTO OUTFILE 'C:/xampp/mysql/data/control_carregues.csv'
    FIELDS TERMINATED BY ';'
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    FROM control_carregues;
END $$

DELIMITER ;