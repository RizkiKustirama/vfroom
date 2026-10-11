import uuid
from datetime import datetime
from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, JSON
from app.database import Base

class Garment(Base):
    __tablename__ = "garments"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    category_id = Column(Integer, ForeignKey("categories.id", ondelete="RESTRICT"), nullable=False, index=True)
    name = Column(String(150), nullable=False)
    sub_category = Column(String(100), nullable=True)
    brand = Column(String(100), nullable=True)
    image_raw_url = Column(String(500), nullable=False)
    image_clean_url = Column(String(500), nullable=False)
    z_index = Column(Integer, nullable=False)
    ai_parsing_meta = Column(JSON, default=lambda: {"dominant_color": None, "cloth_mask_url": None})
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class GarmentVariant(Base):
    __tablename__ = "garment_variants"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    garment_id = Column(String(36), ForeignKey("garments.id", ondelete="CASCADE"), nullable=False, index=True)
    color_name = Column(String(50), nullable=False)
    color_hex = Column(String(10), nullable=False)
    image_url = Column(String(500), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
