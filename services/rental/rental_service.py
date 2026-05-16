# rental_service.py
# Microservice 3: Rental Management (Rent & Return clothes)
# Runs on port 5003
#
# Run with: python rental_service.py

import os

from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import datetime
from shared.db import get_connection



app = Flask(__name__)
CORS(app)

# Auth service URL (to verify tokens); use service DNS in Docker, full URL on AWS
AUTH_SERVICE = os.environ["AUTH_SERVICE_URL"].rstrip("/")
RENTAL_SERVICE_PORT = int(os.environ["RENTAL_SERVICE_PORT"])
FLASK_DEBUG = os.environ["FLASK_DEBUG"].lower() in ("1", "true", "yes")

import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
logger = logging.getLogger("rental_service")

def verify_token(token):
    """Helper: Ask auth service if this token is valid."""
    try:
        response = requests.get(
            f"{AUTH_SERVICE}/verify",
            headers={"Authorization": f"Bearer {token}"}
        )
        if response.status_code == 200:
            return response.json()["user"]
        return None
    except:
        return None


def get_token_from_request():
    """Extract Bearer token from request headers."""
    auth_header = request.headers.get("Authorization", "")
    return auth_header.replace("Bearer ", "")


@app.route("/rental/rent", methods=["POST"])
def rent_cloth():
    """Rent a clothing item."""
    # 1. Check if user is logged in
    token = get_token_from_request()
    user = verify_token(token)
    if not user:
        return jsonify({"error": "Please login to rent items"}), 401

    data = request.json
    cloth_id = data.get("cloth_id")
    start_date = data.get("start_date")   # Format: YYYY-MM-DD
    end_date = data.get("end_date")       # Format: YYYY-MM-DD

    if not cloth_id or not start_date or not end_date:
        return jsonify({"error": "cloth_id, start_date, end_date are required"}), 400

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # 2. Check if the item exists and is available
        cursor.execute("SELECT * FROM clothes WHERE id = %s", (cloth_id,))
        cloth = cursor.fetchone()

        if not cloth:
            return jsonify({"error": "Item not found"}), 404
        if not cloth["available"]:
            return jsonify({"error": "This item is not available"}), 400

        # 3. Calculate total price
        start = datetime.datetime.strptime(start_date, "%Y-%m-%d")
        end = datetime.datetime.strptime(end_date, "%Y-%m-%d")
        days = (end - start).days

        if days <= 0:
            return jsonify({"error": "End date must be after start date"}), 400

        total_price = days * float(cloth["price_per_day"])

        # 4. Create rental record
        cursor.execute(
            """INSERT INTO rentals (user_id, cloth_id, start_date, end_date, total_price, status)
               VALUES (%s, %s, %s, %s, %s, 'active')""",
            (user["user_id"], cloth_id, start_date, end_date, total_price)
        )

        # 5. Mark item as unavailable
        cursor.execute("UPDATE clothes SET available = FALSE WHERE id = %s", (cloth_id,))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({
            "message": "Item rented successfully!",
            "rental": {
                "cloth_name": cloth["name"],
                "start_date": start_date,
                "end_date": end_date,
                "days": days,
                "total_price": total_price
            }
        }), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/rental/my-rentals", methods=["GET"])
def my_rentals():
    """Get all rentals for the logged-in user."""
    token = get_token_from_request()
    user = verify_token(token)
    if not user:
        return jsonify({"error": "Please login"}), 401

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT r.*, c.name AS cloth_name, c.image_url, c.category
            FROM rentals r
            JOIN clothes c ON r.cloth_id = c.id
            WHERE r.user_id = %s
            ORDER BY r.created_at DESC
        """, (user["user_id"],))
        rentals = cursor.fetchall()

        # Convert date objects to strings for JSON
        for rental in rentals:
            rental["start_date"] = str(rental["start_date"])
            rental["end_date"] = str(rental["end_date"])
            rental["created_at"] = str(rental["created_at"])

        cursor.close()
        conn.close()
        return jsonify(rentals), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/rental/return/<int:rental_id>", methods=["POST"])
def return_item(rental_id):
    """Return a rented item."""
    token = get_token_from_request()
    user = verify_token(token)
    if not user:
        return jsonify({"error": "Please login"}), 401

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # Find the rental
        cursor.execute("SELECT * FROM rentals WHERE id = %s AND user_id = %s", (rental_id, user["user_id"]))
        rental = cursor.fetchone()

        if not rental:
            return jsonify({"error": "Rental not found"}), 404

        # Update rental status
        cursor.execute("UPDATE rentals SET status = 'returned' WHERE id = %s", (rental_id,))
        # Mark cloth as available again
        cursor.execute("UPDATE clothes SET available = TRUE WHERE id = %s", (rental["cloth_id"],))

        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"message": "Item returned successfully!"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/rental/health")   # or /catalog/health etc.
def health():
    return jsonify({"status": "ok"}), 200

def init_db():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS rentals (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT,
            product_id INT,
            start_date DATE,
            end_date DATE,
            status VARCHAR(50),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    conn.commit()
    cursor.close()
    conn.close()

init_db()

if __name__ == "__main__":
    print(f"📦 Rental Service running on http://localhost:{RENTAL_SERVICE_PORT}")
    app.run(port=RENTAL_SERVICE_PORT, host="0.0.0.0", debug=FLASK_DEBUG)
