import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerPage extends StatefulWidget {
  final String title;
  final String? filePath;
  final String? url;

  const PdfViewerPage({
    super.key,
    required this.title,
    this.filePath,
    this.url,
  }) : assert(filePath != null || url != null, 'Either filePath or url must be provided');

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  late PdfTextSearchResult _searchResult;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int _pageCount = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _searchResult = PdfTextSearchResult();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _sharePdf() async {
    if (widget.filePath != null) {
      await Share.shareXFiles([XFile(widget.filePath!)], text: 'Sharing ${widget.title}');
    } else if (widget.url != null) {
      await Share.share('Check out this document: ${widget.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search in PDF...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onSubmitted: (query) async {
                  _searchResult = await _pdfViewerController.searchText(query);
                  setState(() {});
                },
              )
            : Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        actions: [
          if (_isSearching) ...[
            IconButton(
              icon: const Icon(Icons.navigate_before, color: Colors.tealAccent),
              onPressed: () => _searchResult.previousInstance(),
            ),
            IconButton(
              icon: const Icon(Icons.navigate_next, color: Colors.tealAccent),
              onPressed: () => _searchResult.nextInstance(),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                _searchResult.clear();
                setState(() => _isSearching = false);
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => setState(() => _isSearching = true),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.tealAccent),
              onPressed: _sharePdf,
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          widget.filePath != null
              ? SfPdfViewer.file(
                  File(widget.filePath!),
                  controller: _pdfViewerController,
                  onDocumentLoaded: (details) {
                    setState(() {
                      _pageCount = details.document.pages.count;
                    });
                  },
                  onPageChanged: (details) {
                    setState(() {
                      _currentPage = details.newPageNumber;
                    });
                  },
                )
              : SfPdfViewer.network(
                  widget.url!,
                  controller: _pdfViewerController,
                  onDocumentLoaded: (details) {
                    setState(() {
                      _pageCount = details.document.pages.count;
                    });
                  },
                  onPageChanged: (details) {
                    setState(() {
                      _currentPage = details.newPageNumber;
                    });
                  },
                ),

          // Bottom Floating Page Indicator Controls
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 10),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_out, color: Colors.white, size: 20),
                      onPressed: () {
                        _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel - 0.25).clamp(1.0, 3.0);
                      },
                    ),
                    Text(
                      '$_currentPage / $_pageCount',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
                      onPressed: () {
                        _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel + 0.25).clamp(1.0, 3.0);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
