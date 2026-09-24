import '../../domain/ports/locale_port.dart';
import 'locale_stub.dart'
    if (dart.library.io) 'locale_io.dart'
    if (dart.library.js_interop) 'locale_web.dart' as implementation;

LocalePort createLocalePort() => implementation.createLocalePort();
