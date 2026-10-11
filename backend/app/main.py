import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.config import settings
from app.routers import garments, avatars, tryon

app = FastAPI(
    title=settings.APP_NAME,
    description="Backend REST API & AI Inference Engine for FitWardrobe AI (VYRO)",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Serve storage files statically
if os.path.exists(settings.STORAGE_LOCAL_ROOT):
    app.mount("/storage", StaticFiles(directory=settings.STORAGE_LOCAL_ROOT), name="storage")

# Include Routers
app.include_router(garments.router, prefix="/api/v1")
app.include_router(avatars.router, prefix="/api/v1")
app.include_router(tryon.router, prefix="/api/v1")

@app.get("/", tags=["Health"])
async def root():
    return {
        "status": "online",
        "app": settings.APP_NAME,
        "environment": settings.ENVIRONMENT,
        "version": "1.0.0"
    }

@app.get("/health", tags=["Health"])
async def health_check():
    return {"status": "healthy"}
