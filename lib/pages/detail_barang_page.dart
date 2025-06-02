import 'package:flutter/material.dart';
import 'package:sisfos_fe/models/barang_model.dart';
import 'package:sisfos_fe/pages/pinjaman_page.dart';

class DetailBarangPage extends StatefulWidget {
  final Barang barang;

  const DetailBarangPage({Key? key, required this.barang}) : super(key: key);

  @override
  State<DetailBarangPage> createState() => _DetailBarangPageState();
}

class _DetailBarangPageState extends State<DetailBarangPage> {
  final Color _primaryOrange = Color(0xFFFF6B00);
  final Color _lightOrange = Color(0xFFFFF3E0);
  final Color _darkOrange = Color(0xFFBF360C);

  @override
  Widget build(BuildContext context) {
    final barang = widget.barang;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Detail Barang',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto Barang
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [_lightOrange, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              height: 250,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: barang.foto != null && barang.foto!.isNotEmpty
                    ? Image.network(
                        barang.foto!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.broken_image,
                          size: 64,
                          color: _primaryOrange,
                        ),
                      )
                    : Icon(Icons.inventory_2, size: 64, color: _primaryOrange),
              ),
            ),
            const SizedBox(height: 20),

            // Nama Barang
            Text(
              barang.namaBarang,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _darkOrange,
              ),
            ),
            const SizedBox(height: 12),

            // Kategori Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                barang.kategori.namaKategori,
                style: TextStyle(
                  color: _primaryOrange,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Detail Info Cards
            _buildInfoCard("Stok Tersedia", "${barang.jumlah} pcs", Icons.inventory_2),
            if (barang.code != null) ...[
              const SizedBox(height: 12),
              _buildInfoCard("Kode Barang", barang.code!, Icons.qr_code),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: barang.jumlah > 0
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PeminjamanPage(barangList: [barang]),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryOrange,
              disabledBackgroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              barang.jumlah > 0 ? 'Pinjam Barang' : 'Stok Habis',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primaryOrange, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
