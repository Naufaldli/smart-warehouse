import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/inventory_provider.dart';
import 'detail_page.dart';

class AllItemsPage extends StatefulWidget {
  const AllItemsPage({super.key});

  @override
  State<AllItemsPage> createState() => _AllItemsPageState();
}

class _AllItemsPageState extends State<AllItemsPage> {
  final TextEditingController _pageSearchController = TextEditingController();
  String _pageSearchQuery = "";

  @override
  void dispose() {
    _pageSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Semua Inventaris",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: TextField(
                controller: _pageSearchController,
                decoration: const InputDecoration(
                  hintText: "Cari berdasarkan nama barang...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
                onChanged: (value) {
                  setState(() {
                    _pageSearchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),

          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (context, provider, child) {
                final semuaBarangGlobal = provider.items;

                // Penyaringan data global berdasarkan query pencarian halaman
                final listTersaring = semuaBarangGlobal.where((item) {
                  final nama = (item['nama_barang'] ?? '').toString().toLowerCase();
                  return nama.contains(_pageSearchQuery);
                }).toList();

                if (listTersaring.isEmpty) {
                  return const Center(
                    child: Text("Tidak ada barang yang cocok.", style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  itemCount: listTersaring.length,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemBuilder: (context, index) {
                    final barang = listTersaring[index];
                    
                    Color statusColor = (barang['jumlah'] ?? 0) > 5 ? Colors.green : Colors.red;
                    String statusText = (barang['jumlah'] ?? 0) > 5 ? "Stok Aman" : "Stok Menipis";
                    final String imagePath = barang['image_path'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: SizedBox(
                          width: 45,
                          height: 45,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imagePath.isNotEmpty
                                ? FutureBuilder<bool>(
                                    future: File(imagePath).exists(),
                                    builder: (context, snapshot) {
                                      if (snapshot.data == true) {
                                        return Image.file(File(imagePath), fit: BoxFit.cover);
                                      } else {
                                        return Image.asset('assets/images/$imagePath', fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey));
                                      }
                                    },
                                  )
                                : const Icon(Icons.image, color: Colors.grey),
                          ),
                        ),
                        title: Text(barang['nama_barang'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${barang['kategori']} | $statusText"), 
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1), 
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Qty: ${barang['jumlah']} ${barang['satuan'] ?? ''}",
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DetailPage(barang: barang)),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}