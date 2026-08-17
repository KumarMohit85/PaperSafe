import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Common page transition used throughout the app.
class PageTransitions {
  static Route<T> fadeScale<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeOut;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final fadeAnimation = animation.drive(tween);
        final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: curve))
            .animate(animation);
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
    );
  }

  static Route<T> slideFromRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final offsetAnimation = animation.drive(
          Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOut)),
        );
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
