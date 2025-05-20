import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisfos_fe/pages/list_peminjam.dart';
import '../models/barang_model.dart';
import '../service/peminjaman_service.dart';
import '../service/auth_service.dart';

class PeminjamanPage extends StatefulWidget {
  final List<Barang> barangList;

  const PeminjamanPage({super.key, required this.barangList});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _kelasController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _tglPinjamController = TextEditingController();
  final _tglKembaliController = TextEditingController();

  Barang? _selectedBarang;
  int? _userId;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserId();

    // Set barang default ke barang pertama yang dikirim (misal dari DetailBarangPage)
    if (widget.barangList.isNotEmpty) {
      _selectedBarang = widget.barangList[0];
    }
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() &&
        _selectedBarang != null &&
        _userId != null) {

      // Get the auth token
      final token = await _authService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi login habis, silakan login kembali')),
        );
        return;
      }

      final data = {
        'user_id': _userId,
        'nama_peminjam': _namaController.text,
        'kelas_peminjam': _kelasController.text,
        'jumlah': int.tryParse(_jumlahController.text) ?? 1,
        'tanggal_pinjam': _tglPinjamController.text,
        'tanggal_pengembalian': _tglKembaliController.text,
        'barang_id': _selectedBarang!.id,
        'keterangan': _keteranganController.text,
        'status': 'menunggu',
      };

     final success = await PeminjamanService.createPeminjaman(data, token);

if (success) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Peminjaman berhasil')),
  );

  // Navigasi ke halaman history dan refresh datanya
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const PeminjamanHistoryPage()),
  );
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Gagal melakukan peminjaman')),
  );
}

    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: Text("Silakan login terlebih dahulu")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Form Peminjaman")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nama peminjam bisa dikosongkan atau diisi manual
              // TextFormField(
              //   controller: _namaController,
              //   decoration: const InputDecoration(labelText: 'Nama Peminjam'),
              //   validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              // ),
              TextFormField(
                controller: _kelasController,
                decoration: const InputDecoration(labelText: 'Kelas'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _jumlahController,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _tglPinjamController,
                readOnly: true,
                onTap: () => _pickDate(_tglPinjamController),
                decoration: const InputDecoration(labelText: 'Tanggal Pinjam'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _tglKembaliController,
                readOnly: true,
                onTap: () => _pickDate(_tglKembaliController),
                decoration:
                    const InputDecoration(labelText: 'Tanggal Pengembalian'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              DropdownButtonFormField<Barang>(
                value: _selectedBarang,
                decoration: const InputDecoration(labelText: 'Pilih Barang'),
                items: widget.barangList.map((barang) {
                  return DropdownMenuItem(
                    value: barang,
                    child: Text(barang.namaBarang),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedBarang = val),
                validator: (v) => v == null ? 'Pilih barang dulu' : null,
              ),
              TextFormField(
                controller: _keteranganController,
                decoration:
                    const InputDecoration(labelText: 'Keterangan (opsional)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
