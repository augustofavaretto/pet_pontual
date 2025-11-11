import 'package:flutter/material.dart';

/// Central place for every color used in the app so we can tweak the palette
/// without hunting through screens.
class AppColors {
  const AppColors._();

  /// Base seed used to derive the Material color scheme.
  static const Color primarySeed = Color(0xFF0EA5A7);

  /// Neutral tone for empty states and subdued icons.
  static const Color emptyStateIcon = Color(0xFF9E9E9E);

  /// Builds the color scheme so the same seed drives every surface.
  static ColorScheme colorScheme([Brightness brightness = Brightness.light]) {
    return ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: brightness,
    );
  }
}
