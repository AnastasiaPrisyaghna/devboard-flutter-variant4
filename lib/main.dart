import 'package:flutter/material.dart';

import 'data/note_repository.dart';
import 'platform/env/env.dart';
import 'platform/locale/locale.dart';
import 'platform/storage/storage.dart';
import 'presentation/notes_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Composition root: лише тут збираємо конкретні адаптери у спільні порти.
  final repository = NoteRepository(createNoteStorage());
  final environment = createEnvInfo();
  final locale = createLocalePort();

  runApp(
    DevBoardApp(
      repository: repository,
      environment: environment,
      locale: locale,
    ),
  );
}
