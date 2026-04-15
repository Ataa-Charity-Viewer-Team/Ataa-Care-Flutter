import 'package:flutter/material.dart';
import '../api_service.dart';

const Color primaryBlue = Color(0xFF1B4B5A);
const Color accentGold = Color(0xFFD4AF37);
const Color lightTeal = Color(0xFF4A9BAE);
const Color lightBeige = Color(0xFFF5EFE7);

class MyDonationsPage extends StatefulWidget {
  const MyDonationsPage({super.key});

  @override
  State<MyDonationsPage> createState() => _MyDonationsPageState();
}

class _MyDonationsPageState extends State<MyDonationsPage> {
  List<dynamic> myDonations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyDonations();
  }

  Future<void> _loadMyDonations() async {
    setState(() {
      isLoading = true;
    });

    final result = await ApiService.getDonations();
    final userResult = await ApiService.getUserInfo();
    final user = userResult['user'];

    if (mounted) {
      setState(() {
        isLoading = false;
        if (result['success']) {
          final allDonations = result['donations'] ?? [];
          myDonations = allDonations.where((donation) {
            return donation['user']?['_id'] == user?['_id'];
          }).toList();
        }
      });
    }
  }

  Future<void> _deleteDonation(dynamic donationId, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 12),
            const Text("حذف التبرع"),
          ],
        ),
        content: const Text("هل أنت متأكد من حذف هذا التبرع؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("إلغاء", style: TextStyle(color: primaryBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("حذف"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await ApiService.deleteDonation(donationId);

      if (mounted) {
        if (result['success']) {
          setState(() {
            myDonations.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف التبرع بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'فشل في الحذف'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'رجالي':
        return Icons.man;
      case 'حريمي':
        return Icons.woman;
      case 'أطفال':
        return Icons.child_care;
      default:
        return Icons.checkroom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      appBar: AppBar(
        title: const Text("تبرعاتي"),
        backgroundColor: primaryBlue,
        foregroundColor: accentGold,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, lightTeal],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Text(
                  isLoading ? "جاري التحميل..." : "${myDonations.length} تبرع",
                  style: const TextStyle(
                    color: accentGold,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "تبرعاتك الخاصة",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: accentGold),
                  )
                : myDonations.isEmpty
                    ? const Center(child: Text("لا يوجد تبرعات"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: myDonations.length,
                        itemBuilder: (context, index) {
                          final donation = myDonations[index];
                          final hasImage = donation['image'] != null &&
                              donation['image'].toString().isNotEmpty;
                          final imageUrl = hasImage
                              ? donation['image'].toString().startsWith('http')
                                  ? donation['image']
                                  : '${ApiService.baseUrl}/${donation['image']}'
                              : null;

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: [
                                if (hasImage)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    child: Image.network(
                                      imageUrl!,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image),
                                    ),
                                  ),
                                ListTile(
                                  leading: Icon(
                                    _getIconForType(
                                        (donation['type'] ?? '').toString()),
                                    color: primaryBlue,
                                  ),
                                  title:
                                      Text(donation['title'] ?? 'بدون عنوان'),
                                  subtitle: Text(
                                      "مقاس: ${donation['size'] ?? 'غير محدد'}"),
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      _deleteDonation(donation['_id'], index),
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  label: const Text("حذف",
                                      style: TextStyle(color: Colors.red)),
                                )
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
