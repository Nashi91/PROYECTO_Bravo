/*----------------------------------------------
    DATABSE CONSTRUCTOR | Reinos de Thalesia
        Carlos Labiano Cerón / 2º GFS ASIR
          Centro integrado Cuatrovientos
                        v1.6
                     27/01/2020
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
    tipo TINYINT NOT NULL, --|Administrador(2)|Moderador(1)|Usuario normal(0)|
        CONSTRAINT PrmKEY_USUARIOS PRIMARY KEY (usuario),
        CONSTRAINT Chk_contrasena CHECK (LEN(contrasena) >= 8), --LEN() devuelve la longitud(int) de una cadena de texto
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
    bloqueado BIT, --|No(0)|Si(1)|
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
        CONSTRAINT Chk_fechainicio CHECK (fecha_inicio <= fecha_fin)
)
    CREATE TABLE PARTICIPANTES
    (
        usuario NVARCHAR(15) NOT NULL,
        codevnt INT NOT NULL,
        personaje BIT NOT NULL, --|No utiliza(0)|Si utiliza(1)|
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
GO
-- TRIGGER CREATION
/*
    --- [Mario] ---
*/
--REGLA 1: Un usuario unicamente podra crear temas si es un administrador
CREATE TRIGGER TRGIn_AdmPrivilege ON TEMAS
INSTEAD OF INSERT
AS
	IF (SELECT TIPO FROM USUARIOS WHERE usuario=(SELECT creado_por FROM inserted))=2
		BEGIN
			INSERT INTO TEMAS
			SELECT * FROM inserted
		END
	ELSE
		PRINT 'NO PUEDES CREAR UN TEMA PORQUE NO ERES ADMINISTRADOR'
GO
/*
EXPLICACIÓN: en este caso necesitamos limitar el permiso de creación de temas a los usuarios que sean administradores,
para ello mediante un trigger que se lanzará tras intentar añadir registros a temas, comprobaremos que dicho usuario
que intenta crear un nuevo tema "sea de tipo administrador", si lo es se realiza la operación pero si no se envía un 
mensaje de error.
*/
--REGLA 2: Solo si un usuario es moderador podra moderar temas
CREATE TRIGGER TRGIn_ModPrivilege ON MODERADORES
INSTEAD OF INSERT
AS
	IF (SELECT TIPO FROM USUARIOS WHERE usuario=(SELECT usuario FROM inserted))>=1
		BEGIN
			INSERT INTO MODERADORES
			SELECT * FROM inserted
		END
	ELSE
		PRINT 'NO PUEDES SER AÑADIDO A LOS MODERADORES PORQUE NO ERES MODERADOR'
GO
/*
EXPLICACIÓN: en este caso necesitamos limitar el permiso de moderación de temas a los usuarios que sean moderadores,
un moderador sólo puede moderar un tema si se encuentra en la tabla de moderadores, pero para estar en esa tabla debe 
ser moderador, con lo cual mediante un trigger que se lanzará tras intentar añadir registros a moderadores, 
comprobaremos que dicho usuario se intenta añadir a los moderadores "sea de tipo moderador", si lo es se realiza la 
operación pero si no se envía un mensaje de error.
*/
/*
    --- [Mario + Carlos] ---
*/
--REGLA 3: El codigo de las conversaciones sera igual al numero de la conversacion dentro de su correspondiente tema. [TRGHelper_GenWeakCode]

CREATE TRIGGER TRGIn_WeakCode ON CONVERSACIONES
INSTEAD OF INSERT
AS
    DECLARE @gencodconv INT
	EXEC @gencodconv = TRGHelper_GenWeakCode 'codtema'

	INSERT INTO CONVERSACIONES (codconv, codtema, titulo, creado_por, fecha_creacion,bloqueado)
	VALUES
    (
         @gencodconv,
         (SELECT codtema FROM inserted),
         (SELECT titulo FROM inserted),
         (SELECT creado_por FROM inserted),
         (SELECT fecha_creacion FROM inserted),
         (SELECT bloqueado FROM inserted)
    )
