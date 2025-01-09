FROM oraclelinux:8

# Instalar dependencias necesarias
RUN yum install -y oracle-release-el8 && \
    yum install -y oracle-instantclient-release-el8 && \
    yum install -y oracle-instantclient-basiclite

# Instalar Python y cx_Oracle
RUN yum install -y python39 python39-pip && pip3 install cx_Oracle python-dotenv


# Copiar el script al contenedor
WORKDIR /app
COPY . /app/

CMD ["tail", "-f", "/dev/null"]