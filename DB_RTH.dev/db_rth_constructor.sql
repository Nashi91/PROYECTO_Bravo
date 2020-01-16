/*----------------------------------------------
    DATABSE CONSTRUCTOR | Reinos de Thalesia
        Carlos Labiano Cerón / 2º GFS ASIR
          Centro integrado Cuatrovientos
                        v0.1
                     14/01/2013
 ----------------------------------------------*/

--  INIT
USE MASTER
GO

-- DATABSE CREATION
IF NOT EXISTS (
    SELECT name FROM sys.databases
        WHERE name = N'db_rth'
)
    CREATE DATABASE db_rth
ELSE
    RAISERROR ( 'CRITICAL ERROR, Database already exists.',15,1)
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
        CONSTRAINT Chk_contrasena CHECK (contrasena LIKE '????????*'),
        CONSTRAINT Chk_provincia CHECK (provincia IN ('Andalucía','Aragón','Asturias','Canarias','Baleares','Cantabria','Castilla y León','Castilla La Mancha','Valencia','Extremadura','Madrid','Galicia','Murcia','Navarra','Pais Vasco','La Rioja','Ceuta y Melilla'))
)
/*
    FORUM-SIDE TABLES
*/
CREATE TABLE TEMAS
(
    codtema CHAR(4) NOT NULL, --Formato: 00AA
    titulo NVARCHAR(20),
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
    titulo NVARCHAR(30),
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
        CONSTRAINT ExtKEY_CONVERSACIONES_MENSAJES FOREIGN KEY (codtema,codconv)
            REFERENCES CONVERSACIONES(codtema,codconv),
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
    genero VARCHAR(6),
    religion NVARCHAR(15),
    historia NVARCHAR(MAX),
    dinero INT DEFAULT 100,
    clase NVARCHAR(15) DEFAULT 'Campesino',
    magia NVARCHAR(10) DEFAULT 'No mago',
    reino NVARCHAR(35) NOT NULL, --ExtKEY_REINOS_PERSONAJES
        CONSTRAINT PrmKEY_PERSONAJES PRIMARY KEY (usuario),
        CONSTRAINT ExtKEY_USUARIOS_PERSONAJES FOREIGN KEY (usuario)
            REFERENCES USUARIOS(usuario),
        CONSTRAINT Chk_raza CHECK (raza IN ('Humano','Elfo','Orco','Mediano')),
        CONSTRAINT Chk_clase CHECK (clase IN ('Picaro','Aventurero','Cazador','Guerrero','Paladin','Hechicero','Mago','Brujo','Alquimista','Barbaro','Campesino')),
        CONSTRAINT Chk_magia CHECK (clase IN ('No mago','Aprendiz','Principiante','Abjuración','Conjuración','Divinación','Encantación','Evocación','Ilusión','Negromancia','Transmutación','Universal'))
)
CREATE TABLE REINOS
(
    nombre NVARCHAR(35) NOT NULL,
    lema NVARCHAR(20),
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
        CONSTRAINT Chk_formagobierno CHECK (forma_gobierno IN ('República','Monarquia','Federación','Imperio'))
)
    CREATE TABLE TERRITORIOS
    (
        nombre NVARCHAR(35) NOT NULL,
        topologia NVARCHAR(15) NOT NULL,
        reino NVARCHAR(25),
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
    nombre NVARCHAR(35) NOT NULL,
    ubicacion NVARCHAR(40),
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
