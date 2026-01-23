# Cek Reklame Mobile

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Platform](https://img.shields.io/badge/Platform-Android-green)
![License](https://img.shields.io/badge/License-Private-red)
![Status](https://img.shields.io/badge/Status-In_Development-yellow)

Aplikasi mobile yang dikembangkan untuk Pemerintah Kota Surabaya (Dinas Pendapatan) untuk memvalidasi informasi reklame atau videotron terdaftar menggunakan foto hasil tangkapan kamera dan geo-location.

---

## 📚 Table of Contents
- [Arsitektur Proyek](#arsitektur-proyek)
- [Tech Stack & Dependencies Krusial](#tech-stack--dependencies-krusial)
- [Panduan Setup (Wajib)](#panduan-setup-wajib)
- [Development Workflow](#development-workflow)
- [Panduan Kontribusi](#panduan-kontribusi)
- [Lisensi](#lisensi)
- [Maintainers](#maintainers)


---

## 🏛️ Arsitektur Proyek <a name="arsitektur-proyek"></a>

Proyek ini menggunakan arsitektur **Clean Architecture** yang diimplementasikan dengan pendekatan **Feature-Driven**, yang menjamin pemisahan tanggung jawab (*Separation of Concerns*) dan mempermudah pengujian (Testability).

### Struktur Layer Utama

| Layer | Lokasi | Tanggung Jawab | 
| :--- | :--- | :--- | 
| **Domain** | `lib/domain/` | *Business Logic* murni (Entities, UseCases, Repository Interfaces). |
| **Data** | `lib/data/` | Implementasi data (API Calls, Models, Repository Impl). |
| **Presentation** | `lib/presentation/` | UI (Pages, Widgets) & State Management (BLoC/Cubit). |
| **Core** | `lib/core/` | Service global (`UpdateService`, `NetworkService`), DI, & Utils. |
| **Routes** | `lib/routes/` | Navigasi & Alur Halaman. **Constants** (`AppRoutes`), **GoRouter Config** (`appRouter`). |

### State Management

Kami menggunakan **BLOC/Cubit** (`flutter_bloc`) untuk mengelola *state* yang kompleks dan `get_it` digunakan untuk memisahkan *dependency* antar layer.


---

## 📦 Tech Stack & Dependencies Krusial<a name="tech-stack--dependencies-krusial"></a>

| Kategori | Package Utama | Fungsi |
| :--- | :--- | :--- |
| **Networking** | `dio` | HTTP Client dengan SSL pinning bypass (untuk server internal) & interceptors. |
| **Update System** | `ota_update`, `package_info_plus` | Menangani download & install APK, serta pengecekan versi aplikasi. |
| **Utilities** | `connectivity_plus` | Monitoring status internet realtime untuk UX yang lebih tangguh. |
| **Routing** | `go_router` | Navigasi deklaratif. |
| **Hardware** | `camera`, `geolocator` | Akses sensor perangkat. |
| **UI Tools** | `image_cropper` | Native cropping & compression. |
| **Config** | `flutter_dotenv` | Manajemen Environment Variables. |
| **Security/Utils** | `flutter_dotenv`, `shared_preferences` | Pengamanan API Key dan *flag* `isFirstLaunch`. |

---

## ⚙️ Panduan Setup (Wajib)<a name="panduan-setup-wajib"></a>

### 1. Konfigurasi API Keys

Kunci API tidak disimpan dalam *source code*. Gunakan `flutter_dotenv` untuk *runtime access*.

1.  Buat file `.env` di *root* proyek Anda dan tambahkan ke **`.gitignore`**.
2.  Isi kunci:
    ```env
    # .env
    GOOGLE_MAPS_API_KEY=...
    API_BASE_URL=...
    APP_ENV=...
    # 
    ```
3.  Pastikan `.env` terdaftar di `pubspec.yaml` sebagai *asset*.

### 2. Konfigurasi Native Android (Penting!)

Untuk *Maps* dan *Cropper*, konfigurasi *native* berikut harus ada di `android/app/src/main/AndroidManifest.xml`:

* **Permissions:** `CAMERA`, `ACCESS_FINE_LOCATION`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE` (maxSdk 32).
* **Cropper Activity (Wajib):** Deklarasi *Activity* berikut harus ada di dalam tag `<application>` untuk menjalankan *cropper*:
    ```xml
    <activity
        android:name="com.yalantis.ucrop.UCropActivity"
        android:screenOrientation="portrait"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>
    ```

### 3. Solusi JVM Target (Jika Build Gagal)

Jika Anda mendapatkan *error* `Inconsistent JVM-target compatibility`, pastikan `compileOptions` dan `kotlinOptions` di `android/app/build.gradle.kts` menargetkan **Java 8 (VERSION\_1\_8)** untuk stabilitas *plugin*:
```kotlin
// android/app/build.gradle.kts
android {
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }
}
```
---
## 🧪 Development Workflow<a name="development-workflow"></a>

Gunakan perintah berikut di terminal Anda untuk mempermudah pekerjaan sehari-hari dan *build* proyek:

| Task | Command |
| :--- | :--- |
| **Install Dependencies** | `flutter pub get` |
| **Clean Build Cache** | `flutter clean` |
| **Run (Hot Reload)** | `flutter run` | 
| **Run with Secrets** | `flutter run --dart-define=KEY=VALUE` | 
| **Format Code** | `dart format lib` | 
| **Run Tests** | `flutter test` | 
| **Build Android Release** | `flutter build appbundle --release` | 

---

## 🤝 Panduan Kontribusi<a name="panduan-kontribusi"></a>

Semua kontribusi harus mengikuti **Conventional Commits** (`feat:`, `fix:`, `refactor:` , `docs`) dan dibuat dalam *branch* terpisah (`feature/nama-fitur`). Riwayat perubahan didokumentasikan di `CHANGELOG.md`.

### 1. Struktur Cabang (Branching Strategy)

| Prefix Cabang | Tujuan | Contoh |
| :--- | :--- | :--- |
| **`feature/`** | Implementasi fitur baru (penambahan *use case* baru). | `feature/billboard-history` |
| **`bugfix/`** | Perbaikan *bug* kritis atau non-kritis. | `bugfix/map-static-error` |
| **`refactor/`** | Pembersihan kode atau perubahan arsitektur tanpa mengubah *output* fitur. | `refactor/move-data-mapping` |
| **`docs/`** | Perubahan pada dokumentasi (`README.md`, `CHANGELOG.md`). | `docs/update-setup-guide` |

### 2. 📝 Aturan Commit (Conventional Commits)
| Tipe Commit | Keterangan | Contoh |
| :--- | :--- | :--- |
| **`feat`** | **Fitur Baru** (Wajib untuk penambahan nilai fungsional). | `feat(api): Tambah endpoint CheckReklame` |
| **`fix`** | **Perbaikan Bug** (Wajib untuk koreksi perilaku yang salah). | `fix(core): Hapus duplikasi 'markers=' di MapService` |
| **`refactor`** | Pembersihan Struktur (*cleanup* atau pemindahan *logic*). | `refactor(data): Pindah model ke folder models/` |
| **`docs`** | Perubahan pada file dokumentasi saja. | `docs: Perbarui panduan setup` |
| **`style`** | Perubahan *formatting* (spasi, indentasi). | `style: Perbaiki indentasi di main.dart` |
| **`test`** | Penambahan atau perbaikan *unit tests*. | `test: Tambah test untuk BillboardCubit` |

---

## 🛡️ Lisensi<a name="lisensi"></a>

Proyek ini adalah **proyek privat** dan hak cipta dimiliki oleh:

> **Dinas Pendapatan Kota Surabaya (BAPENDA)**
>  
> Semua kode sumber, gambar, dan aset hanya boleh digunakan dalam konteks proyek resmi instansi.

---

## 👨‍💻 Maintainers<a name="maintainers"></a>

| Nama | Role | Kontak |
|------|------|--------|
| William J. Pakpahan | Mobile App Developer | williamjohanp@gmail.com |


***
