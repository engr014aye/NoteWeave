import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteweave/core/models/category_model.dart';
import 'package:noteweave/core/models/note_model.dart';
import 'package:noteweave/core/state/notes_provider.dart';
import 'package:noteweave/core/state/theme_provider.dart';
import 'package:noteweave/screens/home_navigation_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Note Model Unit Tests', () {
    test('Note creation, serialization and copyWith', () {
      final now = DateTime.now();
      final note = Note(
        id: 'test_1',
        title: 'Strategic Architecture',
        content: 'Building iOS-grade physics in Flutter',
        category: 'Work',
        isPinned: true,
        tags: ['strategy', 'architecture'],
        createdAt: now,
        updatedAt: now,
      );

      expect(note.id, 'test_1');
      expect(note.isPinned, isTrue);
      expect(note.isEmpty, isFalse);
      expect(note.tags.length, 2);

      final map = note.toMap();
      expect(map['id'], 'test_1');
      expect(map['is_pinned'], 1);
      expect(map['tags'], 'strategy,architecture');

      final fromMap = Note.fromMap(map);
      expect(fromMap.id, 'test_1');
      expect(fromMap.title, 'Strategic Architecture');
      expect(fromMap.isPinned, isTrue);
      expect(fromMap.tags, ['strategy', 'architecture']);

      final updated = note.copyWith(title: 'Updated Architecture', isPinned: false);
      expect(updated.title, 'Updated Architecture');
      expect(updated.isPinned, isFalse);
      expect(updated.category, 'Work');
    });

    test('Note isEmpty detects whitespace only', () {
      final emptyNote = Note(
        id: 'empty_1',
        title: '   ',
        content: ' \n\t ',
        category: 'Work',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(emptyNote.isEmpty, isTrue);

      final nonEmptyNote = Note(
        id: 'non_empty_1',
        title: 'Idea',
        content: '',
        category: 'Ideas',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(nonEmptyNote.isEmpty, isFalse);
    });
  });

  group('Category Model Unit Tests', () {
    test('NoteCategory serialization and color conversion', () {
      final now = DateTime.now();
      final category = NoteCategory(
        id: 'cat_custom',
        name: 'Projects',
        colorValue: 0xFF3B5BFD,
        iconName: 'folder',
        isCustom: true,
        createdAt: now,
      );

      expect(category.name, 'Projects');
      expect(category.isCustom, isTrue);
      expect(category.color, const Color(0xFF3B5BFD));

      final map = category.toMap();
      expect(map['id'], 'cat_custom');
      expect(map['name'], 'Projects');
      expect(map['is_custom'], 1);

      final restored = NoteCategory.fromMap(map);
      expect(restored.id, 'cat_custom');
      expect(restored.name, 'Projects');
      expect(restored.colorValue, 0xFF3B5BFD);
      expect(restored.isCustom, isTrue);
    });
  });

  group('ThemeProvider Unit Tests', () {
    test('Theme switching and font scaling', () async {
      final provider = ThemeProvider();
      expect(provider.themeMode, ThemeMode.light);
      expect(provider.isDarkMode, isFalse);
      expect(provider.textSize, AppTextSize.standard);
      expect(provider.fontScale, 1.0);

      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, isTrue);

      await provider.setTextSize(AppTextSize.large);
      expect(provider.textSize, AppTextSize.large);
      expect(provider.fontScale, 1.15);

      await provider.setTextSize(AppTextSize.compact);
      expect(provider.textSize, AppTextSize.compact);
      expect(provider.fontScale, 0.90);
    });
  });

  group('NotesProvider Logic Tests', () {
    test('Category filtering and real-time search', () {
      final provider = NotesProvider();
      final now = DateTime.now();

      final n1 = Note(
        id: 'n1',
        title: 'Flutter Architecture',
        content: 'Cupertino sliver bar implementation',
        category: 'Work',
        isPinned: true,
        tags: ['flutter', 'code'],
        createdAt: now,
        updatedAt: now,
      );

      final n2 = Note(
        id: 'n2',
        title: 'Morning Reflections',
        content: 'Quiet moments before work',
        category: 'Journal',
        isPinned: false,
        tags: ['mindfulness'],
        createdAt: now,
        updatedAt: now,
      );

      final n3 = Note(
        id: 'n3',
        title: 'Quantum Computing Ideas',
        content: 'Qubits and superposition notes',
        category: 'Ideas',
        isPinned: false,
        tags: ['physics', 'quantum'],
        createdAt: now,
        updatedAt: now,
      );

      // Inject notes into provider
      provider.allNotes.addAll([n1, n2, n3]);

      // Test all notes
      expect(provider.filteredNotes.length, 3);
      expect(provider.pinnedNotes.length, 1);
      expect(provider.unpinnedNotes.length, 2);

      // Filter by category
      provider.setCategoryFilter('Work');
      expect(provider.filteredNotes.length, 1);
      expect(provider.filteredNotes.first.id, 'n1');

      provider.setCategoryFilter('Journal');
      expect(provider.filteredNotes.length, 1);
      expect(provider.filteredNotes.first.id, 'n2');

      // Reset category filter
      provider.setCategoryFilter('All');
      expect(provider.filteredNotes.length, 3);

      // Search by title
      provider.setSearchQuery('quantum');
      expect(provider.filteredNotes.length, 1);
      expect(provider.filteredNotes.first.id, 'n3');

      // Search by tag
      provider.setSearchQuery('flutter');
      expect(provider.filteredNotes.length, 1);
      expect(provider.filteredNotes.first.id, 'n1');

      // Clear search
      provider.setSearchQuery('');
      expect(provider.filteredNotes.length, 3);
    });
  });

  group('Widget Tests', () {
    testWidgets('Home navigation tabs render and switch seamlessly', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();
      final notesProvider = NotesProvider();

      // Seed mock categories
      notesProvider.categories.addAll([
        NoteCategory(
          id: 'cat_work',
          name: 'Work',
          colorValue: 0xFF3B5BFD,
          iconName: 'briefcase',
          createdAt: DateTime.now(),
        ),
        NoteCategory(
          id: 'cat_study',
          name: 'Study',
          colorValue: 0xFF10B981,
          iconName: 'book',
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeNavigationScreen(
            notesProvider: notesProvider,
            themeProvider: themeProvider,
          ),
        ),
      );

      // Verify Notes tab is active
      expect(find.text('NoteWeave'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Switch to Categories tab
      await tester.tap(find.text('Categories'));
      await tester.pumpAndSettle();
      expect(find.text('Notebooks'), findsOneWidget);

      // Switch to Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('WRITING DEFAULTS'), findsOneWidget);
      expect(find.text('ABOUT'), findsOneWidget);
      expect(find.text('Nexus Vice Ltd'), findsOneWidget);
    });
  });
}
