import 'package:flutter/foundation.dart';

class LoginController {
  // Database user hardcoded dengan role dan teamId
  static final Map<String, Map<String, String>> _users = {
    'admin':  {'password': '123',          'role': 'Ketua',   'teamId': 'team_alpha'},
    'oguri':  {'password': 'cap',          'role': 'Anggota', 'teamId': 'team_alpha'},
    'kajido': {'password': 'japanvibes',   'role': 'Asisten', 'teamId': 'team_beta'},
  };

  // State reaktif menggunakan ValueNotifier
  final ValueNotifier<bool> obscureText = ValueNotifier(true);
  final ValueNotifier<int> failedAttempts = ValueNotifier(0);
  final ValueNotifier<bool> isButtonDisabled = ValueNotifier(false);

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  void incrementFailedAttempts() {
    failedAttempts.value++;
  }

  void lockLoginButton() {
    isButtonDisabled.value = true;
    failedAttempts.value = 0;

    // Membuka kunci otomatis setelah 10 detik
    Future.delayed(const Duration(seconds: 10), () {
      isButtonDisabled.value = false;
    });
  }

  /// Mengembalikan Map currentUser jika login berhasil, null jika gagal.
  /// Map berisi: uid, role, teamId
  Map<String, String>? login(String username, String password) {
    final user = _users[username.trim().toLowerCase()];
    if (user != null && user['password'] == password) {
      return {
        'uid': username.trim().toLowerCase(),
        'role': user['role']!,
        'teamId': user['teamId']!,
      };
    }
    return null;
  }
}