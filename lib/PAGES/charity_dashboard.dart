import 'package:flutter/material.dart';
import '../api_service.dart';

const Color primaryBlue = Color(0xFF1B4B5A);
const Color accentGold = Color(0xFFD4AF37);
const Color lightTeal = Color(0xFF4A9BAE);
const Color lightBeige = Color(0xFFF5EFE7);
const Color darkGrey = Color(0xFF455A64);

class CharityDashboard extends StatefulWidget {
  const CharityDashboard({super.key});

  @override
  State<CharityDashboard> createState() => _CharityDashboardState();
}

class _CharityDashboardState extends State<CharityDashboard>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  int currentIndex = 0;

  Map<String, dynamic>? stats;
  List<Map<String, dynamic>> donations = [];
  List<Map<String, dynamic>> requests = [];

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _loadAll();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => isLoading = true);

    final results = await Future.wait([
      ApiService.getStats(),
      ApiService.getDashboardDonations(),
      ApiService.getDashboardRequests(),
    ]);

    if (!mounted) return;

    setState(() {
      isLoading = false;

      // ✅ stats بيرجع { success, stats: { Total_Donations, Pending_Donations, Accepted_Donations } }
      final statsRes = results[0];
      if (statsRes['success'] == true) {
        stats = statsRes['stats'];
      }

      // Donations
      final donRes = results[1];
      if (donRes['success'] == true) {
        final list = donRes['data'] ?? donRes['donations'] ?? [];
        donations = List<Map<String, dynamic>>.from(list);
      }

      // Requests
      final reqRes = results[2];
      if (reqRes['success'] == true) {
        final list = reqRes['data'] ?? reqRes['requests'] ?? [];
        requests = List<Map<String, dynamic>>.from(list);
      }
    });

    _animController.forward(from: 0);
  }

  Future<void> _updateRequest(String id, String status) async {
    final result = await ApiService.updateRequestStatus(id, status);

    if (!mounted) return;

    final success = result['success'] == true;
    _showSnackBar(
      result['message'] ?? (success ? 'تم تحديث الطلب بنجاح' : 'حدث خطأ'),
      success ? Colors.green : Colors.red,
    );

    if (success) _loadAll();
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: accentGold))
          : FadeTransition(
              opacity: _fadeAnim,
              child: RefreshIndicator(
                onRefresh: _loadAll,
                color: accentGold,
                child: _buildBody(),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (currentIndex) {
      case 0:
        return _buildStatsTab();
      case 1:
        return _buildDonationsTab();
      case 2:
        return _buildRequestsTab();
      default:
        return _buildStatsTab();
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: primaryBlue,
        boxShadow: [
          BoxShadow(
              color: primaryBlue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -3))
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: accentGold,
        unselectedItemColor: Colors.white54,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle:
            const TextStyle(fontFamily: 'Cairo', fontSize: 11),
        onTap: (i) {
          setState(() => currentIndex = i);
          _animController.forward(from: 0);
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: 'إحصائيات'),
          BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism), label: 'التبرعات'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pending_actions), label: 'الطلبات'),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  TAB 1 — STATS
  // ═══════════════════════════════════════════════════════

  Widget _buildStatsTab() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildStatsHeader()),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverGrid(
            delegate: SliverChildListDelegate([
              _buildStatCard(
                title: 'إجمالي التبرعات',
                // ✅ Capital keys من الباك
                value: '${stats?['Total_Donations'] ?? 0}',
                icon: Icons.volunteer_activism,
                color: lightTeal,
              ),
              _buildStatCard(
                title: 'تبرعات مقبولة',
                value: '${stats?['Accepted_Donations'] ?? 0}',
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
              _buildStatCard(
                title: 'قيد الانتظار',
                value: '${stats?['Pending_Donations'] ?? 0}',
                icon: Icons.pending_rounded,
                color: Colors.orange,
              ),
              _buildStatCard(
                title: 'الطلبات الواردة',
                value: '${requests.length}',
                icon: Icons.list_alt_rounded,
                color: accentGold,
              ),
            ]),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [primaryBlue, lightTeal],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'لوحة تحكم الجمعية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    'إدارة التبرعات والطلبات',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.account_balance,
                    color: accentGold, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: darkGrey,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  TAB 2 — DONATIONS
  // ═══════════════════════════════════════════════════════

  Widget _buildDonationsTab() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildTabHeader(
            title: 'التبرعات الواردة',
            subtitle: '${donations.length} تبرع',
            icon: Icons.volunteer_activism,
          ),
        ),
        donations.isEmpty
            ? SliverFillRemaining(
                child: _buildEmptyState('لا توجد تبرعات بعد'))
            : SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildDonationCard(donations[i]),
                    childCount: donations.length,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> d) {
    final status = d['status'] ?? 'pending';
    final statusColor = status == 'accepted'
        ? Colors.green
        : status == 'rejected'
            ? Colors.red
            : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status == 'accepted'
                            ? 'مقبول'
                            : status == 'rejected'
                                ? 'مرفوض'
                                : 'قيد الانتظار',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      d['type'] ?? 'غير محدد',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                        fontFamily: 'Cairo',
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${d['quantity'] ?? 0}',
                        style: const TextStyle(
                            color: darkGrey, fontFamily: 'Cairo')),
                    const SizedBox(width: 4),
                    const Text('الكمية:',
                        style: TextStyle(
                            color: darkGrey, fontFamily: 'Cairo')),
                    const SizedBox(width: 12),
                    Text(d['size'] ?? '',
                        style: const TextStyle(
                            color: darkGrey, fontFamily: 'Cairo')),
                    const SizedBox(width: 4),
                    const Text('المقاس:',
                        style: TextStyle(
                            color: darkGrey, fontFamily: 'Cairo')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: lightTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.volunteer_activism,
                color: lightTeal, size: 22),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  TAB 3 — REQUESTS
  // ═══════════════════════════════════════════════════════

  Widget _buildRequestsTab() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildTabHeader(
            title: 'الطلبات الواردة',
            subtitle: '${requests.length} طلب',
            icon: Icons.pending_actions,
          ),
        ),
        requests.isEmpty
            ? SliverFillRemaining(
                child: _buildEmptyState('لا توجد طلبات بعد'))
            : SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildRequestCard(requests[i]),
                    childCount: requests.length,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> r) {
    final id = r['_id']?.toString() ?? r['id']?.toString() ?? '';
    final status = r['status'] ?? 'pending';
    final isPending = status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isPending)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _confirmAction(id, 'rejected'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.red.withOpacity(0.3)),
                        ),
                        child: const Text('رفض',
                            style: TextStyle(
                                color: Colors.red,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _confirmAction(id, 'accepted'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.green.withOpacity(0.3)),
                        ),
                        child: const Text('قبول',
                            style: TextStyle(
                                color: Colors.green,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (status == 'accepted'
                            ? Colors.green
                            : Colors.red)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status == 'accepted' ? 'تم القبول' : 'مرفوض',
                    style: TextStyle(
                      color: status == 'accepted'
                          ? Colors.green
                          : Colors.red,
                      fontFamily: 'Cairo',
                      fontSize: 12,
                    ),
                  ),
                ),
              Text(
                r['type'] ?? 'غير محدد',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                  fontFamily: 'Cairo',
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildChip(
                  '${r['quantity'] ?? 0} قطعة', Icons.numbers, lightTeal),
              const SizedBox(width: 8),
              _buildChip(r['size'] ?? '', Icons.format_size, accentGold),
            ],
          ),
          if (r['description'] != null &&
              r['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              r['description'],
              style: const TextStyle(
                  color: darkGrey, fontSize: 13, fontFamily: 'Cairo'),
              textAlign: TextAlign.right,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontFamily: 'Cairo')),
          const SizedBox(width: 4),
          Icon(icon, color: color, size: 14),
        ],
      ),
    );
  }

  void _confirmAction(String id, String status) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          status == 'accepted' ? 'تأكيد القبول' : 'تأكيد الرفض',
          style: const TextStyle(
              fontFamily: 'Cairo',
              color: primaryBlue,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        content: Text(
          status == 'accepted'
              ? 'هل تريد قبول هذا الطلب؟'
              : 'هل تريد رفض هذا الطلب؟',
          style: const TextStyle(fontFamily: 'Cairo'),
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
              backgroundColor:
                  status == 'accepted' ? Colors.green : Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _updateRequest(id, status);
            },
            child: Text(
              status == 'accepted' ? 'قبول' : 'رفض',
              style: const TextStyle(
                  color: Colors.white, fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
          top: 60, bottom: 24, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [primaryBlue, lightTeal],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  )),
              Text(subtitle,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: 'Cairo')),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentGold, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded,
              size: 70, color: primaryBlue.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(
                color: darkGrey.withOpacity(0.5),
                fontFamily: 'Cairo',
                fontSize: 16,
              )),
        ],
      ),
    );
  }
}
