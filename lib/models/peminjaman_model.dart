import 'barang_model.dart';

class Peminjaman {
  final int id;
  final String? kelasPeminjam;
  final String? keterangan;
  final int jumlah;
  final String tanggalPinjam;
  final String tanggalPengembalian;
  final String status;
  final Barang? barang;

  Peminjaman({
    required this.id,
    this.kelasPeminjam,
    this.keterangan,
    required this.jumlah,
    required this.tanggalPinjam,
    required this.tanggalPengembalian,
    required this.status,
    this.barang,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      id: json['id'],
      kelasPeminjam: json['kelas_peminjam'],
      keterangan: json['keterangan'],
      jumlah: json['jumlah'],
      tanggalPinjam: json['tanggal_pinjam'],
      tanggalPengembalian: json['tanggal_pengembalian'],
      status: json['status'],
      barang: json['barang'] != null ? Barang.fromJson(json['barang']) : null,
    );
  }
}
