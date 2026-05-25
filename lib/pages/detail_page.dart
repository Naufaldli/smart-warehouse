import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/inventory_provider.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> barang;

  const DetailPage({super.key, required this.barang});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isEditing = false;

  late TextEditingController _namaController;
  late TextEditingController _kategoriController;
  late TextEditingController _satuanController;
  late TextEditingController _keteranganController;
  late int _jumlahStok;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = "Tekan tombol lalu bicaralah...";

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.barang['nama_barang']);
    _kategoriController = TextEditingController(text: widget.barang['kategori']);
    _satuanController = TextEditingController(text: widget.barang['satuan'] ?? 'Unit');
    _keteranganController = TextEditingController(text: widget.barang['keterangan'] ?? '');
    _jumlahStok = widget.barang['jumlah'] ?? 0;

    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kategoriController.dispose();
    _satuanController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  // Inisialisasi dan pemrosesan input suara (Speech to Text)
  void _listenVoice() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('Status Suara: $val'),
        onError: (val) => debugPrint('Eror Suara: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) async {
            setState(() {
              _voiceText = val.recognizedWords;
            });
            
            if (val.finalResult) {
              setState(() => _isListening = false);
              
              final provider = context.read<InventoryProvider>();
              String infoHasil = await provider.prosesPerintahSuara(_voiceText);
              
              // Sinkronisasi ulang state internal dengan data provider terbaru
              final barangTerbaru = provider.items.firstWhere((element) => element['id'] == widget.barang['id']);
              setState(() {
                _jumlahStok = barangTerbaru['jumlah'] ?? 0;
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(infoHasil)));
              }
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imagePath = widget.barang['image_path'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Detail Barang", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit, color: Colors.orange),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // Mengembalikan nilai form ke data asli jika membatalkan editing
                  _namaController.text = widget.barang['nama_barang'];
                  _kategoriController.text = widget.barang['kategori'];
                  _satuanController.text = widget.barang['satuan'] ?? 'Unit';
                  _keteranganController.text = widget.barang['keterangan'] ?? '';
                }
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: imagePath.isNotEmpty
                      ? FutureBuilder<bool>(
                          future: File(imagePath).exists(),
                          builder: (context, snapshot) {
                            if (snapshot.data == true) {
                              return Image.file(File(imagePath), fit: BoxFit.cover);
                            } else {
                              return Image.asset('assets/images/$imagePath', fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(Icons.image, size: 100));
                            }
                          },
                        )
                      : const Icon(Icons.image, size: 100),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _isEditing
                ? _buildEditForm()
                : _buildStandardDetails(),

            const SizedBox(height: 25),

            _buildQuantitySection(),

            const SizedBox(height: 30),

            _isEditing ? _buildSaveButton() : _buildVoiceButton(),
          ],
        ),
      ),
    );
  }

  // Tampilan komponen informasi detail produk
  Widget _buildStandardDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_namaController.text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text("Category: ${_kategoriController.text} | Satuan: ${_satuanController.text}", 
            style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 15),
        const Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(_keteranganController.text.isEmpty ? "Tidak ada deskripsi." : _keteranganController.text, 
            style: const TextStyle(color: Colors.black87, fontSize: 15)),
      ],
    );
  }

  // Komponen input form untuk proses pembaruan data
  Widget _buildEditForm() {
    return Column(
      children: [
        TextField(
          controller: _namaController,
          decoration: const InputDecoration(labelText: "Nama Barang", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _kategoriController,
          decoration: const InputDecoration(labelText: "Kategori", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _satuanController,
          decoration: const InputDecoration(labelText: "Satuan (misal: Box, Pcs, Unit)", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _keteranganController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: "Deskripsi", border: OutlineInputBorder()),
        ),
      ],
    );
  }

  // Komponen kontrol penyesuaian kuantitas barang secara manual
  Widget _buildQuantitySection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Current Inventory", style: TextStyle(color: Colors.grey)),
              Text("$_jumlahStok ${_satuanController.text}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 30, color: Colors.grey),
                onPressed: () {
                  if (_jumlahStok > 0) {
                    setState(() => _jumlahStok--);
                    context.read<InventoryProvider>().ubahStokManual(widget.barang['id'], _jumlahStok + 1, -1);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text("$_jumlahStok", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 30, color: Colors.orange),
                onPressed: () {
                  setState(() => _jumlahStok++);
                  context.read<InventoryProvider>().ubahStokManual(widget.barang['id'], _jumlahStok - 1, 1);
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: const StadiumBorder()),
        onPressed: () async {
          await context.read<InventoryProvider>().perbaruiDataBarang(
                id: widget.barang['id'],
                nama: _namaController.text,
                kategori: _kategoriController.text,
                satuan: _satuanController.text,
                keterangan: _keteranganController.text,
                jumlah: _jumlahStok,
                imagePath: widget.barang['image_path'] ?? '',
              );
          setState(() => _isEditing = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data sukses diperbarui!")));
          }
        },
        child: const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isListening ? Colors.red : Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: _listenVoice,
        icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white),
        label: Text(
          _isListening ? "Mendengarkan... Katakan Perintah" : "Bicara untuk Update Stok",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}