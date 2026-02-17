import 'package:flutter/material.dart';
import '../auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int step = 1;

  // Data konten (Gambar, Judul, Deskripsi)
  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/image1.png",
      "title": "Logbook App",
      "desc": "cuman ngetest"
    },
    {
      "image": "assets/images/image2.png",
      "title": "Catat Tanpa Lupa",
      "desc": "cuman ngetest"
    },
    {
      "image": "assets/images/image3.png",
      "title": "Authentikasi Aman",
      "desc": "cuman ngetest"
    },
  ];

  // logika step
  void _nextStep() {
    if (step < 3) {
      setState(() {
        step++;
      });
    } else {
      // berpindah ke loginview setelah 3 step selesai
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = step - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Menampilkan Gambar sesuai urutan
              Image.asset(
                onboardingData[currentIndex]["image"]!,
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),

              // Menampilkan Judul & Deskripsi
              Text(
                onboardingData[currentIndex]["title"]!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                onboardingData[currentIndex]["desc"]!,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Titik Indikator (Page Indicator)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    height: 10,
                    width: currentIndex == index ? 24 : 10,
                    decoration: BoxDecoration(
                      color: currentIndex == index ? Colors.deepPurple : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),

              const Spacer(),

              // Tombol Lanjut / Mulai
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    step == 3 ? "Mulai Sekarang" : "Lanjut",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}