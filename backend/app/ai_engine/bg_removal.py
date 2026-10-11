import io
from PIL import Image
import numpy as np
import logging

logger = logging.getLogger(__name__)

class BackgroundRemover:
    def __init__(self):
        self._session = None

    def _get_session(self):
        if self._session is None:
            try:
                import rembg
                self._session = rembg.new_session("u2net")
            except Exception as e:
                logger.warning(f"Could not load rembg session, using Pillow threshold fallback: {e}")
                self._session = False
        return self._session

    def remove_background(self, input_image_bytes: bytes) -> bytes:
        """
        Removes background from garment image and crops to bounding box.
        Returns PNG bytes with transparent alpha channel.
        """
        try:
            session = self._get_session()
            if session:
                import rembg
                output_bytes = rembg.remove(input_image_bytes, session=session)
                img = Image.open(io.BytesIO(output_bytes)).convert("RGBA")
            else:
                # Fallback: simple luminance thresholding for development
                img = Image.open(io.BytesIO(input_image_bytes)).convert("RGBA")
                np_img = np.array(img)
                # Treat pure white or near white background as transparent
                mask = (np_img[:, :, 0] > 240) & (np_img[:, :, 1] > 240) & (np_img[:, :, 2] > 240)
                np_img[mask, 3] = 0
                img = Image.fromarray(np_img)

            # Auto-crop to content bounding box
            bbox = img.getbbox()
            if bbox:
                img = img.crop(bbox)

            out_buf = io.BytesIO()
            img.save(out_buf, format="PNG")
            return out_buf.getvalue()
        except Exception as e:
            logger.error(f"Error in background removal: {e}")
            return input_image_bytes

bg_remover = BackgroundRemover()
