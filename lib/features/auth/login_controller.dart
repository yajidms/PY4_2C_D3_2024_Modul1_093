import 'package:flutter/foundation.dart';

class LoginController {
  // Database sederhana (Hardcoded)
  final Map<String, String> _users = {
    // username: password
    "admin": "123",
    "oguri": "cap",
    "kajido": "japanvibes",
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

  // Fungsi pengecekan (Logic-Only)
  // Fungsi ini mengembalikan true jika cocok, false jika salah.
  bool login(String username, String password) {
    if (_users.containsKey(username) && _users[username] == password) {
      return true;
    }
    return false;
  }
}