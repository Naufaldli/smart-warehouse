import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventory.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
    );
  }

  // Inisialisasi struktur tabel database lokal
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_barang TEXT NOT NULL UNIQUE,
        kategori TEXT,
        satuan TEXT,
        jumlah INTEGER DEFAULT 0,
        keterangan TEXT,
        image_path TEXT
      )
    ''');

    // Seeding data awal untuk manajemen inventaris
    await db.rawInsert('''
      INSERT INTO items (nama_barang, kategori, satuan, jumlah, keterangan)
      VALUES ('Lemon Tea', 'Bigbrown', 'Unit', 10, 'Stok segar dari supplier')
    ''');
    await db.rawInsert('''
      INSERT INTO items (nama_barang, kategori, satuan, jumlah, keterangan)
      VALUES ('Paper Bowl', 'Kitchen', 'Unit', 10, 'Ukuran medium')
    ''');
  }

  // Mengambil seluruh data entitas dari tabel items
  Future<List<Map<String, dynamic>>> fetchAllItems() async {
    final db = await instance.database;
    return await db.query('items');
  }

  // Memperbarui kuantitas stok berdasarkan ID entitas
  Future<int> updateStok(int id, int jumlahBaru) async {
    final db = await instance.database;
    return await db.update(
      'items',
      {'jumlah': jumlahBaru},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menyisipkan data barang baru ke dalam database
  Future<int> insertItem(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('items', row);
  }

  // Menghapus data entitas berdasarkan ID
  Future<int> deleteItem(int id) async {
    final db = await instance.database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Memperbarui seluruh field record data barang secara komprehensif
  Future<int> updateItemFully(Map<String, dynamic> item) async {
    final db = await instance.database;
    return await db.update(
      'items',
      item,
      where: 'id = ?',
      whereArgs: [item['id']],
    );
  }
}