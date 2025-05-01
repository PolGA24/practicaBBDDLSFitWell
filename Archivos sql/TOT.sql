/*Pas 1*/
CREATE DATABASE IF NOT EXISTS lsfitwell;
USE lsfitwell;

CREATE TABLE IF NOT EXISTS activitats_raw (
    id_activitat INT NOT NULL AUTO_INCREMENT,
    id_usuari INT NOT NULL,
    data_activitat DATE NOT NULL,
    hora_inici TIME NOT NULL,
    durada_minuts INT NOT NULL,
    tipus_activitat VARCHAR(50) NOT NULL,
    calories INT NOT NULL,
    dispositiu VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_activitat)
);

LOAD DATA INFILE 'C:/Users/Xavier Fornes Bort/Documents/GitHub/practicaBBDDLSFitWell/Archivos csv/ListaActividades.csv'
INTO TABLE activitats_raw
FIELDS TERMINATED BY ';'
Lines TERMINATED BY '\n'
IGNORE 1 LINES
(id_usuari, data_activitat, hora_inici, durada_minuts, tipus_activitat, calories, dispositiu);


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
CREATE PROCEDURE cargar_activitats_net()
BEGIN
    DECLARE num_files INT;
    DECLARE nom_fitxer VARCHAR(255);

    INSERT INTO activitats_net (id_usuari, data_activitat, hora_inici, durada_minuts, tipus_activitat, calories, dispositiu, fin_de_semana)
    SELECT id_usuari, data_activitat, hora_inici, durada_minuts, tipus_activitat, calories, dispositiu,
        CASE 
            WHEN DAYOFWEEK(data_activitat) IN (1, 7) THEN TRUE
            ELSE FALSE
        END
    FROM activitats_raw;

    SET num_files = ROW_COUNT();
    SET nom_fitxer = CONCAT('activitats_raw_', DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s'), '.csv');

    INSERT INTO control_carregues (nom_fitxer, files_inserides) VALUES (nom_fitxer, num_files);
END $$
DELIMITER ;

/* Procedure per exportar la taula control_carregues a CSV */
DELIMITER $$
DROP PROCEDURE IF EXISTS exportar_control_carregues$$
CREATE PROCEDURE exportar_control_carregues()
BEGIN
    SELECT * INTO OUTFILE 'C:/Users/Xavier Fornes Bort/Documents/GitHub/practicaBBDDLSFitWell/Archivos csv/control_carregues.csv'
    FIELDS TERMINATED BY ';'
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    FROM control_carregues;
END $$
DELIMITER ;


-- PAS 4: Catàleg d’activitats i clau forana a activitats_net

USE lsfitwell;

-- 1. Crear la taula MD_activitat (catàleg)
DROP TABLE IF EXISTS MD_activitat;
CREATE TABLE MD_activitat (
    id_activitat INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL UNIQUE,
    descripcio TEXT
);

-- 2. Omplir el catàleg amb valors existents de tipus_activitat de activitats_net
INSERT IGNORE INTO MD_activitat (nom, descripcio)
SELECT DISTINCT 
    LOWER(COALESCE(NULLIF(tipus_activitat, ''), 'activitat_desconeguda')) AS nom,
    'Importació automàtica inicial'
FROM activitats_net;

-- 3. Afegir nova columna id_activitat_fk a activitats_net
ALTER TABLE activitats_net
ADD COLUMN id_activitat_fk INT;

-- 4. Omplir id_activitat_fk segons la correspondència amb el catàleg
UPDATE activitats_net an
JOIN MD_activitat md
  ON LOWER(COALESCE(NULLIF(an.tipus_activitat, ''), 'activitat_desconeguda')) = md.nom
SET an.id_activitat_fk = md.id_activitat;

-- 5. Un cop la FK estigui plena, eliminar tipus_activitat i afegir la clau forana
ALTER TABLE activitats_net
DROP COLUMN tipus_activitat,
ADD CONSTRAINT fk_tipus_activitat FOREIGN KEY (id_activitat_fk) REFERENCES MD_activitat(id_activitat);

-- Fi del PAS 4


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


/*Pas 6*/
DROP TABLE IF EXISTS auditoria_activitats;
CREATE TABLE auditoria_activitats (
    id INT AUTO_INCREMENT PRIMARY KEY,     -- ID de la fila d'auditoria
    id_activitat INT NOT NULL,             -- ID de l'activitat afegida a activitats_net
    usuari VARCHAR(100) DEFAULT CURRENT_USER(),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);


DELIMITER $$
DROP TRIGGER IF EXISTS auditoria_activitats_insert$$
CREATE TRIGGER auditoria_activitats_insert
AFTER INSERT ON activitats_net
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_activitats (id_activitat, usuari, data_hora)
    VALUES (NEW.id_activitat, CURRENT_USER(), NOW());
END $$
DELIMITER ;


DROP TABLE IF EXISTS auditoria_md_activitat;
CREATE TABLE auditoria_md_activitat (
    id INT AUTO_INCREMENT PRIMARY KEY,
    accio VARCHAR(10) NOT NULL,
    id_activitat INT NOT NULL,
    nom VARCHAR(50) NOT NULL,
    descripcio VARCHAR(500) NOT NULL,
    usuari VARCHAR(100) DEFAULT CURRENT_USER(),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);


DELIMITER $$
DROP TRIGGER IF EXISTS auditoria_md_activitat_update$$
CREATE TRIGGER auditoria_md_activitat_update
BEFORE UPDATE ON MD_activitat
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_md_activitat (accio, id_activitat, nom, descripcio, usuari, data_hora)
    VALUES ('UPDATE', OLD.id_activitat, OLD.nom, OLD.descripcio, CURRENT_USER(), NOW());
END $$
DELIMITER ;

DELIMITER $$
DROP TRIGGER IF EXISTS auditoria_md_activitat_delete$$
CREATE TRIGGER auditoria_md_activitat_delete
BEFORE DELETE ON MD_activitat
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_md_activitat (accio, id_activitat, nom, descripcio, usuari, data_hora)
    VALUES ('DELETE', OLD.id_activitat, OLD.nom, OLD.descripcio, CURRENT_USER(), NOW());
END $$
DELIMITER ;


-- Per provar que aixo funciona, farem una prova amb un nou arxiu csv

TRUNCATE TABLE activitats_raw;

LOAD DATA INFILE 'C:/Users/Xavier Fornes Bort/Documents/GitHub/practicaBBDDLSFitWell/Archivos csv/activitats2.csv'
INTO TABLE activitats_raw
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id_usuari, data_activitat, hora_inici, durada_minuts, tipus_activitat, calories, dispositiu);

