USE MASTER
GO

-- DATABSE CREATION
IF NOT EXISTS (
    SELECT name FROM sys.databases
        WHERE name = N'db_rth'
)
    CREATE DATABASE db_rth
ELSE
    RAISERROR ( 'CRITICAL ERROR, Database already exists.',20,1) WITH LOG
GO

-- INIT DATABASE
USE db_rth
GO

-- TABLE OBJECTS DEFINITION
CREATE TABLE USUARIOS
(
    usuario NVARCHAR(15) NOT NULL,
    contrasena NVARCHAR(30) NOT NULL,
    correo_electronico NVARCHAR(50) NOT NULL,
    nick NVARCHAR(35) NOT NULL,
    genero VARCHAR(9),
    provincia NVARCHAR(15),
    fecha_nacimiento DATETIME,
    tipo TINYINT NOT NULL, --|Admin(2)|Mod(1)|Usr(0)|
        CONSTRAINT PrmKEY_USUARIOS PRIMARY KEY (usuario),
        CONSTRAINT Chk_contrasena CHECK (LEN(contrasena) >= 8), --LEN() devuelve la longitud(int) de una cadena de texto
        /*CONSTRAINT Chk_contrasena CHECK (contrasena LIKE '???????*'),*/
        CONSTRAINT Chk_provincia CHECK (provincia IN ('Andalucía','Aragón','Asturias','Canarias','Baleares','Cantabria','Castilla y León','Castilla La Mancha','Valencia','Extremadura','Madrid','Galicia','Murcia','Navarra','Pais Vasco','La Rioja','Ceuta y Melilla'))
)
/*
    FORUM-SIDE TABLES
*/
CREATE TABLE TEMAS
(
    codtema CHAR(4) NOT NULL, --Formato: 00AA
    titulo NVARCHAR(75),
    creado_por NVARCHAR(15) NOT NULL,
    fecha_creacion DATETIME NOT NULL,
        CONSTRAINT PrmKEY_TEMAS PRIMARY KEY (codtema),
        CONSTRAINT ExtKEY_USUARIOS_TEMAS FOREIGN KEY (creado_por)
            REFERENCES USUARIOS(usuario)
)
    CREATE TABLE SUPERVISADOS
    (
        usuario NVARCHAR(15) NOT NULL,
        codtema CHAR(4) NOT NULL, --Formato: 00AA
            CONSTRAINT PrmKEY_SUPERVISADOS PRIMARY KEY (usuario,codtema),
            CONSTRAINT ExtKEY_USUARIOS_SUPERVISADOS FOREIGN KEY (usuario)
                REFERENCES USUARIOS(usuario),
            CONSTRAINT ExtKEY_TEMAS_SUPERVISADOS FOREIGN KEY (codtema)
                REFERENCES TEMAS(codtema)
    )
    CREATE TABLE MODERADORES
    (
        usuario NVARCHAR(15) NOT NULL,
        codtema CHAR(4) NOT NULL, --Formato: 00AA
            CONSTRAINT PrmKEY_MODERADORES PRIMARY KEY (usuario,codtema),
            CONSTRAINT ExtKEY_USUARIOS_MODERADORES FOREIGN KEY (usuario)
                REFERENCES USUARIOS(usuario),
            CONSTRAINT ExtKEY_TEMAS_MODERADORES FOREIGN KEY (codtema)
                REFERENCES TEMAS(codtema)
    )
