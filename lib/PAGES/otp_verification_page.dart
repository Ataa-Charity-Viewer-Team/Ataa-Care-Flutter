import 'package:flutter/material.dart';
import 'dart:async';
import '../api_service.dart';
import 'home_page.dart';
import 'ResetPasswordpage.dart';

const Color primaryBlue = Color(0xFF1B4B5A);
const Color accentGold = Color(0xFFD4AF37);
const Color lightTeal = Color(0xFF4A9BAE);
const Color lightBeige = Color(0xFFF5EFE7);

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final bool isForForgotPassword;

  const OtpVerificationPage({
    super.key,
    required this.email,
    this.isForForgotPassword = false,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  bool _canResend = false;
  int _resendTimer = 60;
  Timer? _timer;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() {
      _canResend = false;
      _resendTimer = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  String get _otpCode =>
      _controllers.map((c) => c.text).join();

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green
                  ? Icons.check_circle
                  : Icons.error_outline,
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ✅ التحقق من الكود — مربوط صح مع ApiResult
  void _verifyOTP() async {
    if (_otpCode.length != 6) {
      _showSnackBar('من فضلك أدخل كود التحقق كاملاً', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.verifyOTP(
      email: widget.email,
      code: _otpCode,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      success: (data, message) {
        if (widget.isForForgotPassword) {
          // ✅ جاي من نسيت كلمة المرور → روح لصفحة Reset
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordPage(
                email: widget.email,
                code: _otpCode,
              ),
            ),
          );
        } else {
          // ✅ جاي من Register → روح للهوم
          _showSnackBar('تم تفعيل حسابك بنجاح! 🎉', Colors.green);
          Future.delayed(const Duration(milliseconds: 800), () {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          });
        }
      },
      failure: (exception) {
        _showSnackBar(exception.message, Colors.red);
      },
    );
  }

  // ✅ إعادة الإرسال — مربوط صح مع ApiResult
  void _resendOTP() async {
    setState(() => _isResending = true);

    final result = await ApiService.resendOTP(widget.email);

    if (!mounted) return;
    setState(() => _isResending = false);

    result.when(
      success: (data, message) {
        _showSnackBar(message ?? 'تم إرسال الكود مرة أخرى 📧', Colors.green);
        _startResendTimer();
        // مسح الحقول
        for (var c in _controllers) c.clear();
        _focusNodes[0].requestFocus();
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
        foregroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, lightTeal],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Text(
          widget.isForForgotPassword ? "استعادة الحساب" : "تفعيل الحساب",
          style: const TextStyle(
            color: accentGold,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    // ===== الأيقونة =====
                    _buildTopIcon(),
                    const SizedBox(height: 28),

                    // ===== العنوان =====
                    const Text(
                      "رمز التحقق",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ===== الوصف =====
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black45,
                          height: 1.7,
                          fontFamily: 'Cairo',
                        ),
                        children: [
                          const TextSpan(
                              text: 'أدخل الرمز المكون من 6 أرقام المرسل إلى\n'),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ===== حقول الكود =====
                    _buildOtpFields(),
                    const SizedBox(height: 40),

                    // ===== زر التحقق =====
                    _buildVerifyButton(),
                    const SizedBox(height: 28),

                    // ===== إعادة الإرسال =====
                    _buildResendSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryBlue, lightTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.mark_email_read_outlined,
        size: 48,
        color: accentGold,
      ),
    );
  }

  Widget _buildOtpFields() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) => _buildOTPBox(index)),
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    final isFilled = _controllers[index].text.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46,
      height: 56,
      decoration: BoxDecoration(
        color: isFilled ? primaryBlue.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFilled ? accentGold : Colors.grey.shade300,
          width: isFilled ? 2.5 : 1.5,
        ),
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: accentGold.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
            : null,
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: primaryBlue,
          fontFamily: 'Cairo',
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          // لو اتملت الكود تلقائياً ابدأ التحقق
          if (_otpCode.length == 6) {
            FocusScope.of(context).unfocus();
          }
          setState(() {});
        },
      ),
    );
  }

  Widget _buildVerifyButton() {
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
          onPressed: _isLoading ? null : _verifyOTP,
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
                    Icon(Icons.verified_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "تحقق الآن",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_canResend)
            _isResending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: primaryBlue),
                  )
                : TextButton(
                    onPressed: _resendOTP,
                    style:
                        TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text(
                      "إعادة إرسال",
                      style: TextStyle(
                        color: lightTeal,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        fontSize: 14,
                      ),
                    ),
                  )
          else
            Row(
              children: [
                Text(
                  " $_resendTimer ثانية",
                  style: const TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    fontSize: 14,
                  ),
                ),
                const Text(
                  "إعادة الإرسال خلال ",
                  style: TextStyle(
                    color: Colors.black45,
                    fontFamily: 'Cairo',
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          const SizedBox(width: 6),
          const Text(
            "لم تستلم الرمز؟",
            style: TextStyle(
              color: Colors.black45,
              fontFamily: 'Cairo',
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
