class Barang {
  final int id;
  final String namaBarang;
  final int jumlah;
  final String? code;
  final int kategoriId;
  final String? foto;
  final Kategori kategori;

  Barang({
    required this.id,
    required this.namaBarang,
    required this.jumlah,
    required this.code,
    required this.kategoriId,
    this.foto,
    required this.kategori,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      namaBarang: json['nama_barang'],
      jumlah: json['jumlah'],
      code: json['code'],
      kategoriId: json['kategori_id'],
      foto: json['foto'].toString(),
      kategori: Kategori.fromJson(json['kategori']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_barang': namaBarang,
      'jumlah': jumlah,
      'code': code,
      'kategori_id': kategoriId,
      'foto': foto,
      'kategori': kategori.toJson(),
    };
  }
}

class Kategori {
  final int id;
  final String namaKategori;

  Kategori({
    required this.id,
    required this.namaKategori,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'],
      namaKategori: json['nama_kategori'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_kategori': namaKategori,
    };
  }
}
