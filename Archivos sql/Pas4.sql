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
