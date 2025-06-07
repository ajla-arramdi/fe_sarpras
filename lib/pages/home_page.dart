import 'package:flutter/material.dart';
import 'package:sisfos_fe/models/barang_model.dart';
import 'package:sisfos_fe/service/barang_service.dart';
import 'detail_barang_page.dart';

class ListBarangPage extends StatefulWidget {
  @override
  _ListBarangPageState createState() => _ListBarangPageState();
}

class _ListBarangPageState extends State<ListBarangPage> with SingleTickerProviderStateMixin {
  late Future<List<Barang>> _futureBarang;
  final BarangService _barangService = BarangService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Barang> _filteredBarang = [];
  String? _selectedCategory;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Warna tema modern
  final Color _primaryColor = const Color(0xFF2196F3); // Blue
  final Color _secondaryColor = const Color(0xFF1976D2); // Darker Blue
  final Color _backgroundColor = Colors.white; // White Background
  final Color _textPrimary = const Color(0xFF1A237E); // Darkest Blue
  final Color _textSecondary = const Color(0xFF1565C0); // Dark Blue
  final Color _lightBlue = const Color(0xFFE3F2FD); // Light Blue
  final Color _glassBlue = const Color(0x802196F3); // Glassy Blue with 50% opacity
  final Color _cardColor = Colors.white;
  final Color _accentColor = const Color(0xFF00BCD4); // Cyan accent
  final Color _headerColor = const Color(0xFF1976D2); // Darker Blue for header

  @override
  void initState() {
    super.initState();
    _loadBarang();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
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
      if (query.isEmpty && _selectedCategory == null) {
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
              final matchesSearch = barang.namaBarang.toLowerCase().contains(lowerQuery) ||
                  (barang.code?.toLowerCase().contains(lowerQuery) ?? false);
              final matchesCategory = _selectedCategory == null || 
                  barang.kategori.namaKategori == _selectedCategory;
              return matchesSearch && matchesCategory;
            }).toList();
          });
        });
      }
    });
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      _filterBarang(_searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenHeight < 600;
    final padding = isTablet ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: _backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            _buildHeader(padding, isTablet, isSmallScreen),
            _buildSearchBar(padding),
            _buildCategoryFilter(padding),
            _buildBarangGrid(padding, isTablet, isSmallScreen, screenWidth),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHeader(double padding, bool isTablet, bool isSmallScreen) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(padding, isSmallScreen ? 16 : 24, padding, isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_headerColor, _primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: _headerColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 12 : 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: isTablet ? 32 : 24,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sarpras",
                        style: TextStyle(
                          fontSize: isTablet ? 28 : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        "SMK Taruna Bhakti",
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isSmallScreen) ...[
              SizedBox(height: isTablet ? 20 : 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.info_outline, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selamat Datang",
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Sistem Inventaris Sarana dan Prasarana",
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar(double padding) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, 20, padding, 16),
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _glassBlue.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: _textPrimary),
            decoration: InputDecoration(
              hintText: 'Cari barang...',
              hintStyle: TextStyle(color: _textSecondary.withOpacity(0.7)),
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.search, color: _primaryColor),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: _primaryColor),
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

  SliverToBoxAdapter _buildCategoryFilter(double padding) {
    return SliverToBoxAdapter(
      child: FutureBuilder<List<Barang>>(
        future: _futureBarang,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }

          final categories = snapshot.data!
              .map((barang) => barang.kategori.namaKategori)
              .toSet()
              .toList();

          return Container(
            height: 45,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: padding),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Semua'),
                      selected: _selectedCategory == null,
                      onSelected: (_) => _filterByCategory(null),
                      backgroundColor: _cardColor,
                      selectedColor: _primaryColor,
                      labelStyle: TextStyle(
                        color: _selectedCategory == null ? Colors.white : _primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: _selectedCategory == null ? Colors.transparent : _primaryColor,
                          width: 1,
                        ),
                      ),
                    ),
                  );
                }

                final category = categories[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (_) => _filterByCategory(category),
                    backgroundColor: _cardColor,
                    selectedColor: _primaryColor,
                    labelStyle: TextStyle(
                      color: _selectedCategory == category ? Colors.white : _primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: _selectedCategory == category ? Colors.transparent : _primaryColor,
                        width: 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBarangGrid(double padding, bool isTablet, bool isSmallScreen, double screenWidth) {
    return FutureBuilder<List<Barang>>(
      future: _futureBarang,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: CircularProgressIndicator(
                  color: _primaryColor,
                  strokeWidth: 3,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: _primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      "Terjadi kesalahan: ${snapshot.error}",
                      style: TextStyle(color: _textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData || _filteredBarang.isEmpty) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: _buildEmptyState(),
            ),
          );
        }

        // Calculate grid layout based on screen width
        int crossAxisCount;
        double childAspectRatio;
        double spacing;

        if (screenWidth > 900) {
          crossAxisCount = 4;
          childAspectRatio = 0.85;
          spacing = 20;
        } else if (screenWidth > 600) {
          crossAxisCount = 3;
          childAspectRatio = 0.8;
          spacing = 16;
        } else if (screenWidth > 400) {
          crossAxisCount = 2;
          childAspectRatio = isSmallScreen ? 0.7 : 0.75;
          spacing = 12;
        } else {
          crossAxisCount = 1;
          childAspectRatio = 1.2;
          spacing = 12;
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final barang = _filteredBarang[index];
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildBarangCard(barang, isTablet, isSmallScreen),
                );
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _lightBlue.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 48,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? "Tidak ada barang ditemukan"
                : "Tidak ada hasil untuk '$_searchQuery'",
            style: TextStyle(
              color: _textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarangCard(Barang barang, bool isTablet, bool isSmallScreen) {
    return Hero(
      tag: 'barang-${barang.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailBarangPage(barang: barang),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBarangImage(barang, isTablet, isSmallScreen),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          barang.namaBarang,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 13 : 14,
                            color: _textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 6 : 8,
                            vertical: isSmallScreen ? 3 : 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_primaryColor.withOpacity(0.1), _accentColor.withOpacity(0.1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            barang.kategori.namaKategori,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: _primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                              decoration: BoxDecoration(
                                color: _lightBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: isSmallScreen ? 14 : 16,
                                color: _primaryColor,
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 6 : 8),
                            Text(
                              "${barang.jumlah} pcs",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 13,
                                color: _textSecondary,
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
          ),
        ),
      ),
    );
  }

  Widget _buildBarangImage(Barang barang, bool isTablet, bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 120 : (isTablet ? 180 : 140),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          colors: [_lightBlue, _cardColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: barang.foto != null && barang.foto!.isNotEmpty
            ? Image.network(
                barang.foto!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    Icons.inventory_2,
                    size: isSmallScreen ? 40 : (isTablet ? 64 : 48),
                    color: _primaryColor,
                  ),
                ),
              )
            : Center(
                child: Icon(
                  Icons.inventory_2,
                  size: isSmallScreen ? 40 : (isTablet ? 64 : 48),
                  color: _primaryColor,
                ),
              ),
      ),
    );
  }
}
