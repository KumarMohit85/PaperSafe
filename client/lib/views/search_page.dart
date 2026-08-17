import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:papersafe/core/services/search_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();

  List<SearchDocumentItem> _searchResults = [];
  List<String> _recentSearches = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;

  final List<String> _categories = [
    'All',
    'Identity',
    'Education',
    'Financial',
    'Travel',
    'Medical',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    await _seedDefaultDocumentsIfEmpty();
    await _loadRecentSearches();
    await _performSearch('');
    setState(() => _isLoading = false);
  }

  Future<void> _seedDefaultDocumentsIfEmpty() async {
    final existing = await _searchService.search('');
    if (existing.isEmpty) {
      final defaultItems = [
        SearchDocumentItem(
          id: '1',
          title: 'Aadhaar Card',
          category: 'Identity',
          ocrText: 'Government of India Unique Identification Authority 1234 5678 9012 DOB 15/08/1998',
          tags: 'aadhaar, identity, government, uidai',
          updatedAt: DateTime.now().toIso8601String(),
        ),
        SearchDocumentItem(
          id: '2',
          title: 'PAN Card',
          category: 'Identity',
          ocrText: 'Income Tax Department Permanent Account Number ABCDE1234F',
          tags: 'pan, tax, identity, income tax',
          updatedAt: DateTime.now().toIso8601String(),
        ),
        SearchDocumentItem(
          id: '3',
          title: 'Class 10th Marksheet',
          category: 'Education',
          ocrText: 'Central Board of Secondary Education Secondary School Examination Marks 95%',
          tags: 'cbse, 10th, marksheet, education',
          updatedAt: DateTime.now().toIso8601String(),
        ),
        SearchDocumentItem(
          id: '4',
          title: 'Train Ticket - IRCTC',
          category: 'Travel',
          ocrText: 'IRCTC E-Ticket PNR 4521897630 New Delhi to Mumbai Central Class 2A',
          tags: 'irctc, ticket, train, travel, pnr',
          updatedAt: DateTime.now().toIso8601String(),
        ),
        SearchDocumentItem(
          id: '5',
          title: 'HDFC Credit Card Statement',
          category: 'Financial',
          ocrText: 'HDFC Bank Credit Card Statement Ending 4321 Total Due 12500 INR',
          tags: 'hdfc, credit card, bank, finance',
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ];

      for (var item in defaultItems) {
        await _searchService.indexDocument(item);
      }
    }
  }

  Future<void> _loadRecentSearches() async {
    final recent = await _searchService.getRecentSearches();
    setState(() => _recentSearches = recent);
  }

  Future<void> _performSearch(String query) async {
    final results = await _searchService.search(
      query,
      categoryFilter: _selectedCategory == 'All' ? null : _selectedCategory,
    );
    setState(() => _searchResults = results);
  }

  void _onSearchSubmitted(String term) {
    if (term.trim().isNotEmpty) {
      _searchService.addRecentSearch(term);
      _loadRecentSearches();
    }
    _performSearch(term);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F2027)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => _performSearch(val),
                      onSubmitted: _onSearchSubmitted,
                      decoration: InputDecoration(
                        hintText: 'Search documents by title, OCR text, or tags...',
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Colors.tealAccent),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white54),
                                onPressed: () {
                                  _searchController.clear();
                                  _performSearch('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),

                // Category Chips Selector
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = category);
                              _performSearch(_searchController.text);
                            }
                          },
                          selectedColor: Colors.tealAccent,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? Colors.tealAccent : Colors.white12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Recent Searches Row (if present and query is empty)
                if (_searchController.text.isEmpty && _recentSearches.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Searches',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await _searchService.clearRecentSearches();
                            _loadRecentSearches();
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.tealAccent, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _recentSearches.length,
                      itemBuilder: (context, index) {
                        final term = _recentSearches[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: const Icon(Icons.history, size: 14, color: Colors.white54),
                            label: Text(term, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            backgroundColor: Colors.white.withOpacity(0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.white12),
                            ),
                            onPressed: () {
                              _searchController.text = term;
                              _performSearch(term);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Search Results List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
                      : _searchResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No documents match your query',
                                    style: TextStyle(color: Colors.white54, fontSize: 15),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final item = _searchResults[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.tealAccent.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.description_rounded, color: Colors.tealAccent),
                                    ),
                                    title: Text(
                                      item.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item.category,
                                            style: const TextStyle(color: Colors.tealAccent, fontSize: 11),
                                          ),
                                        ),
                                        if (item.ocrText.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            item.ocrText,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                                          ),
                                        ],
                                      ],
                                    ),
                                    trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Opening ${item.title}')),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
