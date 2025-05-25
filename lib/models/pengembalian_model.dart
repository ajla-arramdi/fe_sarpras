class Pengembalian {
  final int id;
  final int userId;
  final int peminjamanId;
  final int jumlah;
  final String tanggalDikembalikan;
  final String kondisiBarang;
  final double denda;
  final String status;

  Pengembalian({
    required this.id,
    required this.userId,
    required this.peminjamanId,
    required this.jumlah,
    required this.tanggalDikembalikan,
    required this.kondisiBarang,
    required this.denda,
    required this.status,
  });

  factory Pengembalian.fromJson(Map<String, dynamic> json) {
    return Pengembalian(
      id: json['id'],
      userId: json['user_id'],
      peminjamanId: json['peminjaman_id'],
      jumlah: json['jumlah'],
      tanggalDikembalikan: json['tanggal_dikembalikan'],
      kondisiBarang: json['kondisi_barang'],
      denda: (json['denda'] as num).toDouble(),
      status: json['status'],
    );
  }
}
