import 'dart:io';

import 'package:flutter/material.dart';

Widget buildLocalPhotoImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  Widget? errorWidget,
}) {
  return Image.file(
    File(path),
    fit: fit,
    errorBuilder: (_, _, _) => errorWidget ?? const SizedBox.shrink(),
  );
}
