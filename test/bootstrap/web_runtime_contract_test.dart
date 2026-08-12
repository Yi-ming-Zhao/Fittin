import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('public Web runtime contract', () {
    test('nginx serves CanvasKit WebAssembly with an executable MIME type', () {
      final config = File(
        'deploy/nginx/fittin.hammerscholar.net.conf',
      ).readAsStringSync();

      final fingerprintedWasm = config.indexOf(
        'location ~* "[._-][0-9a-f]{8,}\\.wasm\$"',
      );
      final mutableWasm = config.indexOf('location ~* \\.wasm\$');
      final genericAssets = config.indexOf(
        'location ~* \\.(?:css|png|jpg|jpeg|gif|svg|ico|woff2?)\$',
      );

      expect(fingerprintedWasm, greaterThanOrEqualTo(0));
      expect(mutableWasm, greaterThan(fingerprintedWasm));
      expect(genericAssets, greaterThan(mutableWasm));
      expect('default_type application/wasm;'.allMatches(config), hasLength(2));
      expect(config, isNot(contains('(?:wasm|css|')));

      final deploymentScript = File(
        'tool/update_public_web.sh',
      ).readAsStringSync();
      expect(
        deploymentScript,
        contains(r"'^content-type: application/wasm\r?$'"),
      );
    });

    test('launch surface hands off or exposes bounded recovery', () {
      final index = File('web/index.html').readAsStringSync();

      expect(index, contains("'flutter-first-frame'"));
      expect(index, contains('finishStartup'));
      expect(index, contains("'unhandledrejection'"));
      expect(index, contains('window.setTimeout(revealStartupFailure, 30000)'));
      expect(index, contains('fittin-web-launch-status'));
      expect(index, contains('fittin-web-launch-retry'));
      expect(index, contains('window.location.reload()'));
      expect(index, contains('应用暂时无法启动，请检查网络后重试。'));
    });
  });
}