GO
/*
EXPLICACIÓN: en este caso necesitamos que el código de las conversaciones que será igual al número de la conversación 
dentro de su correspondiente tema, para ello mediante un trigger deberemos llamar a un procedimiento (explicado más 
adelante) para obtener el código de la conversación e insertar desde la tabla inserted la información propia de dicha
conversación.
*/
--REGLA 4: El codigo de los mensajes sera igual al numero del mensaje dentro de su correspondiente conversacion.      [^]

CREATE TRIGGER TRGIn_WeakCode ON MENSAJES
INSTEAD OF INSERT
AS
    DECLARE @gencodmsg INT
    EXEC @gencodmsg = TRGHelper_GenWeakCode 'codtema', 'codconv', 1

    INSERT INTO MENSAJES (codmsg, codtema, codconv, contenido, creado_por, fecha_creacion)
	VALUES
    (
        @gencodmsg,
        (SELECT codtema FROM inserted),
        (SELECT codconv FROM inserted),
        (SELECT contenido FROM inserted),
        (SELECT creado_por FROM inserted),
        (SELECT fecha_creacion FROM inserted)
    )
GO
/*
EXPLICACIÓN: en este caso necesitamos que el código de los mensajes que será igual al número del mensaje dentro de 
su correspondiente conversación, para ello  al igual que en la anterior reglas mediante un trigger deberemos llamar 
a un procedimiento (explicado más adelante) para obtener el código del mensaje e insertar desde la tabla inserted 
la información propia de dicho mensaje.
*/
--REGLA 3 + 4: Procedimiento TRGHelper_GenWeakCode que genera los codigos
CREATE PROCEDURE TRGHelper_GenWeakCode
    @codtema CHAR(4),
    @codconv INT,
    @mode BIT = 0 -- (0) Conversaciones | (1) Mensajes
AS
    IF @mode = 0
        BEGIN
            DECLARE @gencodconv INT
            
            SET @gencodconv = (SELECT COUNT(C.codtema) FROM CONVERSACIONES C 
                                WHERE C.codtema = @codtema) + 1

            RETURN @gencodconv
        END
    ELSE IF @mode = 1
        BEGIN
            DECLARE @gencodmsg INT

            SET @gencodmsg = (SELECT COUNT(M.codconv) FROM MENSAJES M
                                WHERE M.codconv = @codconv AND M.codtema = @codtema) + 1
            
            RETURN @gencodmsg
        END
GO
/*
EXPLICACIÓN: en referencia a las dos reglas anteriores disponemos de este procedimiento almacenado que es llamado 
desde los triggers y que, según el código que se le pasa al procedimiento (1 o 0), se genera el código de mensaje 
o de conversación correspondiente contando los registros de los códigos de conversaciones o de temas respectivamente 
presentes en las tablas de conversaciones (codtema) o de mensajes (conconv) añadiéndoles uno para obtener como 
resultado el próximo código necesario.
*/
/*
    --- [Cristian] ---
*/
--REGLA 5: En caso de que un personaje muera, debera de ser eliminado del registro y almacenarse en un registro a parte. [TRGHelper_PlayerCharDeath]
CREATE TRIGGER TRGIn_PlayerCharDeath ON PERSONAJES
INSTEAD OF DELETE
AS
-- Se hace una comprobación de si el personaje existe en dicha tabla.
	IF EXISTS (SELECT * FROM PERSONAJES WHERE PERSONAJES.USUARIO = (SELECT USUARIO FROM DELETED))
	    PRINT 'ERROR EL PERSONAJE NO EXISTE EN LA TABLA :V'
	ELSE
