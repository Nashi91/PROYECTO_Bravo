--TRIGGERS:

--REGLA 1:

CREATE TRIGGER REGLA1 ON TEMAS
INSTEAD OF INSERT
AS
	IF (SELECT TIPO FROM USUARIOS WHERE usuario=(SELECT creado_por FROM inserted))=2
		BEGIN
			INSERT INTO TEMAS
			SELECT * FROM inserted
		END
	ELSE
		PRINT 'NO PUEDES CREAR UN TEMA PORQUE NO ERES ADMINISTRADOR'
/*
EXPLICACIÓN: en este caso necesitamos limitar el permiso de creación de temas a los usuarios que sean administradores,
para ello mediante un trigger que se lanzará tras intentar añadir registros a temas, comprobaremos que dicho usuario
que intenta crear un nuevo tema "sea de tipo administrador", si lo es se realiza la operación pero si no se envía un 
mensaje de error.
*/

--REGLA 2:

CREATE TRIGGER REGLA2 ON MODERADORES
INSTEAD OF INSERT
AS
	IF (SELECT TIPO FROM USUARIOS WHERE usuario=(SELECT usuario FROM inserted))>=1
		BEGIN
			INSERT INTO MODERADORES
			SELECT * FROM inserted
		END
	ELSE
		PRINT 'NO PUEDES SER AÑADIDO A LOS MODERADORES PORQUE NO ERES MODERADOR'
/*
EXPLICACIÓN: en este caso necesitamos limitar el permiso de moderación de temas a los usuarios que sean moderadores,
un moderador sólo puede moderar un tema si se encuentra en la tabla de moderadores, pero para estar en esa tabla debe 
ser moderador, con lo cual mediante un trigger que se lanzará tras intentar añadir registros a moderadores, 
comprobaremos que dicho usuario se intenta añadir a los moderadores "sea de tipo moderador", si lo es se realiza la 
operación pero si no se envía un mensaje de error.
*/

--Regla 3: El codigo de las conversaciones sera igual al numero de la conversacion dentro de su correspondiente tema. [TRGHelper_GenWeakCode]

--Por optimización se asume que el procedimiento ya existe previamente a la ejecución del trigger.
CREATE PROCEDURE CODCONVERS
@CODTEMA CHAR(4)
AS
	DECLARE @CODCONV INT
	SET @CODCONV=(SELECT COUNT(codtema) FROM CONVERSACIONES WHERE codtema=@CODTEMA)+1
	--En caso de no haber conversaciones la cuenta de codtema dentro de conversaciones daría 0, luego sumaríamos 1.

	RETURN @CODCONV

CREATE TRIGGER REGLA3 ON CONVERSACIONES
INSTEAD OF INSERT
AS
	BEGIN
--@TITULO NVARCHAR(30),
--@CREADOR NVARCHAR(15),
--@FECHACREA DATETIME,
--@BLOQUEADO INT
		EXEC CODCONVERS ''
		INSERT INTO CONVERSACIONES
		SELECT * FROM inserted
		
		--INSERT INTO CONVERSACIONES (codconv,codtema,titulo,creado_por,fecha_creacion,bloqueado)
		--VALUES (@CODCONV,@CODTEMA,@TITULO,@CREADOR,@FECHACREA,@BLOQUEADO)
	END
/*
EXPLICACIÓN:
*/

--Regla 4: El codigo de los mensajes sera igual al numero del mensaje dentro de su correspondiente conversacion.      [^]

CREATE PROCEDURE CODMSJS
AS
	INSERT INTO MENSAJES
	--SELECT * FROM MENSAJES WHERE codmsg=(SELECT COUNT(codconv) FROM MENSAJES WHERE codconv=(SELECT codconv FROM CONVERSACIONES))+1

CREATE TRIGGER REGLA4 ON MENSAJES
AFTER INSERT
	BEGIN
		EXEC CODMSJS
	END
/*
EXPLICACIÓN:
*/

--PROCEDIMIENTOS ALMACENADOS:

--REGLA 15:

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
EXEC [SProc_RulerDeath] ''
/*
EXPLICACIÓN: en este caso necesitamos un procedimiento que "elimine" el rey caído y lo sustituya por su 
correspondiente legado, para ello declaramos una variable en la que se almacenará el rey a sustituir y 
otra variable en la que almacenaremos el nuevo rey (legado), mediante el procedimiento modificaremos la 
tabla de reinos sustituyendo el rey cuyo nombre coincida con el introducido (OLDKING) por el personaje sea 
el legado en ese momento (mismo registro) y mediante otra modificación dejaremos el puesto de legado como 
nulo, es decir, libre donde el rey sea igual al nuevo rey (el antiguo legado).
*/