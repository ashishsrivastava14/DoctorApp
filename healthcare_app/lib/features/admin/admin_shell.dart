import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/admin/doctors')) return 1;
    if (loc.startsWith('/admin/patients')) return 2;
    if (loc.startsWith('/admin/appointments')) return 3;
    if (loc.startsWith('/admin/more') ||
        loc.startsWith('/admin/departments') ||
        loc.startsWith('/admin/staff') ||
        loc.startsWith('/admin/billing') ||
        loc.startsWith('/admin/reports') ||
        loc.startsWith('/admin/settings') ||
        loc.startsWith('/admin/profile')) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final idx = _currentIndex(context);

    // Responsive: NavigationRail for wide screens, BottomNav for narrow
    if (width >= 768) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: idx,
              onDestinationSelected: (i) => _navigate(context, i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_hospital,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text('Admin',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('Dashboard')),
                NavigationRailDestination(
                    icon: Icon(Icons.medical_services_outlined),
                    selectedIcon: Icon(Icons.medical_services),
                    label: Text('Doctors')),
                NavigationRailDestination(
                    icon: Icon(Icons.people_outline),
                    selectedIcon: Icon(Icons.people),
                    label: Text('Patients')),
                NavigationRailDestination(
                    icon: Icon(Icons.calendar_today_outlined),
                    selectedIcon: Icon(Icons.calendar_today),
                    label: Text('Appointments')),
                NavigationRailDestination(
                    icon: Icon(Icons.more_horiz),
                    selectedIcon: Icon(Icons.more_horiz),
                    label: Text('More')),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => _navigate(context, i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_outlined),
              activeIcon: Icon(Icons.medical_services),
              label: 'Doctors'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Patients'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Appointments'),
          BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              activeIcon: Icon(Icons.more_horiz),
              label: 'More'),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go('/admin/dashboard');
        break;
      case 1:
        context.go('/admin/doctors');
        break;
      case 2:
        context.go('/admin/patients');
        break;
      case 3:
        context.go('/admin/appointments');
        break;
      case 4:
        context.go('/admin/more');
        break;
    }
  }
}
