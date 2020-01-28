/*----------------------------------------------
    DATABSE CONSTRUCTOR | Reinos de Thalesia
      Carlos, Mario, Cristian / 2º GFS ASIR
          Centro integrado Cuatrovientos
                  v1.0 Release Ver.
                     28/01/2020
 ----------------------------------------------*/
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

	DECLARE @incodtema CHAR(4)
	SET @incodtema = (SELECT codtema FROM inserted)

	EXEC @gencodconv = TRGHelper_GenWeakCode @incodtema

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
CREATE TRIGGER TRGIn_WeakCodeMsg ON MENSAJES
INSTEAD OF INSERT
AS
    DECLARE @gencodmsg INT

	DECLARE @incodtema CHAR(4),
			@incodconv INT
	SELECT @incodtema = codtema, @incodconv = codconv FROM inserted
    EXEC @gencodmsg = TRGHelper_GenWeakCode @incodtema, @incodconv, 1

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
    @codconv INT = null,
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
	IF NOT EXISTS (SELECT * FROM PERSONAJES WHERE PERSONAJES.USUARIO = (SELECT USUARIO FROM DELETED))
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
	    	magia NVARCHAR(15),
	    	reino NVARCHAR(35)
	    	)

	    	INSERT INTO DEAD_CHARACTERS
	    	SELECT * FROM PERSONAJES
	    	    WHERE PERSONAJES.USUARIO IN (SELECT USUARIO FROM DELETED)
-- En el caso de existir un rey o legado, con esto comprobamos de que existe tal rey o legado.

	    IF EXISTS (SELECT REY FROM REINOS WHERE REINOS.REY = (SELECT USUARIO FROM DELETED))
		BEGIN
			DECLARE @delusuario NVARCHAR(15)
			SET @delusuario = (SELECT usuario FROM deleted)

	    	EXEC SProc_RulerDeath @delusuario
		END

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
	    	SET NOMBRE = (SELECT NOMBRE FROM INSERTED),
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
	    	SET NOMBRE = (SELECT NOMBRE FROM INSERTED),
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
CREATE TRIGGER TRGIn_AdmPrivilegeKngdm ON REINOS
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