import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.database import engine, Base

# Ensure test DB tables are created
Base.metadata.create_all(bind=engine)

client = TestClient(app)

def test_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "online"
    assert data["app"] == "FitWardrobe AI (VYRO)"

def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_list_garments_endpoint():
    response = client.get("/api/v1/garments")
    assert response.status_code == 200
    assert "items" in response.json()
    assert "total" in response.json()
