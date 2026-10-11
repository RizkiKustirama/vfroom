import io
import os
from PIL import Image, ImageFilter
import numpy as np
import logging

logger = logging.getLogger(__name__)

class BackgroundRemover:
    def __init__(self):
        self._session = None

    def remove_background(self, input_image_bytes: bytes) -> bytes:
        """
        Removes background from garment image and crops to bounding box.
        Returns PNG bytes with transparent alpha channel.
        """
        try:
            # Smart Adaptive Color Separation (Instant ~30ms, pure NumPy + PIL)
            raw_img = Image.open(io.BytesIO(input_image_bytes)).convert("RGB")
            arr = np.array(raw_img, dtype=float)
            h, w, _ = arr.shape

            # Sample border corners to detect background color
            border_h = max(10, int(h * 0.03))
            border_w = max(10, int(w * 0.05))

            corner_samples = np.concatenate([
                arr[:border_h, :border_w].reshape(-1, 3),
                arr[:border_h, -border_w:].reshape(-1, 3),
                arr[-border_h:, :border_w].reshape(-1, 3),
                arr[-border_h:, -border_w:].reshape(-1, 3)
            ], axis=0)

            bg_color = np.median(corner_samples, axis=0)

            # Euclidean color distance
            diff = np.sqrt(np.sum((arr - bg_color) ** 2, axis=2))

            # Alpha mask: smooth transition from background to foreground
            alpha = np.clip((diff - 38.0) / 20.0 * 255.0, 0, 255).astype(np.uint8)
            mask_img = Image.fromarray(alpha).filter(ImageFilter.GaussianBlur(1.0))

            rgba = raw_img.convert("RGBA")
            rgba.putalpha(mask_img)

            # Bounding box crop
            bbox = rgba.getbbox()
            if bbox:
                # Add slight padding
                pad = 4
                crop_box = (
                    max(0, bbox[0] - pad),
                    max(0, bbox[1] - pad),
                    min(w, bbox[2] + pad),
                    min(h, bbox[3] + pad)
                )
                rgba = rgba.crop(crop_box)

            out_buf = io.BytesIO()
            rgba.save(out_buf, format="PNG")
            return out_buf.getvalue()

        except Exception as e:
            logger.error(f"Error in background removal: {e}")
            return input_image_bytes

bg_remover = BackgroundRemover()
