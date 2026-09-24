"""Dependency-boundary and completeness checks; not a substitute for flutter analyze."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
required = [
    'pubspec.yaml', 'lib/main.dart', 'lib/domain/note.dart',
    'lib/domain/ports/note_storage.dart', 'lib/domain/ports/env_info.dart',
    'lib/domain/ports/locale_port.dart', 'lib/data/note_repository.dart',
    'lib/presentation/notes_page.dart',
]
for group in ('storage', 'env', 'locale'):
    required += [f'lib/platform/{group}/{group}{suffix}.dart'
                 for suffix in ('', '_stub', '_io', '_web')]
required += ['test/widget_test.dart', 'test/storage_io_test.dart',
             'test/note_repository_test.dart']
missing = [p for p in required if not (ROOT / p).is_file()]
assert not missing, f'Missing files: {missing}'

for group in ('domain', 'data', 'presentation'):
    for file in (ROOT / 'lib' / group).rglob('*.dart'):
        code = file.read_text(encoding='utf-8')
        assert "import 'dart:io'" not in code, str(file)
        assert "import 'package:web" not in code, str(file)
        assert 'kIsWeb' not in code, str(file)

for group in ('storage', 'env', 'locale'):
    factory = (ROOT / 'lib/platform' / group / f'{group}.dart').read_text()
    assert 'dart.library.io' in factory, group
    assert 'dart.library.js_interop' in factory, group
    assert "import 'dart:io'" not in factory, group
    assert "import 'package:web" not in factory, group

locale_io = (ROOT / 'lib/platform/locale/locale_io.dart').read_text()
locale_web = (ROOT / 'lib/platform/locale/locale_web.dart').read_text()
assert 'Platform.localeName' in locale_io
assert 'navigator.language' in locale_web
assert 'getApplicationDocumentsDirectory' in (
    ROOT / 'lib/platform/storage/storage_io.dart'
).read_text()
assert 'localStorage' in (
    ROOT / 'lib/platform/storage/storage_web.dart'
).read_text()
print(f'PASS: {len(required)} required files exist; common modules use no platform imports.')
print('PASS: 3 conditional adapter groups; LocalePort Windows and Web strategies.')
print('NOTE: This is a static source check; actual Flutter compilation needs CI or SDK.')
