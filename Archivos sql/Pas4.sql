/*Pas 4*/
/*Creació taula MD_activitat*/
CREATE TABLE IF NOT EXISTS MD_activitat (
    id_activitat INT NOT NULL,
    nom VARCHAR(50),
    descripcio VARCHAR(500),
    FOREIGN KEY (id_activitat) REFERENCES activitats_net(id_activitat)
);