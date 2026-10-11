import uuid
from datetime import datetime
from sqlalchemy import Column, String, Integer, Boolean, DateTime, ForeignKey, Enum
from app.database import Base
import enum

class AvatarStatus(str, enum.Enum):
    temp = "temp"
    saved = "saved"
    archived = "archived"

class Avatar(Base):
    __tablename__ = "avatars"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    pose_name = Column(String(100), default="Front Standing", nullable=False)
    image_url = Column(String(500), nullable=False)
    skeleton_data_url = Column(String(500), nullable=True)
    rotation_angle = Column(Integer, default=0)
    status = Column(String(20), default="saved")
    is_default = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
