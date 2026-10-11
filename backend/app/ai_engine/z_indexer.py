import io
from PIL import Image
from typing import List, Dict, Any
import logging

logger = logging.getLogger(__name__)

class ZIndexEngine:
    """
    Z-Index Layer Hierarchy according to PRD v2.0 & virtual_tryon_architecture.md:
    - Layer 1: Base Avatar (User Body)
    - Layer 1.5: Backpack Body (behind torso)
    - Layer 2: Bottom (Pants / Skirt)
    - Layer 3: Top (T-Shirt / Shirt)
    - Layer 4: Outer (Jacket / Coat)
    - Layer 5: Accessories (Belt, Tie, Crossbody Strap)
    - Layer 6: Footwear (Shoes / Sneakers)
    - Layer 7: Outermost Accessories (Cap, Glasses, Watch, Handbag)
    """

    def composite_outfit(
        self,
        base_avatar_image: Image.Image,
        garment_items: List[Dict[str, Any]],
        anchors: Dict[str, Any]
    ) -> Image.Image:
        """
        Composites garments onto base avatar sorted by z_index.
        Each item dict contains: {'image': PIL.Image, 'z_index': int, 'category_slug': str}
        """
        # Sort items strictly by z_index ascending
        sorted_items = sorted(garment_items, key=lambda x: x.get("z_index", 3))

        canvas = base_avatar_image.convert("RGBA")
        canvas_w, canvas_h = canvas.size

        for item in sorted_items:
            g_img = item["image"].convert("RGBA")
            slug = item.get("category_slug", "top")

            # Calculate anchor target on avatar canvas
            if slug == "top":
                target_w = int(canvas_w * 0.45)
                ratio = target_w / max(1, g_img.width)
                target_h = int(g_img.height * ratio)
                g_resized = g_img.resize((target_w, target_h), Image.Resampling.LANCZOS)
                # Align to chest
                chest = anchors.get("chest_center", {"x": canvas_w * 0.5, "y": canvas_h * 0.32})
                pos_x = int(chest["x"] - (target_w / 2))
                pos_y = int(chest["y"] - (target_h * 0.25))
                canvas.alpha_composite(g_resized, dest=(pos_x, pos_y))

            elif slug == "bottom":
                target_w = int(canvas_w * 0.42)
                ratio = target_w / max(1, g_img.width)
                target_h = int(g_img.height * ratio)
                g_resized = g_img.resize((target_w, target_h), Image.Resampling.LANCZOS)
                waist = anchors.get("waist_center", {"x": canvas_w * 0.5, "y": canvas_h * 0.52})
                pos_x = int(waist["x"] - (target_w / 2))
                pos_y = int(waist["y"] - 10)
                canvas.alpha_composite(g_resized, dest=(pos_x, pos_y))

            elif slug in ["outer"]:
                target_w = int(canvas_w * 0.50)
                ratio = target_w / max(1, g_img.width)
                target_h = int(g_img.height * ratio)
                g_resized = g_img.resize((target_w, target_h), Image.Resampling.LANCZOS)
                chest = anchors.get("chest_center", {"x": canvas_w * 0.5, "y": canvas_h * 0.32})
                pos_x = int(chest["x"] - (target_w / 2))
                pos_y = int(chest["y"] - (target_h * 0.28))
                canvas.alpha_composite(g_resized, dest=(pos_x, pos_y))

            elif slug in ["footwear"]:
                target_w = int(canvas_w * 0.35)
                ratio = target_w / max(1, g_img.width)
                target_h = int(g_img.height * ratio)
                g_resized = g_img.resize((target_w, target_h), Image.Resampling.LANCZOS)
                pos_x = int((canvas_w - target_w) / 2)
                pos_y = int(canvas_h - target_h - 15)
                canvas.alpha_composite(g_resized, dest=(pos_x, pos_y))

            else:
                # Default generic overlay (Cap, Bag, Accessories)
                target_w = int(canvas_w * 0.30)
                ratio = target_w / max(1, g_img.width)
                target_h = int(g_img.height * ratio)
                g_resized = g_img.resize((target_w, target_h), Image.Resampling.LANCZOS)
                pos_x = int((canvas_w - target_w) / 2)
                pos_y = int(canvas_h * 0.10)
                canvas.alpha_composite(g_resized, dest=(pos_x, pos_y))

        return canvas

z_index_engine = ZIndexEngine()
