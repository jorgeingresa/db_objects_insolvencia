import cx_Oracle
from dotenv import load_dotenv
import os

class DBObjectExtractor:
    def __init__(self, user, password, host, port, service_name):
        dsn = cx_Oracle.makedsn(host, port, service_name=service_name)
        self.connection = cx_Oracle.connect(user, password, dsn)
        self.cursor = self.connection.cursor()

    def execute_queries(self, queries):
        """
        Ejecuta un conjunto de queries y guarda los resultados en archivos separados.

        :param queries: Diccionario con el nombre del archivo como clave y la consulta SQL como valor.
        """
        for filename, query in queries.items():
            try:
                print(f"Ejecutando consulta para {filename}...\nquery:\n{query}")
                self.cursor.execute(query)

                # Guardar los resultados en un archivo
                with open(filename, "w") as f:
                    for row in self.cursor:
                        f.write(row[0].read() + "\n\n")  # row[0] contiene el CLOB con la DDL
                print(f"Resultados guardados en {filename}")
            except cx_Oracle.DatabaseError as e:
                print(f"Error en la consulta para {filename}: {e}")
            except Exception as e:
                print(f"Error inesperado en {filename}: {e}")

    def close(self):
        """
        Cierra la conexión con la base de datos.
        """
        self.cursor.close()
        self.connection.close()
        print("Conexión cerrada.")

# Definir las consultas SQL corregidas
queries = {
        "DDL/tablas.sql": """
            SELECT DBMS_METADATA.GET_DDL('TABLE', table_name, owner)
            FROM all_tables
            WHERE owner = 'INGRESA_SISTEMAS_ANEXOS'
            AND UPPER(table_name) LIKE '%INSOLVENCIA%'
        """,
        "DDL/vistas.sql": """
            SELECT DBMS_METADATA.GET_DDL('VIEW', view_name, owner)
            FROM all_views
            WHERE owner = 'INGRESA_SISTEMAS_ANEXOS'
            AND UPPER(view_name) LIKE '%INSOLVENCIA%'
        """,
        "DDL/triggers.sql": """
            SELECT DBMS_METADATA.GET_DDL('TRIGGER', trigger_name, owner)
            FROM all_triggers
            WHERE owner = 'INGRESA_SISTEMAS_ANEXOS'
            AND UPPER(trigger_name) LIKE '%INSOLVENCIA%'
        """,
        "DDL/procedures.sql":"""
            SELECT DBMS_METADATA.GET_DDL('PROCEDURE', object_name, owner)
            FROM all_procedures
            WHERE owner = 'INGRESA_SISTEMAS_ANEXOS'
            AND object_type = 'PROCEDURE'
            AND UPPER(OBJECT_NAME) LIKE '%INSOLVENCIA%' 
        """,
        "DDL/functions.sql":"""
            SELECT DBMS_METADATA.GET_DDL('FUNCTION', object_name, owner)
            FROM all_procedures
            WHERE owner = 'INGRESA_SISTEMAS_ANEXOS'
            AND object_type = 'FUNCTION'
            AND UPPER(OBJECT_NAME) LIKE '%INSOLVENCIA%'
        """,
        "DDL/packages.sql":"""
            SELECT DBMS_METADATA.GET_DDL('PACKAGE', object_name, owner)
            FROM all_objects
            WHERE owner = 'INGRESA_SISTEMAS_ANEXOS'
            AND object_type = 'PACKAGE'
            AND UPPER(OBJECT_NAME) LIKE '%INSOLVENCIA%'
        """,
        "DDL/packages_bodies.sql":"""
            SELECT DBMS_METADATA.GET_DDL('PACKAGE_BODY', object_name, owner)
            FROM all_objects
            WHERE owner = 'INGRESA_SISTEMAS_ANEXOS'
            AND object_type = 'PACKAGE BODY'
            AND UPPER(OBJECT_NAME) LIKE '%INSOLVENCIA%'
        """
}

# Uso de la clase
if __name__ == "__main__":
    # Configuración de la base de datos
    load_dotenv()
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT")
    service_name = os.getenv("DB_SERVICE_NAME")

    extractor = DBObjectExtractor(user, password, host, port, service_name)
    try:
        extractor.execute_queries(queries)
    finally:
        extractor.close()
