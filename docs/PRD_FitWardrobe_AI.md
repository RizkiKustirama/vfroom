# 📄 Product Requirement Document (PRD)
## VYRO / FitWardrobe AI — Mobile Personal Virtual Try-On & AI Stylist

* **Document Version:** 2.0 (Comprehensive Redesign)
* **Target Platform:** Mobile App (iOS & Android)
* **Project Type:** Personal AI Engineering Project
* **Status:** Ready for Implementation

---

## 1. Executive Summary & Problem Statement

### 1.1 Problem Statement
Memilih dan mencocokkan pakaian sehari-hari (*OOTD*) seringkali memakan waktu dan melelahkan jika harus mencoba pakaian secara fisik satu per satu di depan cermin. Selain itu, banyak orang memiliki pakaian di lemari yang jarang dipakai karena sulit membayangkan padu-padannya.

### 1.2 Solusi Produk
**FitWardrobe AI (VYRO)** adalah aplikasi mobile *Personal AI Stylist & Virtual Wardrobe* yang memungkinkan pengguna:
1. Mengabadikan dan mendaftarkan koleksi pakaian pribadi hanya dengan foto kamera HP.
2. AI secara otomatis membersihkan background foto pakaian secara instan.
3. Mencoba pakaian (*virtual fitting*) secara langsung pada foto model tubuh sendiri dengan antarmuka interaktif layaknya kustomisasi karakter di dalam game.
4. Bereksperimen dengan berbagai variasi pose badan dan aksesoris secara dinamis tanpa komputasi berat.

---

## 2. Product Goals & Success Metrics (MVP)

| Goals | Target Metric (MVP) |
| :--- | :--- |
| **Kecepatan Registrasi Baju** | Hapus background foto baju selesai dalam $\le 1.5$ detik di server. |
| **Kualitas Virtual Fitting** | Fitting atasan & bawahan menghasilkan lipatan dan pencahayaan realistis via *Zero-Shot Pretrained VTON*. |
| **Efisiensi Memori & Biaya** | 0% training cost (menggunakan model siap pakai); Cache file sementara dibersihkan otomatis jika memilih *Discard*. |
| **Pengalaman Pengguna (UX)** | Transisi pemilihan baju di viewport avatar terasa responsif seperti game inventory. |

---

## 3. User Personas & Core User Journey

### User Persona
* **Nama:** Alex (20-30 tahun, Fashion & Tech Enthusiast).
* **Kebutuhan:** Ingin mengatur lemari pakaian digital, mencoba padu-padan baju tanpa harus berganti pakaian berkali-kali, dan melihat visualisasi setelan sebelum bepergian.

### Core User Journey
```
[1. Upload Foto Diri] ➔ [2. Foto Pakaian ke Lemari] ➔ [3. Masuk ke Ruang Fitting] ➔ [4. Mix & Match Outfit + Aksesoris] ➔ [5. Ganti Pose / Simpan OOTD]
```

---

## 4. Spesifikasi Kebutuhan Fungsional (Functional Requirements)

### Modul 1: Onboarding & Avatar Setup (Foto Badan User)
* **FR-1.1:** Pengguna dapat mengunggah 1 foto *full-body* posisi berdiri tegak sebagai *Base Avatar*.
* **FR-1.2:** Sistem mengekstrak titik pose (*keypoints skeleton*) menggunakan **MediaPipe Pose** tanpa memerlukan proses training.
* **FR-1.3:** Tampilan avatar di viewport dilengkapi kontrol rotasi interaktif `< 360° >` untuk melihat orientasi model.

### Modul 2: Digital Wardrobe Inventory (Registrasi Pakaian)
* **FR-2.1:** Pengguna mengambil foto pakaian (baju, celana, jaket, sepatu, tas) langsung dari kamera HP atau galeri.
* **FR-2.2:** Backend AI secara otomatis memisahkan pakaian dari latar belakang menggunakan **`RMBG-1.4` / `rembg`** dan menghasilkan file PNG transparan beresolusi tinggi.
* **FR-2.3:** Pengguna menetapkan atribut pakaian:
  * Nama item & Brand.
  * Kategori: *Atasan, Bawahan, Outer, Sepatu, Aksesoris, Tas*.
  * Pilihan varian warna (palette swatch).
* **FR-2.4:** Pakaian yang berhasil didaftarkan langsung muncul di grid katalog lemari digital pengguna.

### Modul 3: Interactive Fitting Viewport (Ala Karakter Game)
* **FR-3.1:** Layar utama (*AI Stylist Screen*) menampilkan model avatar pengguna di bagian atas dan bilah katalog pakaian mengambang (*Floating Wardrobe Strip*) di bagian bawah.
* **FR-3.2:** Mengetuk salah satu item pakaian di katalog akan langsung memasangkan item tersebut ke avatar pengguna.
* **FR-3.3 (Z-Index Layering Engine):** Penumpukan pakaian diproses secara hierarkis agar tampilan tidak tumpang-tindih:
  * *Layer 1:* Base Model Badan User
  * *Layer 1.5:* Tas Punggung (Backpack)
  * *Layer 2:* Celana / Rok (Bawahan)
  * *Layer 3:* Kaos / Kemeja (Atasan)
  * *Layer 4:* Jaket / Outer
  * *Layer 5:* Aksesoris Dada/Leher/Sabuk (Dasi, Kalung, Tali Selempang)
  * *Layer 6:* Sepatu / Sandal
  * *Layer 7:* Aksesoris Terluar & Handheld (Topi, Kacamata, Jam Tangan, Tas Tangan)
