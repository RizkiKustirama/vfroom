# 📁 Panduan Struktur Repositori (Monorepo)
## VYRO / FitWardrobe AI

Untuk *personal project*, format yang **sangat direkomendasikan adalah Monorepo** (Backend dan Frontend Mobile disatukan dalam satu repository Git, namun dipisahkan rapi di dalam sub-folder masing-masing).

---

## 1. Mengapa Monorepo Lebih Baik untuk Proyek Ini?

1. **Satu Repositori Git:** Kamu tidak perlu pusing mengelola 2 repo GitHub berbeda, 2 pull request, atau 2 commit terpisah.
2. **Sinkronisasi Cepat Antara Mobile & Backend:** Saat kamu mengubah endpoint API atau model data pakaian di backend, kamu bisa langsung menyesuaikan tipe data / fungsi API di folder mobile tanpa berpindah repo.
3. **Isolasi Dependency Tetap Bersih:** Lingkungan Python (AI Backend) dan Node.js/Expo (Mobile) tetap terpisah 100% dan tidak saling bentrok.
4. **Setup & Clone Praktis:** Cukup jalankan `git clone` sekali di PC/laptop baru, seluruh kode aplikasi mobile dan AI sudah siap.

---

## 2. Struktur Direktori Proyek

```
vyro-fitwardrobe/
│
├── .gitignore
├── README.md
├── DESIGN.md                        # Desain sistem & panduan UI Stitch
├── PRD_FitWardrobe_AI.md            # Product Requirement Document
├── database_schema.md               # Skema database & DDL PostgreSQL
│
├── mobile/                          # 📱 FRONTEND MOBILE APP (Flutter / Dart)
│   ├── pubspec.yaml                 # Dependensi Flutter (dio, flutter_riverpod, camera, dll)
│   ├── assets/                      # Aset gambar, font, dan icons
│   │   ├── icons/
│   │   └── images/
│   │
│   └── lib/
│       ├── main.dart                # Entrypoint aplikasi Flutter & Theme setup
│       ├── core/                    # Core utilities & constants
│       │   ├── constants/           # Warna (DESIGN.md), URL API, Enums
│       │   └── network/             # Dio HTTP Client & Interceptors
│       │
│       ├── models/                  # Dart Data Models (JSON Serializable)
│       │   ├── garment_model.dart
│       │   ├── avatar_model.dart
│       │   └── tryon_model.dart
│       │
│       ├── repositories/            # Data Fetching / API Calls
│       │   ├── garment_repository.dart
│       │   └── avatar_repository.dart
│       │
│       ├── providers/               # State Management (Riverpod / Bloc)
│       │   ├── wardrobe_provider.dart # State baju aktif yang dipilih di avatar
│       │   └── avatar_provider.dart   # State pose avatar & loading fitting
│       │
│       ├── widgets/                 # Reusable UI Widgets
│       │   ├── common/
│       │   │   └── gradient_button.dart   # Tombol gradasi oranye VYRO
│       │   ├── avatar_viewport.dart       # Widget viewport 360° dengan CustomPainter
│       │   ├── wardrobe_selector.dart     # Bilah horizontal floating capsule items
│       │   ├── garment_card.dart          # Kartu item baju di grid
│       │   ├── prompt_input_bar.dart      # Input text "Describe your look..."
│       │   ├── color_swatches.dart        # Palet pilihan warna (Hitam, Olive, dll)
│       │   └── pose_modal.dart            # Modal dialog (Simpan / Regenerate / Discard)
│       │
│       └── screens/                 # Layar Utama Aplikasi
│           ├── onboarding_screen.dart     # Layar 1 (Dark theme hero & upload foto diri)
│           ├── stylist_screen.dart        # Layar 2 (Main Virtual Fitting & Wardrobe)
│           ├── item_detail_screen.dart    # Layar 3 (Detail spesifikasi item & warna)
│           └── camera_capture_screen.dart # Layar ambil foto pakaian via kamera HP
│

├── backend/                         # 🧠 BACKEND REST API & AI ENGINE (FastAPI)
│   ├── requirements.txt             # Dependensi Python (FastAPI, PyTorch, rembg, dll)
│   ├── .env.example                 # Contoh konfigurasi environment
│   ├── Dockerfile                   # Dockerfile untuk deployment backend
│   │
│   └── app/
│       ├── main.py                  # Entrypoint FastAPI & CORS setup
│       ├── config.py                # Konfigurasi ENV & kredensial database
│       ├── database.py              # Koneksi PostgreSQL / Supabase SQLAlchemy
│       │
│       ├── models/                  # SQLAlchemy ORM Models
│       │   ├── user.py
│       │   ├── avatar.py
│       │   ├── garment.py
│       │   └── tryon.py
│       │
│       ├── schemas/                 # Pydantic Schemas (Request/Response DTO)
│       │   ├── garment_schema.py
│       │   ├── avatar_schema.py
│       │   └── tryon_schema.py
│       │
│       ├── routers/                 # API Routes / Endpoints
│       │   ├── garments.py          # POST /upload, GET /list
│       │   ├── avatars.py           # POST /base, POST /generate-pose, POST /pose/action
│       │   └── tryon.py             # POST /fit (Trigger virtual fitting)
│       │
│       ├── services/                # Logika Bisnis Aplikasi
│       │   ├── storage_service.py   # Upload file ke Supabase Storage / S3 / Local
│       │   └── garment_service.py
│       │
│       └── ai_engine/               # ⚡ Pipeline AI/ML (Zero-Training Inference)
│           ├── bg_removal.py        # RMBG-1.4 / rembg (Hapus background baju)
│           ├── pose_detector.py     # MediaPipe Pose & FaceMesh (Landmark titik tubuh)
│           ├── z_indexer.py         # Logika pengurutan layer Z-Index
│           ├── pose_generator.py    # ControlNet OpenPose + InstantID (Pose Switcher)
│           └── vton_pipeline.py     # CatVTON / IDm-VTON (Diffusion Try-On Engine)
│
└── storage/                         # Folder lokal untuk menyimpan gambar (development)
    ├── raw_uploads/                 # Foto mentah dari kamera HP
    ├── clean_garments/              # Foto PNG transparan hasil RMBG-1.4
    └── temp_cache/                  # Cache sementara untuk pose/fitting yang belum disimpan
```

---

## 3. Cara Menjalankan Project (Local Development Workflow)

### Terminal 1: Menjalankan Backend AI (FastAPI)
```bash
cd backend
python -m venv venv
# Windows:
.\venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
> *Catatan:* Host `0.0.0.0` digunakan agar aplikasi di HP kamu bisa mengakses API backend melalui alamat IP lokal WiFi (misal: `http://192.168.1.x:8000`).

### Terminal 2: Menjalankan Mobile App (Flutter)
```bash
cd mobile
flutter pub get
flutter run
```
> Pastikan HP kamu terhubung via kabel USB dengan mode *USB Debugging* aktif (atau buka emulator Android / iOS Simulator). Aplikasi akan langsung ter-install dan berjalan dengan fitur *Hot Reload*!

