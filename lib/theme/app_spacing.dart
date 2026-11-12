import 'package:flutter/widgets.dart';

// Basic spacing used across the app screens.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pageH = 20;

  // Side padding that scales a bit on small phones and tablets.
  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 14;
    if (width >= 600) return 28;
    return pageH;
  }

  // Max content width so tablets do not stretch text too wide.
  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) return 720;
    if (width >= 600) return 560;
    return width;
  }
}

abstract final class AppRadius {
  // Soft corners for inputs and small UI bits.
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  // Full pill shape for all buttons (radius 100).
  static const double pill = 100;
}
