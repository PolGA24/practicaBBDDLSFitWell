/*Pas 2*/

/* CREACION DE TABLA activitats_net */
CREATE TABLE IF NOT EXISTS activitats_net (
    id_activitat INT NOT NULL,
    id_usuari INT NOT NULL,
    data_activitat DATE NOT NULL,
    hora_inici TIME NOT NULL,
    durada_minuts INT NOT NULL,
    tipus_activitat VARCHAR(50) NOT NULL,
    calories INT NOT NULL,
    dispositiu VARCHAR(20) NOT NULL,
    fin_de_semana BOOLEAN NOT NULL, /* CELDA BOOLEANA FIN DE SEMANA */
    PRIMARY KEY (id_activitat)
);

/* PROCEDEMIENTO PARA COPIAR LOS VALORES DE LA TABLA activitats_raw Y PEGARLO EN activitats_net ADEMAS DE LLENAR LA COLUMNA FIN DE SEMANA */
DELIMITER $$
DROP PROCEDURE IF EXISTS cargar_activitats_net$$
CREATE PROCEDURE cargar_activitats_net()
BEGIN    
    INSERT INTO activitats_net (id_usuari, data_activitat, hora_inici, durada_minuts, tipus_activitat, calories, dispositiu, fin_de_semana)
    SELECT id_usuari, data_activitat, hora_inici, durada_minuts, tipus_activitat, calories, dispositiu,
        CASE 
            WHEN DAYOFWEEK(data_activitat) IN (1, 7) THEN TRUE
            ELSE FALSE
        END AS fin_de_semana
    FROM activitats_raw WHERE DATE(data_activitat) = CURDATE() - INTERVAL 1 DAY;
END $$
DELIMITER ;

/* EVENTO QUE SE EJECUTA TODOS LOS DIAS A LAS 00:00 QUE LLAMA AL PROCEDIMIENTO mover */
DELIMITER $$
DROP EVENT IF EXISTS activitat_moved$$
CREATE EVENT activitat_moved
ON SCHEDULE EVERY 1 DAY STARTS '2024-10-01 00:00:00' DO
BEGIN
    CALL cargar_activitats_net();
END $$
DELIMITER ;
