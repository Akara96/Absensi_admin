import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/biometric_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nreController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    final available = await BiometricService.isBiometricAvailable();
    final hasBio = await BiometricService.hasBiometrics();
    final enabled = await ApiService.isBiometricEnabled();

    if (mounted) {
      setState(() {
        _isBiometricAvailable = available && hasBio;
        _isBiometricEnabled = enabled;
      });

      // Jika biometrik aktif, langsung tawarkan login biometrik
      if (_isBiometricAvailable && _isBiometricEnabled) {
        // Beri sedikit delay agar UI siap
        Future.delayed(const Duration(milliseconds: 500), () {
          _loginWithBiometric();
        });
      }
    }
  }

  Future<void> _loginWithBiometric() async {
    final authenticated = await BiometricService.authenticate(context);
    if (authenticated) {
      final creds = await ApiService.getBiometricCredentials();
      if (creds != null) {
        _nreController.text = creds['nre']!;
        _passwordController.text = creds['password']!;
        _login(isManual: false);
      }
    }
  }

  Future<void> _login({bool isManual = true}) async {
    final nre = _nreController.text.trim();
    final password = _passwordController.text.trim();

    if (nre.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'NRE ho Password la bele mamuk!');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await ApiService.login(nre, password);

      if (!mounted) return;

      // Jika login manual berhasil dan biometrik belum aktif, tawarkan aktivasi
      if (isManual && _isBiometricAvailable && !_isBiometricEnabled) {
        _showEnableBiometricDialog(nre, password);
      } else {
        _goToDashboard();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  void _showEnableBiometricDialog(String nre, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Ativa Biometria?'),
        content: const Text('Ita Boot hakarak uza marka liman hodi tama ba oin?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _goToDashboard();
            },
            child: const Text('Aban Bainrua'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.saveBiometricCredentials(nre, password);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login biometria ativa ona.')),
              );
              _goToDashboard();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            child: const Text('Sin, Ativa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Ikon Instansi
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.account_balance, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sistema Presensa',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const Text(
                'Favor tama uza Ita Boot nia konta',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 40),

              // Card Form Login
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Input NIK
                      TextField(
                        controller: _nreController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'NRE',
                          hintText: 'Númeru Rejistu Estadu',
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Input Password
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        onSubmitted: (_) => _login(),
                      ),

                      // Pesan Error
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Tombol Login
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : () => _login(isManual: true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                      )
                                    : const Text(
                                        'Tama',
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ),
                          if (_isBiometricAvailable && _isBiometricEnabled) ...[
                            const SizedBox(width: 16),
                            InkWell(
                              onTap: _isLoading ? null : _loginWithBiometric,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 54,
                                width: 54,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.teal.shade200, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.teal.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.fingerprint, color: Colors.teal, size: 32),
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (_isBiometricAvailable && _isBiometricEnabled) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _isLoading ? null : _loginWithBiometric,
                          child: Text(
                            'Uza Marka Liman hodi Tama Lalais',
                            style: TextStyle(
                              color: Colors.teal.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Kontaktu administradór se hetan problema\nasesu konta.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nreController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
