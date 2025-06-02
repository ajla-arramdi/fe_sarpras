import 'package:flutter/material.dart';
import 'package:sisfos_fe/models/barang_model.dart';
import 'package:sisfos_fe/service/barang_service.dart';
import 'detail_barang_page.dart';

class ListBarangPage extends StatefulWidget {
  @override
  _ListBarangPageState createState() => _ListBarangPageState();
}

class _ListBarangPageState extends State<ListBarangPage> {
  late Future<List<Barang>> _futureBarang;
  final BarangService _barangService = BarangService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Barang> _filteredBarang = [];

  final Color _primaryOrange = Color(0xFFFF6B00);
  final Color _lightOrange = Color(0xFFFFF3E0);
  final Color _darkOrange = Color(0xFFBF360C);

  @override
  void initState() {
    super.initState();
    _loadBarang();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBarang() async {
    _futureBarang = _barangService.fetchBarangs();
    _futureBarang.then((barangList) {
      setState(() {
        _filteredBarang = barangList;
      });
    });
  }

  void _filterBarang(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _futureBarang.then((barangList) {
          setState(() {
            _filteredBarang = barangList;
          });
        });
      } else {
        _futureBarang.then((barangList) {
          setState(() {
            final lowerQuery = query.toLowerCase();
            _filteredBarang = barangList.where((barang) {
              return barang.namaBarang.toLowerCase().contains(lowerQuery) ||
                  (barang.code?.toLowerCase().contains(lowerQuery) ?? false) ||
                  barang.kategori.namaKategori.toLowerCase().contains(lowerQuery);
            }).toList();
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            _buildAppBar(),
            _buildSearchBar(),
            _buildBarangGrid(),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      pinned: true,
      backgroundColor: _primaryOrange,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "List Barang",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_primaryOrange, Color(0xFFFF8F00)],
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari barang...',
              prefixIcon: Icon(Icons.search, color: _primaryOrange),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: _primaryOrange),
                      onPressed: () {
                        _searchController.clear();
                        _filterBarang('');
                      },
                    )
                  : null,
            ),
            onChanged: _filterBarang,
          ),
        ),
      ),
    );
  }

  Widget _buildBarangGrid() {
    return FutureBuilder<List<Barang>>(
      future: _futureBarang,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: _primaryOrange)),
          );
        }

        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(child: Text("Terjadi kesalahan: ${snapshot.error}")),
          );
        }

        if (!snapshot.hasData || _filteredBarang.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final barang = _filteredBarang[index];
                return _buildBarangCard(barang);
              },
              childCount: _filteredBarang.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? "Tidak ada barang ditemukan"
                : "Tidak ada hasil untuk '$_searchQuery'",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBarangCard(Barang barang) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailBarangPage(barang: barang),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBarangImage(barang, constraints.maxHeight * 0.45),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          barang.namaBarang,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: _darkOrange,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            barang.kategori.namaKategori,
                            style: TextStyle(
                              fontSize: 12,
                              color: _primaryOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "${barang.jumlah} pcs",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBarangImage(Barang barang, double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          colors: [_lightOrange, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        child: barang.foto != null && barang.foto!.isNotEmpty
            ? Image.network(
                barang.foto!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(Icons.inventory_2, size: 48, color: _primaryOrange),
                ),
              )
            : Center(
                child: Icon(Icons.inventory_2, size: 48, color: _primaryOrange),
              ),
      ),
    );
  }
}
