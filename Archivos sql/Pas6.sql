/*Pas 6*/ /*¡¡CAL REVISAR!!*/
(id_activitat, nom_activitat, data_activitat, lloc_activitat);
DELIMITER $$
DROP TRIGGER IF EXISTS auditor_de_dades_carregades$$
CREATE TRIGGER auditor_de_dades_carregades AFTER INSERT ON activitats_net
FOR EACH ROW
BEGIN
     INSERT INTO auditoria_activitats (id_activitat, usuari, data_hora, accio)
     VALUES (NEW.id_activitat, USER(), NOW(), 'INSERT');
END$$

/*Creació fitxer activitats2.csv*/
LOAD DATA INFILE '/path/to/activitats2.csv'
INTO TABLE activitats_net
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS

/*Controla Modificacións i MD_activitat*/
DROP TRIGGER IF EXISTS auditor_de_modificacions$$
CREATE TRIGGER auditor_de_modificacions AFTER UPDATE ON MD_activitat
FOR EACH ROW
BEGIN
     INSERT INTO auditoria_activitats (id_activitat, usuari, data_hora, accio, detall)
     VALUES (OLD.id_activitat, USER(), NOW(), 'UPDATE', CONCAT('Old: ', OLD.nom_activitat, ', New: ', NEW.nom_activitat));
END$$

DROP TRIGGER IF EXISTS auditor_de_esborrats$$
CREATE TRIGGER auditor_de_esborrats AFTER DELETE ON MD_activitat
FOR EACH ROW
BEGIN
     INSERT INTO auditoria_activitats (id_activitat, usuari, data_hora, accio, detall)
     VALUES (OLD.id_activitat, USER(), NOW(), 'DELETE', CONCAT('Deleted: ', OLD.nom_activitat));
END$$

-- Insert a new record into MD_activitat
INSERT INTO MD_activitat (id_activitat, nom_activitat, data_activitat, lloc_activitat)
VALUES (1, 'Yoga Class', '2023-10-01', 'Community Center');

-- Update the record in MD_activitat to test the update trigger
UPDATE MD_activitat
SET nom_activitat = 'Advanced Yoga Class'
WHERE id_activitat = 1;

-- Delete the record from MD_activitat to test the delete trigger
DELETE FROM MD_activitat
WHERE id_activitat = 1;
DELIMITER ;