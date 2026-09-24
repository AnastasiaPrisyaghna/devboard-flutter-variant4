import 'package:devboard/data/note_repository.dart';
import 'package:devboard/domain/note.dart';
import 'package:devboard/domain/ports/env_info.dart';
import 'package:devboard/domain/ports/locale_port.dart';
import 'package:devboard/domain/ports/note_storage.dart';
import 'package:devboard/presentation/notes_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestStorage implements NoteStorage {
  List<Note> notes = <Note>[];

  @override
  Future<List<Note>> readAll() async => List<Note>.of(notes);

  @override
  Future<void> writeAll(List<Note> updated) async {
    notes = List<Note>.of(updated);
  }
}

class TestEnv implements EnvInfo {
  @override
  String get platformName => 'Windows / test';

  @override
  String get storageLocation => 'JSON / test';
}

class TestLocale implements LocalePort {
  @override
  String get localeName => 'uk_UA';
}

void main() {
  testWidgets('UI shows ports; user can add and remove a note', (tester) async {
    final repository = NoteRepository(TestStorage());
    await tester.pumpWidget(
      DevBoardApp(
        repository: repository,
        environment: TestEnv(),
        locale: TestLocale(),
      ),
    );
    await tester.pumpAndSettle();
    final metadata = tester.widgetList<SelectableText>(
      find.byType(SelectableText),
    ).map((widget) => widget.data).toList();
    expect(metadata, contains('Платформа: Windows / test'));
    expect(metadata, contains('Сховище: JSON / test'));
    expect(metadata, contains('Мова системи / браузера: uk_UA'));
    expect(find.text('Нотаток ще немає.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Перевірка інтерфейсу');
    await tester.tap(find.text('Додати'));
    await tester.pumpAndSettle();
    expect(find.text('Перевірка інтерфейсу'), findsOneWidget);
    expect((await repository.getAll()).single.text, 'Перевірка інтерфейсу');

    await tester.tap(find.byTooltip('Видалити'));
    await tester.pumpAndSettle();
    expect(find.text('Перевірка інтерфейсу'), findsNothing);
    expect(find.text('Нотаток ще немає.'), findsOneWidget);
  });
}
