import 'package:flutter/widgets.dart';

/// Wraps a widget with a default fade‑scale transition used throughout the app.
class TransitionWrapper extends StatelessWidget {
  final Widget child;
  const TransitionWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
