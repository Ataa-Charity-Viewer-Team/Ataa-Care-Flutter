import 'package:flutter/material.dart';
import '../api_service.dart';
import 'login_page.dart';

const Color primaryBlue = Color(0xFF1B4B5A);
const Color accentGold = Color(0xFFD4AF37);
const Color lightTeal = Color(0xFF4A9BAE);
const Color lightBeige = Color(0xFFF5EFE7);
const Color darkGrey = Color(0xFF455A64);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ✅ getProfile() الصح
  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    final result = await ApiService.getProfile();
    if (mounted) {
      setState(() {
        isLoading = false;
        if (result['success'] == true) {
          userData = result['data'] ?? result['user'];
        } else {
          _showSnackBar('فشل في تحميل بيانات الحساب', Colors.red);
        }
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'تسجيل الخروج',
              style: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo'),
            ),
          ],
        ),
        content: const Text(
          'هل تود حقاً مغادرة تطبيق عطاء؟',
          style: TextStyle(fontFamily: 'Cairo'),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء',
                style: TextStyle(color: darkGrey, fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              // ✅ logout() بدون context
              await ApiService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('خروج',
                style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name =
        userData?['userName'] ?? userData?['name'] ?? 'مستخدم عطاء';
    final firstLetter =
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';
    final role = userData?['roleType'] ?? userData?['role'] ?? 'user';
    final email = userData?['email'] ?? '';
    final phone = userData?['phone'] ?? 'غير متوفر';
    final address = userData?['address'] ?? 'غير متوفر';

    return Scaffold(
      backgroundColor: lightBeige,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: accentGold))
          : RefreshIndicator(
              onRefresh: _loadUserData,
              color: accentGold,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(firstLetter, name, role, email),
                    const SizedBox(height: 24),
                    _buildSectionTitle('معلومات الحساب'),
                    const SizedBox(height: 12),
                    _buildInfoCard(phone, address, email),
                    const SizedBox(height: 24),
                    _buildSectionTitle('خيارات التحكم'),
                    const SizedBox(height: 12),
                    _buildSettingsCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(
      String letter, String name, String role, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [primaryBlue, lightTeal],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Stack(
        children: [
          // دوائر ديكور
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            right: -10,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentGold.withOpacity(0.08),
              ),
            ),
          ),
          Column(
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: accentGold.withOpacity(0.5), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  child: Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: accentGold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // الاسم
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),

              const SizedBox(height: 4),

              // الإيميل
              Text(
                email,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                  fontFamily: 'Cairo',
                ),
              ),

              const SizedBox(height: 10),

              // Badge الدور
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  color: accentGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: accentGold.withOpacity(0.4), width: 1),
                ),
                child: Text(
                  role == 'admin'
                      ? '👑 ادمن'
                      : role == 'charity'
                          ? '🏢 جمعية'
                          : '💚 متبرع',
                  style: const TextStyle(
                    color: accentGold,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'شكراً لمساهمتك في نشر الخير',
                style: TextStyle(
                  color: lightBeige,
                  fontSize: 13,
                  fontFamily: 'Cairo',
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: accentGold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String phone, String address, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildInfoTile(
                Icons.email_outlined, 'البريد الإلكتروني', email, false),
            _buildDivider(),
            _buildInfoTile(Icons.phone_outlined, 'رقم التواصل', phone, false),
            _buildDivider(),
            _buildInfoTile(
                Icons.location_on_outlined, 'العنوان', address, true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
      IconData icon, String title, String value, bool isLast) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: darkGrey.withOpacity(0.6),
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: primaryBlue,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryBlue, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
        height: 1, color: primaryBlue.withOpacity(0.08), indent: 16);
  }

  Widget _buildSettingsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSettingsTile(
              icon: Icons.edit_outlined,
              iconColor: lightTeal,
              title: 'تعديل البيانات الشخصية',
              onTap: () {
                // TODO: Navigator to edit profile page
              },
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.lock_outline,
              iconColor: accentGold,
              title: 'تغيير كلمة المرور',
              onTap: () {
                // TODO: Navigator to change password page
              },
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.logout,
              iconColor: Colors.red,
              title: 'تسجيل الخروج',
              titleColor: Colors.red,
              onTap: _logout,
              showArrow: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color titleColor = darkGrey,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
          fontSize: 15,
        ),
      ),
      trailing: showArrow
          ? Icon(Icons.arrow_forward_ios,
              size: 14, color: darkGrey.withOpacity(0.4))
          : null,
    );
  }
}
