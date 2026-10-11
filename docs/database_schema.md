# 🗄️ Database Schema - VYRO / FitWardrobe AI

Dokumen ini memuat skema basis data relasional lengkap (**PostgreSQL / Supabase compatible**) yang dirancang untuk mendukung seluruh alur kerja aplikasi mobile **AI Virtual Try-On & Wardrobe Stylist**.

---

## 1. Entity Relationship Diagram (ERD)

```mermaid
erdiagram
    USERS ||--o{ AVATARS : "has many"
    USERS ||--o{ GARMENTS : "owns many"
    USERS ||--o{ OUTFITS : "creates many"
    USERS ||--o{ TRYON_SESSIONS : "runs many"
    USERS ||--o{ FAVORITES : "bookmarks"

    CATEGORIES ||--o{ GARMENTS : "classifies"
    
    GARMENTS ||--o{ GARMENT_VARIANTS : "has colors"
    GARMENTS ||--o{ OUTFIT_ITEMS : "included in"
    
    OUTFITS ||--o{ OUTFIT_ITEMS : "contains"
    
    AVATARS ||--o{ TRYON_SESSIONS : "used as model"
    TRYON_SESSIONS ||--o{ TRYON_RESULTS : "produces"

    USERS {
        uuid id PK
        string email
        string full_name
        jsonb body_profile
        timestamp created_at
    }

    AVATARS {
        uuid id PK
        uuid user_id FK
        string pose_name
        string image_url
        string skeleton_data_url
        int rotation_angle
        enum status
        boolean is_default
        timestamp created_at
    }

    CATEGORIES {
        int id PK
        string name
        string slug
        int default_z_index
    }

    GARMENTS {
        uuid id PK
        uuid user_id FK
        int category_id FK
        string name
        string brand
        string image_raw_url
        string image_clean_url
        int z_index
        jsonb ai_parsing_meta
        timestamp created_at
    }

    GARMENT_VARIANTS {
        uuid id PK
        uuid garment_id FK
        string color_name
        string color_hex
        string image_url
    }

    OUTFITS {
        uuid id PK
        uuid user_id FK
        string title
        string preview_image_url
        timestamp created_at
    }

    OUTFIT_ITEMS {
        uuid id PK
        uuid outfit_id FK
        uuid garment_id FK
        int layer_order
    }

    TRYON_SESSIONS {
        uuid id PK
        uuid user_id FK
        uuid avatar_id FK
        string prompt_text
        enum status
        int processing_time_ms
        timestamp created_at
    }

    TRYON_RESULTS {
        uuid id PK
        uuid session_id FK
        string result_image_url
        boolean is_saved
        timestamp created_at
    }

    FAVORITES {
        uuid id PK
        uuid user_id FK
        uuid garment_id FK
        uuid outfit_id FK
        timestamp created_at
    }
```

---

## 2. PostgreSQL DDL (SQL Script Siap Pakai)

Script SQL di bawah ini dapat langsung dijalankan pada **PostgreSQL**, **Supabase**, atau **Neon DB**.

