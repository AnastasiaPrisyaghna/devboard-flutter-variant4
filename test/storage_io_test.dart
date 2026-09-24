import 'dart:convert';
import 'dart:io';

import 'package:devboard/domain/note.dart';
import 'package:devboard/platform/storage/storage_io.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late FileNoteStorage storage;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('devboard_storage_test_');
    storage = FileNoteStorage(testDirectory: directory);
  });

  tearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test('not found -> empty list', () async {
    expect(await storage.readAll(), isEmpty);
  });

  test('actual JSON file stores notes and survives a new adapter instance', () async {
    final timestamp = DateTime.utc(2026, 9, 24, 10, 30);
    const text = 'Перевірка файлового сховища';
    final notes = <Note>[
      Note(id: 'example-1', text: text, createdAt: timestamp),
    ];
    await storage.writeAll(notes);

    final file = File('${directory.path}${Platform.pathSeparator}devboard_notes.json');
    expect(await file.exists(), isTrue);
    final stored = jsonDecode(await file.readAsString()) as List<dynamic>;
    expect((stored.single as Map<String, dynamic>)['text'], text);

    final freshStorage = FileNoteStorage(testDirectory: directory);
    final restored = await freshStorage.readAll();
    expect(restored, hasLength(1));
    expect(restored.single.id, 'example-1');
    expect(restored.single.text, text);
    expect(restored.single.createdAt, timestamp);

    await freshStorage.writeAll(<Note>[]);
    expect(await storage.readAll(), isEmpty);
  });
}
