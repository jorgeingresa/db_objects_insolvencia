
  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "INGRESA_SISTEMAS_ANEXOS"."PRC_CRG_INSOLVENCIA" (
    LOG_ID      IN NUMBER,
    USER_ID     IN NUMBER,
    PARAMETRO   IN NUMBER)
IS

V_ACTIVA_VALIDACIONES NUMBER := 1;

CURSOR P2 IS
    SELECT *
      FROM TEMPORAL_CARGA_GTT
     WHERE MARCA_ERROR = 0 AND MARCA_ERROR_FORMATO = 0;    

--
BEGIN
    SISTEMA_PORCENTAJE_AVANCE (LOG_ID,1,10,5);
    IF V_ACTIVA_VALIDACIONES = 1 THEN
    
        -------------------------------------------
        -- VALIDACIONES 
        -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        -------------------------------------------
        
        -- VALIDA ROL 
        UPDATE TEMPORAL_CARGA_GTT
           SET C1_ERROR = ' - Rol Incorrecto'
        WHERE MARCA_ERROR_FORMATO = 0;
        --
        COMMIT;
        --
        --VALIDA PROCEDIMIENTO CONCURSAL
        UPDATE TEMPORAL_CARGA_GTT
            SET C2_ERROR = ' - Procedimiento Concursal Incorrecto'
        WHERE MARCA_ERROR_FORMATO = 0;
        --
        COMMIT;
        --
        --VALIDA DEUDOR
        UPDATE TEMPORAL_CARGA_GTT
            SET C3_ERROR = ' - Deudor Incorrecto'
        WHERE MARCA_ERROR_FORMATO = 0;
        --
        COMMIT;
        --        
        --VALIDA RUT
        UPDATE TEMPORAL_CARGA_GTT
            SET C4_ERROR = ' - RUT Incorrecto'
        WHERE MARCA_ERROR_FORMATO = 0;
        --
        COMMIT;
        --        
        --VALIDA VEEDOR
        UPDATE TEMPORAL_CARGA_GTT
            SET C5_ERROR = ' - Veedor Liquidador Titular Incorrecto'
        WHERE  MARCA_ERROR_FORMATO = 0;
        --
        COMMIT;
        --            
        --VALIDA NOMBRE PUBLICACION
        UPDATE TEMPORAL_CARGA_GTT
            SET C6_ERROR = ' - Nombre Publicación Incorrecto'
        WHERE  MARCA_ERROR_FORMATO = 0;
        --
        COMMIT;
        --  
        --VALIDA TRIBUNAL
        UPDATE TEMPORAL_CARGA_GTT
            SET C7_ERROR = ' - Tribunal Incorrecto'
        WHERE  MARCA_ERROR_FORMATO = 0;
        --
        COMMIT;
        --
        --FECHA PUBLICACION
        UPDATE TEMPORAL_CARGA_GTT
            SET C8_ERROR = ' - Fecha Publicación Incorrecto'
        WHERE  MARCA_ERROR_FORMATO = 0;
        --
        COMMIT;
        --        
        ------------------------------------------
        -- FIN VALIDACIONES 
        --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        ------------------------------------------
    --
    END IF;
    --
    ------------------------------------------
    -- MARCA ERRORES FINALES DE LA CARGA
    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ------------------------------------------   
   
    UPDATE
        TEMPORAL_CARGA_GTT
    SET
        MARCA_ERROR = 1
    WHERE
        MARCA_ERROR_FORMATO = 0
        AND (C1_ERROR IS NOT NULL
        OR C2_ERROR IS NOT NULL
        OR C3_ERROR IS NOT NULL
        OR C4_ERROR IS NOT NULL
        OR C5_ERROR IS NOT NULL
        OR C6_ERROR IS NOT NULL
        OR C7_ERROR IS NOT NULL
        OR C8_ERROR IS NOT NULL
        );

    PRC_CRG_RESUMEN_CARGA(LOG_ID);
    --
    COMMIT;
    --
    -----------------------------------------
    --FIN MARCA ERRORES FINALES DE LA CARGA
    --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    -----------------------------------------
    
    SISTEMA_PORCENTAJE_AVANCE (LOG_ID,1,70,7);

    -----------------------------------------
    -- GUARDAR 
    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ----------------------------------------
    

    FOR REG IN P2 LOOP
        INSERT INTO INGRESA_SISTEMAS_ANEXOS.CRGG_INSOLVENCIA 
            (
            RUT,                             
            DV,                              
            ROL,                           
            PROCE_CONCURSAL,               
            DEUDOR,                       
            VEE_LIQ_TIT,                   
            NOM_PUB,                       
            TRIBUNAL,
            FECH_PUB,                           
            VIGENCIA)
         VALUES (
              REG.C1    
             ,REG.C2    
             ,REG.C3    
             ,REG.C4    
             ,REG.C5    
             ,REG.C6    
             ,REG.C7    
             ,REG.C8
             ,REG.C9
             ,REG.C10    
                 );
    END LOOP;
    --
    COMMIT;
    --

    -- FIN GUARDAR 
    --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    ----------------------------------------
  
    SISTEMA_PORCENTAJE_AVANCE (LOG_ID,1,80,9);

    COMMIT;

    EXCEPTION WHEN OTHERS THEN
    BEGIN
        GUARDA_ERROR (SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,LOG_ID);                                 
        SISTEMA_EXCEPTION_CARGA (LOG_ID);
        FINALIZA_CARGAS(0,LOG_ID);
    END;
--
END;

