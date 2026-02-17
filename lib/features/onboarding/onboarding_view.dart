import 'package:flutter/material.dart';
import '../auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  // Data konten (Gambar, Judul, Deskripsi)
  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/image1.png",
      "title": "Logbook App",
      "desc": "Aplikasi untuk mencatat kegiatan harianmu dengan mudah dan praktis."
    },
    {
      "image": "assets/images/image2.png",
      "title": "Catat Tanpa Lupa",
      "desc": "Mencatat kegiatan harianmu dengan cepat"
    },
    {
      "image": "assets/images/image3.png",
      "title": "Authentikasi Aman",
      "desc": "Menjaga privasi dan keamanan data catatanmu dengan sistem autentikasi yang kuat"
    },
  ];

  // fungsi untuk navigasi ke halaman Login
  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _goToLogin,
            child: const Text(
              "Lewati",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Gambar
                        Image.asset(
                          onboardingData[index]["image"]!,
                          height: 280,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 40),
                        // Judul
                        Text(
                          onboardingData[index]["title"]!,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Deskripsi
                        Text(
                          onboardingData[index]["desc"]!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indikator & button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Titik Indikator (Page Indicator)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                          (index) => buildDot(index, context),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Tombol Lanjut/Mulai
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentIndex == onboardingData.length - 1) {
                          _goToLogin();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentIndex == onboardingData.length - 1 ? "Mulai Sekarang" : "Lanjut",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget khusus untuk menggambar titik indikator
  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 10,
      width: _currentIndex == index ? 24 : 10,
      decoration: BoxDecoration(
        color: _currentIndex == index ? Colors.deepPurple : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}