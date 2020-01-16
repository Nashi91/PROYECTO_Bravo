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
VALUES  (),
        (),
        (),
        (),
        ()
/*
    FORUM-SIDE DATA
*/
INSERT INTO TEMAS (codtema, titulo, creado_por, fecha_creacion)
VALUES  (),
        (),
        (),
        (),
        ()
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