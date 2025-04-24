/*Pas 4*/
CREATE TABLE IF NOT EXISTS MD_activitat (
    id INT NOT NULL AUTO_INCREMENT,
    id_activitat INT,
    nom VARCHAR(50),
    descripcio VARCHAR(500),
    FOREIGN KEY (id_activitat) REFERENCES activitats_net(id_activitat)

);