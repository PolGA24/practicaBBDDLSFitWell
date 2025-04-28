/*Pas 8*/
/*Crear els usuaris lsfit_data_loader, lsfit_user, lsfit_backup, lsfit_auditor, lsfit_admin
mitjançant CREATE USER.*/

/*Dona permisos a l’usuari lsfit_data_loader per carregar arxius i fer SELECTS, INSERTS,
UPDATES i DELETES de activitats_raw a la base de dades de producció.*/


/*Dona permisos a l’usuari l’usuari lsfit_user perquè a la base de dades lsfit de producció
executi estructures, però no per crear-les. Pot també generar fitxers i fer SELECTS,
INSERTS, UPDATES i DELETES.*/


/*Dona permisos a l’usuari l’usuari lsfit_backup per llegir totes les taules de la base de
dades lsfit i poder fer totes les operacions a la base de dades de backup, menys donar
permisos a altres usuaris.*/

/*Dona permisos a l’usuari l’usuari lsfit_auditor per veure totes les taules sense poder fer-
hi cap operació extra tant a la base de dades de producció com a la de backup.*/


/*L’usuari lsfit_admin pot fer totes les operacions a la base de dades de lsfit i a la seva
contrapart de backup, però res a cap altra.*/


/*Adjunta proves a la memòria que validin aquest permisos. Si creus que algun usuari ha
de tenir mes permisos que els anomenats gestioneu-ho i justifiqueu-ho a la memòria.*/