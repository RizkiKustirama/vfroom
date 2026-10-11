import os
import time
import logging
from sqlalchemy.orm import Session
from app.models.avatar import Avatar
from app.models.tryon import TryonResult
from app.services.storage_service import storage_service

logger = logging.getLogger(__name__)

def purge_expired_temporary_files(db: Session, max_age_hours: int = 24) -> int:
    """
    Purges temporary avatar previews and try-on results older than max_age_hours
    to prevent memory and disk bloat.
    """
    cutoff_timestamp = time.time() - (max_age_hours * 3600)
    purged_count = 0

    temp_avatars = db.query(Avatar).filter(Avatar.status == "temp").all()
    for av in temp_avatars:
        created_sec = av.created_at.timestamp()
        if created_sec < cutoff_timestamp:
            storage_service.delete_file(av.image_url)
            db.delete(av)
            purged_count += 1

    temp_results = db.query(TryonResult).filter(TryonResult.is_saved == False).all()
    for res in temp_results:
        created_sec = res.created_at.timestamp()
        if created_sec < cutoff_timestamp:
            storage_service.delete_file(res.result_image_url)
            db.delete(res)
            purged_count += 1

    db.commit()
    logger.info(f"Purged {purged_count} temporary items from disk and database.")
    return purged_count
