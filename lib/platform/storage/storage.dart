import '../../domain/ports/note_storage.dart';
import 'storage_stub.dart'
    if (dart.library.io) 'storage_io.dart'
    if (dart.library.js_interop) 'storage_web.dart' as implementation;

NoteStorage createNoteStorage() => implementation.createNoteStorage();
