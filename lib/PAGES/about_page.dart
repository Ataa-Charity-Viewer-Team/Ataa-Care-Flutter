import 'package:flutter/material.dart';

// الألوان من اللوجو
const Color primaryBlue = Color(0xFF1B4B5A);
const Color accentGold = Color(0xFFD4AF37);
const Color lightTeal = Color(0xFF4A9BAE);
const Color lightBeige = Color(0xFFF5EFE7);

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      body: CustomScrollView(
        slivers: [
          // AppBar مخصص
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: primaryBlue,
            foregroundColor: accentGold,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "عن التطبيق",
                style: TextStyle(
                  color: accentGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, lightTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.favorite, size: 60, color: accentGold),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // المحتوى
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // بطاقة المعلومات الأساسية
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentGold.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "تطبيق عطاء للتبرع بالملابس ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: accentGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "الإصدار 1.0.0",
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "منصة التبرع بالملابس هي تطبيق يهدف إلى تسهيل عملية التبرع بالملابس المستعملة والجديدة للمحتاجين. "
                          "من خلال التطبيق يمكنك إضافة تبرعاتك ومشاركة الخير مع الآخرين.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // الرؤية والرسالة
                  _buildInfoBox(
                    icon: Icons.visibility,
                    title: "رؤيتنا",
                    description:
                        "مجتمع متكافل يساعد بعضه البعض، حيث لا يحتاج أحد للملابس الضرورية.",
                  ),

                  const SizedBox(height: 16),

                  _buildInfoBox(
                    icon: Icons.track_changes,
                    title: "رسالتنا",
                    description:
                        "تسهيل عملية التبرع وإيصال المساعدات للمحتاجين بطريقة آمنة وسريعة.",
                  ),

                  const SizedBox(height: 24),
                  // الأهداف
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentGold.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flag, color: accentGold, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              "أهدافنا",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildGoalItem(
                          "مساعدة المحتاجين وتوفير الملابس لهم",
                          Icons.volunteer_activism,
                        ),
                        _buildGoalItem(
                          "تقليل الهدر وإعادة استخدام الملابس",
                          Icons.recycling,
                        ),
                        _buildGoalItem(
                          "نشر ثقافة التكافل الاجتماعي",
                          Icons.groups,
                        ),
                        _buildGoalItem("حماية البيئة من النفايات", Icons.eco),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // الإحصائيات
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue, lightTeal],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "إنجازاتنا",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: accentGold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatBox("1000+", "تبرع", Icons.favorite),
                            _buildStatBox("500+", "مستخدم", Icons.people),
                            _buildStatBox("50+", "عائلة", Icons.home),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // التواصل
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentGold.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.contact_mail,
                              color: accentGold,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "تواصل معنا",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildContactItem(Icons.email, "info@donation-app.com"),
                        const SizedBox(height: 12),
                        _buildContactItem(Icons.phone, "+20 123 456 7890"),
                        const SizedBox(height: 12),
                        _buildContactItem(
                          Icons.language,
                          "www.donation-app.com",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // حقوق النشر
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copyright, color: primaryBlue, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "2025 جميع الحقوق محفوظة",
                          style: TextStyle(
                            fontSize: 14,
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentGold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  lightTeal.withOpacity(0.3),
                  primaryBlue.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryBlue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentGold, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: accentGold, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: accentGold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lightTeal.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
