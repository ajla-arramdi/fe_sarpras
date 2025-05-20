import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/peminjaman_model.dart';

class PengembalianService {
  final String baseUrl = 'http://127.0.0.1:8000/api/pengembalians'; // Ganti dengan URL backend kamu jika berbeda

  Future<bool> kembalikanBarang({
    required int userId,
    required int peminjamanId,
    required String kondisi,
  }) async {
    final url = Uri.parse('$baseUrl/pengembalian');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'peminjaman_id': peminjamanId,
        'kondisi': kondisi,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      // Print log untuk debug jika perlu
      print('Gagal mengembalikan barang: ${response.body}');
      return false;
    }
  }
}
