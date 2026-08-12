import 'package:flutter_riverpod/flutter_riverpod.dart';

final appShellTabIndexProvider = StateProvider.autoDispose<int>((ref) => 0);
