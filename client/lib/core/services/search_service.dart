import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SearchDocumentItem {
  final String id;
  final String title;
  final String category;
  final String ocrText;
  final String tags;
  final String updatedAt;

  SearchDocumentItem({
    required this.id,
    required this.title,
    required this.category,
    required this.ocrText,
    required this.tags,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'ocrText': ocrText,
      'tags': tags,
      'updatedAt': updatedAt,
    };
  }

  factory SearchDocumentItem.fromMap(Map<String, dynamic> map) {
    return SearchDocumentItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      ocrText: map['ocrText'] ?? '',
      tags: map['tags'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }
}

class SearchService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'papersafe_search.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE documents_index (
            id TEXT PRIMARY KEY,
            title TEXT,
            category TEXT,
            ocrText TEXT,
            tags TEXT,
            updatedAt TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE recent_searches (
            term TEXT PRIMARY KEY,
            timestamp INTEGER
          )
        ''');
      },
    );
  }

  /// Insert or update indexed document
  Future<void> indexDocument(SearchDocumentItem item) async {
    final db = await database;
    await db.insert(
      'documents_index',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Perform full-text search over titles, categories, tags, and OCR extracted text
  Future<List<SearchDocumentItem>> search(String query, {String? categoryFilter}) async {
    final db = await database;
    if (query.trim().isEmpty && (categoryFilter == null || categoryFilter.isEmpty)) {
      final List<Map<String, dynamic>> maps = await db.query('documents_index', limit: 20);
      return maps.map((m) => SearchDocumentItem.fromMap(m)).toList();
    }

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (query.trim().isNotEmpty) {
      final cleanQuery = '%${query.trim()}%';
      whereClause += '(title LIKE ? OR category LIKE ? OR ocrText LIKE ? OR tags LIKE ?)';
      whereArgs.addAll([cleanQuery, cleanQuery, cleanQuery, cleanQuery]);
    }

    if (categoryFilter != null && categoryFilter.isNotEmpty && categoryFilter != 'All') {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'category = ?';
      whereArgs.add(categoryFilter);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'documents_index',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'updatedAt DESC',
    );

    return maps.map((m) => SearchDocumentItem.fromMap(m)).toList();
  }

  /// Save recent search query
  Future<void> addRecentSearch(String term) async {
    if (term.trim().isEmpty) return;
    final db = await database;
    await db.insert(
      'recent_searches',
      {
        'term': term.trim(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get list of recent search queries
  Future<List<String>> getRecentSearches() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recent_searches',
      orderBy: 'timestamp DESC',
      limit: 10,
    );
    return maps.map((m) => m['term'] as String).toList();
  }

  /// Clear search history
  Future<void> clearRecentSearches() async {
    final db = await database;
    await db.delete('recent_searches');
  }
}
