from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import os
import io
import json
from PIL import Image

from app.database import get_db
from app.models.avatar import Avatar
from app.models.garment import Garment
from app.models.category import Category
from app.models.tryon import TryonSession, TryonResult
from app.schemas.tryon_schema import TryonFitRequest, TryonResultResponse
from app.services.storage_service import storage_service
from app.ai_engine.vton_pipeline import vton_pipeline

router = APIRouter(prefix="/tryon", tags=["Try-On"])

@router.post("/fit", response_model=TryonResultResponse)
def execute_virtual_tryon(
    req: TryonFitRequest,
    db: Session = Depends(get_db)
):
    # Verify avatar
    avatar = db.query(Avatar).filter(Avatar.id == req.avatar_id).first()
    if not avatar:
        raise HTTPException(status_code=404, detail="Avatar not found")

    avatar_path = os.path.join(storage_service.root, avatar.image_url.replace("/storage/", ""))
    if not os.path.exists(avatar_path):
        raise HTTPException(status_code=404, detail="Avatar image file missing on disk")

    base_avatar_img = Image.open(avatar_path).convert("RGBA")

    # Load skeleton anchors if available
    anchors = {}
    if avatar.skeleton_data_url:
        sk_path = os.path.join(storage_service.root, avatar.skeleton_data_url.replace("/storage/", ""))
        if os.path.exists(sk_path):
            with open(sk_path, "r") as f:
                sk_data = json.load(f)
                anchors = sk_data.get("anchors", {})

    # Fetch garments
    garments = db.query(Garment).filter(Garment.id.in_(req.garment_ids)).all()
    garment_items = []

    for g in garments:
        clean_path = os.path.join(storage_service.root, g.image_clean_url.replace("/storage/", ""))
        if os.path.exists(clean_path):
            cat = db.query(Category).filter(Category.id == g.category_id).first()
            slug = cat.slug if cat else "top"
            g_img = Image.open(clean_path).convert("RGBA")
            garment_items.append({
                "image": g_img,
                "z_index": g.z_index,
                "category_slug": slug
            })

    # Create session record
    session = TryonSession(
        user_id=req.user_id,
        avatar_id=req.avatar_id,
        prompt_text=req.prompt_text,
        status="processing"
    )
    db.add(session)
    db.commit()
    db.refresh(session)

    # Run VTON Pipeline
    fitted_image, proc_time = vton_pipeline.run_tryon(
        base_avatar_image=base_avatar_img,
        garment_items=garment_items,
        anchors=anchors,
        prompt_text=req.prompt_text
    )

    buf = io.BytesIO()
    fitted_image.save(buf, format="PNG")
    _, result_url = storage_service.save_bytes(buf.getvalue(), subfolder="temp_cache", extension=".png")

    session.status = "completed"
    session.processing_time_ms = proc_time
    db.commit()

    result = TryonResult(
        session_id=session.id,
        result_image_url=result_url,
        is_saved=False
    )
    db.add(result)
    db.commit()
    db.refresh(result)

    return {
        "id": result.id,
        "session_id": result.session_id,
        "result_image_url": result.result_image_url,
        "is_saved": result.is_saved,
        "processing_time_ms": proc_time,
        "created_at": result.created_at
    }
