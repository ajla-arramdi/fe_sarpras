import 'package:flutter/material.dart';
import 'package:sisfos_fe/pages/home_page.dart';
import 'package:sisfos_fe/pages/list_peminjam.dart';
import 'package:sisfos_fe/pages/profile_page.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final Color _primaryColor = const Color(0xFF00897B); // Teal
  final Color _secondaryColor = const Color(0xFF00BCD4); // Cyan
  final Color _lightTeal = const Color(0xFFE0F2F1);

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    _pages = [
      ListBarangPage(),
      PeminjamanHistoryPage(),
      ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _refreshCurrentPage() {
    setState(() {
      _pages[_selectedIndex] = _selectedIndex == 0
          ? ListBarangPage()
          : _selectedIndex == 1
              ? PeminjamanHistoryPage()
              : ProfilePage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
            _refreshCurrentPage();
          },
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: _primaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 0 ? _lightTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.inventory_2_outlined, size: 24),
              ),
              activeIcon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _lightTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.inventory_2, size: 24),
              ),
              label: 'Barang',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 1 ? _lightTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.history_outlined, size: 24),
              ),
              activeIcon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _lightTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.history, size: 24),
              ),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 2 ? _lightTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_outline, size: 24),
              ),
              activeIcon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _lightTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person, size: 24),
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
