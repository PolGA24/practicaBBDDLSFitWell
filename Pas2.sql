/*Pas 2*/
CREATE TABLE activitats_net (
    id_activitat INT NOT NULL AUTO_INCREMENT,
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