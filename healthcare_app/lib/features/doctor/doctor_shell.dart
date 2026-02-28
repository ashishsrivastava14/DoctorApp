import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/powered_by_footer.dart';

class DoctorShell extends StatelessWidget {
  final Widget child;
  const DoctorShell({super.key, required this.child});

  static final _items = [
    const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today_outlined),
        activeIcon: Icon(Icons.calendar_today),
        label: 'Appointments'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        activeIcon: Icon(Icons.people),
        label: 'Patients'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.schedule_outlined),
        activeIcon: Icon(Icons.schedule),
        label: 'Schedule'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile'),
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/doctor/appointments')) return 1;
    if (loc.startsWith('/doctor/patients')) return 2;
    if (loc.startsWith('/doctor/schedule')) return 3;
    if (loc.startsWith('/doctor/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    return AppBackground(child: Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PoweredByFooter(),
          BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/doctor/dashboard');
              break;
            case 1:
              context.go('/doctor/appointments');
              break;
            case 2:
              context.go('/doctor/patients');
              break;
            case 3:
              context.go('/doctor/schedule');
              break;
            case 4:
              context.go('/doctor/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey,
        items: _items,
      ),
        ],
      ),
    ));
  }
}
