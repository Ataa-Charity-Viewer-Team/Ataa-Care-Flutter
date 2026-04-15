import 'package:flutter/material.dart';
import '../api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color primaryBlue = Color(0xFF1B4B5A);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color lightBeige = Color(0xFFF5EFE7);

  bool isLoading = true;
  Map<String, dynamic>? stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final result = await ApiService.getStats();

    if (mounted) {
      setState(() {
        isLoading = false;
        if (result['success'] == true) {
          stats = result['data'];
        } else {
          stats = {};
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,

      appBar: AppBar(
        title: const Text("عطاء الخير"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildStats(),
                  const SizedBox(height: 20),
                  _buildServices(),
                ],
              ),
            ),

      bottomNavigationBar: _bottomNav(),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const Text("كن سبباً في السعادة",
              style: TextStyle(
                  color: accentGold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("تبرعك يصنع الفرق",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/add_donation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentGold,
            ),
            child: const Text("تبرع الآن"),
          ),
        ],
      ),
    );
  }

  // ================= STATS =================
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _card(
            stats?['charities']?.toString() ?? "0",
            "جمعية",
            Icons.account_balance,
          ),
          _card(
            stats?['users']?.toString() ?? "0",
            "مستخدم",
            Icons.people,
          ),
          _card(
            stats?['donations']?.toString() ?? "0",
            "تبرع",
            Icons.favorite,
          ),
        ],
      ),
    );
  }

  Widget _card(String value, String label, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryBlue),
          const SizedBox(height: 10),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label),
        ],
      ),
    );
  }

  // ================= SERVICES =================
  Widget _buildServices() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: _service(
              "أضف تبرع",
              Icons.add,
              primaryBlue,
              () => Navigator.pushNamed(context, '/add_donation'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _service(
              "تبرعاتي",
              Icons.favorite,
              accentGold,
              () => Navigator.pushNamed(context, '/my_donations'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _service(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 35),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ================= LOGOUT =================
  void _logout() async {
    await ApiService.logout();
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', (route) => false);
  }

  // ================= BOTTOM NAV =================
  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (i) {
        if (i == 1) Navigator.pushNamed(context, '/my_donations');
        if (i == 2) Navigator.pushNamed(context, '/profile');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "تبرعاتي"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
      ],
    );
  }
}