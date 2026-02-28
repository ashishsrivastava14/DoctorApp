import 'package:flutter/material.dart';

/// A compact branding footer showing "Powered" with the QuickPrepAI logo.
/// Use at the bottom of every page/shell for consistent branding.
class PoweredByFooter extends StatelessWidget {
  const PoweredByFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Powered by ',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
          Image.asset(
            'assets/images/QuickPrepAI.png',
            height: 18,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
