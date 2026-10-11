# Rancangan Sistem AI Virtual Try-On (Personal Outfit Fitting)

Dokumen ini berisi rancangan sistem, rekomendasi model AI/ML, tech stack, dan alur kerja untuk membuat **Personal AI Virtual Try-On System** (fitting pakaian pada model foto diri sendiri layaknya kustomisasi karakter game).

---

## 1. Alur Kerja Sistem (System Workflow)

Sistem dibagi menjadi **3 Modul Utama**:

```mermaid
flowchart TD
    subgraph Registrasi Pakaian
        A[Foto Pakaian] --> B[Background Removal: rembg / RMBG-1.4]
        B --> C[Garment Masking & Crop]
        C --> D[(Database Catalog: Pakaian & Metadata)]
    end

    subgraph Setup Model Diri
        E[Foto Full-Body User] --> F[Pose Estimation: MediaPipe / OpenPose]
        F --> G[Human Body Parsing: Masking Torso/Legs/Feet]
        G --> H[(Database Model User)]
    end

    subgraph Fitting Outfit (Inference)
        D --> I[Pilih Outfit Atasan/Bawahan/Sepatu]
        H --> I
        I --> J[AI Virtual Try-On Engine: CatVTON / IDm-VTON]
        J --> K[Hasil Gambar User Memakai Outfit]
    end
```

---

## 2. Model & Algoritma AI yang Direkomendasikan

Untuk scope personal project yang **ringan namun hasil realistis**, direkomendasikan menggunakan **Pre-trained Open-Source Models** berikut:

| Komponen | Rekomendasi Model / Library | Alasan & Keunggulan |
| :--- | :--- | :--- |
| **1. Background Removal (Foto Pakaian)** | **RMBG-1.4** / `rembg` (U2-Net) | Sangat cepat, berjalan lancar di CPU/GPU, memisahkan baju dari background secara presisi. |
| **2. Body Pose & Parsing (Foto User)** | **MediaPipe Pose** / **DensePose** | MediaPipe sangat ringan (bisa jalan di browser/CPU) untuk mendeteksi sendi & bahu. DensePose/SCHP untuk memetakan area tubuh (dada, kaki, dll). |
| **3. Virtual Try-On (Fitting Engine)** | **CatVTON** atau **IDm-VTON** *(Solusi AI Modern)* | **CatVTON** adalah model Diffusion Try-On berbasis Concatenation yang sangat efisien, cepat, dan hemat VRAM (~6GB-8GB). Menghasilkan lipatan kain dan bayangan alami. |
| **3b. Alternate Try-On (Fast Prototype)** | **Thin Plate Spline (TPS) Warping** *(Solusi Non-Diffusion)* | Mengubah bentuk 2D gambar baju mengikuti titik pose tubuh. Sangat ringan (dapat berjalan tanpa GPU), cocok untuk prototype tahap awal ala stiker game. |

> [!NOTE]
> **PENTING: TIDAK PERLU DATA TRAINING ATAU PROSES TRAINING SAMA SEKALI (Zero-Training)!**
> Kamu cukup mengunduh model yang sudah siap pakai (*pre-trained weights*) dari HuggingFace/GitHub. Model-model ini sudah dilatih sebelumnya dengan jutaan pasang baju & tubuh manusia. Kamu hanya perlu melakukan **Zero-Shot Inference** (memanggil fungsi model dengan parameter gambar kamu & gambar baju).

---

## 3. Tech Stack Rekomendasi

### Option A: MVP Tercepat (Prototyping)
* **Framework UI & Server:** **Gradio** atau **Streamlit** (Python native, hemat waktu tidak perlu pisah frontend/backend).
* **Core Logic:** Python + PyTorch + OpenCV + MediaPipe + `rembg`.
* **Database:** SQLite / Local JSON metadata.

### Option B: Full Web App (Tampilan Lebih Mirip Game Dashboard)
* **Frontend:** **Next.js** / **React** + **Tailwind CSS** (Tampilan katalog baju ala game, drag & drop, outfit grid).
* **Backend REST API:** **FastAPI** (Python) untuk inferensi AI dan preprocessing gambar.
* **Database & Storage:** **SQLite / PostgreSQL** + Local file storage / Cloudinary untuk menyimpan foto-foto baju yang didaftarkan.
* **AI Processing:** PyTorch + HuggingFace Diffusers (`CatVTON` pipeline).

---

## 4. Langkah Registrasi & Cara Kerja Fitting

