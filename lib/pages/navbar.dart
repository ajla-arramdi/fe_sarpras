import 'package:flutter/material.dart';
import 'package:sisfos_fe/pages/home_page.dart'; // Halaman daftar barang
import 'package:sisfos_fe/pages/list_peminjam.dart'; // Halaman riwayat peminjaman
// import 'package:sisfos_fe/pages/profile_page.dart'; // Halaman profil (bisa kamu buat)

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  // Daftar halaman
  final List<Widget> _pages = [
     ListBarangPage(),            // Halaman daftar barang
    const PeminjamanHistoryPage(),     // Halaman riwayat
    // const ProfilePage(),               // Halaman profil
  ];

  final List<String> _titles = [
    'Daftar Barang',
    'Riwayat Peminjaman',
    'Profil',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Barang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
