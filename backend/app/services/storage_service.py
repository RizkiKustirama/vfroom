import os
import uuid
import aiofiles
from fastapi import UploadFile
from app.config import settings

class StorageService:
    def __init__(self):
        self.root = settings.STORAGE_LOCAL_ROOT
        self.raw_dir = os.path.join(self.root, "raw_uploads")
        self.clean_dir = os.path.join(self.root, "clean_garments")
        self.temp_dir = os.path.join(self.root, "temp_cache")

        os.makedirs(self.raw_dir, exist_ok=True)
        os.makedirs(self.clean_dir, exist_ok=True)
        os.makedirs(self.temp_dir, exist_ok=True)

    async def save_upload(self, file: UploadFile, subfolder: str = "raw_uploads") -> tuple[str, str]:
        ext = os.path.splitext(file.filename or ".png")[1]
        filename = f"{uuid.uuid4()}{ext}"
        target_dir = os.path.join(self.root, subfolder)
        os.makedirs(target_dir, exist_ok=True)
        filepath = os.path.join(target_dir, filename)

        async with aiofiles.open(filepath, "wb") as f:
            content = await file.read()
            await f.write(content)

        relative_url = f"/storage/{subfolder}/{filename}"
        return filepath, relative_url

    def save_bytes(self, data: bytes, subfolder: str, extension: str = ".png") -> tuple[str, str]:
        filename = f"{uuid.uuid4()}{extension}"
        target_dir = os.path.join(self.root, subfolder)
        os.makedirs(target_dir, exist_ok=True)
        filepath = os.path.join(target_dir, filename)

        with open(filepath, "wb") as f:
            f.write(data)

        relative_url = f"/storage/{subfolder}/{filename}"
        return filepath, relative_url

    def delete_file(self, relative_url: str) -> bool:
        try:
            rel_path = relative_url.replace("/storage/", "")
            full_path = os.path.join(self.root, rel_path)
            if os.path.exists(full_path):
                os.remove(full_path)
                return True
        except Exception:
            pass
        return False

storage_service = StorageService()
