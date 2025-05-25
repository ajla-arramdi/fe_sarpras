import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/pengembalian_service.dart';

class PengembalianFormPage extends StatefulWidget {
  final Map<String, dynamic> peminjamanData;

  const PengembalianFormPage({super.key, required this.peminjamanData});

  @override
  State<PengembalianFormPage> createState() => _PengembalianFormPageState();
}

class _PengembalianFormPageState extends State<PengembalianFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _tanggalController = TextEditingController();
  String _kondisiBarang = 'baik';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final jumlah = widget.peminjamanData['jumlah'] ?? 1;
    _jumlahController.text = jumlah.toString();
    _tanggalController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _pickTanggalPengembalian() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Pengembalian'),
        content: const Text('Apakah kamu yakin ingin mengembalikan barang ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Kembalikan'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _submitPengembalian() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await _showConfirmationDialog();
    if (!confirm) return;

    setState(() => _isSubmitting = true);

    try {
      final success = await PengembalianService().createPengembalian(
        userId: widget.peminjamanData['user_id'],
        peminjamanId: widget.peminjamanData['id'],
        jumlah: int.parse(_jumlahController.text),
        tanggalDikembalikan: _tanggalController.text,
        kondisiBarang: _kondisiBarang,
        denda: 0,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang berhasil dikembalikan')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengembalikan barang')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final barang = widget.peminjamanData['barang'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Pengembalian'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Barang: ${barang?['nama_barang'] ?? 'Tidak ditemukan'}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Jumlah Pinjam: ${widget.peminjamanData['jumlah']}'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Jumlah yang dikembalikan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final jumlahPinjam = widget.peminjamanData['jumlah'];
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  final intValue = int.tryParse(value);
                  if (intValue == null || intValue <= 0) {
                    return 'Jumlah tidak valid';
                  }
                  if (intValue > jumlahPinjam) {
                    return 'Jumlah melebihi jumlah pinjaman';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _tanggalController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Pengembalian',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _pickTanggalPengembalian,
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _kondisiBarang,
                decoration: const InputDecoration(
                  labelText: 'Kondisi Barang',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'baik', child: Text('Baik')),
                  DropdownMenuItem(value: 'rusak', child: Text('Rusak')),
                  DropdownMenuItem(value: 'hilang', child: Text('Hilang')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _kondisiBarang = value;
                    });
                  }
                },
              ),

              if (_kondisiBarang != 'baik') ...[
                const SizedBox(height: 12),
                const Text(
                  'Catatan: Denda akan ditentukan oleh admin untuk barang rusak atau hilang.',
                  style: TextStyle(color: Colors.red),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.assignment_return),
                  label: Text(_isSubmitting ? 'Memproses...' : 'Kembalikan Barang'),
                  onPressed: _isSubmitting ? null : _submitPengembalian,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
