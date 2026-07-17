import 'dart:async';

import 'package:fittin_v2/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'initial preferences cannot hold the first Flutter frame indefinitely',
    () async {
      final pendingPreferences = Completer<SharedPreferences>();

      final preferences = await app.loadInitialPreferences(
        loader: () => pendingPreferences.future,
        timeout: const Duration(milliseconds: 10),
      );

      expect(preferences, isNull);
    },
  );

  test('initial preferences remain available on the fast path', () async {
    SharedPreferences.setMockInitialValues({'launch-palette': 'saved'});

    final preferences = await app.loadInitialPreferences();

    expect(preferences, isNotNull);
    expect(preferences!.getString('launch-palette'), 'saved');
  });
}
