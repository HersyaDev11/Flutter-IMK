import 'dart:convert';
import 'package:flutter/services.dart' as root_bundle;
import 'package:flutter/material.dart';
import 'package:sejarah_pahlawan/model_main.dart';
import 'package:sejarah_pahlawan/page/detail_page.dart';

void main() {
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomePage> {
  // 1. Simpan hasil Future di state untuk efisiensi
  Future<List<ModelMain>>? _pahlawanFuture;
  final TextEditingController _searchController = TextEditingController();
  String _filterData = "";
  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    // 2. Panggil fungsi pemuat data HANYA SEKALI di initState
    _pahlawanFuture = _readJsonData();

    _searchController.addListener(() {
      setState(() {
        _filterData = _searchController.text;
      });
    });

    _scrollController.addListener(() {
      // Logika untuk menampilkan Floating Action Button dibuat lebih efisien
      if (_scrollController.offset > 10) {
        if (!_showFab) {
          setState(() {
            _showFab = true;
          });
        }
      } else {
        if (_showFab) {
          setState(() {
            _showFab = false;
          });
        }
      }
    });
  }

  Future<List<ModelMain>> _readJsonData() async {
    final jsonData = await root_bundle.rootBundle
        .loadString('assets/pahlawan_nasional.json');
    final listData = json.decode(jsonData) as List<dynamic>;
    return listData.map((e) => ModelMain.fromJson(e)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Fungsi untuk navigasi ke halaman detail
  void _navigateToDetail(ModelMain pahlawan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPahlawan(
          nama: pahlawan.nama.toString(),
          nama2: pahlawan.nama2.toString(),
          kategori: pahlawan.kategori.toString(),
          asal: pahlawan.asal.toString(),
          usia: pahlawan.usia.toString(),
          lahir: pahlawan.lahir.toString(),
          gugur: pahlawan.gugur.toString(),
          lokasimakam: pahlawan.lokasimakam.toString(),
          history: pahlawan.history.toString(),
          img: pahlawan.img.toString(),
        ),
      ),
    );
  }

  // 3. Buat widget terpisah untuk Card Pahlawan agar tidak duplikasi kode
  Widget _buildPahlawanCard(ModelMain pahlawan) {
    return GestureDetector(
      onTap: () => _navigateToDetail(pahlawan),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // 4. Implementasi Image dengan loading dan error builder
              SizedBox(
                width: 70,
                height: 70,
                child: ClipOval(
                  child: Image.network(
                    pahlawan.img.toString(),
                    fit: BoxFit.cover,
                    // Menampilkan indikator loading saat gambar diunduh
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    // Menampilkan ikon error jika gambar gagal dimuat
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      // Ini akan mencetak alasan error ke konsol debug Anda
                      print("Image Load Error: $exception");
                      return const Icon(Icons.error,
                          color: Colors.red, size: 40);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pahlawan.nama.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pahlawan.nama2.toString(),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Anda bisa menambahkan kategori di sini jika mau
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
          child: Text('Sejarah Pahlawan',
              style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 30)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _showFab ? 1.0 : 0.0,
        child: FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn);
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.arrow_upward),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: 'Cari nama pahlawan',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () => _searchController.clear(),
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.red,
                          ),
                        ),
                  contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  )),
            ),
          ),
          Expanded(
            // 5. Gunakan FutureBuilder dengan state _pahlawanFuture
            child: FutureBuilder<List<ModelMain>>(
              future: _pahlawanFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text("Gagal memuat data: ${snapshot.error}"));
                } else if (snapshot.hasData) {
                  // 6. Logika filter yang disederhanakan
                  final allPahlawan = snapshot.data!;
                  final filteredPahlawan = allPahlawan.where((pahlawan) {
                    final nama = pahlawan.nama.toString().toLowerCase();
                    final filter = _filterData.toLowerCase();
                    return nama.contains(filter);
                  }).toList();

                  if (filteredPahlawan.isEmpty) {
                    return const Center(
                        child: Text("Pahlawan tidak ditemukan.",
                            style: TextStyle(fontSize: 16)));
                  }

                  // 7. Gunakan ListView.builder dengan widget Card yang sudah dibuat
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: filteredPahlawan.length,
                    itemBuilder: (context, index) {
                      return _buildPahlawanCard(filteredPahlawan[index]);
                    },
                  );
                } else {
                  return const Center(child: Text("Tidak ada data pahlawan."));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
