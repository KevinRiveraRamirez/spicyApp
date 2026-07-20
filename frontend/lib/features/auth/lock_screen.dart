import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/pin_service.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/spicy_logo.dart';
import 'widgets/pin_pad.dart';

/// Pantalla de bloqueo por PIN de 4 dígitos, con biometría opcional.
/// Si el dueño no tiene PIN configurado todavía, esta misma pantalla
/// funciona en modo "crear PIN" (pide el PIN dos veces para confirmar).
class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _pinService = PinService();
  String _buffer = '';
  String? _firstPin; // usado durante la creación de PIN (confirmación)
  bool _isCreating = false;
  bool _checkingPin = true;
  bool _error = false;
  String _hint = '';
  bool _canBiometrics = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final hasPin = await _pinService.hasPin();
    final canBio = await _pinService.canUseBiometrics();
    setState(() {
      _isCreating = !hasPin;
      _checkingPin = false;
      _canBiometrics = canBio && hasPin;
      _hint = _isCreating ? 'Crea un PIN de 4 dígitos para tu tienda.' : '';
    });
    if (!_isCreating && _canBiometrics) {
      _tryBiometrics();
    }
  }

  Future<void> _tryBiometrics() async {
    final ok = await _pinService.authenticateWithBiometrics();
    if (ok && mounted) widget.onUnlocked();
  }

  void _onDigit(String d) {
    if (_buffer.length >= 4) return;
    setState(() {
      _buffer += d;
      _error = false;
    });
    if (_buffer.length == 4) {
      Future.delayed(const Duration(milliseconds: 120), _handleComplete);
    }
  }

  void _onDelete() {
    if (_buffer.isEmpty) return;
    setState(() => _buffer = _buffer.substring(0, _buffer.length - 1));
  }

  Future<void> _handleComplete() async {
    if (_isCreating) {
      if (_firstPin == null) {
        setState(() {
          _firstPin = _buffer;
          _buffer = '';
          _hint = 'Confírmalo de nuevo.';
        });
      } else {
        if (_buffer == _firstPin) {
          await _pinService.setPin(_buffer);
          widget.onUnlocked();
        } else {
          setState(() {
            _error = true;
            _hint = 'No coincide. Empecemos de nuevo.';
          });
          await Future.delayed(const Duration(milliseconds: 400));
          setState(() {
            _buffer = '';
            _firstPin = null;
            _error = false;
          });
        }
      }
      return;
    }

    final ok = await _pinService.verifyPin(_buffer);
    if (ok) {
      widget.onUnlocked();
    } else {
      setState(() {
        _error = true;
        _hint = 'PIN incorrecto, intenta de nuevo.';
      });
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        _buffer = '';
        _error = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingPin) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Buenos días' : (hour < 19 ? 'Buenas tardes' : 'Buenas noches');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.spicyRed, AppColors.spicyRedDark, Color(0xFF1A0405)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ResponsiveCenter(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SpicyLogo(width: 220),
                const SizedBox(height: 6),
                const Text('STREETWEAR CO.', style: TextStyle(color: Colors.white70, fontSize: 10.5, letterSpacing: 2.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 22),
                Text(
                  _isCreating ? 'Configura tu acceso' : '$greeting 👋',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 4),
                Text(
                  _isCreating ? _hint : (_hint.isEmpty ? 'Ingresa tu PIN. Sin rodeos.' : _hint),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13.5),
                ),
                const SizedBox(height: 34),
                PinDots(filled: _buffer.length, error: _error),
                const SizedBox(height: 34),
                PinPad(onDigit: _onDigit, onDelete: _onDelete),
                const SizedBox(height: 24),
                if (_canBiometrics && !_isCreating)
                  TextButton.icon(
                    onPressed: _tryBiometrics,
                    icon: const Icon(Icons.fingerprint, color: Colors.white),
                    label: const Text('Usar biometría', style: TextStyle(color: Colors.white)),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('🔒 Cifrado local · Bloqueo automático',
                      style: TextStyle(color: Colors.white, fontSize: 11.5)),
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}