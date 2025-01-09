
  CREATE OR REPLACE NONEDITIONABLE TRIGGER "INGRESA_SISTEMAS_ANEXOS"."INSOLVENCIA_LOAD_INSERT" 
AFTER INSERT ON INSOLVENCIA_LOAD
FOR EACH ROW
BEGIN
    INSERT INTO INSOLVENCIA_LOAD_insert (
          ID                        ,
          RUT                       ,
          DV                        ,
          FECHA_PUBLICACION         ,
          ROL                       ,
          TRIBUNAL                  ,
          NOMBRE_PUBLICACION        ,
          TIPO_PROCEDIMIENTO        ,
          GRUPO                     ,
          ANIO_LICITACION           ,
          ARANCEL_LICITADO          ,
          CARTERA                   ,
          NOMBRE_BANCO              ,
          ACREEDOR                  ,
          ESTADO_RENOVANTE          ,
          GARANTIAS_APROBADAS       ,
          FECHA_SOLICITUD_GARANTIA  ,
          CREATED_AT                ,
          UPDATED_AT                ,
          ACTIVO                    ,
          CONTADOR_ROW_UNICO        
    )
    VALUES (
        :NEW.ID,
        :NEW.RUT,
        :NEW.DV,
        :NEW.FECHA_PUBLICACION,
        :NEW.ROL,
        :NEW.TRIBUNAL,
        :NEW.NOMBRE_PUBLICACION,
        :NEW.TIPO_PROCEDIMIENTO,
        :NEW.GRUPO,
        :NEW.ANIO_LICITACION,
        :NEW.ARANCEL_LICITADO,
        :NEW.CARTERA,
        :NEW.NOMBRE_BANCO,
        :NEW.ACREEDOR,
        :NEW.ESTADO_RENOVANTE,
        :NEW.GARANTIAS_APROBADAS,
        :NEW.FECHA_SOLICITUD_GARANTIA,
        :NEW.CREATED_AT,
        :NEW.UPDATED_AT,
        :NEW.ACTIVO,
        :NEW.CONTADOR_ROW_UNICO
    );
END;
ALTER TRIGGER "INGRESA_SISTEMAS_ANEXOS"."INSOLVENCIA_LOAD_INSERT" ENABLE


  CREATE OR REPLACE NONEDITIONABLE TRIGGER "INGRESA_SISTEMAS_ANEXOS"."INSOLVENCIA_LOAD_UPDATE" 
AFTER UPDATE ON INSOLVENCIA_LOAD
FOR EACH ROW
BEGIN
    INSERT INTO INSOLVENCIA_LOAD_update (
          ID                        ,
          RUT                       ,
          DV                        ,
          FECHA_PUBLICACION         ,
          ROL                       ,
          TRIBUNAL                  ,
          NOMBRE_PUBLICACION        ,
          TIPO_PROCEDIMIENTO        ,
          GRUPO                     ,
          ANIO_LICITACION           ,
          ARANCEL_LICITADO          ,
          CARTERA                   ,
          NOMBRE_BANCO              ,
          ACREEDOR                  ,
          ESTADO_RENOVANTE          ,
          GARANTIAS_APROBADAS       ,
          FECHA_SOLICITUD_GARANTIA  ,
          CREATED_AT                ,
          UPDATED_AT                ,
          ACTIVO                    ,
          CONTADOR_ROW_UNICO        
    )
    VALUES (
        :NEW.ID,
        :NEW.RUT,
        :NEW.DV,
        :NEW.FECHA_PUBLICACION,
        :NEW.ROL,
        :NEW.TRIBUNAL,
        :NEW.NOMBRE_PUBLICACION,
        :NEW.TIPO_PROCEDIMIENTO,
        :NEW.GRUPO,
        :NEW.ANIO_LICITACION,
        :NEW.ARANCEL_LICITADO,
        :NEW.CARTERA,
        :NEW.NOMBRE_BANCO,
        :NEW.ACREEDOR,
        :NEW.ESTADO_RENOVANTE,
        :NEW.GARANTIAS_APROBADAS,
        :NEW.FECHA_SOLICITUD_GARANTIA,
        :NEW.CREATED_AT,
        :NEW.UPDATED_AT,
        :NEW.ACTIVO,
        :NEW.CONTADOR_ROW_UNICO
    );
END;
ALTER TRIGGER "INGRESA_SISTEMAS_ANEXOS"."INSOLVENCIA_LOAD_UPDATE" ENABLE


  CREATE OR REPLACE NONEDITIONABLE TRIGGER "INGRESA_SISTEMAS_ANEXOS"."INSOLVENCIA_SCRAPPER_TRG_BEFORE_UPDATE" 
BEFORE UPDATE ON INSOLVENCIA_SCRAPPER
FOR EACH ROW
BEGIN
    :NEW.updated_at := CURRENT_TIMESTAMP;
END;
ALTER TRIGGER "INGRESA_SISTEMAS_ANEXOS"."INSOLVENCIA_SCRAPPER_TRG_BEFORE_UPDATE" ENABLE


  CREATE OR REPLACE NONEDITIONABLE TRIGGER "INGRESA_SISTEMAS_ANEXOS"."TRG_UPDATEINSOLVENCIALOAD" 
AFTER UPDATE ON INSOLVENCIA_LOAD
FOR EACH ROW
BEGIN
    INSERT INTO INSOLVENCIA_LOAD_HISTORY 
    VALUES ('ACTUALIZADO');
END;
ALTER TRIGGER "INGRESA_SISTEMAS_ANEXOS"."TRG_UPDATEINSOLVENCIALOAD" ENABLE