* **FR-3.4 (AI Diffusion Try-On):** Untuk pakaian atasan dan bawahan, sistem memproses perpaduan kain secara realistis menggunakan model pre-trained **CatVTON / IDm-VTON**.

### Modul 4: Pose Switcher & State Management (Simpan / Regenerate / Discard)
* **FR-4.1:** Pengguna dapat menekan tombol **"Ubah Pose"** dan memilih template pose (*Walking, 45° Angle, Hands in Pocket*).
* **FR-4.2:** AI menghasilkan gambar pose baru menggunakan **ControlNet OpenPose + InstantID** tanpa merubah wajah dan identitas fisik pengguna.
* **FR-4.3 (Kontrol Memori):** Hasil pose baru ditampilkan dalam status *Temporary Preview* dengan 3 opsi tindakan:
  1. **`Simpan Pose`**: Menyimpan pose ke *Avatar Library* pengguna secara permanen.
  2. **`Generate Ulang`**: Menjalankan ulang AI inference dengan variasi seed baru.
  3. **`Abaikan / Discard`**: Menghapus file cache temporary dari server & storage seketika agar memori tidak membengkak.

### Modul 5: AI Prompt Stylist Assistant
* **FR-5.1:** Terdapat kolom input pintar *"Describe your look..."* pada layar fitting.
* **FR-5.2:** Pengguna dapat mengetikkan teks (misal: *"Casual summer outfit untuk nongkrong di kafe"*).
* **FR-5.3:** Sistem akan merekomendasikan dan otomatis memilihkan kombinasi pakaian yang ada di lemari pengguna yang paling sesuai dengan deskripsi tersebut.

### Modul 6: Koleksi OOTD & Favorit
* **FR-6.1:** Pengguna dapat menyimpan hasil padu-padan terbaik ke dalam album **"Saved Outfits / OOTD"**.
* **FR-6.2:** Menandai item pakaian atau setelan dengan ikon *Favorites (Love)* untuk akses cepat.

---

## 5. Kebutuhan Non-Fungsional (Non-Functional Requirements)

* **NFR-1 (Performa & Latensi):**
  * Auto Background Removal: $\le 2$ detik per gambar.
  * Virtual Try-On AI: $\le 3-5$ detik per request fitting (menggunakan async task queue Celery/Redis).
  * 2D Landmark Aksesoris Overlay (Kacamata, Topi, Tas): $\le 150$ ms (instan di client-side/FastAPI).
* **NFR-2 (Efisiensi Sumber Daya / Resource Efficiency):**
  * Zero-Training Architecture: 100% menggunakan checkpoint pre-trained model.
  * Pembersihan file sampah (*Garbage Collection*): Job otomatis menghapus file berstatus `is_temp = true` yang berusia lebih dari 24 jam.
* **NFR-3 (Keamanan & Privasi):**
  * Foto tubuh pengguna disimpan secara privat dan tidak dibagikan ke publik.
* **NFR-4 (UI/UX Fluidity):**
  * Desain mengacu pada standar `DESIGN.md` (Warm Sunset Modernism, palet oranye terakota, sudut membulat 24px-32px, dan indikator 360°).

---

## 6. Spesifikasi Tech Stack

```
+-------------------------------------------------------------------------+
|                              MOBILE CLIENT                              |
|          React Native (Expo) / Flutter + Tailwind / NativeWind          |
+-------------------------------------------------------------------------+
                                    | HTTPS / REST & WebSocket
+-------------------------------------------------------------------------+
|                               API GATEWAY                               |
|                         FastAPI (Python 3.10+)                          |
+-------------------------------------------------------------------------+
       |                                                 |
+------------------------------------+   +--------------------------------+
|         AI PIPELINE WORKER         |   |       DATABASE & STORAGE       |
|  - RMBG-1.4 (Background Removal)   |   |  - PostgreSQL (Supabase/Neon)  |
|  - MediaPipe (Pose/Face/Hand Mesh) |   |  - Object Storage (Cloudinary  |
|  - ControlNet (Pose Generator)     |   |    / Supabase Storage)         |
|  - CatVTON (Diffusion Try-On)      |   |  - Redis (Task Queue Cache)    |
+------------------------------------+   +--------------------------------+
```

---

## 7. Rencana Rilis & Milestone Pengembangan

### Tahap 1: Pondasi & Registrasi Lemari (Sprint 1)
* Setup project FastAPI & Mobile App UI (React Native / Flutter).
* Integrasi kamera HP untuk foto pakaian.
* Endpoint otomatis hapus background (`RMBG-1.4`) dan penyimpanan katalog ke database.

### Tahap 2: Avatar & Overlay Aksesoris (Sprint 2)
* Upload foto *full-body* user & deteksi titik sendi dengan `MediaPipe Pose`.
* Implementasi sistem Z-Index layering 2D untuk pakaian dan aksesoris (kacamata, topi, tas).
* Antarmuka Wardrobe Selector ala game di layar HP.

### Tahap 3: Virtual Try-On & Pose Switcher (Sprint 3)
* Integrasi model **CatVTON** untuk perpaduan tekstur & lipatan pakaian yang realistis.
* Implementasi fitur **Ubah Pose** dengan ControlNet beserta modal konfirmasi (*Simpan / Generate Ulang / Discard*).
* Fitur simpan kombinasi OOTD.
