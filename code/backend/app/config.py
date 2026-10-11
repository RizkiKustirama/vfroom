import os
from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    APP_NAME: str = "FitWardrobe AI (VYRO)"
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    PORT: int = 8000
    HOST: str = "0.0.0.0"

    DATABASE_URL: str = "postgresql://postgres:postgres@localhost:5432/vfroom"
    STORAGE_BACKEND: str = "local"
    STORAGE_LOCAL_ROOT: str = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "storage"))

    ENABLE_GPU: bool = False
    DEVICE: str = "cpu"

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()
