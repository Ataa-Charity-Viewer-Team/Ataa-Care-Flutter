import 'package:flutter/material.dart';
import '../api_service.dart';
import 'otp_verification_page.dart';

const Color primaryBlue = Color(0xFF1B4B5A);
const Color accentGold = Color(0xFFD4AF37);
const Color lightTeal = Color(0xFF4A9BAE);
const Color lightBeige = Color(0xFFF5EFE7);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;

  String? _selectedRole = 'user';

  final List<Map<String, dynamic>> _roles = [
    {'value': 'user', 'label': 'متبرع', 'icon': Icons.volunteer_activism},
    {'value': 'charity', 'label': 'جمعية', 'icon': Icons.business},
    {'value': 'admin', 'label': 'أدمن', 'icon': Icons.admin_panel_settings},
  ];

  // ================= VALIDATION =================

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'الاسم مطلوب';
    if (value.length < 3) return 'الاسم قصير جداً';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'البريد الإلكتروني مطلوب';
    if (!value.contains('@')) return 'بريد غير صحيح';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'رقم الهاتف مطلوب';
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) return 'العنوان مطلوب';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
    if (value.length < 8) return 'يجب 8 أحرف على الأقل';
    return null;
  }

  String? _validatePasswordConfirmation(String? value) {
    if (value != _passwordController.text) return 'كلمة المرور غير متطابقة';
    return null;
  }

  // ================= REGISTER =================

  Future<void> _register() async {
    final errors = [
      _validateName(_nameController.text),
      _validateEmail(_emailController.text),
      _validatePhone(_phoneController.text),
      _validateAddress(_addressController.text),
      _validatePassword(_passwordController.text),
      _validatePasswordConfirmation(_passwordConfirmationController.text),
    ];

    for (var error in errors) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final result = await ApiService.register(
      userName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _passwordConfirmationController.text,
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      roleType: _selectedRole!,
    );

    setState(() => _isLoading = false);

    result.when(
      success: (data, message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(message ?? 'تم التسجيل بنجاح'),
              backgroundColor: Colors.green),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OTPVerificationPage(
              email: _emailController.text.trim(),
            ),
          ),
        );
      },
      failure: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error.message), backgroundColor: Colors.red),
        );
      },
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: accentGold))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // LOGO
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text("إنشاء حساب",
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue)),

                    const SizedBox(height: 30),

                    _buildField(_nameController, "الاسم", Icons.person),
                    _buildField(_emailController, "الإيميل", Icons.email),
                    _buildField(_phoneController, "الموبايل", Icons.phone),
                    _buildField(_addressController, "العنوان", Icons.location_on),

                    _buildRoleDropdown(),

                    _buildField(
                      _passwordController,
                      "الباسورد",
                      Icons.lock,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),

                    _buildField(
                      _passwordConfirmationController,
                      "تأكيد الباسورد",
                      Icons.lock,
                      obscure: _obscurePasswordConfirmation,
                      suffix: IconButton(
                        icon: Icon(_obscurePasswordConfirmation
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() =>
                            _obscurePasswordConfirmation =
                                !_obscurePasswordConfirmation),
                      ),
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text("إنشاء الحساب",
                          style: TextStyle(
                              color: accentGold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField(TextEditingController c, String hint, IconData icon,
      {bool obscure = false, Widget? suffix}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: c,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: primaryBlue),
          suffixIcon: suffix,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        decoration: InputDecoration(
          prefixIcon:
              Icon(Icons.account_circle, color: primaryBlue),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
        ),
        items: _roles.map((role) {
          return DropdownMenuItem<String>(
            value: role['value'],
            child: Text(role['label']),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedRole = value),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }
}