import 'package:flutter/material.dart';
import '../api_service.dart';

const Color primaryBlue = Color(0xFF1B4B5A);
const Color accentGold = Color(0xFFD4AF37);
const Color lightTeal = Color(0xFF4A9BAE);
const Color lightBeige = Color(0xFFF5EFE7);

class CharitiesPage extends StatefulWidget {
  const CharitiesPage({super.key});

  @override
  State<CharitiesPage> createState() => _CharitiesPageState();
}

class _CharitiesPageState extends State<CharitiesPage> {
  List<dynamic> charities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharities();
  }

  Future<void> _loadCharities() async {
    setState(() => isLoading = true);
    final result = await ApiService.getCharities();
    if (mounted) {
      setState(() {
        isLoading = false;
        if (result['success']) {
          charities = result['charities'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Header احترافي يتفاعل مع السحب
          _buildSliverAppBar(),

          // 2. محتوى الصفحة
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 25,
                    decoration: BoxDecoration(
                      color: accentGold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "شركاء العطاء الموثوقين",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: accentGold)),
                )
              : charities.isEmpty
                  ? _buildEmptyState()
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildCharityCard(charities[index], index),
                          childCount: charities.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        title: const Text(
          "الجمعيات الخيرية",
          style: TextStyle(
            color: accentGold,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [primaryBlue, lightTeal],
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: -20,
              child: Icon(Icons.favorite, size: 150, color: Colors.white.withOpacity(0.05)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharityCard(dynamic charity, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // أيقونة الجمعية بتصميم مميز
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: lightBeige,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: primaryBlue, size: 35),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          charity['name'] ?? 'جمعية خيرية',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: accentGold),
                            const SizedBox(width: 4),
                            Text(
                              charity['address'] ?? 'العنوان غير متوفر',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: primaryBlue.withOpacity(0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBadge("${charity['donations_count'] ?? 0} تبرع", Icons.volunteer_activism),
                  ElevatedButton(
                    onPressed: () => _showDetails(charity),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGold,
                      foregroundColor: primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("استعراض الملف", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: lightTeal),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, color: primaryBlue, fontSize: 13),
        ),
      ],
    );
  }

  void _showDetails(dynamic charity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailSheet(charity),
    );
  }

  Widget _buildDetailSheet(dynamic charity) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 24),
          Text(charity['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue)),
          const SizedBox(height: 16),
          const Text("عن الجمعية", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accentGold)),
          const SizedBox(height: 8),
          Text(charity['description'] ?? "لا يوجد وصف متوفر حالياً.", style: TextStyle(color: Colors.grey[700], height: 1.5)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("إغلاق", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("لا توجد جمعيات مسجلة حالياً", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}