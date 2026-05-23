import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared tab index for the bottom NavigationBar in MainShell.
/// Allows other screens (like Home) to switch tabs programmatically.
final mainShellTabIndexProvider = StateProvider<int>((ref) => 0);
