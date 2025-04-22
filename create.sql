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
    dispositiu VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_activitat)
);

LOAD DATA INFILE 'C:\Users\Xavier Fornes Bort\Documents\GitHub\practicaBBDDLSFitWell'
INTO TABLE activitats_raw
FIELDS TERMINATED BY ';'
Lines TERMINATED BY '\n'
IGNORE 1 LINES;