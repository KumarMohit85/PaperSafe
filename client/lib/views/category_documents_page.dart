import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:papersafe/core/widgets/glassmorphism.dart';
import 'package:papersafe/models/documents_manager.dart';
import 'package:papersafe/models/image_model.dart';
import 'package:papersafe/views/add_document.dart';
import 'package:papersafe/views/add_documents.dart';

// Design Tokens matching YourDocuments & HomePage
const _kBg = Color(0xFF0D1424);
const _kSurface = Color(0xFF131D30);
const _kElevated = Color(0xFF1A2540);
const _kAccent = Color(0xFF4361EE);
const _kGreen = Color(0xFF22C55E);
const _kCircle = Color(0xFF1A2D4A);

class CategoryDocumentsPage extends StatefulWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color accentColor;

  const CategoryDocumentsPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    this.accentColor = _kAccent,
  });

  @override
  State<CategoryDocumentsPage> createState() => _CategoryDocumentsPageState();
}

class _CategoryDocumentsPageState extends State<CategoryDocumentsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<ImageModel?> _categoryDocs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryDocuments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryDocuments() async {
    setState(() => _isLoading = true);
    final allImages = DocumentManager().allImages;
    final catNameLower = widget.categoryName.toLowerCase();

    List<ImageModel?> docs = [];

    if (catNameLower.contains('marksheet') || catNameLower.contains('education')) {
      docs = DocumentManager().educationImages;
    } else if (catNameLower.contains('credential') || catNameLower.contains('identity')) {
      docs = DocumentManager().identityImages;
    } else if (catNameLower.contains('ticket') || catNameLower.contains('travel')) {
      if (DocumentManager().movieTickets["tickets"] != null) {
        for (var i = 0; i < DocumentManager().movieTickets["tickets"]!.length; i++) {
          Uint8List? imageData = await DocumentManager().movieTickets["tickets"]![i].readAsBytes();
          docs.add(ImageModel(title: "Ticket ${i + 1}", image: imageData));
        }
      }
    } else if (catNameLower.contains('card')) {
      docs = DocumentManager().identityImages;
    } else {
      docs = allImages;
    }

    // Fallback if empty — show all or filtered list
    if (docs.isEmpty && allImages.isNotEmpty) {
      docs = allImages.where((img) {
        if (img == null || img.title == null) return false;
        final t = img.title!.toLowerCase();
        return t.contains(catNameLower) || catNameLower.contains('all');
      }).toList();
    }

    if (mounted) {
      setState(() {
        _categoryDocs = docs;
        _isLoading = false;
      });
    }
  }

  documentType _getDocTypeForCategory() {
    final name = widget.categoryName.toLowerCase();
    if (name.contains('marksheet')) return documentType.XMarkSheet;
    if (name.contains('ticket')) return documentType.MovieTicket;
    if (name.contains('card')) return documentType.PAN;
    if (name.contains('credential') || name.contains('identity')) return documentType.Aadhaar;
    return documentType.XMarkSheet;
  }

  void _openAddDocument() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddDocument(
          docType: _getDocTypeForCategory(),
          id: 'user_doc',
        ),
      ),
    ).then((_) => _loadCategoryDocuments());
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocs = _categoryDocs.where((doc) {
      if (doc == null || doc.title == null) return false;
      return doc.title!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // Background Glow / Circle
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.accentColor.withOpacity(0.18),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kCircle.withOpacity(0.4),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header Bar
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: _kSurface,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CATEGORY VAULT',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: const Color(0xFF8B9ABB),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              widget.categoryName,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: widget.accentColor.withOpacity(0.4)),
                        ),
                        child: Text(
                          '${_categoryDocs.length} Items',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Glassmorphic Category Banner
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: GlassMorphism(
                    borderRadius: 18,
                    blurSigma: 12,
                    color: _kSurface.withOpacity(0.6),
                    padding: EdgeInsets.all(16.r),
                    child: Row(
                      children: [
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: widget.accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Icon(
                            widget.categoryIcon,
                            color: widget.accentColor,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.categoryName} Storage',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'AES-256 Encrypted • Ready for Instant Access',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF8B9ABB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: Colors.white10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Color(0xFF8B9ABB), size: 20),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            style: TextStyle(color: Colors.white, fontSize: 14.sp),
                            decoration: InputDecoration(
                              hintText: 'Search in ${widget.categoryName}...',
                              hintStyle: TextStyle(color: const Color(0xFF8B9ABB), fontSize: 14.sp),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Document Grid / List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: _kAccent))
                      : filteredDocs.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                              physics: const BouncingScrollPhysics(),
                              itemCount: filteredDocs.length,
                              itemBuilder: (context, index) {
                                final doc = filteredDocs[index];
                                if (doc == null) return const SizedBox.shrink();
                                return _buildDocumentCard(doc);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Glassmorphic Add Document Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: _openAddDocument,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 6,
              shadowColor: widget.accentColor.withOpacity(0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10.w),
                Text(
                  'Add New ${widget.categoryName}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.w),
                const Text('✦', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(ImageModel doc) {
    final title = doc.title ?? 'Document';
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Preview or Icon
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: widget.accentColor.withOpacity(0.3)),
            ),
            child: doc.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.memory(
                      doc.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(widget.categoryIcon, color: widget.accentColor, size: 22.sp),
                    ),
                  )
                : Icon(widget.categoryIcon, color: widget.accentColor, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, color: _kGreen, size: 12.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Encrypted • Local Vault',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF8B9ABB),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _kElevated,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Text(
                  'View',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: widget.accentColor,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.arrow_forward_ios_rounded, color: widget.accentColor, size: 10.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: GlassMorphism(
          borderRadius: 20,
          blurSigma: 10,
          color: _kSurface.withOpacity(0.5),
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.categoryIcon, color: widget.accentColor, size: 32.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                'No ${widget.categoryName} Found',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'You haven\'t added any ${widget.categoryName.toLowerCase()} yet. Tap the button below to upload or scan your documents.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF8B9ABB),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
