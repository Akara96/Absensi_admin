import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Jenera estadu disponibilidade biometria iha ekipamentu
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  /// Haree fali se marka liman/oin rejista ona ka seidauk
  static Future<bool> hasBiometrics() async {
    try {
      final List<BiometricType> availableBiometrics = await _auth
          .getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Halo autentikasaun uza biometria
  static Future<bool> authenticate(BuildContext context) async {
    try {
      final available = await isBiometricAvailable();
      final hasBio = await hasBiometrics();

      if (!available || !hasBio) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ Marka liman seidauk rejista iha definisaun HP/Emulator Ita Boot nian.',
              ),
            ),
          );
        }
        return false;
      }

      return await _auth.authenticate(
        localizedReason: 'Uza marka liman hodi loke',
      );
    } on PlatformException catch (e) {
      debugPrint("Error biometric: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.message ?? "Funsaun Biometria falla tiha"}',
            ),
          ),
        );
      }
      return false;
    }
  }
}
