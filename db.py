import mysql.connector
from mysql.connector import Error

MYSQL_HOST = "localhost"
MYSQL_PORT = 3306
MYSQL_DB = "dv1587"
MYSQL_USER = "root"
MYSQL_PASSWORD = "Behrzade11" 


def connect_db():
    try:
        conn = mysql.connector.connect(
            host=MYSQL_HOST,
            port=MYSQL_PORT,
            user=MYSQL_USER,
            password=MYSQL_PASSWORD,
            database=MYSQL_DB,
            ssl_disabled=True
        )
        print(" Connected to database!")
        return conn
    except Error as err:
        print(" MySQL Error:", err)
        return None