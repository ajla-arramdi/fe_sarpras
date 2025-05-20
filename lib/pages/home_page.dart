import 'package:flutter/material.dart';
import 'package:sisfos_fe/models/barang_model.dart';
import 'package:sisfos_fe/service/barang_service.dart';
import 'detail_barang_page.dart';  // Import halaman detail yang sudah dibuat

class ListBarangPage extends StatefulWidget {
  @override
  _ListBarangPageState createState() => _ListBarangPageState();
}

class _ListBarangPageState extends State<ListBarangPage> {
  late Future<List<Barang>> _futureBarang;
  final BarangService _barangService = BarangService();

  @override
  void initState() {
    super.initState();
    _futureBarang = _barangService.fetchBarangs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Barang')),
      body: FutureBuilder<List<Barang>>(
        future: _futureBarang,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada barang.'));
          }

          final barangList = snapshot.data!;

          return ListView.builder(
            itemCount: barangList.length,
            itemBuilder: (context, index) {
              final barang = barangList[index];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: barang.foto != null && barang.foto!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            barang.foto!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.broken_image, size: 50);
                            },
                          ),
                        )
                      : Icon(Icons.inventory, size: 50),
                  title: Text(barang.namaBarang),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jumlah: ${barang.jumlah}'),
                      Text('Kategori: ${barang.kategori.namaKategori}'),
                      if (barang.code != null) Text('Kode: ${barang.code}'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailBarangPage(barang: barang),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
