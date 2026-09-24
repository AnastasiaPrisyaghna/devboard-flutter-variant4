import 'package:web/web.dart' as web;

import '../../domain/ports/locale_port.dart';

LocalePort createLocalePort() => WebLocalePort();

class WebLocalePort implements LocalePort {
  @override
  String get localeName => web.window.navigator.language;
}
