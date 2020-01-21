/*----------------------------------------------
    SP+TRG DelAllUserData | Reinos de Thalesia
        Carlos Labiano Cerón / 2º GFS ASIR
          Centro integrado Cuatrovientos
                        v0.1
                     21/01/2020
 ----------------------------------------------*/
-- INIT DATABASE
USE db_rth
GO
/*  TODO
    -> Combinacion de este TRIGGER con el de que no se puedan eliminar usuarios administradores
    -> Combinacion de este TRIGGER con el de muerte de rey, ver WORK IN PROGRESS
*/

-- [DelAllUserData] TRIGGER CREATION
CREATE TRIGGER TRGIn_UserDelete ON USUARIOS
INSTEAD OF DELETE
AS
    DECLARE @usrlogin NVARCHAR(15)
    SET @usrlogin = (SELECT usuario FROM deleted)

    EXEC TRGHelper_DelAllUserData @usrlogin
GO
-- [DelAllUserData] PROCEDURE CREATION
CREATE PROCEDURE TRGHelper_DelAllUserData
    @usrlogin NVARCHAR(15) -- Login del usuario (USUARIOS.usuario)
AS
    DECLARE @usrtype TINYINT -- Tipo del usuario
    SET @usrtype = (SELECT U.tipo FROM USUARIOS U WHERE U.usuario = @usrlogin)
    -- Eliminación de datos irrelevantes
    DELETE FROM SUPERVISADOS
        WHERE usuario = @usrlogin
    DELETE FROM PARTICIPANTES
        WHERE usuario = @usrlogin
    -- Sustitucion de todas las referencias al usuario por DELETED
    UPDATE CONVERSACIONES
        SET creado_por = 'DELETED'
        WHERE creado_por = @usrlogin
    UPDATE MENSAJES
        SET creado_por = 'DELETED'
        WHERE creado_por = @usrlogin
    -- Sentencias a ejecutar si su personaje es rey o legado
    IF EXISTS (SELECT * FROM REINOS R WHERE R.rey = @usrlogin OR R.legado = @usrlogin)
        BEGIN
            UPDATE REINOS
                SET rey = legado
                WHERE rey = @usrlogin
            /*EXEC SProc_RulerDeath -- WORK IN PROGRESS*/
            UPDATE REINOS
                SET legado = null
                WHERE rey = legado OR legado = @usrlogin
        END
    -- Limpieza del personaje
    EXEC SP_PlayerCharDeath @usrlogin
    DELETE FROM PERSONAJES
        WHERE usuario = @usrlogin
    -- Sentencias a ejecutar si el usuario es moderador
    IF @usrtype = 1
        BEGIN
            DELETE FROM MODERADORES
                WHERE usuario = @usrlogin
        END
    -- Sentencias a ejecutar si el usuario es administrador
    IF @usrtype = 2
        BEGIN
            UPDATE TEMAS
                SET creado_por = 'DELETED'
                WHERE creado_por = @usrlogin
            UPDATE REINOS
                SET creado_por = 'DELETED'
                WHERE creado_por = @usrlogin
        END
    -- Eliminación del usuario
    DELETE FROM USUARIOS
    WHERE usuario = @usrlogin
GO