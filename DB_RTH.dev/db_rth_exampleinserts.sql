/*----------------------------------------------
        EXAMPLE DATA | Reinos de Thalesia
        Carlos Labiano Cerón / 2º GFS ASIR
          Centro integrado Cuatrovientos
                        v0.1
                     16/01/2020
 ----------------------------------------------*/

-- INIT
USE MASTER
GO

-- EXAMPLE DATA INSERTS
INSERT INTO USUARIOS (usuario, contrasena, correo_electronico, nick, genero, provincia, fecha_nacimiento, tipo)
VALUES  ('admin','12345678','admin@localhost','admin',null,null,null,2),
        ('carlos','12345678','carlos@correo.es','Cruzadito','Masculino','Navarra','1999-04-16',2),
        ('mario','12345678','mario@correo.es','BrasileiroMore','Masculino','Navarra','1999-09-24',1),
        ('crisfc','12345678','cristian@correo.es','Crisfc98','Masculino','Navarra','1998-05-11',1),
        ('ryona','12345678','xryona@myacademy.ft','XryonaThePacifier','Femenino','Madrid','2002-05-30',0),
        ('adarin','12345678','adarin@aizenmind.inf','TheTrueWaifu','Femenino','Madrid','1915-12-30',0)
/*
    FORUM-SIDE DATA
*/
INSERT INTO TEMAS (codtema, titulo, creado_por, fecha_creacion)
VALUES  ('00AA','Reinos y Guerras','admin','2011-03-24'),
        ('00AB','Personajes y LARP','admin','2011-03-24'),
        ('00AC','Eventos','admin','2011-03-24'),
        ('00AD','Off-topic','admin','2011-03-24'),
        ('11BA','Shitposting General /stg/','carlos','2020-01-17')
    INSERT INTO SUPERVISADOS (usuario, codtema)
    VALUES  (),
            (),
            (),
            (),
            ()
    INSERT INTO MODERADORES (usuario, codtema)
    VALUES  (),
            (),
            (),
            (),
            ()
INSERT INTO CONVERSACIONES (codconv, codtema, titulo, creado_por, fecha_creacion, bloqueado)
VALUES  (),
        (),
        (),
        (),
        ()
INSERT INTO MENSAJES (codmsg, codtema, codconv, contenido, creado_por, fecha_creacion)
VALUES  (),
        (),
        (),
        (),
        ()
/*
    LARP-SIDE TABLES
*/
INSERT INTO PERSONAJES (usuario, nombre, apellido1, apellido2, raza, genero, religion, historia, dinero, clase, magia, reino)
VALUES  (),
        (),
        (),
        (),
        ()
INSERT INTO REINOS (nombre, lema, capital, descripcion, creado_por, forma_gobierno, rey, legado, religion, ejercito)
VALUES  (),
        (),
        (),
        (),
        ()
    INSERT INTO TERRITORIOS (nombre, topologia, reino, comida, madera, piedra, hierro, dinero, edificios, poblacion, def, atk)
    VALUES  (),
            (),
            (),
            (),
            ()
/*
    EVENT-SIDE TABLES
*/
INSERT INTO EVENTOS (codevnt, nombre, ubicacion, detalles, coste, fecha_inicio, fecha_fin)
VALUES  (),
        (),
        (),
        (),
        ()
    INSERT INTO PARTICIPANTES (usuario, codevnt, personaje)
    VALUES  (),
            (),
            (),
            (),
            ()