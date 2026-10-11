from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class TryonFitRequest(BaseModel):
    user_id: str
    avatar_id: str
    garment_ids: List[str]
    accessory_ids: Optional[List[str]] = []
    prompt_text: Optional[str] = None

class TryonResultResponse(BaseModel):
    id: str
    session_id: str
    result_image_url: str
    is_saved: bool
    processing_time_ms: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True

class TryonSessionResponse(BaseModel):
    id: str
    user_id: str
    avatar_id: str
    prompt_text: Optional[str] = None
    status: str
    processing_time_ms: Optional[int] = None
    result: Optional[TryonResultResponse] = None
    created_at: datetime

    class Config:
        from_attributes = True
