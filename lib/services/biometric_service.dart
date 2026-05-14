import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'biometric_exception.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    final bool canCheck = await _auth.canCheckBiometrics;
    final bool isSupported = await _auth.isDeviceSupported();
    return canCheck && isSupported;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  Future<bool> authenticate({String reason = 'Verifikasi dibutuhkan'}) async {
    final bool available = await isBiometricAvailable();
    if (!available) {
      throw BiometricException(
        code: BiometricErrorCode.noBiometricHardware,
        userMessage: 'Perangkat tidak memiliki sensor biometrik.',
      );
    }

    final List<BiometricType> types = await getAvailableBiometrics();
    if (types.isEmpty) {
      throw BiometricException(
        code: BiometricErrorCode.notEnrolled,
        userMessage: 'Belum ada sidik jari tersimpan. Daftarkan di Pengaturan.',
      );
    }

    final bool result = await _auth.authenticate(
      localizedReason: reason,
      authMessages: const <AuthMessages>[
        AndroidAuthMessages(
          signInTitle: 'Verifikasi Diperlukan',
          cancelButton: 'Batal',
          signInHint: 'Tempelkan jari atau arahkan wajah',
        ),
      ],
      // Ubah bagian ini agar sesuai dengan dokumen:
      biometricOnly: false, //
      sensitiveTransaction: true, // [cite: 78]
      persistAcrossBackgrounding: true, // [cite: 78]
    );

    if (!result) {
      throw BiometricException(
        code: BiometricErrorCode.userCanceled,
        userMessage: 'Dibatalkan',
      );
    }
    return true;
  }
}
