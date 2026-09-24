import 'package:web/web.dart' as web;

import '../../domain/ports/env_info.dart';

EnvInfo createEnvInfo() => WebEnvInfo();

class WebEnvInfo implements EnvInfo {
  @override
  String get platformName => 'Web / ${web.window.navigator.userAgent}';

  @override
  String get storageLocation =>
      'localStorage браузера; ключ devboard_notes';
}
