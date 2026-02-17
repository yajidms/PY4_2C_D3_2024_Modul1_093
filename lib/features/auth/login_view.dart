// login_view.dart
import 'package:flutter/material.dart';
// Import Controller milik sendiri (masih satu folder)
import '/features/auth/login_controller.dart';
// Import View dari fitur lain (Logbook) untuk navigasi
import '/features/logbook/counter_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Inisialisasi Otak dan Controller Input
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _obscureText = true;
  int _failedAttempts = 0;
  bool _isButtonDisabled = false;

  void _lockLoginButton() {
    setState(() {
      _isButtonDisabled = true;
      _failedAttempts = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Akses terkunci! Tunggu 10 detik."),
        backgroundColor: Colors.red,
      ),
    );

    // Membuka kunci otomatis setelah 10 detik
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isButtonDisabled = false;
        });
      }
    });
  }

  void _handleLogin() {
    String user = _userController.text;
    String pass = _passController.text;

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan Password tidak boleh kosong!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    bool isSuccess = _controller.login(user, pass);

    if (isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CounterView(username: user),
        ),
      );
    } else {
      setState(() {
        _failedAttempts++;
      });
      // batas 3x percobaan
      if (_failedAttempts >= 3) {
        _lockLoginButton();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login Gagal! Sisa percobaan: ${3 - _failedAttempts}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Gatekeeper")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: "Password",
                // Menambahkan ikon (Show/Hide)
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText; //membalikkan nilai true/false
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _isButtonDisabled ? null : _handleLogin,
              child: Text(_isButtonDisabled ? "Harap Tunggu..." : "Masuk"),
            ),
          ],
        ),
      ),
    );
  }
}