
  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "INGRESA_SISTEMAS_ANEXOS"."PCK_INSOLVENCIA" AS
/******************************************************************************
   NAME:       PCK_INSOLVENCIA
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        26/09/2024      Jorge Obreque       1. Created this package.
******************************************************************************/

    PROCEDURE INSOLVENCIA_INSERT_TRANSFORM(ERR OUT VARCHAR2)
IS
    ID_ERROR NUMBER;
    FECHA_ERROR VARCHAR(10);


    BEGIN
       -- Ejecutar la transformación previa
       INSOLVENCIA_INSERT_TRANSFORM_TEMP();
        
        MERGE INTO INSOLVENCIA_LOAD DATA_TARGET
        USING TEMP_INSOLVENCIA_LOAD DATA_SOURCE
        ON (DATA_TARGET.RUT                     = DATA_SOURCE.RUT 
            AND DATA_TARGET.ANIO_LICITACION     = DATA_SOURCE.ANIO_LICITACION 
            AND DATA_TARGET.NOMBRE_PUBLICACION  = DATA_SOURCE.NOMBRE_PUBLICACION 
            AND DATA_TARGET.ROL                 = DATA_SOURCE.ROL 
            AND DATA_TARGET.TRIBUNAL            = DATA_SOURCE.TRIBUNAL
            AND DATA_TARGET.TIPO_PROCEDIMIENTO  = DATA_SOURCE.TIPO_PROCEDIMIENTO
            AND DATA_TARGET.FECHA_PUBLICACION   = DATA_SOURCE.FECHA_PUBLICACION
            AND DATA_TARGET.CONTADOR_ROW_UNICO  = DATA_SOURCE.CONTADOR_ROW_UNICO
            )
        WHEN MATCHED THEN
            UPDATE SET 
                DATA_TARGET.GRUPO                       = DATA_SOURCE.GRUPO,
                DATA_TARGET.ARANCEL_LICITADO            = DATA_SOURCE.ARANCEL_LICITADO,
                DATA_TARGET.CARTERA                     = DATA_SOURCE.CARTERA,
                DATA_TARGET.NOMBRE_BANCO                = DATA_SOURCE.NOMBRE_BANCO,
                DATA_TARGET.ACREEDOR                    = DATA_SOURCE.ACREEDOR,
                DATA_TARGET.ESTADO_RENOVANTE            = DATA_SOURCE.ESTADO_RENOVANTE,
                DATA_TARGET.GARANTIAS_APROBADAS         = DATA_SOURCE.GARANTIAS_APROBADAS,
                DATA_TARGET.FECHA_SOLICITUD_GARANTIA    = DATA_SOURCE.FECHA_SOLICITUD_GARANTIA,
                DATA_TARGET.UPDATED_AT                  = SYSDATE
           
        WHEN NOT MATCHED THEN
            INSERT (RUT, DV, FECHA_PUBLICACION, ROL, TRIBUNAL, NOMBRE_PUBLICACION, TIPO_PROCEDIMIENTO, GRUPO, ANIO_LICITACION, ARANCEL_LICITADO, CARTERA, NOMBRE_BANCO, ACREEDOR, ESTADO_RENOVANTE, GARANTIAS_APROBADAS, FECHA_SOLICITUD_GARANTIA,CONTADOR_ROW_UNICO)
            VALUES (DATA_SOURCE.RUT,
                    DATA_SOURCE.DV,
                    DATA_SOURCE.FECHA_PUBLICACION,
                    DATA_SOURCE.ROL,
                    DATA_SOURCE.TRIBUNAL,
                    DATA_SOURCE.NOMBRE_PUBLICACION,
                    DATA_SOURCE.TIPO_PROCEDIMIENTO,
                    DATA_SOURCE.GRUPO,
                    DATA_SOURCE.ANIO_LICITACION,
                    DATA_SOURCE.ARANCEL_LICITADO,
                    DATA_SOURCE.CARTERA,
                    DATA_SOURCE.NOMBRE_BANCO,
                    DATA_SOURCE.ACREEDOR,
                    DATA_SOURCE.ESTADO_RENOVANTE,
                    DATA_SOURCE.GARANTIAS_APROBADAS,
                    DATA_SOURCE.FECHA_SOLICITUD_GARANTIA,
                    DATA_SOURCE.CONTADOR_ROW_UNICO
            )
