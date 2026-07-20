import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Bloqueo rápido por PIN local (con biometría opcional), independiente
/// de la sesión de Supabase. Así el dueño no tiene que escribir su
/// correo/contraseña cada vez que abre la app en su propio dispositivo,
/// pero los datos siguen protegidos si alguien más toma el teléfono.
///
/// El PIN se guarda hasheado (SHA-256) en el almacenamiento seguro del
/// sistema operativo (Keychain en iOS, Keystore en Android) — nunca en
/// texto plano.
class PinService {
  static const _storage = FlutterSecureStorage();
  static const _pinHashKey = 'spicy_pin_hash';
  static const _autoLockMinKey = 'spicy_auto_lock_min';
  final _localAuth = LocalAuthentication();

  String _hash(String pin) => sha256.convert(utf8.encode(pin)).toString();

  Future<bool> hasPin() async {
    final v = await _storage.read(key: _pinHashKey);
    return v != null && v.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    await _storage.write(key: _pinHashKey, value: _hash(pin));
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinHashKey);
    if (stored == null) return false;
    return stored == _hash(pin);
  }

  Future<int> getAutoLockMinutes() async {
    final v = await _storage.read(key: _autoLockMinKey);
    return int.tryParse(v ?? '') ?? 5;
  }

  Future<void> setAutoLockMinutes(int minutes) async {
    await _storage.write(key: _autoLockMinKey, value: minutes.toString());
  }

  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Confirma tu identidad para entrar a SPICY Admin',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}