CREATE TABLE CONVERSACIONES
(
    codconv INT NOT NULL,
    codtema CHAR(4) NOT NULL,
    titulo NVARCHAR(75),
    creado_por NVARCHAR(15) NOT NULL,
    fecha_creacion DATETIME NOT NULL,
    bloqueado BIT, --No(0) Si(1)
        CONSTRAINT PrmKEY_CONVERSACIONES PRIMARY KEY (codconv,codtema),
        CONSTRAINT ExtKEY_TEMAS_CONVERSACIONES FOREIGN KEY (codtema)
            REFERENCES TEMAS(codtema),
        CONSTRAINT ExtKEY_USUARIOS_CONVERSACIONES FOREIGN KEY (creado_por)
            REFERENCES USUARIOS(usuario)
)
CREATE TABLE MENSAJES
(
    codmsg INT NOT NULL,
    codtema CHAR(4) NOT NULL,
    codconv INT NOT NULL,
    contenido NVARCHAR(MAX) NOT NULL,
    creado_por NVARCHAR(15) NOT NULL,
    fecha_creacion DATETIME NOT NULL,
        CONSTRAINT PrmKEY_MENSAJES PRIMARY KEY (codmsg,codtema,codconv),
        CONSTRAINT ExtKEY_CONVERSACIONES_MENSAJES FOREIGN KEY (codconv,codtema)
            REFERENCES CONVERSACIONES(codconv,codtema),
        CONSTRAINT ExtKEY_USUARIOS_MENSAJES FOREIGN KEY (creado_por)
            REFERENCES USUARIOS(usuario)
)
/*
    LARP-SIDE TABLES
*/
CREATE TABLE PERSONAJES
(
    usuario NVARCHAR(15) NOT NULL,
    nombre NVARCHAR(30),
    apellido1 NVARCHAR(30),
    apellido2 NVARCHAR(30),
    raza NVARCHAR(15),
    genero VARCHAR(9),
    religion NVARCHAR(15),
    historia NVARCHAR(MAX),
    dinero INT DEFAULT 100,
    clase NVARCHAR(15) DEFAULT 'Campesino',
    magia NVARCHAR(15) DEFAULT 'No mago',
    reino NVARCHAR(35) --ExtKEY_REINOS_PERSONAJES
        CONSTRAINT PrmKEY_PERSONAJES PRIMARY KEY (usuario),
        CONSTRAINT ExtKEY_USUARIOS_PERSONAJES FOREIGN KEY (usuario)
            REFERENCES USUARIOS(usuario),
        CONSTRAINT Chk_raza CHECK (raza IN ('Humano','Elfo','Orco','Mediano')),
        CONSTRAINT Chk_clase CHECK (clase IN ('Pícaro','Aventurero','Cazador','Guerrero','Paladín','Hechicero','Mago','Brujo','Alquimista','Bárbaro','Campesino')),
        CONSTRAINT Chk_magia CHECK (magia IN ('No mago','Aprendiz','Principiante','Abjuración','Conjuración','Adivinación','Encantación','Evocación','Ilusión','Negromancia','Transmutación','Universal'))
)
CREATE TABLE REINOS
(
    nombre NVARCHAR(35) NOT NULL,
    lema NVARCHAR(100),
    capital NVARCHAR(35) NOT NULL, --ExtKEY_REINOS_TERRITORIOS_CAPITAL
    descripcion NVARCHAR(MAX),
    creado_por NVARCHAR(15) NOT NULL,
    forma_gobierno NVARCHAR(30) NOT NULL,
    rey NVARCHAR(15) NOT NULL,
    legado NVARCHAR(15),
    contacto NVARCHAR(50) NOT NULL,
    religion NVARCHAR(15),
    ejercito BIGINT,
        CONSTRAINT PrmKEY_REINOS PRIMARY KEY (nombre),
        CONSTRAINT ExtKEY_PERSONAJES_REINOS FOREIGN KEY (creado_por)
            REFERENCES USUARIOS(usuario),
        CONSTRAINT ExtKEY_REINOS_PERSONAJES_REY FOREIGN KEY (rey)
            REFERENCES PERSONAJES(usuario),
        CONSTRAINT ExtKEY_REINOS_PERSNAJES_LEGADO FOREIGN KEY (legado)
            REFERENCES PERSONAJES(usuario),
        CONSTRAINT Chk_formagobierno CHECK (forma_gobierno IN ('República','Monarquía','Federación','Imperio'))
)
    CREATE TABLE TERRITORIOS
    (
        nombre NVARCHAR(35) NOT NULL,
        topologia NVARCHAR(15) NOT NULL,
        reino NVARCHAR(35),
        comida INT DEFAULT 0,
        madera INT DEFAULT 0,
        piedra INT DEFAULT 0,
        hierro INT DEFAULT 0,
        dinero INT DEFAULT 0,
        edificios SMALLINT DEFAULT 0,
        poblacion INT DEFAULT 0,
        def TINYINT DEFAULT 0,
        atk TINYINT DEFAULT 0,
            CONSTRAINT PrmKEY_TERRITORIOS PRIMARY KEY (nombre),
            CONSTRAINT ExtKEY_REINOS_TERRITORIOS FOREIGN KEY (reino)
                REFERENCES REINOS(nombre),
            CONSTRAINT Chk_topologia CHECK (topologia IN ('Llanura','Meseta','Estepa','Valle','Montañoso','Islas','Costero','Península','Acantilados'))
    )
