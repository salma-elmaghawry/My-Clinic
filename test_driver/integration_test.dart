import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Saves every screenshot the demo tour takes to docs/screenshots/.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('docs/screenshots/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
