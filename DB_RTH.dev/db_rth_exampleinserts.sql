/*----------------------------------------------
        EXAMPLE DATA | Reinos de Thalesia
        Carlos Labiano Cerón / 2º GFS ASIR
          Centro integrado Cuatrovientos
                        v1.1
                     19/01/2020
 ----------------------------------------------*/

-- INIT
USE MASTER
GO

-- INIT DATABASE
USE db_rth
GO

-- EXAMPLE DATA INSERTS
INSERT INTO USUARIOS (usuario, contrasena, correo_electronico, nick, genero, provincia, fecha_nacimiento, tipo)
VALUES  ('admin','12345678','admin@localhost','admin',null,null,null,2),
        ('carlos','12345678','carlos@correo.es','Cruzadito','Masculino','Navarra','19990416',2),
        ('mario','12345678','mario@correo.es','BrasileiroMore','Masculino','Navarra','19990924',1),
        ('crisfc','12345678','cristian@correo.es','Crisfc98','Masculino','Navarra','19980511',1),
        ('ryona','12345678','xryona@myacademy.ft','XryonaThePacifier','Femenino','Madrid','20020530',0),
        ('adarin','12345678','adarin@aizenmind.inf','TheTrueWaifu','Femenino','Madrid','19151230',0)
/*
    FORUM-SIDE DATA
*/
INSERT INTO TEMAS (codtema, titulo, creado_por, fecha_creacion)
VALUES  ('00AA','Reinos y Guerras','admin','20110324'),
        ('00AB','Personajes y LARP','admin','20110324'),
        ('00AC','Eventos','admin','20110324'),
        ('00AD','Off-topic','admin','20110324'),
        ('11BA','Shitposting General /stg/','carlos','20200117')
    INSERT INTO SUPERVISADOS (usuario, codtema)
    VALUES  ('ryona','00AD'),
            ('adarin','11BA'),
            ('mario','00AA'),
            ('mario','00AB'),
            ('crisfc','00AD')
    INSERT INTO MODERADORES (usuario, codtema)
    VALUES  ('mario','00AA'),
            ('mario','00AB'),
            ('mario','00AC'),
            ('crisfc','00AD'),
            ('carlos','11BA')
INSERT INTO CONVERSACIONES (codconv, codtema, titulo, creado_por, fecha_creacion, bloqueado)
-- A ejecutar antes de la creacion del Trigger, se asumen datos correctos
VALUES  (1,'00AA','Organizacion de las tropas del reino','mario','20190106',0),
        (2,'00AA','Re-organizacion del gobierno republicano','crisfc','20190803',0),
        (3,'00AA','Declaracion de guerra total a todos los hijos de ****','carlos','20200117',1),
        (1,'00AD','Hagamos la paz y no la guerra','ryona','20200116',0),
        (1,'11BA','1001 razones por las que adorar a Aizen','adarin','20190214',1)
INSERT INTO MENSAJES (codmsg, codtema, codconv, contenido, creado_por, fecha_creacion)
VALUES  (1,'00AA',1,'Viendo el movimiento de los diferentes reinos, creo que tenemos que organizar las tropas mejor, vieno lo que puede ocurrir.','mario','20190106'),
        (2,'00AA',1,'No te rayes marieria','crisfc','20190107'),
        (1,'00AD',1,'Esforcémonos día a día por hacer lo correcto, ayudar y proteger a la gente para convertir este mundo en un lugar mejor donde podamos vivir felices y orgullosos de nosotros mismos, por duro que sea el camino, seguiremos adelante, juntos','ryona','20200116'),
        (2,'00AD',1,'Madre mia, deja de globearnos de una vez P O R F A V O R','carlos','20200117'),
        (1,'00AA',3,'Su os vais a cagar cabrones, vais a moir tos','carlos','20200117')
