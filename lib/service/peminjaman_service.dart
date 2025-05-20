// services/peminjaman_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sisfos_fe/models/peminjaman_model.dart';

class PeminjamanService {
  // When running on physical device, use your network IP instead of 127.0.0.1
  static const String baseUrl = 'http://127.0.0.1:8000/api';


  /// Membuat peminjaman baru
  static Future<bool> createPeminjaman(Map<String, dynamic> data, String token) async {
    try {
      // This matches your Laravel route: POST /peminjaman
      final response = await http.post(
        Uri.parse('$baseUrl/peminjaman'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print('Create peminjaman response: ${response.statusCode}');
      print('Create peminjaman body: ${response.body}');

      if (response.statusCode == 201) {
        return true;
      } else {
        // Try to parse error message if available
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            print("Server error: ${errorData['message']}");
          }
        } catch (_) {}
        
        print("Gagal membuat peminjaman: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception during createPeminjaman: $e");
      return false;
    }
  }

 static Future<List<dynamic>> fetchPeminjamanUser(String token) async {
    final response = await http.get(
     Uri.parse('$baseUrl/peminjaman/user'),

      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['success'] == true && jsonData['data'] != null) {
        return jsonData['data'];
      } else {
        throw Exception('Data tidak ditemukan');
      }
    } else {
      throw Exception('Gagal memuat data peminjaman');
    }
  }

}