--Si la tabla no existe se crea otra donde se insertan los personajes muertos.
    BEGIN
	    IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME = 'DEAD_CHARACTERS')
	    	CREATE TABLE DEAD_CHARACTERS(
	    	usuario NVARCHAR(15),
	    	nombre NVARCHAR(30),
	    	apellido1 NVARCHAR(30),
	    	apellido2 NVARCHAR(30),
	    	raza NVARCHAR(15),
	    	genero VARCHAR(9),
	    	religion NVARCHAR(15),
	    	historia NVARCHAR(MAX),
	    	dinero INT,
	    	clase NVARCHAR(15),
	    	magia NVARCHAR(10),
	    	reino NVARCHAR(35)
	    	)

	    	INSERT INTO DEAD_CHARACTERS
	    	SELECT * FROM PERSONAJES
	    	    WHERE PERSONAJES.USUARIO IN (SELECT USUARIO FROM DELETED)
-- En el caso de existir un rey o legado, con esto comprobamos de que existe tal rey o legado.

	    IF EXISTS (SELECT REY FROM REINOS WHERE REINOS.REY = (SELECT USUARIO FROM DELETED))
	    	EXEC SProc_RulerDeath (SELECT USUARIO FROM DELETED)
    
	    IF EXISTS (SELECT LEGADO FROM REINOS WHERE REINOS.LEGADO = (SELECT USUARIO FROM DELETED))	
	    BEGIN
	    	UPDATE REINOS
	    	SET LEGADO = NULL
	    	WHERE REINOS.LEGADO = (SELECT LEGADO FROM DELETED)
	    END
    
	    DELETE PERSONAJES -- Hecho dicha comprobación, hacemos la eliminación en la tabla personajes, en el where cogemos el campo usuario para eliminar los personajes.
	    FROM PERSONAJES
	    WHERE PERSONAJES.USUARIO IN (SELECT USUARIO FROM DELETED)
    END
GO
/*
    --- [Carlos] ---
*/
--REGLA 10: La fecha de fin de un evento debera ser siempre posterior respetando un minimo de un dia respecto a la fecha de inicio
CREATE TRIGGER TRGIn_EndDateDiff ON EVENTOS
INSTEAD OF UPDATE
AS
	IF (SELECT FECHA_FIN FROM DELETED) = (SELECT FECHA_FIN FROM INSERTED) AND 
        (SELECT FECHA_INICIO FROM DELETED) = (SELECT FECHA_INICIO FROM INSERTED) -- Comprobar que no se ha modificado nada para poder actualizar. Hacemos una comprobación de los campos FECHA_FIN y FECHA_INICIO
	    BEGIN --> Si no se ha modificado ninguna de las tablas, se ejecuta el UPDATE.
	    	UPDATE EVENTOS
	    	SET CODEVNT = (SELECT CODEVNT FROM INSERTED),
	    	    NOMBRE = (SELECT NOMBRE FROM INSERTED),
	    	    UBICACION = (SELECT UBICACION FROM INSERTED),
	    	    DETALLES = (SELECT DETALLES FROM INSERTED),
	    	    COSTE = (SELECT COSTE FROM INSERTED),
	    	    FECHA_INICIO = (SELECT FECHA_INICIO FROM INSERTED),
	    	    FECHA_FIN = (SELECT FECHA_FIN FROM INSERTED)
	    	WHERE CODEVNT = (SELECT CODEVNT FROM DELETED)
	    END
	ELSE IF DATEDIFF(day, (SELECT FECHA_INICIO FROM INSERTED), (SELECT FECHA_FIN FROM INSERTED)) >= 1 --> Si se ha modificado alguna de las tablas, se hace la diferencia entre los 2 campos (FECHA_INICIO Y FECHA_FIN de la nueva tabla)
        BEGIN --> Si el día respeta el mínimo del día, se ejecuta el UPDATE
            UPDATE EVENTOS
	    	SET CODEVNT = (SELECT CODEVNT FROM INSERTED),
	    	    NOMBRE = (SELECT NOMBRE FROM INSERTED),
	    	    UBICACION = (SELECT UBICACION FROM INSERTED),
	    	    DETALLES = (SELECT DETALLES FROM INSERTED),
	    	    COSTE = (SELECT COSTE FROM INSERTED),
	    	    FECHA_INICIO = (SELECT FECHA_INICIO FROM INSERTED),
	    	    FECHA_FIN = (SELECT FECHA_FIN FROM INSERTED)
	    	WHERE CODEVNT = (SELECT CODEVNT FROM DELETED)
        END
    ELSE
        PRINT 'LA DIFERENCIA ENTRE LA FECHA DE INICIO Y LA FECHA DE FIN ES MENOR DE 1 DIA' --> Si no se cumple lo del día, saldrá un mensaje de error, diciendo que no se ha respestado lo del mínimo de un día.
