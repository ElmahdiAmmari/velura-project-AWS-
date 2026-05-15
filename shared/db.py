# db.py - Shared database connection helper
# All microservices import this file

import os
import mysql.connector


def _db_config():
    return {
        "host": os.environ.get("MYSQL_HOST", "mysql"),
        "user": os.environ.get("MYSQL_USER", "rental_user"),
        "password": os.environ.get("MYSQL_PASSWORD", "rental123"),
        "database": os.environ.get("MYSQL_DATABASE", "clothes_rental"),
        "port": int(os.environ.get("MYSQL_PORT", "3306")),
    }


def get_connection():
    """Returns a new MySQL connection."""
    return mysql.connector.connect(**_db_config())
