import 'package:flutter/material.dart';
import 'package:sisfos_fe/service/pengembalian_service.dart';
import '../models/peminjaman_model.dart';


class PengembalianForm extends StatefulWidget {
  final int userId;
  final Peminjaman peminjaman;
  final PengembalianService pengembalianService;

  const PengembalianForm({
    Key? key,
    required this.userId,
    required this.peminjaman,
    required this.pengembalianService,
  }) : super(key: key);

  @override
  State<PengembalianForm> createState() => _PengembalianFormState();
}

class _PengembalianFormState extends State<PengembalianForm> {
  final _formKey = GlobalKey<FormState>();
  int? _jumlah;
  DateTime? _tanggalDikembalikan;
  String _kondisiBarang = 'baik';

  final List<String> kondisiOptions = ['baik', 'terlambat', 'rusak', 'hilang'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form Pengembalian')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Barang: ${widget.peminjaman.barang?.namaBarang ?? 'Nama barang'}'),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: widget.peminjaman.jumlah.toString(),
                decoration: InputDecoration(
                  labelText: 'Jumlah yang dikembalikan',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Jumlah wajib diisi';
                  final jumlah = int.tryParse(val);
                  if (jumlah == null || jumlah <= 0) return 'Jumlah tidak valid';
                  if (jumlah > widget.peminjaman.jumlah) return 'Jumlah tidak boleh lebih dari yang dipinjam';
                  return null;
                },
                onSaved: (val) => _jumlah = int.tryParse(val!),
              ),

              const SizedBox(height: 16),

              ListTile(
                title: Text(_tanggalDikembalikan == null
                    ? 'Pilih tanggal pengembalian'
                    : 'Tanggal dikembalikan: ${_tanggalDikembalikan!.toLocal()}'.split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _tanggalDikembalikan = picked;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _kondisiBarang,
                decoration: InputDecoration(
                  labelText: 'Kondisi Barang',
                  border: OutlineInputBorder(),
                ),
                items: kondisiOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _kondisiBarang = val!;
                  });
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (_tanggalDikembalikan == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tanggal pengembalian harus dipilih')),
                    );
                    return;
                  }
                  _formKey.currentState!.save();

                  final body = {
                    'user_id': widget.userId,
                    'peminjaman_id': widget.peminjaman,
                    'jumlah': _jumlah,
                    'tanggal_dikembalikan': _tanggalDikembalikan!.toIso8601String(),
                    'kondisi_barang': _kondisiBarang,
                  };

                  try {
                    final result = await widget.pengembalianService;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pengembalian berhasil dikirim')),
                    );
                    Navigator.pop(context, result);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal mengirim pengembalian: $e')),
                    );
                  }
                },
                child: Text('Kirim Pengembalian'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
