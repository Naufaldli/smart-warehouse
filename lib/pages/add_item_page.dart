import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  
  String _selectedKategori = 'Bigbrown';
  String _selectedSatuan = 'Unit';
  String _imagePath = '';
  final ImagePicker _picker = ImagePicker();

  final List<String> _kategoriList = ['Bigbrown', 'Kitchen', 'Futsal'];
  final List<String> _satuanList = ['Unit', 'Box', 'Pcs'];

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Tambah Barang", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Ambil dari Kamera'),
                              onTap: () {
                                Navigator.pop(context);
                                _ambilGambar(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Pilih dari Galeri'),
                              onTap: () {
                                Navigator.pop(context);
                                _ambilGambar(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      image: _imagePath.isNotEmpty
                          ? DecorationImage(image: FileImage(File(_imagePath)), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _imagePath.isEmpty
                        ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              
              _buildLabel("Nama Barang"),
              TextFormField(
                controller: _namaController,
                decoration: _inputDecoration("Masukkan nama barang"),
                validator: (v) => v!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              const SizedBox(height: 20),

              _buildLabel("Kategori"),
              DropdownButtonFormField<String>(
                initialValue: _selectedKategori,
                decoration: _inputDecoration("Pilih Kategori"),
                items: _kategoriList.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                onChanged: (v) => setState(() => _selectedKategori = v!),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Jumlah"),
                        TextFormField(
                          controller: _jumlahController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration("0"),
                          validator: (v) => v!.isEmpty ? "Isi stok awal" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Satuan"),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSatuan,
                          decoration: _inputDecoration("Unit"),
                          items: _satuanList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setState(() => _selectedSatuan = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildLabel("Keterangan"),
              TextFormField(
                controller: _keteranganController,
                maxLines: 3,
                decoration: _inputDecoration("Tambahkan catatan barang..."),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _simpanBarang,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Simpan Barang", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    );
  }

  // Mengambil gambar dari sumber yang dipilih dan menerapkan kompresi media
  Future<void> _ambilGambar(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  // Melakukan validasi input form dan menyimpan data ke penyimpanan lokal
  void _simpanBarang() {
    if (_namaController.text.isEmpty || _jumlahController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Jumlah wajib diisi!')),
      );
      return;
    }

    context.read<InventoryProvider>().tambahBarangBaru(
      nama: _namaController.text,
      kategori: _selectedKategori,
      satuan: _selectedSatuan,
      jumlah: int.parse(_jumlahController.text),
      keterangan: _keteranganController.text,
      imagePath: _imagePath,
    );

    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Barang baru berhasil ditambahkan!')),
    );
  }
}