/*Pas 2*/
CREATE TABLE IF NOT EXISTS activitats_net (
    id_activitat INT NOT NULL,
    id_usuari INT NOT NULL,
    data_activitat DATE NOT NULL,
    hora_inici TIME NOT NULL,
    durada_minuts INT NOT NULL,
    tipus_activitat VARCHAR(50) NOT NULL,
    calories INT NOT NULL,
    dispositiu VARCHAR(20) NOT NULL,
    fin_de_semana BOOLEAN NOT NULL,
    PRIMARY KEY (id_activitat)
);

DELIMITER $$

DROP PROCEDURE IF EXISTS mover$$
CREATE PROCEDURE mover()
BEGIN    
    INSERT INTO activitats_net (
        id_activitat, id_usuari, data_activitat, hora_inici, durada_minuts, tipus_activitat, calories, dispositiu, fin_de_semana
    )
    SELECT id_activitat, id_usuari, data_activitat, hora_inici, durada_minuts, tipus_activitat, calories, dispositiu,
        CASE 
            WHEN DAYOFWEEK(data_activitat) IN (1, 7) THEN TRUE
            ELSE FALSE
        END AS fin_de_semana
    FROM activitats_raw;
END $$

DELIMITER ;