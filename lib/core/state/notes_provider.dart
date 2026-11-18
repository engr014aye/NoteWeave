import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/note_model.dart';
import '../services/storage_service.dart';

class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];
  List<NoteCategory> _categories = [];
  String? _selectedCategoryFilter;
  String _searchQuery = '';
  String _defaultCategory = 'Work';
  bool _isLoading = true;

  List<Note> get allNotes => _notes;
  List<NoteCategory> get categories => _categories;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  String get searchQuery => _searchQuery;
  String get defaultCategory => _defaultCategory;
  bool get isLoading => _isLoading;

  List<Note> get filteredNotes {
    return _notes.where((note) {
      final matchesCategory = _selectedCategoryFilter == null ||
          _selectedCategoryFilter == 'All' ||
          note.category.toLowerCase() == _selectedCategoryFilter!.toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<Note> get pinnedNotes => filteredNotes.where((n) => n.isPinned).toList();
  List<Note> get unpinnedNotes => filteredNotes.where((n) => !n.isPinned).toList();

  int getNoteCountForCategory(String categoryName) {
    return _notes.where((n) => n.category.toLowerCase() == categoryName.toLowerCase()).length;
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _categories = await StorageService.instance.getAllCategories();
    _notes = await StorageService.instance.getAllNotes();
    
    final defCat = await StorageService.instance.getPreference('default_category', defaultValue: 'Work');
    if (defCat != null && defCat.isNotEmpty) {
      _defaultCategory = defCat;
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    if (_selectedCategoryFilter == category) return;
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> setDefaultCategory(String category) async {
    if (_defaultCategory == category) return;
    _defaultCategory = category;
    notifyListeners();
    await StorageService.instance.setPreference('default_category', category);
  }

  Future<void> saveNote(Note note) async {
    // If note is completely empty, don't persist or delete it if exists
    if (note.isEmpty) {
      await deleteNote(note.id);
      return;
    }

    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _notes[index] = note;
    } else {
      _notes.insert(0, note);
    }
    // Resort by pinned, then updated_at
    _notes.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });

    notifyListeners();
    await StorageService.instance.saveNote(note);
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    await StorageService.instance.deleteNote(id);
  }

  Future<void> togglePin(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index >= 0) {
      final updated = _notes[index].copyWith(
        isPinned: !_notes[index].isPinned,
        updatedAt: DateTime.now(),
      );
      _notes[index] = updated;
      _notes.sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });
      notifyListeners();
      await StorageService.instance.saveNote(updated);
    }
  }

  Future<void> addCategory(String name, int colorValue, {String iconName = 'folder'}) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    if (_categories.any((c) => c.name.toLowerCase() == trimmedName.toLowerCase())) return;

    final newCat = NoteCategory(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: trimmedName,
      colorValue: colorValue,
      iconName: iconName,
      isCustom: true,
      createdAt: DateTime.now(),
    );

    _categories.add(newCat);
    notifyListeners();
    await StorageService.instance.saveCategory(newCat);
  }

  Future<void> renameCategory(String id, String newName) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) return;

    final index = _categories.indexWhere((c) => c.id == id);
    if (index >= 0) {
      final oldName = _categories[index].name;
      final updatedCat = _categories[index].copyWith(name: trimmedName);
      _categories[index] = updatedCat;

      // Also update notes with this category
      for (int i = 0; i < _notes.length; i++) {
        if (_notes[i].category == oldName) {
          _notes[i] = _notes[i].copyWith(category: trimmedName);
          await StorageService.instance.saveNote(_notes[i]);
        }
      }

      if (_selectedCategoryFilter == oldName) {
        _selectedCategoryFilter = trimmedName;
      }
      if (_defaultCategory == oldName) {
        _defaultCategory = trimmedName;
        await StorageService.instance.setPreference('default_category', trimmedName);
      }

      notifyListeners();
      await StorageService.instance.renameCategory(id, trimmedName);
    }
  }

  Future<void> deleteCategory(String id, String categoryName) async {
    _categories.removeWhere((c) => c.id == id);
    
    // Move notes belonging to deleted category to default 'Work' or first available
    final fallbackCategory = _categories.isNotEmpty ? _categories.first.name : 'Work';
    for (int i = 0; i < _notes.length; i++) {
      if (_notes[i].category == categoryName) {
        _notes[i] = _notes[i].copyWith(category: fallbackCategory);
        await StorageService.instance.saveNote(_notes[i]);
      }
    }

    if (_selectedCategoryFilter == categoryName) {
      _selectedCategoryFilter = null;
    }
    if (_defaultCategory == categoryName) {
      _defaultCategory = fallbackCategory;
      await StorageService.instance.setPreference('default_category', fallbackCategory);
    }

    notifyListeners();
    await StorageService.instance.deleteCategory(id);
  }
}
