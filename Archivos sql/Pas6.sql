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