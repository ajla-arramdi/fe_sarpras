import 'package:flutter/material.dart';
import 'package:sisfos_fe/models/barang_model.dart';
import 'package:sisfos_fe/pages/pinjaman_page.dart'; // Pastikan nama file/class benar

class DetailBarangPage extends StatefulWidget {
  final Barang barang;

  const DetailBarangPage({Key? key, required this.barang}) : super(key: key);

  @override
  State<DetailBarangPage> createState() => _DetailBarangPageState();
}

class _DetailBarangPageState extends State<DetailBarangPage> {
  @override
  Widget build(BuildContext context) {
    final barang = widget.barang;

    return Scaffold(
      appBar: AppBar(title: Text(barang.namaBarang)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto barang tampil di atas
            Center(
              child: barang.foto != null && barang.foto!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        barang.foto!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.broken_image, size: 100);
                        },
                      ),
                    )
                  : Icon(Icons.inventory, size: 100),
            ),
            const SizedBox(height: 16),

            Text(
              'Nama: ${barang.namaBarang}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Kategori: ${barang.kategori.namaKategori}'),
            const SizedBox(height: 8),
            Text('Jumlah stok: ${barang.jumlah}'),
            const SizedBox(height: 8),
            if (barang.code != null) Text('Kode barang: ${barang.code}'),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: barang.jumlah > 0
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PeminjamanPage(barangList: [barang]),
                          ),
                        );
                      }
                    : null,
                child: const Text('Pinjam Barang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