GO
/*
    --- [Cristian] ---
*/
--REGLA 13: Los reinos unicamente podran ser declarados por usuarios administradores
CREATE TRIGGER TRGIn_AdmPrivilege ON REINOS
INSTEAD OF INSERT -- Antes de insertar, por ello es INSTEAD OF, que haga una comprobación
-- Hacemos una comprobación de que el usuario sea root o no... Si no lo es no puede declarar los reinos
AS
	IF (SELECT TIPO FROM USUARIOS WHERE USUARIOS.USUARIO=(SELECT CREADO_POR FROM INSERTED))<>2 -- De la tabla USUARIOS cogemos el tipo donde en la tabla USUARIOS sea igual al campo CREADO_POR de la nueva tabla, en este caso si es distinto que 2. Quiere decir que el usuario no es administrador
	    BEGIN
	    	PRINT 'ERROR, EL USUARIO NO ES ROOT :V'
	    END
	ELSE
	    BEGIN --> Si es usuario administrador
	    	INSERT INTO REINOS --> Insertamos en la tabla REINOS los datos de la nueva tabla (INSERTED)
	    	SELECT * FROM INSERTED
	    END
GO
-- STORED PROCEDURE CREATION
/*
    --- [Cristian] ---
*/
--REGLA 6: Dada la destruccion de un reino, todos sus territorios deberan volverse tierra de nadie. [SProc_KngdmDestroyed]
CREATE PROCEDURE SProc_KngdmDestroyed
@KINGDOM_DEAD NVARCHAR(35) --Creamos un parámetro, se escoge el campo nombre de la tabla territorios.
AS
	UPDATE TERRITORIOS --Hacemos un UPDATE en la tabla TERRITORIOS
	    SET REINO = NULL -- Donde hacemos que el campo REINO sea nulo
	WHERE TERRITORIOS.REINO = @KINGDOM_DEAD -- En el where cogemos el campo reino que sea igual al parámetro que le pasamos en este caso el nombre del reino.
GO
-- EXEC SProc_KngdmDestroyed 'reino'
/*
    --- [Mario] ---
*/
--REGLA 15: En caso de que un rey caiga, se le sustuira por el legado y este ultimo quedara vacio hasta que se nombre otro. [SProc_RulerDeath]
CREATE PROCEDURE [SProc_RulerDeath] 
@OLDKING NVARCHAR(15)
AS
	DECLARE @NEWKING NVARCHAR(15)
	SET @NEWKING=(SELECT legado FROM REINOS WHERE rey=@OLDKING)
	
	UPDATE REINOS
	    SET rey=legado
	WHERE rey=@OLDKING

	UPDATE REINOS
	    SET legado=NULL
	WHERE rey=@NEWKING
-- EXEC [SProc_RulerDeath] 'rey'
/*
EXPLICACIÓN: en este caso necesitamos un procedimiento que "elimine" el rey caído y lo sustituya por su 
correspondiente legado, para ello declaramos una variable en la que se almacenará el rey a sustituir y 
otra variable en la que almacenaremos el nuevo rey (legado), mediante el procedimiento modificaremos la 
tabla de reinos sustituyendo el rey cuyo nombre coincida con el introducido (OLDKING) por el personaje sea 
el legado en ese momento (mismo registro) y mediante otra modificación dejaremos el puesto de legado como 
nulo, es decir, libre donde el rey sea igual al nuevo rey (el antiguo legado).
*/