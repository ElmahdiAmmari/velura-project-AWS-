# catalog_service.py
# Microservice 2: Clothes Catalog (View all clothes)
# Runs on port 5002
#
# Run with: python catalog_service.py

import os
import requests
from functools import wraps

from flask import Flask, request, jsonify
from flask_cors import CORS
from shared.db import get_connection


app = Flask(__name__)
CORS(app)

AUTH_SERVICE_URL = os.environ["AUTH_SERVICE_URL"]

CATALOG_SERVICE_PORT = int(os.environ["CATALOG_SERVICE_PORT"])
FLASK_DEBUG = os.environ["FLASK_DEBUG"].lower() in ("1", "true", "yes")

import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
logger = logging.getLogger("catalog_service")


def verify_auth_token(token):
    """Vérifie le token auprès du service d'authentification."""
    try:
        response = requests.get(
            f"{AUTH_SERVICE_URL}/verify",
            headers={"Authorization": f"Bearer {token}"},
            timeout=5
        )
        if response.status_code == 200:
            return response.json().get("user")
        return None
    except requests.exceptions.RequestException as e:
        app.logger.error(f"Auth service unreachable: {e}")
        return None


def require_auth(f):
    """Décorateur pour sécuriser les routes nécessitant une authentification."""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return jsonify({"error": "Missing or invalid Authorization header"}), 401

        token = auth_header.split(" ")[1]

        user = verify_auth_token(token)
        if not user:
            return jsonify({"error": "Unauthorized or Token Expired"}), 401

        return f(current_user=user, *args, **kwargs)
    return decorated_function


@app.route("/catalog/clothes", methods=["GET"])
def get_all_clothes():
    """Get all clothes. Optional filter by category or size."""
    category = request.args.get("category")
    size = request.args.get("size")
    available_only = request.args.get("available", "false").lower() == "true"

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # Build query dynamically based on filters
        query = "SELECT * FROM clothes WHERE 1=1"
        params = []

        if category:
            query += " AND category = %s"
            params.append(category)
        if size:
            query += " AND size = %s"
            params.append(size)
        if available_only:
            query += " AND available = TRUE"

        query += " ORDER BY created_at DESC"
        cursor.execute(query, params)
        clothes = cursor.fetchall()

        cursor.close()
        conn.close()
        return jsonify(clothes), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/catalog/clothes/<int:cloth_id>", methods=["GET"])
def get_cloth(cloth_id):
    """Get a single cloth by ID."""
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM clothes WHERE id = %s", (cloth_id,))
        cloth = cursor.fetchone()
        cursor.close()
        conn.close()

        if not cloth:
            return jsonify({"error": "Item not found"}), 404
        return jsonify(cloth), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/catalog/categories", methods=["GET"])
def get_categories():
    """Get all unique categories."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT DISTINCT category FROM clothes ORDER BY category")
        categories = [row[0] for row in cursor.fetchall()]
        cursor.close()
        conn.close()
        return jsonify(categories), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/catalog/items", methods=["POST"])
@require_auth
def add_item(current_user):
    """Création d'un article (route protégée — vérification JWT via auth-service)."""
    data = request.json or {}
    name = data.get("name")
    category = data.get("category")
    size = data.get("size")
    price_per_day = data.get("price_per_day")

    if not all([name, category, size, price_per_day]):
        return jsonify({"error": "name, category, size, price_per_day are required"}), 400

    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(
            """INSERT INTO clothes (name, description, category, size, price_per_day, image_url)
               VALUES (%s, %s, %s, %s, %s, %s)""",
            (
                name,
                data.get("description", ""),
                category,
                size,
                price_per_day,
                data.get("image_url", ""),
            ),
        )
        conn.commit()
        new_id = cursor.lastrowid
        cursor.close()
        conn.close()
        return jsonify({
            "message": f"Accès autorisé pour {current_user['email']}",
            "id": new_id,
        }), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/catalog/health")   # or /catalog/health etc.
def health():
    return jsonify({"status": "ok"}), 200

def init_db():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS products (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255),
            price DECIMAL(10,2),
            description TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    conn.commit()
    cursor.close()
    conn.close()

init_db()

if __name__ == "__main__":
    print(f"👗 Catalog Service running on http://localhost:{CATALOG_SERVICE_PORT}")
    app.run(port=CATALOG_SERVICE_PORT, host="0.0.0.0", debug=FLASK_DEBUG)
