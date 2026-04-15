import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ================= PAGES =================
import 'PAGES/splash_screen.dart';
import 'PAGES/login_page.dart';
import 'PAGES/register_page.dart';
import 'PAGES/home_page.dart'; // ✔ تم إصلاح المسافة
import 'PAGES/admin_dashboard.dart';
import 'PAGES/charity_dashboard.dart';
import 'PAGES/add_donation_page.dart';
import 'PAGES/my_donations_page.dart';
import 'PAGES/profile_page.dart';
import 'PAGES/about_page.dart';

// ⚠ نفس أسماء الملفات عندك (ما غيرتهاش)
import 'PAGES/ForgetpasswordPage.dart';
import 'PAGES/ResetPasswordpage.dart';
import 'PAGES/otp_verification_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const AtaaApp());
}

class AtaaApp extends StatelessWidget {
  const AtaaApp({super.key});

  static const Color primaryBlue = Color(0xFF1B4B5A);
  static const Color accentGold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق عطاء',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: primaryBlue,
        scaffoldBackgroundColor: const Color(0xFFF5EFE7),
        fontFamily: 'Cairo',

        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: accentGold,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(color: accentGold),
          titleTextStyle: TextStyle(
            color: accentGold,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),

      // ================= START =================
      home: const SplashScreen(),

      // ================= ROUTES =================
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/admin': (context) => const AdminDashboard(),
        '/charity': (context) => const CharityDashboard(),
        '/add_donation': (context) => const AddDonationPage(),
        '/my_donations': (context) => const MyDonationsPage(),
        '/profile': (context) => const ProfilePage(),
        '/about': (context) => const AboutPage(),

        // 🔐 Auth Flow
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/otp_verify': (context) => const OtpVerificationPage(email: ''),
        '/reset_password': (context) =>
            const ResetPasswordpage(email: '', code: ''),
      },
    );
  }
}