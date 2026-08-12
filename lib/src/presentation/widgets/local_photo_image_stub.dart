import 'package:flutter/material.dart';

Widget buildLocalPhotoImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  Widget? errorWidget,
}) {
  return Image.network(
    path,
    fit: fit,
    errorBuilder: (_, _, _) => errorWidget ?? const SizedBox.shrink(),
  );
}
