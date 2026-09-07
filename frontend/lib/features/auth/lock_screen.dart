import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../services/pin_service.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/spicy_logo.dart';
import 'widgets/pin_pad.dart';

/// Pantalla de bloqueo por PIN de 4 dígitos, con biometría opcional.
/// Si el dueño no tiene PIN configurado todavía, esta misma pantalla
/// funciona en modo "crear PIN" (pide el PIN dos veces para confirmar).
///
/// Fondo azul de marca sólido (sin degradado): es la puerta de entrada
/// de la app, la única pantalla donde el azul cubre toda la superficie.
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
  bool _authenticatingBiometrics = false;

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
    setState(() => _authenticatingBiometrics = true);
    final ok = await _pinService.authenticateWithBiometrics();
    if (!mounted) return;
    setState(() => _authenticatingBiometrics = false);
    if (ok) widget.onUnlocked();
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
      backgroundColor: AppColors.lightBrandPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xxxl),
          child: ResponsiveCenter(
            maxWidth: 420,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SpicyWordmark(width: 200, blue: false),
                const SizedBox(height: 6),
                Text('STREETWEAR CO.', style: AppTypography.label.copyWith(color: Colors.white70, letterSpacing: 2.5)),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  _isCreating ? 'Configura tu acceso' : greeting,
                  style: AppTypography.screenTitle.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _isCreating ? _hint : (_hint.isEmpty ? 'Ingresa tu PIN para continuar.' : _hint),
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                PinDots(filled: _buffer.length, error: _error),
                const SizedBox(height: AppSpacing.xxxl),
                PinPad(onDigit: _onDigit, onDelete: _onDelete),
                const SizedBox(height: AppSpacing.xl),
                if (_canBiometrics && !_isCreating)
                  TextButton.icon(
                    onPressed: _authenticatingBiometrics ? null : _tryBiometrics,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    icon: _authenticatingBiometrics
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.fingerprint, color: Colors.white),
                    label: Text(_authenticatingBiometrics ? 'Verificando…' : 'Usar biometría'),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline, size: 13, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('Cifrado local · Bloqueo automático', style: AppTypography.label.copyWith(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
