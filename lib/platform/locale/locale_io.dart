import 'dart:io';

import '../../domain/ports/locale_port.dart';

LocalePort createLocalePort() => IoLocalePort();

class IoLocalePort implements LocalePort {
  @override
  String get localeName => Platform.localeName;
}
