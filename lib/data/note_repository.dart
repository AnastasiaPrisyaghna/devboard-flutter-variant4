import '../domain/note.dart';
import '../domain/ports/note_storage.dart';

class NoteRepository {
  NoteRepository(this._storage);

  final NoteStorage _storage;
  List<Note>? _cache;

  Future<List<Note>> getAll() async {
    _cache ??= await _storage.readAll();
    return List<Note>.unmodifiable(_cache!);
  }

  Future<void> add(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Порожню нотатку не можна зберегти.');
    }
    final notes = await getAll();
    final now = DateTime.now();
    final note = Note(
      id: now.microsecondsSinceEpoch.toString(),
      text: trimmed,
      createdAt: now,
    );
    final updated = <Note>[...notes, note];
    await _storage.writeAll(updated);
    _cache = updated; // Оновлюємо лише після успішного збереження.
  }

  Future<void> remove(String id) async {
    final notes = await getAll();
    final updated = notes.where((note) => note.id != id).toList();
    await _storage.writeAll(updated);
    _cache = updated;
  }
}
