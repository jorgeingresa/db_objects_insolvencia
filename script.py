import subprocess
import cx_Oracle

def execute_query():
    # Configura la conexión
    dsn = cx_Oracle.makedsn("10.0.1.184", "1521", service_name="DB1PRE_SCL1WS.SUB01051809441.VNCINGR.ORACLEVCN.COM")
    connection = cx_Oracle.connect("INGRESA_SISTEMAS_ANEXOS", "3VHEFwAQjBPGTZmw._12.Q22.R", dsn)

    cursor = connection.cursor()

    # Ejecuta la consulta
    queries = {
        "tablas.sql": """
            SELECT DBMS_METADATA.GET_DDL('TABLE', table_name, owner)
            FROM all_tables
            WHERE owner = 'INGRESA_SISTEMAS_ANEXOS'
            AND UPPER(table_name) LIKE '%INSOLVENCIA%';
        """,
        "vistas.sql": """
            SELECT DBMS_METADATA.GET_DDL('VIEW', view_name, owner)
            FROM all_views
            WHERE owner = 'INGRESA_SISTEMAS_ANEXOS'
            AND UPPER(view_name) LIKE '%INSOLVENCIA%';
        """,
        "triggers.sql": """
            SELECT DBMS_METADATA.GET_DDL('TRIGGER', trigger_name, owner)
            FROM all_triggers
            WHERE owner = 'INGRESA_SISTEMAS_ANEXOS'
            AND UPPER(trigger_name) LIKE '%INSOLVENCIA%';
        """,
        "procedures.sql":"""
            SELECT DBMS_METADATA.GET_DDL('PROCEDURE', object_name, owner)
            FROM all_procedures
            WHERE owner = 'INGRESA_SISTEMAS_ANEXOS'
            AND object_type = 'PROCEDURE'
            AND UPPER(OBJECT_NAME) LIKE '%INSOLVENCIA%'; 
        """,
        "functions.sql":"""
            SELECT DBMS_METADATA.GET_DDL('FUNCTION', object_name, owner)
            FROM all_procedures
            WHERE owner = 'INGRESA_SISTEMAS_ANEXOS'
            AND object_type = 'FUNCTION'
            AND UPPER(OBJECT_NAME) LIKE '%INSOLVENCIA%';
        """,
        "packages.sql":"""
            SELECT DBMS_METADATA.GET_DDL('PACKAGE', object_name, owner)
            FROM all_objects
            WHERE owner = 'INGRESA_SISTEMAS_ANEXOS'
            AND object_type = 'PACKAGE'
            AND UPPER(OBJECT_NAME) LIKE '%INSOLVENCIA%';
        """,
        "packages_bodies.sql":"""
            SELECT DBMS_METADATA.GET_DDL('PACKAGE_BODY', object_name, owner)
            FROM all_objects
            WHERE owner = 'INGRESA_SISTEMAS_ANEXOS'
            AND object_type = 'PACKAGE BODY'
            AND UPPER(OBJECT_NAME) LIKE '%INSOLVENCIA%';
        """
    }
    
    try:
        for filename, query in queries.items():
            print(f"Ejecutando consulta para {filename}...")
            print(f"query: {query}")
            cursor.execute(query)

            # Escribir resultados en un archivo
            with open(filename, "w") as f:
                for row in cursor:
                    f.write(row[0].read() + "\n\n")  # row[0] contiene el CLOB con la DDL

    except cx_Oracle.DatabaseError as e:
        print("Error en la consulta:", e)
    finally:
        cursor.close()
        connection.close()


execute_query()
