# db.py - Shared database connection helper
# All microservices import this file

import os
import mysql.connector


def _db_config():
    return {
        "host": os.environ["MYSQL_HOST"],
        "user": os.environ["MYSQL_USER"],
        "password": os.environ["MYSQL_PASSWORD"],
        "database": os.environ["MYSQL_DATABASE"],
        "port": int(os.environ["MYSQL_PORT"]),
    }


def get_connection():
    """Returns a new MySQL connection."""
    return mysql.connector.connect(**_db_config())
