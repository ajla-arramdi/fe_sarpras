import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisfos_fe/pages/navbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Color _primaryColor = const Color(0xFF2196F3);
  final Color _secondaryColor = const Color(0xFF1976D2);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _textPrimary = const Color(0xFF1A237E);
  final Color _textSecondary = const Color(0xFF1565C0);
  final Color _lightBlue = const Color(0xFFE3F2FD);
  final Color _glassBlue = const Color(0x802196F3);
  final Color _cardColor = Colors.white;
  final Color _accentColor = const Color(0xFF00BCD4);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final userId = data['user']['id'];
        final userEmail = _emailController.text;
        final userName = data['user']['name'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setInt('user_id', userId);
        await prefs.setString('user_email', userEmail);
        await prefs.setString('user_name', userName);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Navbar()),
          );
        }
      } else {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Gagal login';
        _showError(message);
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(Icons.person_outline, size: 40, color: _primaryColor),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Masuk ke Akun Anda',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Silakan masuk untuk melanjutkan',
                          style: TextStyle(
                            fontSize: 14,
                            color: _textSecondary.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            color: _lightBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _primaryColor.withOpacity(0.1)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(color: _textPrimary),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email_outlined, color: _primaryColor),
                                  labelText: 'Email',
                                  labelStyle: TextStyle(color: _primaryColor),
                                  hintText: 'Masukkan email Anda',
                                  hintStyle: TextStyle(color: _textSecondary.withOpacity(0.5)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: _primaryColor.withOpacity(0.5)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: _primaryColor, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                                  if (!value.contains('@')) return 'Email tidak valid';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(color: _textPrimary),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline, color: _primaryColor),
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: _primaryColor),
                                  hintText: 'Masukkan password Anda',
                                  hintStyle: TextStyle(color: _textSecondary.withOpacity(0.5)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: _primaryColor.withOpacity(0.5)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: _primaryColor, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      color: _primaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() => _obscurePassword = !_obscurePassword);
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                                  if (value.length < 6) return 'Password minimal 6 karakter';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: _primaryColor.withOpacity(0.3),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.login),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Masuk',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
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
            ),
          ),
        ),
      ),
    );
  }
}
