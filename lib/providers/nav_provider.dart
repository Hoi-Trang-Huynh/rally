import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage the selected bottom navigation tab index.
final StateProvider<int> navIndexProvider = StateProvider<int>((Ref ref) => 0);
