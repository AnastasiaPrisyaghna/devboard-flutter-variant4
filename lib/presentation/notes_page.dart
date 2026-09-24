import 'package:flutter/material.dart';

import '../data/note_repository.dart';
import '../domain/note.dart';
import '../domain/ports/env_info.dart';
import '../domain/ports/locale_port.dart';

class DevBoardApp extends StatelessWidget {
  const DevBoardApp({
    super.key,
    required this.repository,
    required this.environment,
    required this.locale,
  });

  final NoteRepository repository;
  final EnvInfo environment;
  final LocalePort locale;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DevBoard',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3158A6)),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        ),
        home: NotesPage(
          repository: repository,
          environment: environment,
          locale: locale,
        ),
      );
}

class NotesPage extends StatefulWidget {
  const NotesPage({
    super.key,
    required this.repository,
    required this.environment,
    required this.locale,
  });

  final NoteRepository repository;
  final EnvInfo environment;
  final LocalePort locale;

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _input = TextEditingController();
  List<Note> _notes = <Note>[];
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final notes = await widget.repository.getAll();
      if (!mounted) return;
      setState(() {
        _notes = notes;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Не вдалося прочитати нотатки: $error';
        _loading = false;
      });
    }
  }

  Future<void> _add() async {
    if (_busy || _input.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await widget.repository.add(_input.text);
      final notes = await widget.repository.getAll();
      if (!mounted) return;
      _input.clear();
      setState(() => _notes = notes);
    } catch (error) {
      _showError('Не вдалося зберегти нотатку: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(String id) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.repository.remove(id);
      final notes = await widget.repository.getAll();
      if (!mounted) return;
      setState(() => _notes = notes);
    } catch (error) {
      _showError('Не вдалося видалити нотатку: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _date(DateTime input) {
    final value = input.toLocal();
    String pad(int number) => number.toString().padLeft(2, '0');
    return '${pad(value.day)}.${pad(value.month)}.${value.year} '
        '${pad(value.hour)}:${pad(value.minute)}';
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('DevBoard · журнал нотаток'),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Середовище виконання',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          SelectableText('Платформа: ${widget.environment.platformName}'),
                          SelectableText('Сховище: ${widget.environment.storageLocation}'),
                          SelectableText('Мова системи / браузера: ${widget.locale.localeName}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _input,
                          maxLength: 300,
                          maxLines: 1,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Текст нової нотатки',
                            counterText: '',
                          ),
                          onSubmitted: (_) => _add(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _busy ? null : _add,
                        icon: const Icon(Icons.add),
                        label: const Text('Додати'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Text(_error!))
                            : _notes.isEmpty
                                ? const Center(child: Text('Нотаток ще немає.'))
                                : ListView.builder(
                                    itemCount: _notes.length,
                                    itemBuilder: (context, index) {
                                      final note = _notes[index];
                                      return Card(
                                        child: ListTile(
                                          title: Text(note.text),
                                          subtitle: Text(_date(note.createdAt)),
                                          trailing: IconButton(
                                            tooltip: 'Видалити',
                                            onPressed: _busy
                                                ? null
                                                : () => _remove(note.id),
                                            icon: const Icon(Icons.delete_outline),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
