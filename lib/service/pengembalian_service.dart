import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sisfos_fe/models/Pengembalian_Model.dart';
 // Pastikan path-nya benar

class PengembalianService {
  // Ganti IP sesuai kebutuhan: emulator (10.0.2.2) atau device (192.168.x.x)
  final String baseUrl = 'http://127.0.0.1:8000/api/pengembalian';

  /// Ambil semua data pengembalian
  Future<List<Pengembalian>> getAllPengembalian() async {
    final response = await http.get(Uri.parse('$baseUrl/pengembalian'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List pengembalians = data['data'];

      return pengembalians.map((e) => Pengembalian.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data pengembalian: ${response.body}');
    }
  }

  /// Ambil pengembalian berdasarkan ID
  Future<Pengembalian?> getPengembalianById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/pengembalian/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Pengembalian.fromJson(data);
    } else {
      print('Gagal mengambil detail: ${response.body}');
      return null;
    }
  }

  /// Kirim data pengembalian ke API
  Future<bool> createPengembalian({
    required int userId,
    required int peminjamanId,
    required int jumlah,
    required String tanggalDikembalikan,
    required String kondisiBarang,
    double denda = 0,
    String status = 'pending',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'peminjaman_id': peminjamanId,
        'jumlah': jumlah,
        'tanggal_dikembalikan': tanggalDikembalikan,
        'kondisi_barang': kondisiBarang,
        'denda': denda,
        'status': status,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
