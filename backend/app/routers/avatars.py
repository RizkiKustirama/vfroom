from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from sqlalchemy.orm import Session
from typing import Optional, List
import json
import os
from PIL import Image

from app.database import get_db
from app.models.avatar import Avatar
from app.schemas.avatar_schema import AvatarResponse, GeneratePoseRequest, PoseActionRequest
from app.services.storage_service import storage_service
from app.ai_engine.pose_detector import pose_detector
from app.ai_engine.pose_generator import pose_generator

router = APIRouter(prefix="/avatars", tags=["Avatars"])

@router.post("/base", response_model=AvatarResponse)
async def create_base_avatar(
    file: UploadFile = File(...),
    user_id: str = Form(...),
    pose_name: str = Form("Front Standing"),
    db: Session = Depends(get_db)
):
    content = await file.read()

    # Step 1: Save full-body image
    path, img_url = storage_service.save_bytes(content, subfolder="raw_uploads", extension=".jpg")

    # Step 2: Extract keypoints via MediaPipe
    keypoints = pose_detector.extract_keypoints(content)

    # Save skeleton JSON
    json_bytes = json.dumps(keypoints).encode("utf-8")
    _, skeleton_url = storage_service.save_bytes(json_bytes, subfolder="raw_uploads", extension=".json")

    avatar = Avatar(
        user_id=user_id,
        pose_name=pose_name,
        image_url=img_url,
        skeleton_data_url=skeleton_url,
        rotation_angle=0,
        status="saved",
        is_default=True
    )
    db.add(avatar)
    db.commit()
    db.refresh(avatar)
    return avatar

@router.post("/generate-pose")
def generate_new_pose(
    req: GeneratePoseRequest,
    db: Session = Depends(get_db)
):
    base_avatar = db.query(Avatar).filter(Avatar.id == req.base_avatar_id).first()
    if not base_avatar:
        raise HTTPException(status_code=404, detail="Base avatar not found")

    rel_path = base_avatar.image_url.replace("/storage/", "")
    full_path = os.path.join(storage_service.root, rel_path)

    if not os.path.exists(full_path):
        raise HTTPException(status_code=404, detail="Avatar image file not found on disk")

    with Image.open(full_path) as img:
        new_img, duration = pose_generator.generate_pose(img, pose_template=req.target_pose_template)
        import io
        buf = io.BytesIO()
        new_img.save(buf, format="PNG")
        _, temp_url = storage_service.save_bytes(buf.getvalue(), subfolder="temp_cache", extension=".png")

    temp_avatar = Avatar(
        user_id=base_avatar.user_id,
        pose_name=f"Pose {req.target_pose_template.capitalize()}",
        image_url=temp_url,
        skeleton_data_url=base_avatar.skeleton_data_url,
        rotation_angle=0,
        status="temp",
        is_default=False
    )
    db.add(temp_avatar)
    db.commit()
    db.refresh(temp_avatar)

    return {
        "temp_avatar_id": temp_avatar.id,
        "temp_avatar_url": temp_avatar.image_url,
        "status": "preview",
        "processing_time_ms": duration
    }

@router.post("/pose/action")
def handle_pose_action(
    req: PoseActionRequest,
    db: Session = Depends(get_db)
):
    avatar = db.query(Avatar).filter(Avatar.id == req.avatar_id).first()
    if not avatar:
        raise HTTPException(status_code=404, detail="Avatar not found")

    if req.action == "save":
        avatar.status = "saved"
        db.commit()
        return {"status": "saved", "message": "Avatar pose saved to user library"}

    elif req.action == "discard":
        # Discard immediately from storage and DB
        storage_service.delete_file(avatar.image_url)
        db.delete(avatar)
        db.commit()
        return {"status": "discarded", "message": "Temporary avatar purged from storage"}

    elif req.action == "regenerate":
        return {"status": "regenerate_requested"}

    raise HTTPException(status_code=400, detail="Invalid action")
