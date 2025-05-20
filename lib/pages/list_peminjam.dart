import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/peminjaman_service.dart';
import '../service/auth_service.dart';

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
    final prefs = await SharedPreferences.getInstance();
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

  Widget _buildListItem(Map<String, dynamic> item) {
    final barang = item['barang'];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: ListTile(
        title: Text(
          barang != null ? barang['nama_barang'] ?? 'Barang' : 'Barang tidak ditemukan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jumlah: ${item['jumlah'] ?? '-'}'),
              Text('Tanggal Pinjam: ${item['tanggal_pinjam'] ?? '-'}'),
              Text('Tanggal Kembali: ${item['tanggal_pengembalian'] ?? '-'}'),
              Text('Status: ${item['status'] ?? '-'}'),
            ],
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Peminjaman')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _peminjamanList.isEmpty
              ? const Center(child: Text('Belum ada riwayat peminjaman'))
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
