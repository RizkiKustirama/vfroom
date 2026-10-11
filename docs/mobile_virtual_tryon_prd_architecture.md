# 📱 PRD & Rancangan Arsitektur Mobile App: Personal AI Virtual Try-On (Wardrobe Fitting)

Dokumen ini berisi spesifikasi kebutuhan produk (**PRD**), **Database Schema**, **Arsitektur Sistem Mobile**, **Spesifikasi API**, serta **Rancangan UI/UX** untuk aplikasi mobile fitting baju personal berbasis AI.

---

## 1. Product Requirement Document (PRD)

### 1.1 Ringkasan Produk & Visi
**FitWardrobe AI (Personal Mobile App)** adalah aplikasi mobile personal yang memungkinkan pengguna mengambil foto pakaian milik sendiri, mendaftarkannya ke dalam katalog digital, dan mencobanya (*fitting*) secara langsung pada model digital foto tubuh diri sendiri dengan tampilan *mix-and-match* serasa memilih kostum di dalam game.

### 1.2 Target Scope & Constraint
* **Platform:** Mobile Application (Android / iOS).
* **Tipe Project:** Personal Project (Ringan, *cost-efficient*, menggunakan model AI *open-source pre-trained* tanpa training).
* **User Target:** Personal / Individual.

### 1.3 Fitur Utama (Core Features)

| No | Modul Fitur | Deskripsi |
| :--- | :--- | :--- |
| 1 | **Digital Garment Registration** | Ambil foto baju/celana/sepatu via kamera HP. AI otomatis menghapus background (`RMBG-1.4`) dan menyimpan gambar transparan ke katalog. |
| 2 | **User Avatar & Pose Library** | Upload foto *full-body*. Pengguna dapat memilih/membuat variasi pose baru (*standing, walking, side view*) menggunakan AI Pose Generator. |
| 3 | **Game-like Wardrobe Fitting** | UI antarmuka ala *character inventory game*. Pilih atasan + bawahan + sepatu + aksesoris $\rightarrow$ AI melakukan *Virtual Try-On* & *Layering*. |
| 4 | **Accessory Overlay** | Pemasangan aksesoris instan (kacamata, topi, jam tangan) menggunakan *MediaPipe Face & Body Mesh*. |
| 5 | **State & Memory Control** | Opsi **Simpan / Generate Ulang / Discard** untuk hasil pose baru & fitting agar tidak membebani memori HP. |
| 6 | **Saved Outfits Collection** | Simpan kombinasi setelan favorit untuk inspirasi OOTD harian. |

---

## 2. Arsitektur Sistem Mobile App

### 2.1 Diagram Arsitektur

```mermaid
flowchart TD
    subgraph Mobile Client (React Native / Flutter)
        UI[UI Wardrobe & Camera Interface]
        State[Local State / Redux / Zustand]
        UI --> Camera[Kamera HP / Gallery]
    end

    subgraph Backend Services (FastAPI - Python)
        API[REST API Gateway]
        BgWorker[Async Task Queue: Celery + Redis]
    end

    subgraph Pre-trained AI Engine (PyTorch)
        RMBG[1. Auto BG Removal: RMBG-1.4 / rembg]
        MediaPipe[2. Pose/Face Mesh: MediaPipe]
        ControlNet[3. Pose Generator: ControlNet + InstantID]
        VTON[4. Fitting Engine: CatVTON / IDm-VTON]
    end

    subgraph Database & Storage
        DB[(Database: PostgreSQL / SQLite)]
        Storage[(Object Storage: S3 / Cloudinary / Supabase)]
    end

    UI <-->|HTTPS / REST API| API
    API --> BgWorker
    BgWorker --> RMBG & MediaPipe & ControlNet & VTON
    API <--> DB
    API <--> Storage
```

### 2.2 Recommended Mobile Tech Stack

* **Mobile Frontend:** **React Native (Expo)** atau **Flutter**
  * *Alasan:* Pengembangan cepat *cross-platform*, dukungan library kamera & manipulasi gambar yang kaya, UI responsive animasi smooth.
* **Backend API:** **Python (FastAPI)**
  * *Alasan:* Kompatibel secara native dengan ekosistem PyTorch, MediaPipe, dan HuggingFace Diffusers.
* **Task Queue (Async Fitting Processing):** **Redis + Celery** (atau FastAPI `BackgroundTasks` untuk versi simpel).
* **Database:** **PostgreSQL** (via Supabase / Railway) atau **SQLite** (lokal untuk versi offline-first).
* **Storage:** **Supabase Storage** / **Cloudinary** / **AWS S3** untuk menyimpan foto PNG transparan baju dan avatar.

---

## 3. Database Schema (ERD & Data Dictionary)

```mermaid
erdiagram
    USERS ||--o{ AVATARS : has
    USERS ||--o{ GARMENTS : owns
    USERS ||--o{ OUTFITS : creates
    OUTFITS ||--o{ OUTFIT_ITEMS : contains
    GARMENTS ||--o{ OUTFIT_ITEMS : used_in
    AVATARS ||--o{ TRYON_CACHE : generates

    USERS {
        uuid id PK
        string name
        datetime created_at
    }

    AVATARS {
        uuid id PK
        uuid user_id FK
        string pose_name
        string image_url
        string pose_skeleton_url
        boolean is_default
        boolean is_temp
        datetime created_at
    }

    GARMENTS {
        uuid id PK
        uuid user_id FK
        string name
        string category
        string sub_category
        string image_raw_url
        string image_clean_url
        int z_index
        datetime created_at
    }

    OUTFITS {
        uuid id PK
        uuid user_id FK
        string outfit_name
        string preview_result_url
        datetime created_at
    }

    OUTFIT_ITEMS {
        uuid id PK
        uuid outfit_id FK
        uuid garment_id FK
    }

    TRYON_CACHE {
        uuid id PK
        uuid avatar_id FK
        uuid outfit_id FK
        string result_image_url
        datetime created_at
    }
```