/*
    LARP-SIDE TABLES
*/
INSERT INTO PERSONAJES (usuario, nombre, apellido1, apellido2, raza, genero, religion, historia, dinero, clase, magia, reino)
VALUES  ('ryona','Xryona','Rion','Reyhan','Humano','Femenino',null,'La ultima waifu de su dimensión',98420,'Aventurero','Universal',null),
        ('adarin','Adarín',null,null,'Humano','Femenino','Aifunismo','La eterna waifu de Aizen',0,'Brujo','Ilusión',null),
        ('carlos','Ricker(Fang)','De','Ravenford','Humano','Masculino','Aifunismo','Un chaval sin nada que perder',23,'Pícaro','No mago',null),
        ('mario','Pedro','Do','Brasil','Elfo','Masculino','Ateo','P o r t u g a l es G R A N D E',3000000,'Alquimista','Negromancia',null),
        ('crisfc','Krispy','Karsperky','Kolcas','Humano','Masculino','Cristianismo','oof',1000000000,'Mago','Adivinación',null)
INSERT INTO TERRITORIOS (nombre, topologia, reino, comida, madera, piedra, hierro, dinero, edificios, poblacion, def, atk)
VALUES  ('Ciudad academia','Islas',null,300,200,232,145,71500,2345,50000,90,20),
        ('Naventia','Valle',null,0,0,0,0,0,0,2,0,250),
        ('Gariniostian','Montañoso',null,1,2,10,0,100,3,2,3,12),
        ('Nexo','Meseta',null,20000,2245,3125,2374,1788,2547,2354678,100,100),
        ('Itoiz','Llanura',null,300,100,125,0,0,0,0,10,30)
INSERT INTO REINOS (nombre, lema, capital, descripcion, creado_por, forma_gobierno, rey, legado, contacto, religion, ejercito)
VALUES  ('Imperio de Aifun','Haga la fuerza ley, pues si no caos todo sera lol','Naventia','FATE','carlos','Imperio','carlos','adarin','aifun@aizenmind.ai','Aifunismo',12),
        ('Federación SQL','CREATE es nuestra fundación e INSERT nuestra construccón','Gariniostian','Naciones construidas y unidas a traves de un par de batchs SQL','admin','Federación','mario','crisfc','dropmylife@oof.es','Cristianismo',3000),
        ('Akademia','Avancemos todos juntos en nombre de la ciencia','Ciudad academia','La republica que Xryona dirije con mano de hierro','admin','República','ryona',null,'rioni@fate.org',null,0)
/* ASSIGN KINGDOMS TO CHARACTERS */
UPDATE PERSONAJES
	SET reino = 'Akademia'
	WHERE usuario = 'ryona'
UPDATE PERSONAJES
	SET reino = 'Imperio de Aifun'
	WHERE usuario IN ('adarin','carlos')
UPDATE PERSONAJES
	SET reino = 'Imperio de Aifun'
	WHERE usuario = 'carlos'
UPDATE PERSONAJES
	SET reino = 'Federación SQL'
	WHERE usuario IN ('mario','crisfc')
/* ASSIGN KINGDOMS TO TERRITORIES */
UPDATE TERRITORIOS
	SET reino = 'Akademia'
	WHERE nombre = 'Ciudad academia'
UPDATE TERRITORIOS
	SET reino = 'Imperio de Aifun'
	WHERE nombre IN ('Naventia','Nexo')
UPDATE TERRITORIOS
	SET reino = 'Federación SQL'
	WHERE nombre = 'Gariniostian'
/*
    EVENT-SIDE TABLES
*/
INSERT INTO EVENTOS (nombre, ubicacion, detalles, coste, fecha_inicio, fecha_fin)
VALUES  ('Conquista del reino de Granada','Granada','Reconquista 2.0',20,'19820102','19920320'),
        ('Kancolle','FATE','Ah shit, here we go again (t.Aizen)',0,'20191103','20201230'),
        ('Encuentro General de la comunidad LARP','Pampona, Navarra','Encuentro de todos los apasionados por este hobby',15,'20200612','20200613'),
        ('Asalto al castillo hinchable','Garinoain, Tafalla, Comunidad foral de Navarra','ACABAD CON ELLOOOOOOOOOOS!!!!',30,'20200120','20200130'),
        ('NLP3 2020','Polideportivo de la UPNA','YEEEEEEEEEEEEEEEE BOIIIIIIIIIIIII',60,'20200905',null)
    INSERT INTO PARTICIPANTES (usuario, codevnt, personaje)
    VALUES  ('ryona',2,1),
            ('adarin',2,1),
            ('carlos',1,0),
            ('mario',4,1),
            ('crisfc',1,1)