import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api_service.dart';

class AddDonationPage extends StatefulWidget {
  const AddDonationPage({super.key});

  @override
  State<AddDonationPage> createState() => _AddDonationPageState();
}

class _AddDonationPageState extends State<AddDonationPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(text: '1');

  String? _selectedType;
  String? _selectedSize;
  String? _selectedCharityId;

  final List<File> _images = [];
  bool _isLoading = false;
  bool _loadingCharities = true;
  List<CharityModel> _charities = [];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const Color primaryBlue = Color(0xFF1B4B5A);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color lightTeal = Color(0xFF4A9BAE);
  static const Color lightBeige = Color(0xFFF5EFE7);
  static const Color darkGrey = Color(0xFF455A64);
  static const Color cardWhite = Color(0xFFFFFFFF);

  final List<String> _types = ['clothes', 'food', 'toys', 'books', 'other'];
  final Map<String, String> _typeLabels = {
    'clothes': 'ملابس',
    'food': 'طعام',
    'toys': 'ألعاب',
    'books': 'كتب',
    'other': 'أخرى',
  };

  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'غير محدد'];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
    _loadCharities();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadCharities() async {
    setState(() => _loadingCharities = true);
    final result = await ApiService.getCharities();
    setState(() {
      _loadingCharities = false;
      if (result.isSuccess && result.data != null) {
        _charities = result.data!;
      }
    });
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) {
      _showSnackBar('يمكنك رفع 5 صور كحد أقصى', Colors.orange);
      return;
    }
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _images.add(File(picked.path)));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCharityId == null) {
      _showSnackBar('برجاء اختيار الجمعية المستلمة', Colors.orange);
      return;
    }
    if (_selectedType == null) {
      _showSnackBar('برجاء اختيار نوع التبرع', Colors.orange);
      return;
    }
    if (_selectedSize == null) {
      _showSnackBar('برجاء اختيار المقاس', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.createDonation(
      charityId: _selectedCharityId!,
      type: _selectedType!,
      size: _selectedSize!,
      quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      images: _images.isNotEmpty ? _images : null,
    );

    setState(() => _isLoading = false);

    result.when(
      success: (data, message) {
        _showSnackBar(
            message ?? 'تم إرسال تبرعك بنجاح، شكراً لعطائك 💚', Colors.green);
        Navigator.pop(context);
      },
      failure: (exception) {
        _showSnackBar(exception.message, Colors.red);
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: primaryBlue,
              foregroundColor: accentGold,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(),
                title: const Text(
                  'إضافة تبرع جديد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildSectionHeader(
                          icon: Icons.photo_library_outlined,
                          title: 'صور التبرع'),
                      const SizedBox(height: 12),
                      _buildImageSection(),
                      const SizedBox(height: 28),
                      _buildSectionHeader(
                          icon: Icons.account_balance_outlined,
                          title: 'الجمعية المستلمة'),
                      const SizedBox(height: 12),
                      _buildCharityDropdown(),
                      const SizedBox(height: 28),
                      _buildSectionHeader(
                          icon: Icons.inventory_2_outlined,
                          title: 'تفاصيل التبرع'),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        label: 'نوع التبرع',
                        icon: Icons.category_outlined,
                        value: _selectedType,
                        items: _types
                            .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(_typeLabels[t] ?? t,
                                    style: const TextStyle(
                                        fontFamily: 'Cairo'))))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedType = val as String?),
                        validator: (v) => v == null ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildDropdownField(
                              label: 'المقاس',
                              icon: Icons.format_size_outlined,
                              value: _selectedSize,
                              items: _sizes
                                  .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s,
                                          style: const TextStyle(
                                              fontFamily: 'Cairo'))))
                                  .toList(),
                              onChanged: (val) => setState(
                                  () => _selectedSize = val as String?),
                              validator: (v) => v == null ? 'مطلوب' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: _buildTextField(
                              controller: _quantityController,
                              label: 'الكمية',
                              icon: Icons.numbers_outlined,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'مطلوب';
                                if (int.tryParse(v) == null ||
                                    int.parse(v) < 1) return 'رقم صحيح';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _buildSectionHeader(
                          icon: Icons.description_outlined,
                          title: 'وصف إضافي (اختياري)'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'اكتب أي تفاصيل عن التبرع',
                        icon: Icons.edit_note_outlined,
                        maxLines: 4,
                        validator: null,
                      ),
                      const SizedBox(height: 36),
                      _buildSubmitButton(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [primaryBlue, lightTeal],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentGold.withOpacity(0.1),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.volunteer_activism,
                      size: 42, color: accentGold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'شارك الخير.. تبرع بما لا تحتاج',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryBlue, size: 18),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        if (_images.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true,
              itemCount: _images.length,
              itemBuilder: (ctx, i) => _buildImageThumb(i),
            ),
          ),
          const SizedBox(height: 12),
        ],
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: _images.isEmpty ? 180 : 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: primaryBlue.withOpacity(0.25),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: _images.isEmpty ? 52 : 24, color: lightTeal),
                if (_images.isEmpty) ...[
                  const SizedBox(height: 10),
                  const Text('اضغط لرفع صورة',
                      style: TextStyle(
                          color: darkGrey,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo')),
                  const Text('يمكنك رفع حتى 5 صور',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ] else
                  const Text('إضافة صورة أخرى',
                      style: TextStyle(
                          color: lightTeal,
                          fontSize: 13,
                          fontFamily: 'Cairo')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumb(int index) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10),
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(_images[index], fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          left: 14,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCharityDropdown() {
    if (_loadingCharities) {
      return _buildCardShell(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(
                color: primaryBlue, strokeWidth: 2),
          ),
        ),
      );
    }
    if (_charities.isEmpty) {
      return _buildCardShell(
        child: InkWell(
          onTap: _loadCharities,
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, color: lightTeal),
                SizedBox(width: 8),
                Text('إعادة تحميل الجمعيات',
                    style: TextStyle(color: lightTeal, fontFamily: 'Cairo')),
              ],
            ),
          ),
        ),
      );
    }
    return _buildCardShell(
      child: DropdownButtonFormField<String>(
        value: _selectedCharityId,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryBlue),
        decoration: const InputDecoration(
          prefixIcon:
              Icon(Icons.account_balance_outlined, color: primaryBlue),
          hintText: 'اختر الجمعية المستلمة',
          hintStyle: TextStyle(fontFamily: 'Cairo', color: darkGrey),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: _charities
            .map((c) => DropdownMenuItem<String>(
                  value: c.id,
                  child: Text(c.name,
                      style: const TextStyle(fontFamily: 'Cairo')),
                ))
            .toList(),
        onChanged: (val) => setState(() => _selectedCharityId = val),
        validator: (v) => v == null ? 'برجاء اختيار الجمعية' : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required dynamic value,
    required List<DropdownMenuItem<dynamic>> items,
    required Function(dynamic) onChanged,
    required String? Function(dynamic)? validator,
  }) {
    return _buildCardShell(
      child: DropdownButtonFormField<dynamic>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryBlue),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryBlue),
          hintText: label,
          hintStyle: const TextStyle(fontFamily: 'Cairo', color: darkGrey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return _buildCardShell(
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontFamily: 'Cairo', color: darkGrey),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryBlue),
          hintText: label,
          hintStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator ??
            (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
      ),
    );
  }

  Widget _buildCardShell({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: primaryBlue.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [primaryBlue, lightTeal],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        boxShadow: [
          BoxShadow(
              color: primaryBlue.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _submitDonation,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                        color: accentGold, strokeWidth: 2.5),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.volunteer_activism,
                          color: accentGold, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'تأكيد التبرع الآن',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
