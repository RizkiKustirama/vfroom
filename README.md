# 👗 VFROOM (Virtual Fitting Room - FitWardrobe AI)

Aplikasi mobile personal AI Virtual Try-On dan Wardrobe Stylist yang memungkinkan pengguna mencoba pakaian pada foto model tubuh sendiri dengan antarmuka interaktif ala game kustomisasi karakter.

## 📂 Struktur Direktori

```
vfroom/
├── README.md
├── docs/                                  # Dokumentasi lengkap & spesifikasi sistem
│   ├── PRD_FitWardrobe_AI.md              # Product Requirement Document (PRD v2.0)
│   ├── DESIGN.md                          # Design System & UI Specs (Stitch-ready)
│   ├── database_schema.md                 # PostgreSQL DDL & ERD Diagram
│   ├── repository_structure.md            # Arsitektur Monorepo (Flutter + FastAPI)
│   ├── virtual_tryon_architecture.md      # AI/ML Zero-Shot Try-On Architecture
│   └── mobile_virtual_tryon_prd_architecture.md # Mobile PRD & Wireframe awal
│
└── code/                                  # Source code proyek
    ├── mobile/                            # Frontend Mobile App (Flutter)
    └── backend/                           # Backend API & AI Engine (FastAPI + PyTorch)
```

## 🚀 Dokumentasi Utama (Lihat di folder `docs/`)
1. **[PRD_FitWardrobe_AI.md](docs/PRD_FitWardrobe_AI.md)**: Spesifikasi kebutuhan fungsional & non-fungsional aplikasi.
2. **[DESIGN.md](docs/DESIGN.md)**: Token warna, tipografi, dan layout 3 layar utama (Onboarding, AI Stylist Viewport, Detail Items).
3. **[database_schema.md](docs/database_schema.md)**: Script SQL tabel `users`, `avatars`, `garments`, `outfits`, dan `tryon_sessions`.
4. **[repository_structure.md](docs/repository_structure.md)**: Panduan detail folder `mobile/` (Flutter) dan `backend/` (FastAPI).
5. **[virtual_tryon_architecture.md](docs/virtual_tryon_architecture.md)**: Alur model AI tanpa training (`RMBG-1.4`, `MediaPipe`, `ControlNet`, `CatVTON`).
