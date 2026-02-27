import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  Color get _backgroundColor {
    switch (status) {
      case 'Confirmed':
        return AppTheme.successGreen.withValues(alpha: 0.15);
      case 'Pending':
        return AppTheme.warningAmber.withValues(alpha: 0.15);
      case 'Completed':
        return AppTheme.primaryBlue.withValues(alpha: 0.15);
      case 'Cancelled':
        return AppTheme.errorRed.withValues(alpha: 0.15);
      case 'Rescheduled':
        return AppTheme.infoCyan.withValues(alpha: 0.15);
      case 'Active':
        return AppTheme.successGreen.withValues(alpha: 0.15);
      case 'Inactive':
        return AppTheme.textLight.withValues(alpha: 0.15);
      case 'Paid':
        return AppTheme.successGreen.withValues(alpha: 0.15);
      case 'Overdue':
        return AppTheme.errorRed.withValues(alpha: 0.15);
      default:
        return AppTheme.textLight.withValues(alpha: 0.15);
    }
  }

  Color get _textColor {
    switch (status) {
      case 'Confirmed':
      case 'Active':
      case 'Paid':
        return AppTheme.successGreen;
      case 'Pending':
        return AppTheme.warningAmber;
      case 'Completed':
        return AppTheme.primaryBlue;
      case 'Cancelled':
      case 'Overdue':
        return AppTheme.errorRed;
      case 'Rescheduled':
        return AppTheme.infoCyan;
      case 'Inactive':
        return AppTheme.textLight;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
