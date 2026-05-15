# auth_service.py
# Microservice 1: Authentication (Register & Login)
# Runs on port 5001
#
# Run with: python auth_service.py

import os

from flask import Flask, request, jsonify
from flask_cors import CORS
import bcrypt
import jwt
import datetime
from db import get_connection

#request lets u read what the user sent(JSON)
#jsonify converts a Python dict into a JSON response to send back
#CORS without it ur browser blocks requests from index.html to localhost 5001 cz of security it can t accept smtg from diffrent port
#bycrypt a library for hashing pswd + jwt lib creates and reads tokens btw browser and service + datetime for tocken s expiration tiiime

import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
logger = logging.getLogger("auth_service")

app = Flask(__name__)
CORS(app)  # Allow frontend to call this service

# Secret key for JWT tokens (set JWT_SECRET_KEY in the environment for production)
SECRET_KEY = os.environ.get("JWT_SECRET_KEY", "my_super_secret_key_change_this")
AUTH_SERVICE_PORT = int(os.environ.get("AUTH_SERVICE_PORT", "5001"))
FLASK_DEBUG = os.environ.get("FLASK_DEBUG", "true").lower() in ("1", "true", "yes")


@app.route("/register", methods=["POST"])
def register():
    """Register a new user"""
    data = request.json
    name = data.get("name")
    email = data.get("email")
    password = data.get("password")

    # Basic validation
    if not name or not email or not password:
        return jsonify({"error": "All fields are required"}), 400

    # Hash the password (never store plain text passwords!)
    hashed = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt())

    try:
        conn = get_connection()
        cursor = conn.cursor() #Creates a cursor — the object you use to send SQL queries to the database
        cursor.execute(
            "INSERT INTO users (name, email, password) VALUES (%s, %s, %s)",
            (name, email, hashed.decode("utf-8"))
        )
        conn.commit()
        cursor.close()
        conn.close()
        app.logger.info(f"USER_REGISTERED — IP: {request.remote_addr} — email: {email}")
        return jsonify({"message": "User registered successfully!"}), 201

    except Exception as e:
        # Email already exists
        if "Duplicate" in str(e):
            return jsonify({"error": "Email already registered"}), 409
        return jsonify({"error": str(e)}), 500


@app.route("/login", methods=["POST"])
def login():
    """Login and get a JWT token."""
    data = request.json
    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        return jsonify({"error": "Email and password required"}), 400

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        # Check if user exists and password is correct
        if not user or not bcrypt.checkpw(password.encode("utf-8"), user["password"].encode("utf-8")):
            app.logger.info(f"LOGIN_FAILED — IP: {request.remote_addr} — email: {email}")
            return jsonify({"error": "Invalid email or password"}), 401

        app.logger.info(f"LOGIN_SUCCESS — IP: {request.remote_addr} — email: {email}")

        # Create a JWT token (expires in 24 hours)
        token = jwt.encode({
            "user_id": user["id"],
            "email": user["email"],
            "role": user["role"],
            "name": user["name"],
            "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=24)
        }, SECRET_KEY, algorithm="HS256")

        return jsonify({
            "token": token,
            "user": {
                "id": user["id"],
                "name": user["name"],
                "email": user["email"],
                "role": user["role"]
            }
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/verify", methods=["GET"])
def verify_token():
    """Verify if a JWT token is valid (used by other services)."""
    token = request.headers.get("Authorization", "").replace("Bearer ", "")
    if not token:
        app.logger.info(f"VERIFY_FAILED — No token — IP: {request.remote_addr}")
        return jsonify({"error": "No token provided"}), 401

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        app.logger.info(f"VERIFY_SUCCESS — IP: {request.remote_addr} — user: {payload.get('email')}")
        return jsonify({"valid": True, "user": payload}), 200
    except jwt.ExpiredSignatureError:
        return jsonify({"error": "Token expired"}), 401
    except jwt.InvalidTokenError:
        return jsonify({"error": "Invalid token"}), 401


if __name__ == "__main__":
    print(f"Auth Service running on http://localhost:{AUTH_SERVICE_PORT}")
    app.run(port=AUTH_SERVICE_PORT, host="0.0.0.0", debug=FLASK_DEBUG)