CALL cargar_activitats_net();

SELECT * FROM auditoria_activitats ORDER BY id DESC;


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


-- PAS 8: Creació d’usuaris i assignació de permisos

-- Crear usuaris amb contrasenyes i host especificat
CREATE USER 'lsfit_data_loader'@'localhost' IDENTIFIED BY 'password1';
CREATE USER 'lsfit_user'@'localhost' IDENTIFIED BY 'password2';
CREATE USER 'lsfit_backup'@'localhost' IDENTIFIED BY 'password3';
CREATE USER 'lsfit_auditor'@'localhost' IDENTIFIED BY 'password4';
CREATE USER 'lsfit_admin'@'localhost' IDENTIFIED BY 'password5';

-- Permisos per a lsfit_data_loader
GRANT SELECT, INSERT, UPDATE, DELETE ON lsfitwell.activitats_raw TO 'lsfit_data_loader'@'localhost';
GRANT FILE ON *.* TO 'lsfit_data_loader'@'localhost';

-- Permisos per a lsfit_user
GRANT SELECT, INSERT, UPDATE, DELETE ON lsfitwell.* TO 'lsfit_user'@'localhost';

-- Permisos per a lsfit_backup
GRANT SELECT ON lsfitwell.* TO 'lsfit_backup'@'localhost';
GRANT ALL PRIVILEGES ON lsfitwell_backup.* TO 'lsfit_backup'@'localhost';

-- Permisos per a lsfit_auditor
GRANT SELECT ON lsfitwell.* TO 'lsfit_auditor'@'localhost';
GRANT SELECT ON lsfitwell_backup.* TO 'lsfit_auditor'@'localhost';

-- Permisos per a lsfit_admin
GRANT ALL PRIVILEGES ON lsfitwell.* TO 'lsfit_admin'@'localhost';
GRANT ALL PRIVILEGES ON lsfitwell_backup.* TO 'lsfit_admin'@'localhost';
