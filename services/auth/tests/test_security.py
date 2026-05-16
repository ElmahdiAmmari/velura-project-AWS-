import os
import sys
from unittest.mock import MagicMock

# 1. Isolation de l'environnement
os.environ["JWT_SECRET_KEY"] = "ci_safety_key_override"
os.environ["AUTH_SERVICE_PORT"] = "5001"
os.environ["FLASK_DEBUG"] = "false"
os.environ["MYSQL_PORT"] = "3306"
os.environ["MYSQL_HOST"] = "127.0.0.1"
os.environ["MYSQL_USER"] = "test"
os.environ["MYSQL_PASSWORD"] = "test"
os.environ["MYSQL_DATABASE"] = "test"

# 2. Interception du connecteur MySQL
import mysql.connector
mysql.connector.connect = MagicMock(return_value=MagicMock())

import pytest
import jwt

@pytest.fixture
def client():
    from auth_service import app
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_verify_token_missing_vulnerability(client):
    """Sécurité : Une requête sans en-tête Authorization doit être rejetée avec une 401"""
    # CORRECTION : Utilisation du nouveau chemin de route AWS (ex: /auth/verify)
    response = client.get('/auth/verify') 
    assert response.status_code == 401
    assert b"No token provided" in response.data

def test_verify_token_corrupted_signature(client):
    """Sécurité : Un token modifié manuellement doit être rejeté (Anti-tampering)"""
    bad_token = jwt.encode({'user': 'attacker'}, 'WRONG_SECRET_KEY', algorithm='HS256')
    
    # CORRECTION : Utilisation du nouveau chemin de route AWS (ex: /auth/verify)
    response = client.get('/auth/verify', headers={
        'Authorization': f'Bearer {bad_token}'
    })
    assert response.status_code == 401