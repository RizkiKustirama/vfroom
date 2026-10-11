from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime

class GarmentVariantBase(BaseModel):
    color_name: str
    color_hex: str
    image_url: Optional[str] = None

class GarmentVariantResponse(GarmentVariantBase):
    id: str
    garment_id: str
    created_at: datetime

    class Config:
        from_attributes = True

class GarmentCreate(BaseModel):
    name: str
    category_id: int
    sub_category: Optional[str] = None
    brand: Optional[str] = None
    z_index: Optional[int] = None

class GarmentResponse(BaseModel):
    id: str
    user_id: str
    category_id: int
    name: str
    sub_category: Optional[str] = None
    brand: Optional[str] = None
    image_raw_url: str
    image_clean_url: str
    z_index: int
    ai_parsing_meta: Optional[Dict[str, Any]] = None
    created_at: datetime

    class Config:
        from_attributes = True

class GarmentListResponse(BaseModel):
    items: List[GarmentResponse]
    total: int
