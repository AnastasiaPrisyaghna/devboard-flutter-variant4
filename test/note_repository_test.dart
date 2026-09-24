import 'package:flutter_test/flutter_test.dart';
import 'package:devboard/data/note_repository.dart';
import 'package:devboard/domain/note.dart';
import 'package:devboard/domain/ports/note_storage.dart';

class MemoryNoteStorage implements NoteStorage {
  List<Note> notes = <Note>[];

  @override
  Future<List<Note>> readAll() async => List<Note>.of(notes);

  @override
  Future<void> writeAll(List<Note> newNotes) async {
    notes = List<Note>.of(newNotes);
  }
}

void main() {
  test('додавання та видалення нотатки через порт', () async {
    final storage = MemoryNoteStorage();
    final repository = NoteRepository(storage);
    await repository.add('   тестова нотатка   ');
    final notes = await repository.getAll();
    expect(notes.length, 1);
    expect(notes.single.text, 'тестова нотатка');
    await repository.remove(notes.single.id);
    expect(await repository.getAll(), isEmpty);
  });

  test('порожню нотатку не додаємо', () async {
    final repository = NoteRepository(MemoryNoteStorage());
    await expectLater(repository.add('   '), throwsArgumentError);
  });
}
