import 'dart:convert';

import 'package:web/web.dart' as web;

import '../../domain/note.dart';
import '../../domain/ports/note_storage.dart';

NoteStorage createNoteStorage() => LocalStorageNoteStorage();

const String storageKey = 'devboard_notes';

class LocalStorageNoteStorage implements NoteStorage {
  @override
  Future<List<Note>> readAll() async {
    final raw = web.window.localStorage.getItem(storageKey);
    if (raw == null || raw.trim().isEmpty) return <Note>[];
    final entries = jsonDecode(raw) as List<dynamic>;
    return entries
        .map((entry) => Note.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> writeAll(List<Note> notes) async {
    web.window.localStorage.setItem(
      storageKey,
      jsonEncode(notes.map((note) => note.toJson()).toList()),
    );
  }
}
