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
    PRINT 'CRITICAL ERROR, Database already exists.'
GO

-- TABLE OBJECTS DEFINITION
CREATE TABLE USUARIOS
(
    usuario NVARCHAR(15) NOT NULL,
    contrasena NVARCHAR(30) NOT NULL,
    correo_electronico NVARCHAR(50) NOT NULL,
    nick NVARCHAR(35) NOT NULL,
    genero VARCHAR(6),
    provincia NVARCHAR(15),
    fecha_nacimiento DATETIME,
    tipo TINYINT NOT NULL, --|Admin(2)|Mod(1)|Usr(0)|
        CONSTRAINT PrmKEY_USUARIOS PRIMARY KEY (usuario),
        /*  TODO
            -Constraint de provincia y genero
            -Constraint de fechanacimiento (General o local?)
            -Constraint de contraseña
        */
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
            REFERENCES USUARIOS(usuario),
        /* TODO
            -Constraint de codtema
            -Default de fecha_creacion (General o local?)
        */
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
        /* TODO
            -Constraint de codtema
            -Default de fecha_creacion (General o local?)
        */
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
    /* TODO
        -Constraint de codtema
        -Default de fecha_creacion (General o local?)
    */
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
    dinero INT,
    clase NVARCHAR(15),
    magia NVARCHAR(10),
    reino NVARCHAR(35) NOT NULL, --ExtKEY_REINOS_PERSONAJES
        CONSTRAINT PrmKEY_PERSONAJES PRIMARY KEY (usuario),
        CONSTRAINT ExtKEY_USUARIOS_PERSONAJES FOREIGN KEY (usuario)
            REFERENCES USUARIOS(usuario)
    /*  TODO
        -Constraint de genero
        -Constraint de raza, clase y magia (???)
        -Default dinero 100 oros
    */
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
            REFERENCES PERSONAJES(usuario)
    /* TODO
        - Constraint de forma_gobierno (?¿)
    */
)
    CREATE TABLE TERRITORIOS
    (
        nombre NVARCHAR(35) NOT NULL,
        topologia NVARCHAR(15) NOT NULL,
        reino NVARCHAR(25),
        comida INT,
        madera INT,
        piedra INT,
        hierro INT,
        dinero INT,
        edificios SMALLINT,
        poblacion INT,
        def TINYINT,
        atk TINYINT,
            CONSTRAINT PrmKEY_TERRITORIOS PRIMARY KEY (nombre),
            CONSTRAINT ExtKEY_REINOS_TERRITORIOS FOREIGN KEY (reino)
                REFERENCES REINOS(nombre)
        /* TODO
            -Constraint de topologia
        */
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
        CONSTRAINT PrmKEY_EVENTOS PRIMARY KEY (codevnt)
    /* TODO
        -Defaults de fecha
        -Constraint de fechas inicio - fin
    */
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
