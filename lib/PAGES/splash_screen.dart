import 'dart:async';
import 'package:flutter/material.dart';
import '../api_service.dart';
import 'login_page.dart';
import 'home_page.dart';

const Color primaryBlue = Color(0xFF1B4B5A);
const Color accentGold = Color(0xFFD4AF37);
const Color lightTeal = Color(0xFF4A9BAE);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  late Animation<double> _scaleAnim;
  late Animation<double> _logoOpacityAnim;
  late Animation<double> _textOpacityAnim;
  late Animation<Offset> _textSlideAnim;

  @override
  void initState() {
    super.initState();

    // ===== أنيماشين اللوجو =====
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // ===== أنيماشين النص =====
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _textOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // ===== تشغيل الأنيماشين بالترتيب =====
    _logoController.forward().then((_) => _textController.forward());

    // ===== الانتقال بعد 3 ثواني =====
    Timer(const Duration(seconds: 3), _checkLoginStatus);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // ✅ الفحص الصح — بيعتمد على auth_token مش isLoggedIn
  Future<void> _checkLoginStatus() async {
    if (!mounted) return;

    final token = await ApiService.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // ✅ في توكن محفوظ → روح للهوم
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      // ✅ مفيش توكن → روح للوجين
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginPage(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryBlue, lightTeal, primaryBlue],
          ),
        ),
        child: Stack(
          children: [
            // ===== دوائر ديكور في الخلفية =====
            Positioned(
              top: -60,
              right: -60,
              child: _buildDecorCircle(200, Colors.white.withOpacity(0.05)),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: _buildDecorCircle(250, Colors.white.withOpacity(0.04)),
            ),
            Positioned(
              top: 150,
              left: -40,
              child: _buildDecorCircle(120, Colors.white.withOpacity(0.03)),
            ),

            // ===== المحتوى الرئيسي =====
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ===== اللوجو =====
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) => Transform.scale(
                      scale: _scaleAnim.value,
                      child: Opacity(
                        opacity: _logoOpacityAnim.value,
                        child: child,
                      ),
                    ),
                    child: _buildLogo(),
                  ),

                  const SizedBox(height: 32),

                  // ===== النصوص =====
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) => SlideTransition(
                      position: _textSlideAnim,
                      child: FadeTransition(
                        opacity: _textOpacityAnim,
                        child: child,
                      ),
                    ),
                    child: _buildTexts(),
                  ),

                  const SizedBox(height: 80),

                  // ===== مؤشر التحميل =====
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) => Opacity(
                      opacity: _textOpacityAnim.value,
                      child: child,
                    ),
                    child: _buildLoader(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.jpeg',
          height: 130,
          width: 130,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.volunteer_activism,
            size: 80,
            color: accentGold,
          ),
        ),
      ),
    );
  }

  Widget _buildTexts() {
    return Column(
      children: [
        const Text(
          "عطــــاء",
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: accentGold,
            fontFamily: 'Cairo',
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            color: accentGold.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "ملابسك قد تكون فرحة لغيرك",
          style: TextStyle(
            fontSize: 15,
            color: Colors.white70,
            fontStyle: FontStyle.italic,
            fontFamily: 'Cairo',
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoader() {
    return Column(
      children: [
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            color: accentGold,
            strokeWidth: 2.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "جاري التحميل...",
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}
