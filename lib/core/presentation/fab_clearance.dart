import 'package:flutter/material.dart';

/// Space to keep at the bottom of a scrolling list that has a floating action
/// button, so the last row can be scrolled clear of the button: the button
/// itself, its margin above and below, a little air, and the bottom inset.
double fabListBottomPadding(BuildContext context) {
  const fabHeight = 56.0;
  const air = 24.0;
  return fabHeight +
      2 * kFloatingActionButtonMargin +
      air +
      MediaQuery.paddingOf(context).bottom;
}
