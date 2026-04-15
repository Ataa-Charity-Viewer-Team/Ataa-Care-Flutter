import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:url_launcher/url_launcher.dart';

const Color primaryBlue = Color(0xFF1B4B5A);
const Color accentGold = Color(0xFFD4AF37);
const Color lightTeal = Color(0xFF4A9BAE);
const Color lightBeige = Color(0xFFF5EFE7);

class DonationsListPage extends StatefulWidget {
  const DonationsListPage({super.key});

  @override
  State<DonationsListPage> createState() => _DonationsListPageState();
}

class _DonationsListPageState extends State<DonationsListPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> allDonations = [];
  List<dynamic> filteredDonations = [];
  bool isLoading = true;

  // Search & Filter
  TextEditingController searchController = TextEditingController();
  String? selectedType;
  String? selectedSize;
  bool showFilters = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> types = [
    {'name': 'الكل', 'icon': Icons.apps},
    {'name': 'رجالي', 'icon': Icons.man},
    {'name': 'حريمي', 'icon': Icons.woman},
    {'name': 'أطفال', 'icon': Icons.child_care},
    {'name': 'شتوي', 'icon': Icons.ac_unit},
    {'name': 'صيفي', 'icon': Icons.wb_sunny},
  ];

  final List<String> sizes = ['الكل', 'XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    _loadDonations();
    searchController.addListener(_filterDonations);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDonations() async {
    setState(() {
      isLoading = true;
    });

    final result = await ApiService.getDonations();

    if (mounted) {
      setState(() {
        isLoading = false;
        if (result['success']) {
          allDonations = result['donations'];
          filteredDonations = allDonations;
          _animationController.forward();
        }
      });
    }
  }

  void _filterDonations() {
    setState(() {
      filteredDonations = allDonations.where((donation) {
        bool matchesSearch = true;
        if (searchController.text.isNotEmpty) {
          matchesSearch = (donation['title'] ?? '')
              .toString()
              .toLowerCase()
              .contains(searchController.text.toLowerCase());
        }

        bool matchesType = true;
        if (selectedType != null && selectedType != 'الكل') {
          matchesType = donation['type'] == selectedType;
        }

        bool matchesSize = true;
        if (selectedSize != null && selectedSize != 'الكل') {
          matchesSize = donation['size'] == selectedSize;
        }

        return matchesSearch && matchesType && matchesSize;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      searchController.clear();
      selectedType = null;
      selectedSize = null;
      filteredDonations = allDonations;
    });
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'رجالي':
        return Icons.man;
      case 'حريمي':
        return Icons.woman;
      case 'أطفال':
        return Icons.child_care;
      case 'شتوي':
        return Icons.ac_unit;
      case 'صيفي':
        return Icons.wb_sunny;
      default:
        return Icons.checkroom;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'رجالي':
        return Colors.blue;
      case 'حريمي':
        return Colors.pink;
      case 'أطفال':
        return Colors.orange;
      case 'شتوي':
        return lightTeal;
      case 'صيفي':
        return accentGold;
      default:
        return primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: primaryBlue,
            foregroundColor: accentGold,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, lightTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 60),
                    Icon(Icons.volunteer_activism, size: 60, color: accentGold),
                    const SizedBox(height: 12),
                    Text(
                      isLoading
                          ? "جاري التحميل..."
                          : "${filteredDonations.length} تبرع متاح",
                      style: TextStyle(
                        color: accentGold,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "ساعد من يحتاج وكن سبباً في السعادة ✨",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                    showFilters ? Icons.filter_list_off : Icons.filter_list),
                tooltip: showFilters ? "إخفاء الفلاتر" : "إظهار الفلاتر",
                onPressed: () {
                  setState(() {
                    showFilters = !showFilters;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: "تحديث",
                onPressed: _loadDonations,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "ابحث عن تبرع بالاسم...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: primaryBlue, size: 28),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded,
                                    color: Colors.grey),
                                onPressed: () {
                                  searchController.clear();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(18),
                      ),
                    ),
                  ),
                ),
                if (showFilters)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, lightBeige.withOpacity(0.3)],
                      ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tune_rounded,
                                color: primaryBlue, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              "تصفية النتائج",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "النوع",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: types.map((type) {
                            final isSelected = selectedType == type['name'];
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedType = type['name'];
                                  _filterDonations();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [primaryBlue, lightTeal])
                                      : null,
                                  color: isSelected ? null : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: isSelected
                                        ? accentGold
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      type['icon'],
                                      size: 18,
                                      color: isSelected
                                          ? accentGold
                                          : Colors.grey[700],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      type['name'],
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[700],
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "المقاس",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: sizes.map((size) {
                            final isSelected = selectedSize == size;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedSize = size;
                                  _filterDonations();
                                });
                              },
                              child: Container(
                                width: 60,
                                height: 45,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(colors: [
                                          accentGold,
                                          Color(0xFFE6C45C)
                                        ])
                                      : null,
                                  color: isSelected ? null : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryBlue
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: accentGold.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  size,
                                  style: TextStyle(
                                    color: isSelected
                                        ? primaryBlue
                                        : Colors.grey[700],
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade50,
                                  foregroundColor: Colors.red,
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: _resetFilters,
                                icon: const Icon(Icons.restart_alt_rounded,
                                    size: 20),
                                label: const Text(
                                  "إعادة تعيين",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          isLoading
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: accentGold,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "جاري تحميل التبرعات...",
                          style: TextStyle(
                            color: primaryBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : filteredDonations.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: lightBeige,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.inbox_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "لا توجد تبرعات مطابقة",
                              style: TextStyle(
                                fontSize: 20,
                                color: primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "جرب تغيير معايير البحث",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final donation = filteredDonations[index];
                            final hasImage = donation['image'] != null &&
                                donation['image'].toString().isNotEmpty;
                            final imageUrl = hasImage
                                ? 'https://donations.codezoneeg.com/storage/${donation['image']}'
                                : null;

                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryBlue.withOpacity(0.12),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (hasImage)
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(24),
                                              topRight: Radius.circular(24),
                                            ),
                                            child: Image.network(
                                              imageUrl!,
                                              width: double.infinity,
                                              height: 220,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 220,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        lightTeal
                                                            .withOpacity(0.3),
                                                        primaryBlue
                                                            .withOpacity(0.2)
                                                      ],
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons
                                                          .image_not_supported_rounded,
                                                      size: 70,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                );
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Container(
                                                  height: 220,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        lightBeige,
                                                        Colors.grey.shade100
                                                      ],
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: accentGold,
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            top: 12,
                                            right: 12,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    primaryBlue
                                                        .withOpacity(0.95),
                                                    lightTeal.withOpacity(0.95)
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .account_balance_rounded,
                                                    color: accentGold,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    donation['charity']
                                                            ?['name'] ??
                                                        'غير محدد',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 12,
                                            left: 12,
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: _getColorForType(
                                                        donation['type'] ?? '')
                                                    .withOpacity(0.95),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                _getIconForType(
                                                    donation['type'] ?? ''),
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            donation['title'] ?? 'بدون عنوان',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: primaryBlue,
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      _getColorForType(donation[
                                                                  'type'] ??
                                                              '')
                                                          .withOpacity(0.15),
                                                      _getColorForType(donation[
                                                                  'type'] ??
                                                              '')
                                                          .withOpacity(0.05),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: _getColorForType(
                                                            donation['type'] ??
                                                                '')
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      _getIconForType(
                                                          donation['type'] ??
                                                              ''),
                                                      size: 14,
                                                      color: _getColorForType(
                                                          donation['type'] ??
                                                              ''),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      donation['type'] ??
                                                          'غير محدد',
                                                      style: TextStyle(
                                                        color: _getColorForType(
                                                            donation['type'] ??
                                                                ''),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      accentGold
                                                          .withOpacity(0.15),
                                                      accentGold
                                                          .withOpacity(0.05),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: accentGold
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.straighten_rounded,
                                                      size: 14,
                                                      color: accentGold,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      donation['size'] ?? '؟',
                                                      style: TextStyle(
                                                        color: primaryBlue,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: _getConditionColor(
                                                          donation[
                                                                  'condition'] ??
                                                              '')
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: _getConditionColor(
                                                            donation[
                                                                    'condition'] ??
                                                                '')
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  donation['condition'] ??
                                                      'غير محدد',
                                                  style: TextStyle(
                                                    color: _getConditionColor(
                                                        donation['condition'] ??
                                                            ''),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Icon(Icons.access_time_rounded,
                                                  size: 16,
                                                  color: Colors.grey[500]),
                                              const SizedBox(width: 6),
                                              Text(
                                                _formatDate(
                                                    donation['created_at'] ??
                                                        ''),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Container(
                                            width: double.infinity,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  accentGold,
                                                  Color(0xFFE6C45C)
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: accentGold
                                                      .withOpacity(0.4),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              onPressed: () {
                                                _showContactOptions(
                                                    context, donation);
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .phone_in_talk_rounded,
                                                      color: primaryBlue,
                                                      size: 22),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "تواصل مع المتبرع",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: primaryBlue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: filteredDonations.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'جديد':
        return Colors.green;
      case 'مستعمل':
        return Colors.orange;
      case 'قديم':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showContactOptions(
      BuildContext context, Map<String, dynamic> donation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryBlue.withOpacity(0.1),
                    lightTeal.withOpacity(0.1)
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(Icons.volunteer_activism_rounded,
                      size: 50, color: accentGold),
                  const SizedBox(height: 12),
                  Text(
                    "تواصل مع المتبرع",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    donation['title'] ?? 'التبرع',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.green.shade600],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.chat_rounded,
                      color: Colors.white, size: 24),
                ),
                title: const Text(
                  "واتساب",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text(
                  "إرسال رسالة عبر واتساب",
                  style: TextStyle(fontSize: 13),
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.green, size: 18),
                onTap: () {
                  Navigator.pop(context);
                  _openWhatsApp(donation);
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryBlue.withOpacity(0.1),
                    lightTeal.withOpacity(0.1)
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryBlue.withOpacity(0.3)),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryBlue, lightTeal],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.phone_rounded, color: accentGold, size: 24),
                ),
                title: const Text(
                  "اتصال هاتفي",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text(
                  "الاتصال برقم المتبرع مباشرة",
                  style: TextStyle(fontSize: 13),
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    color: primaryBlue, size: 18),
                onTap: () {
                  Navigator.pop(context);
                  _makePhoneCall(donation);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openWhatsApp(Map<String, dynamic> donation) async {
    String phoneNumber = donation['user']?['phone'] ?? '01234567890';

    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+2$phoneNumber';
    }

    String message = 'السلام عليكم، أنا مهتم بالتبرع: ${donation['title']}';

    final whatsappUrl = Uri.parse(
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.error_outline_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                      child: Text('لا يمكن فتح واتساب. تأكد من تثبيت التطبيق')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('حدث خطأ: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _makePhoneCall(Map<String, dynamic> donation) async {
    String phoneNumber = donation['user']?['phone'] ?? '01234567890';

    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    final telUrl = Uri.parse('tel:$phoneNumber');

    try {
      if (await canLaunchUrl(telUrl)) {
        await launchUrl(telUrl);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.error_outline_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('لا يمكن إجراء المكالمة')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('حدث خطأ: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else if (difference.inHours < 24) {
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} يوم';
      } else if (difference.inDays < 30) {
        return 'منذ ${(difference.inDays / 7).floor()} أسبوع';
      } else {
        return 'منذ ${(difference.inDays / 30).floor()} شهر';
      }
    } catch (e) {
      return 'منذ فترة';
    }
  }
}
