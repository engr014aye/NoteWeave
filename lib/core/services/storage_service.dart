import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/category_model.dart';
import '../models/note_model.dart';

class StorageService {
  static final StorageService instance = StorageService._internal();
  StorageService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'noteweave.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        tags TEXT NOT NULL DEFAULT '',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        color_value INTEGER NOT NULL,
        icon_name TEXT NOT NULL,
        is_custom INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE preferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Seed default categories
    final now = DateTime.now();
    final defaultCategories = [
      NoteCategory(
        id: 'cat_work',
        name: 'Work',
        colorValue: 0xFF3B5BFD,
        iconName: 'briefcase',
        isCustom: false,
        createdAt: now,
      ),
      NoteCategory(
        id: 'cat_study',
        name: 'Study',
        colorValue: 0xFF10B981,
        iconName: 'book',
        isCustom: false,
        createdAt: now,
      ),
      NoteCategory(
        id: 'cat_ideas',
        name: 'Ideas',
        colorValue: 0xFFF59E0B,
        iconName: 'lightbulb',
        isCustom: false,
        createdAt: now,
      ),
      NoteCategory(
        id: 'cat_journal',
        name: 'Journal',
        colorValue: 0xFF8B5CF6,
        iconName: 'bookmark',
        isCustom: false,
        createdAt: now,
      ),
    ];

    for (final cat in defaultCategories) {
      await db.insert('categories', cat.toMap());
    }

    // Seed 4 realistic, beautifully-formatted sample notes
    final sampleNotes = [
      Note(
        id: 'sample_note_work',
        title: 'Q4 Product Strategy & Architecture',
        content: '## Executive Vision\nDeliver NoteWeave with frictionless iOS-native physics, silent background persistence, and refined editorial typography.\n\n### Primary Deliverables\n• Zero-latency markdown editing with tactile spring interactions\n• Fluid gesture navigation and large Cupertino sliver headers\n• Dynamic category tagging and real-time search indexing\n\n> "Simplicity is about subtracting the obvious and adding the meaningful." — John Maeda\n\n---\nRefine touch curves and haptics before launch.',
        category: 'Work',
        isPinned: true,
        tags: ['strategy', 'roadmap', 'deliverables'],
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(minutes: 15)),
      ),
      Note(
        id: 'sample_note_ideas',
        title: 'The Art of Thought Weaving',
        content: '## Thoughts as Raw Threads\nEvery sudden inspiration begins as an unformed thread. When captured quickly and woven together with clarity, raw concepts crystallize into tangible reality.\n\n### Daily Mental Habits\n1. Capture thoughts before everyday noise dissolves them\n2. Revisit notes during peaceful evening review blocks\n3. Allow unexpected intersections between separate notebooks\n\n> The clearest minds are not empty; they are well-ordered.',
        category: 'Ideas',
        isPinned: true,
        tags: ['philosophy', 'creative', 'writing'],
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      Note(
        id: 'sample_note_study',
        title: 'Deep Work & Cognitive Flow Notes',
        content: '## Key Insights from Cal Newport\n\n### The Four Rules of Deep Work\n• **Rule 1**: Work deeply; remove low-friction digital distractions\n• **Rule 2**: Embrace boredom; resist habitual phone checking\n• **Rule 3**: Quit shallow entertainment loops\n• **Rule 4**: Drain the shallows; protect uninterrupted blocks of time\n\n> "To produce at your peak level you need to work for extended periods with full concentration on a single task free from distraction."',
        category: 'Study',
        isPinned: false,
        tags: ['focus', 'psychology', 'reading'],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
      Note(
        id: 'sample_note_journal',
        title: 'Morning Reflections & Intentions',
        content: '## Sunrise Clarity\nA calm, crisp start to the day. Fresh pour-over coffee, an open canvas, and absolute quiet outside.\n\n### Intentions for Today\n• Move deliberately rather than reacting hurriedly\n• Build with excellence in every subtle interaction\n• End the workday with a clear and untroubled mind\n\n---\n"Peace comes from within. Do not seek it without."',
        category: 'Journal',
        isPinned: false,
        tags: ['morning', 'mindfulness', 'intentions'],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    for (final note in sampleNotes) {
      await db.insert('notes', note.toMap());
    }

    // Default preferences
    await db.insert('preferences', {'key': 'theme_mode', 'value': 'light'});
    await db.insert('preferences', {'key': 'text_size', 'value': 'standard'});
    await db.insert('preferences', {'key': 'default_category', 'value': 'Work'});
    await db.insert('preferences', {'key': 'first_launch_done', 'value': '1'});
  }

  // Notes CRUD
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query(
      'notes',
      orderBy: 'is_pinned DESC, updated_at DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  Future<void> saveNote(Note note) async {
    final db = await database;
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> togglePin(String id, bool isPinned) async {
    final db = await database;
    await db.update(
      'notes',
      {'is_pinned': isPinned ? 1 : 0, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Categories CRUD
  Future<List<NoteCategory>> getAllCategories() async {
    final db = await database;
    final maps = await db.query(
      'categories',
      orderBy: 'is_custom ASC, created_at ASC',
    );
    return maps.map((m) => NoteCategory.fromMap(m)).toList();
  }

  Future<void> saveCategory(NoteCategory category) async {
    final db = await database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> renameCategory(String id, String newName) async {
    final db = await database;
    await db.update(
      'categories',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Preferences
  Future<String?> getPreference(String key, {String? defaultValue}) async {
    final db = await database;
    final maps = await db.query(
      'preferences',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return defaultValue;
  }

  Future<void> setPreference(String key, String value) async {
    final db = await database;
    await db.insert(
      'preferences',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
