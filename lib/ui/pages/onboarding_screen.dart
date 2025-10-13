import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:capstone/ui/pages/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  
  final List<Widget> _onboardingPages = [
    const OnboardingPageContent(
      icon: Icons.monitor_heart_outlined, 
      title: "Lacak Tidur Harianmu",
      description:
          "Catat durasi tidurmu setiap hari dengan mudah untuk melihat polanya.",
    ),
    const OnboardingPageContent(
      icon: Icons.auto_graph_outlined,
      title: "Dapatkan Prediksi Produktivitas",
      description:
          "Model cerdas kami akan menganalisis data tidurmu dan memberikan prediksi produktivitas.",
    ),
    const OnboardingPageContent(
      icon: Icons.lightbulb_outline,
      title: "Rekomendasi Cerdas",
      description:
          "Terima rekomendasi yang dipersonalisasi untuk meningkatkan kualitas tidur dan kinerjamu.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryPurple = Theme.of(context).primaryColor;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: _onboardingPages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indikator titik-titik
                  Row(
                    children: List.generate(
                      _onboardingPages.length,
                      (index) => buildDot(index, context),
                    ),
                  ),
                  // Tombol Lanjut/Mulai
                  SizedBox(
                    height: 50,
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _onboardingPages.length - 1) {
                          // Navigasi ke halaman home atau login setelah onboarding selesai
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        _currentPage == _onboardingPages.length - 1
                            ? "Mulai"
                            : "Lanjut",
                        style: const TextStyle(fontWeight: FontWeight.bold),
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

  // Widget untuk membuat titik indikator
  AnimatedContainer buildDot(int index, BuildContext context) {
    final Color primaryPurple = Theme.of(context).primaryColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? primaryPurple : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Widget untuk konten di setiap halaman onboarding
class OnboardingPageContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingPageContent({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryPurple = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryPurple.withOpacity(0.15),
            ),
            child: Icon(icon, size: 80, color: primaryPurple),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
