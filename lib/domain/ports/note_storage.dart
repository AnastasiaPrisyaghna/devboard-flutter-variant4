import '../note.dart';

abstract interface class NoteStorage {
  Future<List<Note>> readAll();
  Future<void> writeAll(List<Note> notes);
}
