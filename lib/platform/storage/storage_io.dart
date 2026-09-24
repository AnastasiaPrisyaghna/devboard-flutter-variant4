import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../domain/note.dart';
import '../../domain/ports/note_storage.dart';

NoteStorage createNoteStorage() => FileNoteStorage();

/// Windows: the normal location comes from path_provider.
/// An optional directory is injected only by tests to verify real dart:io I/O
/// without depending on a running native plugin host.
class FileNoteStorage implements NoteStorage {
  FileNoteStorage({Directory? testDirectory}) : _testDirectory = testDirectory;

  final Directory? _testDirectory;

  Future<File> _file() async {
    final directory = _testDirectory ?? await getApplicationDocumentsDirectory();
    return File('${directory.path}${Platform.pathSeparator}devboard_notes.json');
  }

  @override
  Future<List<Note>> readAll() async {
    final file = await _file();
    if (!await file.exists()) return <Note>[];
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return <Note>[];
    final entries = jsonDecode(raw) as List<dynamic>;
    return entries
        .map((entry) => Note.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> writeAll(List<Note> notes) async {
    final file = await _file();
    final payload = jsonEncode(notes.map((note) => note.toJson()).toList());
    await file.writeAsString(payload, flush: true);
  }
}
