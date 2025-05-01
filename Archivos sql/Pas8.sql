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
