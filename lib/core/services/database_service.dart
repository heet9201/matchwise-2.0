import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

/// Database service with optimized indexing for comparison items
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  bool _initialized = false;

  // Table names
  static const String tableComparisons = 'comparisons';
  static const String tableComparisonItems = 'comparison_items';
  static const String tableShortlist = 'shortlist';
  static const String tableHistory = 'history';

  // Database version
  static const int _databaseVersion = 1;

  /// Get database instance
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'matchwise.db');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  /// Create tables with proper indexes
  Future<void> _onCreate(Database db, int version) async {
    // Comparisons table
    await db.execute('''
      CREATE TABLE $tableComparisons (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        status TEXT NOT NULL,
        total_items INTEGER DEFAULT 0,
        metadata TEXT
      )
    ''');

    // Indexes for comparisons
    await db.execute('''
      CREATE INDEX idx_comparisons_created_at 
      ON $tableComparisons(created_at DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_comparisons_type 
      ON $tableComparisons(type)
    ''');

    await db.execute('''
      CREATE INDEX idx_comparisons_status 
      ON $tableComparisons(status)
    ''');

    // Comparison items table
    await db.execute('''
      CREATE TABLE $tableComparisonItems (
        id TEXT PRIMARY KEY,
        comparison_id TEXT NOT NULL,
        title TEXT NOT NULL,
        score REAL DEFAULT 0.0,
        data TEXT,
        image_url TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        position INTEGER DEFAULT 0,
        FOREIGN KEY (comparison_id) REFERENCES $tableComparisons(id) ON DELETE CASCADE
      )
    ''');

    // Indexes for comparison items
    await db.execute('''
      CREATE INDEX idx_items_comparison_id 
      ON $tableComparisonItems(comparison_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_items_score 
      ON $tableComparisonItems(score DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_items_created_at 
      ON $tableComparisonItems(created_at DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_items_position 
      ON $tableComparisonItems(position ASC)
    ''');

    // Composite index for efficient queries
    await db.execute('''
      CREATE INDEX idx_items_comparison_score 
      ON $tableComparisonItems(comparison_id, score DESC)
    ''');

    // Shortlist table
    await db.execute('''
      CREATE TABLE $tableShortlist (
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        comparison_id TEXT NOT NULL,
        added_at INTEGER NOT NULL,
        notes TEXT,
        FOREIGN KEY (item_id) REFERENCES $tableComparisonItems(id) ON DELETE CASCADE,
        FOREIGN KEY (comparison_id) REFERENCES $tableComparisons(id) ON DELETE CASCADE
      )
    ''');

    // Indexes for shortlist
    await db.execute('''
      CREATE INDEX idx_shortlist_added_at 
      ON $tableShortlist(added_at DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_shortlist_comparison_id 
      ON $tableShortlist(comparison_id)
    ''');

    // History table
    await db.execute('''
      CREATE TABLE $tableHistory (
        id TEXT PRIMARY KEY,
        comparison_id TEXT NOT NULL,
        action TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        metadata TEXT,
        FOREIGN KEY (comparison_id) REFERENCES $tableComparisons(id) ON DELETE CASCADE
      )
    ''');

    // Indexes for history
    await db.execute('''
      CREATE INDEX idx_history_timestamp 
      ON $tableHistory(timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_history_comparison_id 
      ON $tableHistory(comparison_id)
    ''');

    debugPrint('Database tables created with indexes');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future schema updates
    debugPrint('Database upgraded from version $oldVersion to $newVersion');
  }

  /// Configure database on open
  Future<void> _onOpen(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');

    // Enable WAL mode for better performance
    await db.execute('PRAGMA journal_mode = WAL');

    // Optimize for performance
    await db.execute('PRAGMA synchronous = NORMAL');
    await db.execute('PRAGMA temp_store = MEMORY');
    await db.execute('PRAGMA cache_size = -10000'); // 10MB cache

    debugPrint('Database opened with optimizations');
  }

  /// Initialize service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await database;
      _initialized = true;
      debugPrint('DatabaseService initialized');
    } catch (e) {
      debugPrint('DatabaseService initialization error: $e');
      rethrow;
    }
  }

  // ============ COMPARISON OPERATIONS ============

  /// Insert comparison
  Future<String> insertComparison(Map<String, dynamic> comparison) async {
    final db = await database;
    await db.insert(tableComparisons, comparison);
    return comparison['id'];
  }

  /// Get comparison by ID
  Future<Map<String, dynamic>?> getComparison(String id) async {
    final db = await database;
    final results = await db.query(
      tableComparisons,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get all comparisons with pagination
  Future<List<Map<String, dynamic>>> getComparisons({
    int limit = 20,
    int offset = 0,
    String? type,
    String? status,
  }) async {
    final db = await database;

    String? where;
    List<dynamic>? whereArgs;

    if (type != null && status != null) {
      where = 'type = ? AND status = ?';
      whereArgs = [type, status];
    } else if (type != null) {
      where = 'type = ?';
      whereArgs = [type];
    } else if (status != null) {
      where = 'status = ?';
      whereArgs = [status];
    }

    return await db.query(
      tableComparisons,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Update comparison
  Future<int> updateComparison(String id, Map<String, dynamic> updates) async {
    final db = await database;
    return await db.update(
      tableComparisons,
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete comparison
  Future<int> deleteComparison(String id) async {
    final db = await database;
    return await db.delete(
      tableComparisons,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ COMPARISON ITEM OPERATIONS ============

  /// Insert comparison item
  Future<String> insertComparisonItem(Map<String, dynamic> item) async {
    final db = await database;
    await db.insert(tableComparisonItems, item);
    return item['id'];
  }

  /// Batch insert comparison items (optimized)
  Future<void> batchInsertComparisonItems(
    List<Map<String, dynamic>> items,
  ) async {
    final db = await database;
    final batch = db.batch();

    for (final item in items) {
      batch.insert(tableComparisonItems, item);
    }

    await batch.commit(noResult: true);
  }

  /// Get items for comparison with pagination
  Future<List<Map<String, dynamic>>> getComparisonItems({
    required String comparisonId,
    int limit = 20,
    int offset = 0,
    String orderBy = 'position ASC',
  }) async {
    final db = await database;

    return await db.query(
      tableComparisonItems,
      where: 'comparison_id = ?',
      whereArgs: [comparisonId],
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Get top scored items
  Future<List<Map<String, dynamic>>> getTopScoredItems({
    required String comparisonId,
    int limit = 10,
  }) async {
    final db = await database;

    return await db.query(
      tableComparisonItems,
      where: 'comparison_id = ?',
      whereArgs: [comparisonId],
      orderBy: 'score DESC',
      limit: limit,
    );
  }

  /// Search items by title
  Future<List<Map<String, dynamic>>> searchItems({
    required String comparisonId,
    required String query,
    int limit = 20,
  }) async {
    final db = await database;

    return await db.query(
      tableComparisonItems,
      where: 'comparison_id = ? AND title LIKE ?',
      whereArgs: [comparisonId, '%$query%'],
      orderBy: 'score DESC',
      limit: limit,
    );
  }

  /// Update item
  Future<int> updateComparisonItem(
      String id, Map<String, dynamic> updates) async {
    final db = await database;
    return await db.update(
      tableComparisonItems,
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete item
  Future<int> deleteComparisonItem(String id) async {
    final db = await database;
    return await db.delete(
      tableComparisonItems,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ SHORTLIST OPERATIONS ============

  /// Add to shortlist
  Future<String> addToShortlist(Map<String, dynamic> shortlistItem) async {
    final db = await database;
    await db.insert(tableShortlist, shortlistItem);
    return shortlistItem['id'];
  }

  /// Get shortlist items
  Future<List<Map<String, dynamic>>> getShortlist({
    String? comparisonId,
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;

    String? where;
    List<dynamic>? whereArgs;

    if (comparisonId != null) {
      where = 'comparison_id = ?';
      whereArgs = [comparisonId];
    }

    return await db.query(
      tableShortlist,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'added_at DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Remove from shortlist
  Future<int> removeFromShortlist(String id) async {
    final db = await database;
    return await db.delete(
      tableShortlist,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ HISTORY OPERATIONS ============

  /// Add history entry
  Future<String> addHistoryEntry(Map<String, dynamic> entry) async {
    final db = await database;
    await db.insert(tableHistory, entry);
    return entry['id'];
  }

  /// Get history with pagination
  Future<List<Map<String, dynamic>>> getHistory({
    String? comparisonId,
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;

    String? where;
    List<dynamic>? whereArgs;

    if (comparisonId != null) {
      where = 'comparison_id = ?';
      whereArgs = [comparisonId];
    }

    return await db.query(
      tableHistory,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
  }

  // ============ UTILITY OPERATIONS ============

  /// Get database statistics
  Future<Map<String, dynamic>> getStats() async {
    final db = await database;

    final comparisonsCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $tableComparisons'),
        ) ??
        0;

    final itemsCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $tableComparisonItems'),
        ) ??
        0;

    final shortlistCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $tableShortlist'),
        ) ??
        0;

    final historyCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $tableHistory'),
        ) ??
        0;

    return {
      'comparisons': comparisonsCount,
      'items': itemsCount,
      'shortlist': shortlistCount,
      'history': historyCount,
    };
  }

  /// Analyze query performance (development only)
  Future<void> analyzeQuery(String query) async {
    if (kDebugMode) {
      final db = await database;
      final results = await db.rawQuery('EXPLAIN QUERY PLAN $query');
      debugPrint('Query Plan:');
      for (final row in results) {
        debugPrint(row.toString());
      }
    }
  }

  /// Vacuum database (clean up and optimize)
  Future<void> vacuum() async {
    final db = await database;
    await db.execute('VACUUM');
    debugPrint('Database vacuumed');
  }

  /// Close database
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
      _initialized = false;
      debugPrint('Database closed');
    }
  }
}

/// Global instance
final databaseService = DatabaseService();
