from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import Base, engine
from app.auth.router import router as auth_router
from app.users.router import router as users_router
from app.subscriptions.router import router as subscriptions_router
from app.catalog.router import router as catalog_router
from app.rentals.router import router as rentals_router
from app.ai.router import router as ai_router
import os


# Crée toutes les tables en DB automatiquement au démarrage
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Velura API", version="1.0.0")
# CORS — permet au frontend (port 3000) d'appeler le backend (port 8000)

# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["http://localhost:3000"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",                          # local dev
        os.getenv("FRONTEND_URL", "http://localhost:3000") # AWS ALB URL injected via env
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Toutes les routes sous /api/
app.include_router(auth_router,          prefix="/api")
app.include_router(users_router,         prefix="/api")
app.include_router(subscriptions_router, prefix="/api")
app.include_router(catalog_router,       prefix="/api")
app.include_router(rentals_router,       prefix="/api")
app.include_router(ai_router,            prefix="/api")

@app.get("/")
def root():
    return {"message": "Velura API is running ✅"}
