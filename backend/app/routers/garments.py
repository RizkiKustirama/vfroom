from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from sqlalchemy.orm import Session
from typing import Optional, List
import io

from app.database import get_db
from app.models.garment import Garment
from app.models.category import Category
from app.schemas.garment_schema import GarmentResponse, GarmentListResponse
from app.services.storage_service import storage_service
from app.ai_engine.bg_removal import bg_remover

router = APIRouter(prefix="/garments", tags=["Garments"])

@router.post("/upload", response_model=GarmentResponse)
async def upload_garment(
    file: UploadFile = File(...),
    user_id: str = Form(...),
    category_id: int = Form(...),
    name: str = Form(...),
    sub_category: Optional[str] = Form(None),
    brand: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    # Verify category
    cat = db.query(Category).filter(Category.id == category_id).first()
    if not cat:
        raise HTTPException(status_code=400, detail="Invalid category_id")

    # Read raw image
    content = await file.read()

    # Step 1: Save raw image
    raw_path, raw_url = storage_service.save_bytes(content, subfolder="raw_uploads", extension=".jpg")

    # Step 2: Background removal via AI
    clean_png_bytes = bg_remover.remove_background(content)
    clean_path, clean_url = storage_service.save_bytes(clean_png_bytes, subfolder="clean_garments", extension=".png")

    # Step 3: Record to database
    garment = Garment(
        user_id=user_id,
        category_id=category_id,
        name=name,
        sub_category=sub_category,
        brand=brand,
        image_raw_url=raw_url,
        image_clean_url=clean_url,
        z_index=cat.default_z_index,
        ai_parsing_meta={"dominant_color": None}
    )
    db.add(garment)
    db.commit()
    db.refresh(garment)

    return garment

@router.get("", response_model=GarmentListResponse)
def list_garments(
    user_id: Optional[str] = None,
    category_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Garment)
    if user_id:
        query = query.filter(Garment.user_id == user_id)
    if category_id:
        query = query.filter(Garment.category_id == category_id)

    items = query.order_by(Garment.created_at.desc()).all()
    return {"items": items, "total": len(items)}
