import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisfos_fe/pages/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {
    'name': '',
    'email': '',
  };
  bool _isLoading = true;

  final Color _primaryColor = const Color(0xFF00897B); // Teal
  final Color _secondaryColor = const Color(0xFF00BCD4); // Cyan
  final Color _lightTeal = const Color(0xFFE0F2F1);
  final Color _darkTeal = const Color(0xFF00695C);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        userData['name'] = prefs.getString('user_name') ?? 'Nama tidak tersedia';
        userData['email'] = prefs.getString('user_email') ?? 'Email tidak tersedia';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal logout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: _primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _primaryColor,
                            _secondaryColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: _logout,
                      tooltip: 'Logout',
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _primaryColor,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: _primaryColor,
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildInfoCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _lightTeal),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            'Username',
            userData['name'],
            Icons.person_outline,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            'Email',
            userData['email'],
            Icons.email_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _lightTeal,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: _darkTeal.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _darkTeal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
