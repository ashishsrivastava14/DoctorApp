import 'package:flutter/material.dart';

/// A reusable widget that wraps its child with the app background image.
/// Use this around a [Scaffold] (with [Scaffold.backgroundColor] set to
/// [Colors.transparent]) so the background shows through.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          opacity: 0.95,
        ),
      ),
      child: child,
    );
  }
}
