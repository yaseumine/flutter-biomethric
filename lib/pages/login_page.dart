import 'package:biometricauth/services/biometric_exception.dart';
import 'package:biometricauth/services/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

enum _AuthMethod { face, fingerprint, password }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final BiometricService _service = BiometricService();

  _AuthMethod? _activeMethod;
  bool _isLoading = false;
  String? _errorMessage;
  BiometricErrorCode? _errorCode;
  List<_AuthMethod> _availableMethods = [];

  // Animasi berdenyut dari dokumen
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _pulseAnim = Tween(
    begin: 1.0,
    end: 1.12,
  ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final types = await _service.getAvailableBiometrics();

    final hasFace =
        types.contains(BiometricType.face) ||
        types.contains(BiometricType.weak);
    final hasFingerprint =
        types.contains(BiometricType.fingerprint) ||
        types.contains(BiometricType.strong);

    setState(() {
      // Tambahkan metode yang tersedia berdasarkan hardware
      _availableMethods = [];
      if (hasFace) _availableMethods.add(_AuthMethod.face);
      if (hasFingerprint) _availableMethods.add(_AuthMethod.fingerprint);
      _availableMethods.add(_AuthMethod.password);
    });
  }

  void _handleError(BiometricException e) {
    setState(() {
      _errorMessage = e.userMessage;
      _errorCode = e.code;
      if (e.requiresFallback) _activeMethod = _AuthMethod.password;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _authenticate(_AuthMethod method) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authenticated = await _service.authenticate();
      if (authenticated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication successful!')),
        );
      }
    } on BiometricException catch (e) {
      _handleError(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display error message if any
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),

            // Auth method buttons
            ..._availableMethods.map((method) {
              IconData icon;
              String label;

              switch (method) {
                case _AuthMethod.face:
                  icon = Icons.face;
                  label = 'Face ID';
                case _AuthMethod.fingerprint:
                  icon = Icons.fingerprint;
                  label = 'Fingerprint';
                case _AuthMethod.password:
                  icon = Icons.lock;
                  label = 'Password';
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _authenticate(method),
                    icon: Icon(icon),
                    label: Text(label),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
