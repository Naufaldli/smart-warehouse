import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'detail_page.dart';
import 'add_item_page.dart';
import 'voice_button.dart';
import 'dart:io';
import 'all_items_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Konversi indeks bulan ke nama bulan dalam Bahasa Indonesia
  String _getNamaBulan(int month) {
    List<String> bulan = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return bulan[month - 1];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSmartWarehouseCard(context),
            _buildCategoryFilters(),
            Expanded(child: _buildPopularList()),
            _buildVoiceCommandButton(),
          ],
        ),
      ),
    );
  }

  // Header komponen: Menampilkan tanggal saat ini atau form pencarian
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!_isSearching)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Date", style: TextStyle(color: Colors.grey, fontSize: 14)),
                Row(
                  children: [
                    Text(
                      "${DateTime.now().day} ${_getNamaBulan(DateTime.now().month)} ${DateTime.now().year}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                    ),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ],
            )
          else
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "Cari nama barang...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
            ),
          
          const SizedBox(width: 15),

          GestureDetector(
            onTap: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = "";
                } else {
                  _isSearching = true;
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: _isSearching ? Colors.red : Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }

  // Banner informasi Smart Warehouse
  Widget _buildSmartWarehouseCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE082),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    children: [
                      TextSpan(text: "Smart "),
                      TextSpan(text: "Warehouse", style: TextStyle(color: Colors.orange)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Kendali penuh inventaris dalam satu genggaman"),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddItemPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text("Add Item"),
                )
              ],
            ),
          ),
          Image.asset(
            'assets/images/Banner img.png',
            width: 100,
            height: 170,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  // Filter Kategori menggunakan Horizontal ChoiceChip
  Widget _buildCategoryFilters() {
    final categories = ['All', 'Bigbrown', 'Kitchen', 'Futsal'];

    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 15),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = provider.selectedCategory == cat;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(
                    cat, 
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.orange,
                  backgroundColor: Colors.white,
                  side: BorderSide.none, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (bool selected) {
                    if (selected) {
                      provider.setCategory(cat);
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  // List data barang utama berdasarkan filter kategori dan keyword pencarian
  Widget _buildPopularList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Popular", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllItemsPage()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text("View All >", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (context, inventoryProvider, child) {
                final semuaBarang = inventoryProvider.items;

                // Proses filtering gabungan data lokal memori
                final listBarang = semuaBarang.where((item) {
                  final namaBarang = (item['nama_barang'] ?? '').toString().toLowerCase();
                  final kategoriBarang = (item['kategori'] ?? '').toString().toLowerCase();

                  bool cocokKategori = inventoryProvider.selectedCategory == "All" || 
                                       kategoriBarang == inventoryProvider.selectedCategory.toLowerCase();

                  bool cocokSearch = namaBarang.contains(_searchQuery);

                  return cocokKategori && cocokSearch;
                }).toList();

                if (listBarang.isEmpty) {
                  return const Center(
                    child: Text(
                      "Barang tidak ditemukan atau gudang kosong.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: listBarang.length,
                  itemBuilder: (context, index) {
                    final barang = listBarang[index];
                    
                    Color statusColor = (barang['jumlah'] ?? 0) > 5 ? Colors.green : Colors.red;
                    String statusText = (barang['jumlah'] ?? 0) > 5 ? "Stok Aman" : "Stok Menipis";

                    return Dismissible(
                      key: Key(barang['id'].toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8), 
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15), 
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white, size: 28),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text("Hapus Barang"),
                              content: Text("Apakah Anda yakin ingin menghapus '${barang['nama_barang']}'?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext, false),
                                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext, true),
                                  child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        context.read<InventoryProvider>().hapusBarang(barang['id']);
                        
                        if (!mounted) return;
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${barang['nama_barang']} berhasil dihapus")),
                        );
                      },
                      child: _buildItemCard(
                        id: barang['id'],
                        title: barang['nama_barang'] ?? '',
                        sub: barang['kategori'] ?? '',
                        qty: (barang['jumlah'] ?? 0).toString(),
                        statusColor: statusColor,
                        statusText: statusText,
                        imageFileName: barang['image_path'] ?? '',
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

  // Komponen Card Item dengan penanganan gambar asinkron
  Widget _buildItemCard({
    required int id,
    required String title,
    required String sub,
    required String qty,
    required Color statusColor,
    required String statusText,
    required String imageFileName,
  }) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(
                  barang: {
                    'id': id,
                    'nama_barang': title,
                    'kategori': sub,
                    'jumlah': int.parse(qty),
                    'image_path': imageFileName,
                    'keterangan': title == "Lemon Tea" 
                        ? "Stok segar langsung dari supplier utama." 
                        : "Ukuran standar untuk kebutuhan operasional.",
                  },
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageFileName.isNotEmpty
                        ? FutureBuilder<bool>(
                            future: File(imageFileName).exists(),
                            builder: (context, snapshot) {
                              if (snapshot.data == true) {
                                return Image.file(
                                  File(imageFileName),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
                                );
                              } else {
                                return Image.asset(
                                  'assets/images/$imageFileName',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
                                );
                              }
                            },
                          )
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          CircleAvatar(backgroundColor: statusColor, radius: 4),
                          const SizedBox(width: 5),
                          Text(statusText, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(qty, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVoiceCommandButton() {
    return const VoiceButton(); 
  }
}