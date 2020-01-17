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
    VALUES  ('ryona','00AD'),
            ('adarin','11BA'),
            ('mario','00AA'),
            ('mario','00AB'),
            ('crisfc','00AD')
    INSERT INTO MODERADORES (usuario, codtema)
    VALUES  ('mario','00AA'),
            ('mario','00AB'),
            ('mario','0AC'),
            ('crisfc','00AD'),
            ('carlos','11BA')
INSERT INTO CONVERSACIONES (codconv, codtema, titulo, creado_por, fecha_creacion, bloqueado)
-- A ejecutar antes de la creacion del Trigger, se asumen datos correctos
VALUES  (1,'00AA','Organizacion de las tropas del reino','mario','06-01-2019',0),
        (2,'00AA','Re-organizacion del gobierno republicano','crisfc','03-08-2019',0),
        (3,'00AA','Declaracion de guerra total a todos los hijos de ****','carlos','17-01-2020',1),
        (1,'00AD','Hagamos la paz y no la guerra','ryona','16-01-2020',0),
        (1,'11BA','1001 razones por las que adorar a Aizen','adarin','14-02-2019',1)
INSERT INTO MENSAJES (codmsg, codtema, codconv, contenido, creado_por, fecha_creacion)
VALUES  (1,'00AA',1,'Viendo el movimiento de los diferentes reinos, creo que tenemos que organizar las tropas mejor, vieno lo que puede ocurrir.','mario','06-01-2019'),
        (2,'00AA',1,'No te rayes marieria','crisfc','07-01-2019'),
        (1,'00AD',1,'Esforcémonos día a día por hacer lo correcto, ayudar y proteger a la gente para convertir este mundo en un lugar mejor donde podamos vivir felices y orgullosos de nosotros mismos, por duro que sea el camino, seguiremos adelante, juntos','ryona','16-01-2020'),
        (2,'00AD',1,'Madre mia, deja de globearnos de una vez P O R F A V O R','carlos','17-01-2020'),
        (1,'00AA',3,'Su os vais a cagar cabrones, vais a moir tos','carlos','17-01-2020')
/*
    LARP-SIDE TABLES
*/
INSERT INTO PERSONAJES (usuario, nombre, apellido1, apellido2, raza, genero, religion, historia, dinero, clase, magia, reino)
VALUES  ('ryona','Xryona','Rion','Reyhan','Humano','Femenino',null,'La ultima waifu de su dimensión',98420,'Aventurero','Universal','Akademia'),
        ('adarin','Adarín',null,null,'Humano','Femenino','Aifunismo','La eterna waifu de Aizen',0,'Brujo','Ilusión','Imperio de Aifun'),
        ('carlos','Ricker(Fang)','De','Ravenford','Humano','Masculino','Aifunismo','Un chaval sin nada que perder',23,'Pícaro','No mago','Imperio de Aifun'),
        ('mario','Pedro','Do','Brasil','Elfo','Masculino','Ateo','P o r t u g a l es G R A N D E',3000000,'Alquimista','Negromancia','Federación SQL'),
        ('crisfc','Krispy','Karsperky','Kolcas','Humano','Masculino','Cristianismo','oof',10000000000,'Mago','Adivinación','Federación SQL')
INSERT INTO REINOS (nombre, lema, capital, descripcion, creado_por, forma_gobierno, rey, legado, religion, ejercito)
VALUES  ('Imperio de Aifun','Haga la fuerza ley, pues si no caos todo sera lol','Naventia','FATE','carlos','Imperio','carlos','adarin','Aifunismo',12),
        ('Federación SQL','CREATE es nuestra fundación e INSERT nuestra construccón','Ciudad academia','Naciones construidas y unidas a traves de un par de batchs SQL','admin','Federación','mario','crisfc'),
        ('Akademia','Avancemos todos juntos en nombre de la ciencia','Gariniostian','La republica que Xryona dirije con mano de hierro','admin','República','ryona',null,null,0),
    INSERT INTO TERRITORIOS (nombre, topologia, reino, comida, madera, piedra, hierro, dinero, edificios, poblacion, def, atk)
    VALUES  ('Ciudad academia','Islas','Akademia',300,200,232,145,71500,2345,50000,90,20),
            ('Naventia','Valle','Imperio de Aifun',0,0,0,0,0,0,2,0,250),
            ('Gariniostian','Montañoso','Federación SQL',1,2,10,0,100,3,2,3,12),
            ('Nexo','Meseta','Imperio de Aifun',20000,2245,3125,2374,1788,2547,2354678,100,100),
            ('Itoiz','Llanura',null,300,100,125,0,0,0,0,10,30)
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