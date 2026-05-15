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
    response = client.get('/verify')
    assert response.status_code == 401
    assert b"No token provided" in response.data

def test_verify_token_corrupted_signature(client):
    """Sécurité : Un token modifié manuellement doit être rejeté (Anti-tampering)"""
    bad_token = jwt.encode({'user': 'attacker'}, 'WRONG_SECRET_KEY', algorithm='HS256')
    
    response = client.get('/verify', headers={
        'Authorization': f'Bearer {bad_token}'
    })
    assert response.status_code == 401