### Detail Kategori & Z-Index Garments:
* `category`: `top` (Atasan), `bottom` (Bawahan), `outer` (Jaket/Outer), `footwear` (Sepatu), `accessory` (Aksesoris).
* `z_index`:
  * 1: Base Avatar (Foto Diri)
  * 1.5: Backpack Body (Tas Punggung - posisi di belakang tubuh)
  * 2: Bawahan (Celana / Rok)
  * 3: Atasan (Kaos / Kemeja)
  * 4: Outer (Jaket / Coat)
  * 5: Aksesoris Leher/Dada/Pinggang (Dasi, Sabuk, Tali Tas Selempang / Crossbody Strap)
  * 6: Sepatu / Kaos Kaki
  * 7: Aksesoris Terluar & Handheld (Topi, Kacamata, Jam Tangan, Tas Tangan / Handbag / Tote bag / Pouch)


---

## 4. Spesifikasi API Endpoints (REST)

### A. Garment Management
* **`POST /api/v1/garments/upload`**
  * *Request:* Multipart form (`file`, `name`, `category`, `sub_category`).
  * *Process:* Menjalankan `RMBG-1.4` background removal otomatis.
  * *Response:* Metadata baju + `image_clean_url`.
* **`GET /api/v1/garments`**
  * *Query:* `category` (optional).
  * *Response:* List daftar baju yang sudah didaftarkan.

### B. Avatar & Pose Management
* **`POST /api/v1/avatars/base`**
  * Upload foto *full-body* utama user.
* **`POST /api/v1/avatars/generate-pose`**
  * *Request:* `{ "base_avatar_id": "uuid", "target_pose_template": "walking_side" }`
  * *Process:* Panggil ControlNet OpenPose.
  * *Response:* `{ "temp_avatar_url": "...", "status": "preview" }`
* **`POST /api/v1/avatars/pose/action`**
  * *Request:* `{ "temp_avatar_id": "uuid", "action": "save" | "regenerate" | "discard" }`

### C. Virtual Try-On Fitting Engine
* **`POST /api/v1/tryon/fit`**
  * *Request:* 
    ```json
    {
      "avatar_id": "uuid-avatar-1",
      "garment_ids": ["uuid-top-baju-A", "uuid-bottom-celana-B"],
      "accessory_ids": ["uuid-glasses-C"]
    }
    ```
  * *Process:* Menggabungkan overlay aksesoris + CatVTON Try-On inference.
  * *Response:* `{ "result_image_url": "...", "processing_time_ms": 1200 }`

---

## 5. UI/UX Wireframe & Mobile App Flow (Ala Game Inventory)

### Layout Antarmuka Mobile (Split Screen Game Style)

```
+------------------------------------------+
|  [<-] FitWardrobe AI         [⚙️ Settings]|
+------------------------------------------+
|                                          |
|            +-----------------+           |
|            |                 |           |
|            |   PREVIEW 2D/3D |           |
|            |   AVATAR USER   |           |
|            |   (FITTED OUTFIT|           |
|            |    RESULT)      |           |
|            |                 |           |
|            +-----------------+           |
|                                          |
| [💃 Ubah Pose]   [🔄 Reset]  [💾 Simpan OOTD]|
+------------------------------------------+
|  [👕 Atasan] [👖 Bawahan] [👟 Sepatu] [🕶️ Acc]|
+------------------------------------------+
|  +----+  +----+  +----+  +----+          |
|  |👕1 |  |👕2 |  |👕3 |  | +  |  <-- Grid  |
|  |Kaos|  |Keme|  |Hoo |  |Tamb|      Baju  |
|  +----+  +----+  +----+  +----+          |
+------------------------------------------+
|  [ 📸 Tambah Pakaian Baru (Kamera HP) ]  |
+------------------------------------------+
```

### Flow Penggunaan Mobile User:
1. **Daftar Baju Baru:** Klik tombol `📸 Tambah Pakaian Baru` $\rightarrow$ Foto baju via kamera HP $\rightarrow$ AI langsung hapus background $\rightarrow$ Pilih kategori $\rightarrow$ Terdaftar di grid.
2. **Fitting Wardrobe:** Tap item baju di grid katalog $\rightarrow$ Baju langsung terpasang di avatar preview di layar atas.
3. **Ubah Pose:** Tap `💃 Ubah Pose` $\rightarrow$ Pilih template pose $\rightarrow$ AI render preview $\rightarrow$ Muncul pop-up modal `[Simpan Pose]` `[Generate Ulang]` `[Abaikan]`.

---

## 6. Roadmap Implementasi Mobile App

1. **Sprint 1 (Backend Core & API):** Setup FastAPI, integrasi `rembg/RMBG-1.4`, database schema, dan endpoint upload baju.
2. **Sprint 2 (Mobile App UI & Camera):** Setup React Native (Expo) / Flutter, buat UI Wardrobe grid ala game, kamera upload, dan katalog item.
3. **Sprint 3 (Overlay Engine & MediaPipe):** Implementasi overlay 2D untuk aksesoris & TPS warping baseline.
4. **Sprint 4 (Integration AI Try-On & Pose Gen):** Integrasi model **CatVTON** + **ControlNet** via PyTorch backend.
5. **Sprint 5 (Polishing & Testing):** Optimasi *caching*, penanganan memori, dan testing pada perangkat HP.
