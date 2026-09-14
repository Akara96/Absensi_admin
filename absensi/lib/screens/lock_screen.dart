import 'package:flutter/material.dart';
import '../services/biometric_service.dart';
import '../services/api_service.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // Beri sedikit jeda agar UI selesai di-render sebelum memanggil dialog sistem
    Future.delayed(const Duration(milliseconds: 300), () {
      _showBiometricPrompt();
    });
  }

  Future<void> _showBiometricPrompt() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    final authenticated = await BiometricService.authenticate(context);

    if (authenticated && mounted) {
      // Jika sukses, masuk ke MainScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // Jika dibatalkan atau gagal
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  Future<void> _logout() async {
    await ApiService.clearSession();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'App Xave Ona',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Favor verifika marka liman\nhodi loke applikasaun',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isAuthenticating ? null : _showBiometricPrompt,
              icon: const Icon(Icons.fingerprint, size: 28),
              label: const Text('Loke Xave', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: _logout,
              child: const Text(
                'Tama ho Konta Seluk',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
