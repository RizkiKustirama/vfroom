import uuid
from datetime import datetime
from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, UniqueConstraint
from app.database import Base

class Outfit(Base):
    __tablename__ = "outfits"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String(150), default="Casual OOTD", nullable=False)
    preview_image_url = Column(String(500), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class OutfitItem(Base):
    __tablename__ = "outfit_items"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    outfit_id = Column(String(36), ForeignKey("outfits.id", ondelete="CASCADE"), nullable=False, index=True)
    garment_id = Column(String(36), ForeignKey("garments.id", ondelete="CASCADE"), nullable=False, index=True)
    layer_order = Column(Integer, default=1, nullable=False)

    __table_args__ = (
        UniqueConstraint("outfit_id", "garment_id", name="unique_outfit_garment"),
    )
