from app.database import engine, Base, SessionLocal
from app.models.category import Category
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def init_db():
    logger.info("Initializing database tables...")
    Base.metadata.create_all(bind=engine)

    # Seed default categories with Z-Index as defined in database_schema.md
    db = SessionLocal()
    try:
        categories_data = [
            {"id": 1, "name": "Bawahan", "slug": "bottom", "default_z_index": 2},
            {"id": 2, "name": "Atasan", "slug": "top", "default_z_index": 3},
            {"id": 3, "name": "Outer / Jaket", "slug": "outer", "default_z_index": 4},
            {"id": 4, "name": "Aksesoris Leher & Sabuk", "slug": "accessory", "default_z_index": 5},
            {"id": 5, "name": "Sepatu & Sandal", "slug": "footwear", "default_z_index": 6},
            {"id": 6, "name": "Aksesoris Kepala & Tas Tangan", "slug": "bag", "default_z_index": 7},
        ]

        for cat in categories_data:
            existing = db.query(Category).filter(Category.id == cat["id"]).first()
            if not existing:
                category_obj = Category(
                    id=cat["id"],
                    name=cat["name"],
                    slug=cat["slug"],
                    default_z_index=cat["default_z_index"]
                )
                db.add(category_obj)
        db.commit()
        logger.info("Default categories seeded successfully.")
    except Exception as e:
        logger.error(f"Error seeding categories: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    init_db()
