import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// The caller owns the explicit privacy confirmation. Desktop/Web save a file;
/// phones open the system sheet, where the user chooses a recipient or Files.
Future<void> exportPrivateGpx(Uint8List bytes, String name, Rect origin) async {
  final file = XFile.fromData(
    bytes,
    mimeType: 'application/gpx+xml',
    name: name,
  );
  if (!kIsWeb &&
      {
        TargetPlatform.android,
        TargetPlatform.iOS,
      }.contains(defaultTargetPlatform)) {
    await Share.shareXFiles(
      [file],
      fileNameOverrides: [name],
      sharePositionOrigin: origin,
    );
    return;
  }
  final destination = await getSaveLocation(
    suggestedName: name,
    acceptedTypeGroups: const [
      XTypeGroup(label: 'GPX', extensions: ['gpx']),
    ],
  );
  if (destination == null) return;
  await file.saveTo(destination.path);
}
