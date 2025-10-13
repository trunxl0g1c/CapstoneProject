import 'package:capstone/theme.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:capstone/ui/pages/home_screen.dart';

class _OnboardPage {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  _OnboardPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  LandingScreenState createState() => LandingScreenState();
}

class LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<_OnboardPage> pages = [
    _OnboardPage(
      title: "Track Your Sleep Easily",
      description: "Let Owl monitor your rest and boost your productivity.",
      icon: LucideIcons.moon,
      gradient: [Color(0xFF3B0764), Color(0xFF2E1065)],
    ),
    _OnboardPage(
      title: "Personalized Insights",
      description: "Understand your sleep patterns with smart analytics.",
      icon: LucideIcons.squareActivity,
      gradient: [Color(0xFF2E1065), Color(0xFF3B0764)],
    ),
    _OnboardPage(
      title: "Wake Up at the Right Time",
      description: "Smart alarms to help you feel refreshed every morning.",
      icon: LucideIcons.alarmClock,
      gradient: [Color(0xFF1E0F4B), Color(0xFF3B0764)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == pages.length - 1) {
      _goToHome();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() => _goToHome();

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0118), Color(0xFF1E0B37), Color(0xFF0A0118)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    _scaleController.reset();
                    _scaleController.forward();
                  },
                  itemBuilder: (_, index) {
                    final page = pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 260,
                                  height: 260,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        page.gradient[0].withValues(alpha: 0.4),
                                        Colors.transparent,
                                      ],
                                      stops: [0.4, 1.0],
                                    ),
                                  ),
                                ),

                                Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: page.gradient,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: page.gradient[0].withValues(
                                          alpha: 0.6,
                                        ),
                                        blurRadius: 80,
                                        spreadRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      page.icon,
                                      size: 100,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 60),

                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              "${page.title} 🦉",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          // Description
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              page.description,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const Spacer(flex: 3),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 50),

              // Bottom Controls
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    // Indicator Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (index) => AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: _currentPage == index ? 20 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? AppTheme.deepPrimary
                                : Colors.white,
                            boxShadow: _currentPage == index
                                ? [
                                    BoxShadow(
                                      color: AppTheme.deepPrimary.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    // Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip Button
                        TextButton(
                          onPressed: _skip,
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        PrimaryButton(
                          onPressed: _nextPage,
                          shape: ButtonShape.circle,
                          child: Icon(
                            LucideIcons.chevronRight,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
