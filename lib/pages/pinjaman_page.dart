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
  final _kelasController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _tglPinjamController = TextEditingController();
  final _tglKembaliController = TextEditingController();

  Barang? _selectedBarang;
  int? _userId;
  final _authService = AuthService();

  final Color _primaryColor = const Color(0xFF00897B); // Teal
  final Color _secondaryColor = const Color(0xFF00BCD4); // Cyan
  final Color _lightTeal = const Color(0xFFE0F2F1);
  final Color _darkTeal = const Color(0xFF00695C);

  @override
  void initState() {
    super.initState();
    _loadUserId();

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
      final token = await _authService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi login habis, silakan login kembali')),
        );
        return;
      }

      final data = {
        'user_id': _userId,
        'nama_peminjam': '',
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
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _darkTeal,
            ),
          ),
          child: child!,
        );
      },
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
      appBar: AppBar(
        title: const Text(
          "Form Peminjaman",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  label: 'Kelas',
                  controller: _kelasController,
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                _buildTextField(
                  label: 'Jumlah',
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                _buildTextField(
                  label: 'Tanggal Pinjam',
                  controller: _tglPinjamController,
                  readOnly: true,
                  onTap: () => _pickDate(_tglPinjamController),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                _buildTextField(
                  label: 'Tanggal Pengembalian',
                  controller: _tglKembaliController,
                  readOnly: true,
                  onTap: () => _pickDate(_tglKembaliController),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Barang>(
                  value: _selectedBarang,
                  decoration: InputDecoration(
                    labelText: 'Barang',
                    filled: true,
                    fillColor: _lightTeal,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _primaryColor, width: 2),
                    ),
                  ),
                  items: widget.barangList.map((barang) {
                    return DropdownMenuItem(
                      value: barang,
                      child: Text(
                        barang.namaBarang,
                        style: TextStyle(color: _darkTeal),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedBarang = val),
                  validator: (v) => v == null ? 'Pilih barang dulu' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Keterangan',
                  controller: _keteranganController,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text("Pinjam Sekarang"),
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        style: TextStyle(color: _darkTeal),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _primaryColor),
          filled: true,
          fillColor: _lightTeal,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
        ),
      ),
    );
  }
}
