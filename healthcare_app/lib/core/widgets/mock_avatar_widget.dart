import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MockAvatarWidget extends StatelessWidget {
  final String name;
  final double size;
  final Color? backgroundColor;

  const MockAvatarWidget({
    super.key,
    required this.name,
    this.size = 48,
    this.backgroundColor,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  Color get _color {
    if (backgroundColor != null) return backgroundColor!;
    final colors = [
      AppTheme.primaryBlue,
      AppTheme.successGreen,
      AppTheme.warningAmber,
      AppTheme.errorRed,
      AppTheme.infoCyan,
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF97316),
    ];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: _color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: _color,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
