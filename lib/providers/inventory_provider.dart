import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class InventoryProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  String _selectedCategory = 'All';

  List<Map<String, dynamic>> get items {
    if (_selectedCategory == 'All') {
      return _items;
    }
    return _items.where((item) => item['kategori'] == _selectedCategory).toList();
  }

  String get selectedCategory => _selectedCategory;

  // Mengambil data dari database lokal dan memperbarui state memori aplikasi
  Future<void> refreshItems() async {
    _items = await DatabaseHelper.instance.fetchAllItems();
    notifyListeners();
  }

  // Menyesuaikan jumlah kuantitas stok barang secara manual
  Future<void> ubahStokManual(int id, int jumlahSekarang, int perubahan) async {
    int jumlahBaru = jumlahSekarang + perubahan;
    if (jumlahBaru < 0) jumlahBaru = 0;

    await DatabaseHelper.instance.updateStok(id, jumlahBaru);
    await refreshItems();
  }

  // Menyimpan entitas barang baru ke database lokal
  Future<void> tambahBarangBaru({
    required String nama,
    required String kategori,
    required String satuan,
    required int jumlah,
    required String keterangan,
    required String imagePath
  }) async {
    await DatabaseHelper.instance.insertItem({
      'nama_barang': nama,
      'kategori': kategori,
      'satuan': satuan,
      'jumlah': jumlah,
      'keterangan': keterangan,
      'image_path': imagePath,
    });
    await refreshItems();
  }

  // Memproses transkripsi teks perintah suara menggunakan NLP berbasis Regular Expression
  Future<String> prosesPerintahSuara(String teksSuara) async {
    String input = teksSuara.toLowerCase();
    int perubahan = 0;
    
    if (input.contains('tambah') || input.contains('masuk')) {
      perubahan = 1;
    } else if (input.contains('kurang') || input.contains('keluar') || input.contains('ambil')) {
      perubahan = -1;
    } else {
      return "Perintah tidak dikenali. Gunakan kata 'Tambah' atau 'Kurang'.";
    }

    RegExp regExpAngka = RegExp(r'\d+');
    Match? match = regExpAngka.firstMatch(input);
    if (match == null) return "Jumlah angka tidak ditemukan.";
    int jumlahInput = int.parse(match.group(0)!);

    int totalPerubahan = perubahan * jumlahInput;
    int? idBarangCocok;
    String namaBarangCocok = "";
    int stokSekarang = 0;

    // Pencocokan string nama entitas barang di dalam kalimat perintah suara
    for (var item in _items) {
      String namaBarang = item['nama_barang'].toString().toLowerCase();
      if (input.contains(namaBarang)) {
        idBarangCocok = item['id'];
        namaBarangCocok = item['nama_barang'];
        stokSekarang = item['jumlah'] ?? 0;
        break;
      }
    }

    if (idBarangCocok == null) {
      return "Barang tidak ditemukan di gudang.";
    }

    await ubahStokManual(idBarangCocok, stokSekarang, totalPerubahan);
    
    String aksi = totalPerubahan > 0 ? "ditambahkan" : "dikurangi";
    return "Berhasil! $namaBarangCocok $aksi sebanyak $jumlahInput unit.";
  }

  // Menghapus data barang dari penyimpanan lokal berdasarkan ID
  Future<void> hapusBarang(int id) async {
    await DatabaseHelper.instance.deleteItem(id);
    await refreshItems();
  }

  // Mengatur filter kategori aktif dan memperbarui visualisasi UI
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Memperbarui keseluruhan data spesifik dari entitas barang
  Future<void> perbaruiDataBarang({
    required int id,
    required String nama,
    required String kategori,
    required String satuan,
    required String keterangan,
    required int jumlah,
    required String imagePath,
  }) async {
    await DatabaseHelper.instance.updateItemFully({
      'id': id,
      'nama_barang': nama,
      'kategori': kategori,
      'satuan': satuan,
      'keterangan': keterangan,
      'jumlah': jumlah,
      'image_path': imagePath,
    });
    await refreshItems();
  }
}