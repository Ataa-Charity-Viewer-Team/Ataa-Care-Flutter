import 'package:flutter/material.dart';
import '../api_service.dart';
import 'otp_verification_page.dart';

// الثوابت اللونية الموحدة لمشروع عطاء
const Color primaryBlue = Color(0xFF1B4B5A);
const Color accentGold = Color(0xFFD4AF37);
const Color lightTeal = Color(0xFF4A9BAE);
const Color lightBeige = Color(0xFFF5EFE7);

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _emailController.clear();
      _formKey.currentState?.reset();
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _sendReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ApiService.forgotPassword(_emailController.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      success: (data, message) {
        _showSnackBar(message ?? "تم إرسال كود التحقق بنجاح", Colors.green);
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OtpVerificationPage(email: _emailController.text.trim()),
            ),
          );
        });
      },
      failure: (exception) {
        _showSnackBar(exception.message, Colors.red);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: accentGold,
        title: const Text(
          "استعادة الحساب",
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, lightTeal],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: accentGold,
        backgroundColor: primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildHeroLogo(),
                      const SizedBox(height: 30),

                      const Text(
                        "هل نسيت كلمة المرور؟",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 10),

                      const Text(
                        "أدخل بريدك الإلكتروني المسجل وسنرسل لك\nكود التحقق لإعادة تعيين كلمة المرور",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 13,
                          height: 1.7,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 35),

                      _buildEmailField(),
                      const SizedBox(height: 30),

                      _buildSubmitButton(),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: Colors.black12, thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "أو",
                              style: TextStyle(
                                color: Colors.black38,
                                fontFamily: 'Cairo',
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: Colors.black12, thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildBackButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroLogo() {
    return Hero(
      tag: 'logo',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.15),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/logo.jpeg',
          height: 110,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.mark_email_read_outlined,
            size: 70,
            color: primaryBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textAlign: TextAlign.right,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'من فضلك أدخل البريد الإلكتروني';
          }
          if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
              .hasMatch(value.trim())) {
            return 'صيغة البريد الإلكتروني غير صحيحة';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: "البريد الإلكتروني",
          labelStyle: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontFamily: 'Cairo',
          ),
          prefixIcon: const Icon(Icons.email_outlined, color: primaryBlue, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: lightTeal, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          errorStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [primaryBlue, lightTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _sendReset,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: accentGold, strokeWidth: 2.5),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "إرسال كود التحقق",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: primaryBlue, width: 1.5),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back_ios_rounded, size: 14, color: primaryBlue),
          SizedBox(width: 6),
          Text(
            "العودة لتسجيل الدخول",
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}