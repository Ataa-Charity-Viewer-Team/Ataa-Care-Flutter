import 'package:flutter/material.dart';
import '../api_service.dart';

// ألوان المشروع
const Color primaryBlue = Color(0xFF1B4B5A);
const Color accentGold = Color(0xFFD4AF37);
const Color lightBeige = Color(0xFFF5EFE7);

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  List<dynamic> _reports = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  // ✅ جلب التقارير من الباك
  Future<void> _fetchReports() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getAllReports();

      if (mounted) {
        setState(() {
          _reports = response['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar("فشل تحميل التقارير", Colors.red);
      }
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.right),
        backgroundColor: color,
      ),
    );
  }

  // 🧠 إحصائيات بسيطة
  int get totalReports => _reports.length;

  int get bugReports =>
      _reports.where((r) => r['type'] == 'bug').length;

  int get otherReports =>
      _reports.where((r) => r['type'] != 'bug').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      appBar: AppBar(
        title: const Text("لوحة تحكم الأدمن"),
        backgroundColor: primaryBlue,
        foregroundColor: accentGold,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchReports,
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryBlue))
          : RefreshIndicator(
              onRefresh: _fetchReports,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "إحصائيات التقارير",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 15),

                    _buildStats(),

                    const SizedBox(height: 30),

                    const Text(
                      "كل التقارير",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 15),

                    _buildReportsList(),
                  ],
                ),
              ),
            ),
    );
  }

  // 📊 كروت الإحصائيات
  Widget _buildStats() {
    return Row(
      children: [
        _buildStatCard(
            "Bug", bugReports.toString(), Colors.red, Icons.bug_report),
        const SizedBox(width: 10),
        _buildStatCard(
            "أخرى", otherReports.toString(), Colors.orange, Icons.report),
        const SizedBox(width: 10),
        _buildStatCard("الإجمالي", totalReports.toString(),
            primaryBlue, Icons.list),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(title,
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // 📋 عرض التقارير
  Widget _buildReportsList() {
    if (_reports.isEmpty) {
      return const Center(
        child: Text("لا توجد تقارير"),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border:
                Border.all(color: primaryBlue.withOpacity(0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: report['type'] == 'bug'
                  ? Colors.red.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              child: Icon(
                report['type'] == 'bug'
                    ? Icons.bug_report
                    : Icons.report,
                color: report['type'] == 'bug'
                    ? Colors.red
                    : Colors.orange,
              ),
            ),
            title: Text(
              report['type'] ?? "Report",
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              report['description'] ?? "لا يوجد وصف",
              textAlign: TextAlign.right,
            ),
          ),
        );
      },
    );
  }
}