/*
    EVENT-SIDE TABLES
*/
CREATE TABLE EVENTOS
(
    codevnt INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(50) NOT NULL,
    ubicacion NVARCHAR(100),
    detalles NVARCHAR(MAX),
    coste MONEY,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME,
        CONSTRAINT PrmKEY_EVENTOS PRIMARY KEY (codevnt),
        CONSTRAINT Chk_fechaincio CHECK (fecha_inicio <= fecha_fin)
)
    CREATE TABLE PARTICIPANTES
    (
        usuario NVARCHAR(15) NOT NULL,
        codevnt INT NOT NULL,
        personaje BIT NOT NULL, -- no utiliza(0), si utiliza(1)
            CONSTRAINT PrmKEY_PARTICIPANTES PRIMARY KEY (usuario),
            CONSTRAINT ExtKEY_USUARIOS_PARTICIPANTES FOREIGN KEY (usuario)
                REFERENCES USUARIOS(usuario),
            CONSTRAINT ExtKEY_EVENTOS_PARTICIPANTES FOREIGN KEY (codevnt)
                REFERENCES EVENTOS(codevnt)
    )
GO

-- TABLE OBJECTS POST CREATE ALTERATION
/* Unique index for USUARIOS.correo_electronico */
CREATE UNIQUE INDEX UIx_correo
ON USUARIOS (correo_electronico)
/* ExtKEY_REINOS_PERSONAJES */
ALTER TABLE PERSONAJES 
    ADD CONSTRAINT ExtKEY_REINOS_PERSONAJES
            FOREIGN KEY (reino) REFERENCES REINOS(nombre)
/* ExtKEY_REINOS_TERRITORIOS_CAPITAL */
ALTER TABLE REINOS
    ADD CONSTRAINT ExtKEY_REINOS_TERRITORIOS_CAPITAL
            FOREIGN KEY (capital) REFERENCES TERRITORIOS(nombre)
GO

-- GLOBAL CONSTRAINT / DEFAULT DECLARATION
/*RULES*/
CREATE RULE NO_DATE_AFTER_TODAY AS
    (
        @field <= GETDATE()
    )
GO
CREATE RULE GENDER_GLOBAL AS
    (
        @field IN ('Masculino','Femenino')
    )
GO
CREATE RULE CHK_codtema AS
    (
        @field LIKE '[0-9][0-9][A-Z][A-Z]'
    )
GO
/*DEFAULTS*/
CREATE DEFAULT DATE_TODAY AS 
    GETDATE()
GO
CREATE DEFAULT BITFALSE AS
    0
GO
-- GLOBAL CONSTRAINT / DEFAULT LINKAGE
/*RULES*/
EXEC SP_BINDRULE CHK_codtema, 'TEMAS.codtema'
EXEC SP_BINDRULE CHK_codtema, 'SUPERVISADOS.codtema'
EXEC SP_BINDRULE CHK_codtema, 'MODERADORES.codtema'
EXEC SP_BINDRULE CHK_codtema, 'CONVERSACIONES.codtema'
EXEC SP_BINDRULE CHK_codtema, 'MENSAJES.codtema'

EXEC SP_BINDRULE NO_DATE_AFTER_TODAY, 'USUARIOS.fecha_nacimiento'
EXEC SP_BINDRULE NO_DATE_AFTER_TODAY, 'TEMAS.fecha_creacion'
EXEC SP_BINDRULE NO_DATE_AFTER_TODAY, 'CONVERSACIONES.fecha_creacion'
EXEC SP_BINDRULE NO_DATE_AFTER_TODAY, 'MENSAJES.fecha_creacion'

EXEC SP_BINDRULE GENDER_GLOBAL, 'USUARIOS.genero'
EXEC SP_BINDRULE GENDER_GLOBAL, 'PERSONAJES.genero'
/*DEFAULTS*/
EXEC SP_BINDEFAULT DATE_TODAY, 'TEMAS.fecha_creacion'
EXEC SP_BINDEFAULT DATE_TODAY, 'CONVERSACIONES.fecha_creacion'
EXEC SP_BINDEFAULT DATE_TODAY, 'MENSAJES.fecha_creacion'
EXEC SP_BINDEFAULT DATE_TODAY, 'EVENTOS.fecha_inicio'

EXEC SP_BINDEFAULT BITFALSE, 'USUARIOS.tipo'
EXEC SP_BINDEFAULT BITFALSE, 'CONVERSACIONES.bloqueado'
EXEC SP_BINDEFAULT BITFALSE, 'PARTICIPANTES.personaje'

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
