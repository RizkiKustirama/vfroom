from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime

class AvatarBase(BaseModel):
    pose_name: str = "Front Standing"
    rotation_angle: int = 0
    is_default: bool = False

class AvatarCreate(AvatarBase):
    user_id: str

class AvatarResponse(AvatarBase):
    id: str
    user_id: str
    image_url: str
    skeleton_data_url: Optional[str] = None
    status: str
    created_at: datetime

    class Config:
        from_attributes = True

class GeneratePoseRequest(BaseModel):
    base_avatar_id: str
    target_pose_template: str = "walking" # walking, 45_degree, hands_in_pocket

class PoseActionRequest(BaseModel):
    avatar_id: str
    action: str # "save", "regenerate", "discard"
