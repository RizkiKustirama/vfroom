import uuid
from datetime import datetime
from sqlalchemy import Column, String, Integer, Boolean, DateTime, ForeignKey, Text
from app.database import Base

class TryonSession(Base):
    __tablename__ = "tryon_sessions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    avatar_id = Column(String(36), ForeignKey("avatars.id", ondelete="RESTRICT"), nullable=False, index=True)
    prompt_text = Column(Text, nullable=True)
    status = Column(String(20), default="pending")  # pending, processing, completed, failed
    processing_time_ms = Column(Integer, nullable=True)
    error_message = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class TryonResult(Base):
    __tablename__ = "tryon_results"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    session_id = Column(String(36), ForeignKey("tryon_sessions.id", ondelete="CASCADE"), nullable=False, index=True)
    result_image_url = Column(String(500), nullable=False)
    is_saved = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