;

        ERR := 'SIN ERRORES';

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN

            SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY')  INTO FECHA_ERROR  FROM DUAL;
            
            ERR := '-CODIGO DE ERROR: ' || SQLCODE 
            || ' -FECHA_ERROR: '        || FECHA_ERROR
            || ' -MENSAJE: '            || SQLERRM
            || ' -LINEA: '              || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
            
            -- EN CASO DE ERROR BUSCAR ESTE IDENT EN LA TABLA INGRESA_SISTEMAS_ANEXOS.ERROR_PROCESO
            ID_ERROR := 01102024;
            
            dbms_output.put_line('valor salida error: '||ERR);
            
            GUARDA_ERROR(ERR, ID_ERROR);
            ROLLBACK;
    END INSOLVENCIA_INSERT_TRANSFORM;

    
    
 PROCEDURE INSOLVENCIA_INSERT_TRANSFORM_TEMP
    IS
    BEGIN     
        
        EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_INSOLVENCIA_LOAD';
        INSERT INTO TEMP_INSOLVENCIA_LOAD 
        (RUT, DV, FECHA_PUBLICACION, ROL, TRIBUNAL, NOMBRE_PUBLICACION, TIPO_PROCEDIMIENTO, GRUPO, ANIO_LICITACION, ARANCEL_LICITADO, CARTERA, NOMBRE_BANCO, ACREEDOR, ESTADO_RENOVANTE, GARANTIAS_APROBADAS,FECHA_SOLICITUD_GARANTIA,CONTADOR_ROW_UNICO)
        WITH INSOLVENCIA_HISTORICO_DATA AS(
            SELECT 
                    SUBSTR(A.RUT,0,INSTR(A.RUT,'-') - 1) AS RUT,
                    SUBSTR(A.RUT,-1) AS DV,
                    A.FECHAPUBLICACION AS FECHA_PUBLICACION,
                    A.ROLCAUSA AS ROL, 
                    NVL(A.TRIBUNAL,'Sin Tribunal') AS TRIBUNAL,
                    NVL(A.NOMBREPUBLICACION,'Sin publicacion') AS NOMBRE_PUBLICACION,
                    NVL(A.TIPOPROCEDIMIENTO,'Sin Tipo Procedimiento') AS  TIPO_PROCEDIMIENTO,
                    CASE 
                        WHEN TRANSLATE(UPPER(A.TIPOPROCEDIMIENTO), 'ÁÉÍÓÚÑ', 'AEIOUN') LIKE '%LIQUIDACION%' THEN 'Liquidación'
                        WHEN TRANSLATE(UPPER(A.TIPOPROCEDIMIENTO), 'ÁÉÍÓÚÑ', 'AEIOUN') LIKE '%RENEGOCIACION%' THEN 'Renegociación' 
                        ELSE 'Otro'
                    END AS GRUPO,
                    RUT_ANOS_LICITACION.ANO_LICITACION,
                    NVL(RUT_ANOS_LICITACION.ARANCEL_SOLICITADO,0) AS ARANCEL_SOLICITADO,
                    CASE
                        WHEN CERT.RUT IS NULL THEN 'Gracia'
                        ELSE 'En Servicio' 
                    END AS CARTERA,
                    BANCO_ADMINISTRTADOR.NOMBRE_BANCO AS NOMBRE_BANCO,
                    CASE
                        WHEN BANCO_ACREEDOR.RUT_BANCO = 60805000 THEN 'TGR'
                        ELSE 'BANCO'
                    END ACREEDOR,
                    CASE 
                        WHEN CERT.ESTADO_RENOVANTE = 4 THEN 'Egresado'
                        WHEN CERT.ESTADO_RENOVANTE = 7 THEN 'Desertor'
                        ELSE 'Normal' 
                    END AS ESTADO_RENOVANTE,
                    CASE
                        WHEN PAGO_GARANTIAS.ESTADO_SOL_COD IN (5,6) THEN 'Si'
                        ELSE 'No'
                    END AS GARANTIAS_APROBADAS,
                    PAGO_GARANTIAS.SOLICITUD_FECHA AS FECHA_SOLICITUD_GARANTIA
                FROM INSOLVENCIA_SCRAPPER A
                INNER JOIN (
                    SELECT  
                        H1.RUT,
                        H1.ANO_LICITACION,
                        SUM(H1.ARANCEL_SOLICITADO) AS ARANCEL_SOLICITADO,
                        H1.RUT_BANCO_ADMINISTRADOR,
                        H1.RUT_ACREEDOR_FINANCIERO,
                        H2.ESTADO_RENOVANTE
                    FROM INGRESA_HISTORICO H1
                    INNER JOIN (
                        SELECT RUT, MAX(ANO_OPERACION) AS MAX_ANO_OPERACION
                        FROM INGRESA_HISTORICO
                        GROUP BY RUT
                    ) H2_MAX ON H1.RUT = H2_MAX.RUT
                    INNER JOIN INGRESA_HISTORICO H2 ON H1.RUT = H2.RUT 
                        AND H2.ANO_OPERACION = H2_MAX.MAX_ANO_OPERACION
                        AND H1.ANO_LICITACION = H2.ANO_LICITACION
                    GROUP BY  H1.RUT, H1.ANO_LICITACION, H1.RUT_BANCO_ADMINISTRADOR, H1.RUT_ACREEDOR_FINANCIERO, H2.ESTADO_RENOVANTE
                ) RUT_ANOS_LICITACION  ON   RUT_ANOS_LICITACION.RUT = SUBSTR(A.RUT,0,INSTR(A.RUT,'-') - 1)
                LEFT JOIN CER_CRG_CERTIFICACION_DET CERT ON SUBSTR(A.RUT,0,INSTR(A.RUT,'-') - 1) = CERT.RUT AND RUT_ANOS_LICITACION.ANO_LICITACION = CERT.ANO_LICITACION
                INNER JOIN BNC_BANCOS BANCO_ADMINISTRTADOR ON BANCO_ADMINISTRTADOR.RUT_BANCO = RUT_ANOS_LICITACION.RUT_BANCO_ADMINISTRADOR
                INNER JOIN BNC_BANCOS BANCO_ACREEDOR ON BANCO_ACREEDOR.RUT_BANCO = RUT_ANOS_LICITACION.RUT_ACREEDOR_FINANCIERO
                LEFT JOIN PG_SOLICITUDES PAGO_GARANTIAS ON PAGO_GARANTIAS.RUT_DEUDOR = SUBSTR(A.RUT,0,INSTR(A.RUT,'-') - 1) AND PAGO_GARANTIAS.ANIO_LICITACION =  RUT_ANOS_LICITACION.ANO_LICITACION 
                WHERE EXISTS(
                    SELECT 1 
                    FROM INGRESA_HISTORICO H 
                    WHERE H.RUT = SUBSTR(A.RUT,0,INSTR(A.RUT,'-') - 1)
                )
            )

        SELECT 
            RUT,
            DV,
            FECHA_PUBLICACION,
            ROL,
            TRIBUNAL,
            NOMBRE_PUBLICACION,
            TIPO_PROCEDIMIENTO,
            GRUPO,
            ANO_LICITACION,
            ARANCEL_SOLICITADO,
            CARTERA,
            NOMBRE_BANCO,
            ACREEDOR,
            ESTADO_RENOVANTE,
            GARANTIAS_APROBADAS,
            FECHA_SOLICITUD_GARANTIA,
            ROW_NUMBER() OVER (
                PARTITION BY 
                    RUT
                ORDER BY
                RUT,FECHA_PUBLICACION,ROL,TRIBUNAL,NOMBRE_PUBLICACION,TIPO_PROCEDIMIENTO,GRUPO,ANO_LICITACION,ARANCEL_SOLICITADO 
                DESC) CONTADOR_ROW_UNICO 
        FROM INSOLVENCIA_HISTORICO_DATA;
    COMMIT;   
  
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;

      
    END INSOLVENCIA_INSERT_TRANSFORM_TEMP;


END PCK_INSOLVENCIA;

