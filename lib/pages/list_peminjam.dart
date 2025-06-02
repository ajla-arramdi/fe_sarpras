import 'package:flutter/material.dart';
import '../service/peminjaman_service.dart';
import '../service/auth_service.dart';
import 'pengembalian_form_page.dart';

class PeminjamanHistoryPage extends StatefulWidget {
  const PeminjamanHistoryPage({super.key});

  @override
  State<PeminjamanHistoryPage> createState() => _PeminjamanHistoryPageState();
}

class _PeminjamanHistoryPageState extends State<PeminjamanHistoryPage> {
  final _authService = AuthService();
  List<dynamic> _peminjamanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    final token = await _authService.getToken();
    if (token == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User belum login')),
      );
      return;
    }

    try {
      final data = await PeminjamanService.fetchPeminjamanUser(token);
      setState(() {
        _peminjamanList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildListItem(Map<String, dynamic> item) {
    final barang = item['barang'];
    final namaBarang = barang?['nama_barang'] ?? 'Barang';
    final status = (item['status'] ?? '').toString().toLowerCase();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER BARANG
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 32, color: Colors.deepOrange),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    namaBarang,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.1),
                    border: Border.all(color: _statusColor(status)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
            const Divider(height: 24),
            /// DETAIL PINJAMAN
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Jumlah", "${item['jumlah']}"),
                  _buildDetailRow("Tanggal Pinjam", item['tanggal_pinjam']),
                  _buildDetailRow("Tanggal Kembali", item['tanggal_pengembalian']),
                ],
              ),
            ),
            /// TOMBOL KEMBALIKAN
            if (status == 'disetujui') ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.assignment_return),
                  label: const Text("Kembalikan"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PengembalianFormPage(peminjamanData: item),
                      ),
                    );
                  },
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value ?? '-', style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.history, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Belum ada riwayat peminjaman',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Riwayat Peminjaman"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _peminjamanList.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _peminjamanList.length,
                  itemBuilder: (context, index) {
                    final item = _peminjamanList[index];
                    return _buildListItem(item);
                  },
                ),
    );
  }
}
