import io
from PIL import Image
import numpy as np
from typing import Dict, Any, List, Optional
import logging

logger = logging.getLogger(__name__)

class PoseDetector:
    def __init__(self):
        self._pose = None

    def _get_detector(self):
        if self._pose is None:
            try:
                import mediapipe as mp
                self._mp_pose = mp.solutions.pose
                self._pose = self._mp_pose.Pose(
                    static_image_mode=True,
                    model_complexity=1,
                    enable_segmentation=True,
                    min_detection_confidence=0.5
                )
            except Exception as e:
                logger.warning(f"MediaPipe not initialized, using skeleton fallback: {e}")
                self._pose = False
        return self._pose

    def extract_keypoints(self, image_bytes: bytes) -> Dict[str, Any]:
        """
        Extracts 33 body landmarks and accessory anchor points (eyes, shoulders, hips, wrists).
        """
        img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        w, h = img.size
        detector = self._get_detector()

        if detector:
            import mediapipe as mp
            img_np = np.array(img)
            results = detector.process(img_np)

            if results.pose_landmarks:
                landmarks = []
                for idx, lm in enumerate(results.pose_landmarks.landmark):
                    landmarks.append({
                        "id": idx,
                        "x": lm.x * w,
                        "y": lm.y * h,
                        "z": lm.z,
                        "visibility": lm.visibility
                    })

                # Compute anchor points
                anchors = {
                    "nose": {"x": landmarks[0]["x"], "y": landmarks[0]["y"]},
                    "left_shoulder": {"x": landmarks[11]["x"], "y": landmarks[11]["y"]},
                    "right_shoulder": {"x": landmarks[12]["x"], "y": landmarks[12]["y"]},
                    "chest_center": {
                        "x": (landmarks[11]["x"] + landmarks[12]["x"]) / 2,
                        "y": (landmarks[11]["y"] + landmarks[12]["y"]) / 2
                    },
                    "left_hip": {"x": landmarks[23]["x"], "y": landmarks[23]["y"]},
                    "right_hip": {"x": landmarks[24]["x"], "y": landmarks[24]["y"]},
                    "waist_center": {
                        "x": (landmarks[23]["x"] + landmarks[24]["x"]) / 2,
                        "y": (landmarks[23]["y"] + landmarks[24]["y"]) / 2
                    },
                    "left_wrist": {"x": landmarks[15]["x"], "y": landmarks[15]["y"]},
                    "right_wrist": {"x": landmarks[16]["x"], "y": landmarks[16]["y"]},
                    "left_ankle": {"x": landmarks[27]["x"], "y": landmarks[27]["y"]},
                    "right_ankle": {"x": landmarks[28]["x"], "y": landmarks[28]["y"]},
                }

                return {
                    "width": w,
                    "height": h,
                    "landmarks": landmarks,
                    "anchors": anchors,
                    "status": "detected"
                }

        # Fallback default anatomical ratios if MediaPipe not loaded
        return {
            "width": w,
            "height": h,
            "landmarks": [],
            "anchors": {
                "nose": {"x": w * 0.5, "y": h * 0.15},
                "chest_center": {"x": w * 0.5, "y": h * 0.32},
                "waist_center": {"x": w * 0.5, "y": h * 0.52},
                "left_shoulder": {"x": w * 0.35, "y": h * 0.25},
                "right_shoulder": {"x": w * 0.65, "y": h * 0.25},
                "left_hip": {"x": w * 0.4, "y": h * 0.52},
                "right_hip": {"x": w * 0.6, "y": h * 0.52},
                "left_ankle": {"x": w * 0.42, "y": h * 0.90},
                "right_ankle": {"x": w * 0.58, "y": h * 0.90},
            },
            "status": "estimated"
        }

pose_detector = PoseDetector()
