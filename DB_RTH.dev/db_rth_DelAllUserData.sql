/*----------------------------------------------
    SP+TRG DelAllUserData | Reinos de Thalesia
        Carlos Labiano Cerón / 2º GFS ASIR
          Centro integrado Cuatrovientos
                        v0.5
                     22/01/2020
 ----------------------------------------------*/
-- INIT DATABASE
USE db_rth
GO

-- [DelAllUserData] + RULE 11 TRIGGER CREATION
CREATE TRIGGER TRGIn_UserDelete ON USUARIOS
INSTEAD OF DELETE
AS
    /* Cristian */
    IF (SELECT TIPO FROM DELETED) = 2
        BEGIN
            PRINT 'NO SE PUEDEN ELIMINAR USUARIOS ADMINISTRADORES'
        END
    ELSE
    /* Carlos */
        BEGIN
            DECLARE @usrlogin NVARCHAR(15)
            SET @usrlogin = (SELECT usuario FROM deleted)
        
            EXEC TRGHelper_DelAllUserData @usrlogin, 1
        
            DELETE FROM USUARIOS
            WHERE usuario = @usrlogin
        END
GO
-- [DelAllUserData] PROCEDURE CREATION
CREATE PROCEDURE TRGHelper_DelAllUserData
    @usrlogin NVARCHAR(15), -- Login del usuario (USUARIOS.usuario)
    @mode BIT = 0 -- (0) Llamado por usuario, (1) Llamado por Trigger
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
    -- Limpieza del personaje
    DELETE FROM PERSONAJES
        WHERE usuario = @usrlogin
    -- Sentencias a ejecutar si el usuario es moderador
    IF @usrtype >= 1
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
    -- Eliminación del usuario si es llamado por usuario (Modo no trigger)
    IF @mode = 1
        DELETE FROM USUARIOS
        WHERE usuario = @usrlogin
GO