```sql
-- Enable extension UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. ENUMS
-- ============================================================================
CREATE TYPE avatar_status_enum AS ENUM ('temp', 'saved', 'archived');
CREATE TYPE tryon_status_enum AS ENUM ('pending', 'processing', 'completed', 'failed');
CREATE TYPE category_type_enum AS ENUM ('top', 'bottom', 'outer', 'footwear', 'accessory', 'bag');

-- ============================================================================
-- 2. TABEL USERS & BODY PROFILE
-- ============================================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    avatar_thumbnail_url TEXT,
    -- body_profile menyimpan estimasi tinggi, bentuk badan, atau rasio pose untuk AI
    body_profile JSONB DEFAULT '{"height_cm": null, "weight_kg": null, "gender": "unspecified"}'::JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 3. TABEL AVATARS (MODEL FOTO BADAN USER & POSE LIBRARY)
-- ============================================================================
CREATE TABLE avatars (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    pose_name VARCHAR(100) NOT NULL DEFAULT 'Front Standing', -- misal: Front, 45 Degree, Walking
    image_url TEXT NOT NULL,                                  -- Foto badan user full-body
    skeleton_data_url TEXT,                                   -- JSON koordinat keypoints MediaPipe/OpenPose
    rotation_angle INT DEFAULT 0,                             -- 0, 90, 180, 270, 360 (untuk rotasi UI)
    status avatar_status_enum DEFAULT 'saved',                -- 'temp' untuk preview generasi sebelum di-save
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_avatars_user_id ON avatars(user_id);

-- ============================================================================
-- 4. TABEL KATEGORI PAKAIAN & DEFAULT Z-INDEX
-- ============================================================================
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,                               -- Atasan, Bawahan, Sepatu, dll
    slug category_type_enum NOT NULL UNIQUE,
    default_z_index INT NOT NULL                             -- Urutan lapis standar
);

-- Inisialisasi Kategori Standar
INSERT INTO categories (name, slug, default_z_index) VALUES
('Bawahan', 'bottom', 2),
('Atasan', 'top', 3),
('Outer / Jaket', 'outer', 4),
('Aksesoris Leher & Sabuk', 'accessory', 5),
('Sepatu & Sandal', 'footwear', 6),
('Aksesoris Kepala & Tas Tangan', 'bag', 7);

-- ============================================================================
-- 5. TABEL GARMENTS (KATALOG PAKAIAN USER DARI HASIL FOTO)
-- ============================================================================
CREATE TABLE garments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id INT NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    name VARCHAR(150) NOT NULL,                               -- Contoh: "Nexus Tech Jacket", "Oversized Black Tee"
    sub_category VARCHAR(100),                                -- Hoodie, Kemeja, Jeans, Cargo
    brand VARCHAR(100),
    image_raw_url TEXT NOT NULL,                              -- Foto asli dari kamera HP sebelum crop
    image_clean_url TEXT NOT NULL,                            -- Foto PNG transparan hasil RMBG-1.4
    z_index INT NOT NULL,                                     -- Urutan rendering penumpukan lapis
    -- Menyimpan bounding box, segmentasi mask, dan dominant colors
    ai_parsing_meta JSONB DEFAULT '{"dominant_color": null, "cloth_mask_url": null}'::JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_garments_user_category ON garments(user_id, category_id);

-- ============================================================================
-- 6. TABEL GARMENT VARIANTS (PILIHAN WARNA SWATCH ALA UI)
-- ============================================================================
CREATE TABLE garment_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    garment_id UUID NOT NULL REFERENCES garments(id) ON DELETE CASCADE,
    color_name VARCHAR(50) NOT NULL,                          -- Black, Olive, Nude, Orange
    color_hex VARCHAR(10) NOT NULL,                           -- #18181B, #4D5D4E, dll
    image_url TEXT,                                           -- URL gambar spesifik warna tsb
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 7. TABEL OUTFITS & OUTFIT ITEMS (KOLEKSI SETELAN TERSIMPAN)
-- ============================================================================
CREATE TABLE outfits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL DEFAULT 'Casual OOTD',
    preview_image_url TEXT,                                   -- Hasil gabungan fitting baju
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE outfit_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    outfit_id UUID NOT NULL REFERENCES outfits(id) ON DELETE CASCADE,
    garment_id UUID NOT NULL REFERENCES garments(id) ON DELETE CASCADE,
    layer_order INT NOT NULL DEFAULT 1,                       -- Prioritas tumpukan saat dipakai
    CONSTRAINT unique_outfit_garment UNIQUE (outfit_id, garment_id)
);

-- ============================================================================
-- 8. TABEL TRYON SESSIONS & RESULTS (LOG PROSES AI FITTING)
-- ============================================================================
CREATE TABLE tryon_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    avatar_id UUID NOT NULL REFERENCES avatars(id) ON DELETE RESTRICT,
    prompt_text TEXT,                                         -- "Describe your look..." bar
    status tryon_status_enum DEFAULT 'pending',
    processing_time_ms INT,                                   -- Durasi inferensi AI
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tryon_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES tryon_sessions(id) ON DELETE CASCADE,
    result_image_url TEXT NOT NULL,                           -- URL gambar fitting yang dihasilkan AI
    is_saved BOOLEAN DEFAULT FALSE,                           -- True jika user menekan tombol [Simpan]
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 9. TABEL FAVORITES (BOOKMARKS)
-- ============================================================================
CREATE TABLE favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    garment_id UUID REFERENCES garments(id) ON DELETE CASCADE,
    outfit_id UUID REFERENCES outfits(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_favorite_type CHECK (
        (garment_id IS NOT NULL AND outfit_id IS NULL) OR
        (garment_id IS NULL AND outfit_id IS NOT NULL)
    )
);
```

---

## 3. Penjelasan Desain Tabel & Optimasi

1. **Efisiensi Memori (Opsi Simpan / Discard):**
   * Tabel `avatars` memiliki kolom `status` (`'temp' | 'saved'`). Ketika user mencoba pose baru, record dibuat dengan status `temp`. Jika user memilih *Abaikan/Discard*, record dan file di storage langsung dibersihkan oleh cron job background.
   * Tabel `tryon_results` memiliki boolean `is_saved`. Hanya hasil yang disukai user yang akan disimpan permanen.
2. **Fleksibilitas Z-Index Layering:**
   * Setiap pakaian di tabel `garments` memiliki kolom `z_index` eksplisit yang terisi otomatis berdasarkan kategori standarnya, namun dapat disesuaikan per item (misal jaket tebal vs cardigan tipis).
3. **Dukungan Swatch Warna (Screen 3 UI):**
   * Tabel `garment_variants` mendukung visual palet warna seperti yang terlihat pada UI `NEXUS TECH JACKET` (pilihan warna hitam, olive, abu, krem, orange).
