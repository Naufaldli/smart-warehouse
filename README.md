# LogiTrack Mini - Smart Warehouse Logistics System

LogiTrack Mini adalah aplikasi manajemen inventaris gudang berbasis mobile yang dirancang untuk efisiensi pelacakan stok barang secara *real-time*. Aplikasi ini mengintegrasikan penyimpanan data lokal yang andal dengan fitur perintah suara (*voice command*) untuk mempercepat proses pembaruan kuantitas barang di lapangan tanpa memerlukan input keyboard manual.

## Fitur Utama

* **Manajemen Inventaris Komprehensif**: Mengakomodasi operasi penambahan, pembaruan detail, penyesuaian stok, hingga penghapusan data barang (*CRUD*).
* **Asisten Perintah Suara (Voice Command)**: Mengintegrasikan teknologi *Speech-to-Text* (STT) dikombinasikan dengan pemrosesan teks berbasis *Regular Expression* (Regex) untuk mengenali perintah pembaruan stok dalam Bahasa Indonesia (contoh: *"Tambah 5 Lemon Tea"* atau *"Kurang 2 Paper Bowl"*).
* **Pencarian & Filtrasi Real-time**: Arsitektur pencarian responsif berdasarkan kata kunci nama barang dan klasifikasi kategori (*Horizontal Choice Chips*).
* **Integrasi Media Kamera & Galeri**: Mendukung dokumentasi visual produk langsung dari penyimpanan perangkat atau tangkapan kamera lokal melalui kompresi gambar yang dioptimalkan.
* **State Management Efisien**: Memanfaatkan arsitektur *Provider* untuk memastikan sinkronisasi data yang reaktif antara memori aplikasi, antarmuka pengguna (UI), dan database.

## Komponen Arsitektur Sistem

Aplikasi ini dibangun dengan memisahkan logik bisnis, representasi data, dan manajemen antarmuka:

* **`DatabaseHelper`**: Mengelola siklus hidup database lokal menggunakan **SQLite** (`sqflite`), mencakup inisialisasi tabel, operasi query terisolasi, pembaruan rekaman data, dan *seeding* data awal.
* **`InventoryProvider`**: Bertindak sebagai *State Manager* pusat yang mengatur aliran data enkapsulasi dari database ke seluruh komponen visual widget melalui *ChangeNotifier*.
* **`VoiceButton` & Halaman Detail**: Antarmuka perekaman asinkronus yang memanfaatkan pustaka `speech_to_text` untuk menangkap modulasi suara pengguna dengan penanganan validasi *widget state lifecycle* (`mounted`).

## Spesifikasi Teknologi

* **Framework**: Flutter (Channel Stable)
* **Bahasa Pemrograman**: Dart
* **Penyimpanan Lokal**: SQLite (`sqflite`, `path`)
* **State Management**: Provider
* **Dependensi Eksternal**: `speech_to_text`, `image_picker`

## Struktur Direktori Inti

```text
lib/
├── helpers/
│   └── database_helper.dart      # Abstraksi dan konfigurasi SQLite
├── providers/
│   └── inventory_provider.dart   # Manajemen state dan logika Regex NLP
└── screens/
    ├── add_item_page.dart        # Form registrasi barang baru & Image Picker
    ├── all_items_page.dart       # Daftar inventaris global & pencarian terpusat
    ├── dashboard_page.dart       # Antarmuka utama & filtrasi kategori
    ├── detail_page.dart          # Detail entitas, manajemen kuantitas & STT lokal
    └── voice_button.dart         # Komponen global pemicu mikrofon perangkat