### A. Registrasi Pakaian
1. User mengambil foto baju (misal: kaos/kemeja) yang diletakkan di lantai/gantungan.
2. AI secara otomatis menghapus background (`RMBG-1.4` / `rembg`).
3. User menentukan kategori pakaian (**Atasan**, **Bawahan**, **Sepatu**, **Outer**).
4. Gambar bersih dan metadata disimpan di katalog.

### B. Registrasi Model Badan (User Avatar)
1. User memasukkan foto diri sendiri posisi tegak berdiri (full-body).
2. Sistem mengekstrak pose keypoints (bahu, pinggang, lutut, tumit) dan membuat mask badan.

### C. Modul Fitting (Game-like Wardrobe)
1. Di layar katalog, user memilih kombinasi:
   * Atasan: *Baju A*
   * Bawahan: *Celana B*
2. Sistem menggabungkan gambar baju dengan pose tubuh user melalui AI Virtual Try-On.
3. Menampilkan preview hasil fitting dengan lighting dan bayangan yang realistis.

### D. Modul Pose Generation & State Management (Pengaturan Pose)
1. **Trigger Pose Baru:** User memilih template pose (misal: *Pose Berjalan*, *Pose Samping*, *Pose Tangan di Saku*).
2. **Generasi Pose (ControlNet OpenPose):** AI memicu pengerjaan ControlNet + IP-Adapter untuk mengubah pose foto badan user ke pose target tanpa merubah wajah/identitas user.
3. **Pilihan Aksesibilitas (Manajemen Memori & Penyimpanan):**
   * **`Simpan Pose`**: Menyimpan pose baru ke database library pose user agar dapat digunakan kembali secara permanen tanpa perlu komputasi ulang.
   * **`Generate Ulang`**: Menjalankan ulang AI inference dengan seed acak jika pose yang dihasilkan kurang pas.
   * **`Abaikan / Hapus (Discard)`**: Menghapus file temporary dari RAM/Cache tanpa menyimpan ke disk agar penyimpanan lokal tidak membengkak.

### E. Modul Aksesoris & Sistem Layering (Z-Index Hierarchy)
1. **Pendekatan Dual Engine:**
   * **Aksesoris Kaku (Topi, Kacamata, Jam Tangan, Tas):** Menggunakan **MediaPipe FaceMesh / Hand Landmark** untuk overlay 2D secara instan & tepat pada koordinat mata/kepala/pergelangan tangan tanpa beban GPU.
   * **Aksesoris Fleksibel (Syal, Dasi, Sabuk):** Menggunakan AI Inpainting / Try-On mask agar menyatu secara alami dengan lipatan baju.
2. **Sistem Layering Ala Game (Z-Index):**
   * *Layer 1 (Dasar):* Foto Model Badan User
   * *Layer 2:* Celana / Rok (Bawahan)
   * *Layer 3:* Kaos / Kemeja (Atasan)
   * *Layer 4:* Jaket / Outer
   * *Layer 5:* Sabuk / Dasi / Kalung
   * *Layer 6:* Sepatu / Kaos Kaki
   * *Layer 7:* Topi / Kacamata / Jam Tangan / Tas (Top Layer)


---

## 5. Roadmap Pengembangan Bertahap (Tahap-demi-Tahap)

> [!TIP]
> Kerjakan secara bertahap agar project tidak terasa memberatkan!

1. **Fase 1 (Warping & Catalog Basics - 1 Minggu)**
   * Buat UI katalog sederhana (Gradio/Streamlit/React).
   * Fitur hapus background otomatis saat upload baju (`rembg`).
   * Pasangkan baju ke foto user menggunakan warping geometri 2D sederhana (`MediaPipe` pose keypoints + OpenCV).
2. **Fase 2 (Integrasi Pre-trained AI VTON - 1-2 Minggu)**
   * Integrasikan model **CatVTON** / **IDm-VTON** via HuggingFace `diffusers` / ComfyUI API / PyTorch script.
   * Ganti rendering warping sederhana dengan AI Diffusion VTON agar lipatan baju & bayangan terlihat alami.
3. **Fase 3 (UI Enhancements & Polish)**
   * Buat UI ala game inventory (kategori tab atasan/bawahan/sepatu, simpan favorit outfit).
   * Tambahkan statistik/label pakaian (warna, merk, tipe acara).

---

## 6. Contoh Command / Code Snippet Preprocessing (Python)

```python
# Contoh script hapus background baju secara otomatis
from rembg import remove
from PIL import Image

def process_garment_photo(input_path, output_path):
    input_img = Image.open(input_path)
    output_img = remove(input_img)
    output_img.save(output_path)
    print(f"Baju berhasil diisolasi dan disimpan di: {output_path}")

# Jalankan: process_garment_photo("baju_foto.jpg", "baju_clean.png")
```
