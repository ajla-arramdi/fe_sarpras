import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sisfos_fe/models/barang_model.dart';

class BarangService {
  final String baseUrl;

  BarangService({this.baseUrl = 'http://localhost:8000/api'}); // bisa override saat testing/production

  Future<List<Barang>> fetchBarangs() async {
    final url = Uri.parse('$baseUrl/barangs');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        if (body['success'] == true && body['data'] is List) {
          List data = body['data'];
          return data.map((json) => Barang.fromJson(json)).toList();
        } else {
          throw Exception('Format data barang tidak valid.');
        }
      } else {
        throw Exception('Gagal memuat barang: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat barang: $e');
    }
  }
}
