/*Pas 6*/

DELIMITER $$
DROP TRIGGER IF EXISTS auditor_de_dades_carregades$$
CREATE PROCEDURE auditor_de_dades_carregades AFTER INSERT ON activitats_net
FOR EACH ROW
BEGIN
     SELECT NEW.
END$$
DELIMITER ;