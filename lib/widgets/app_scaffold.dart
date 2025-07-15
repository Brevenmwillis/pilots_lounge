import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.currentIndex,
    required this.child,
    super.key,
  });

  final int currentIndex;
  final Widget child;

  static const _routes = [
    ('Home', Icons.home, '/'),
    ('Rentals', Icons.flight, '/rentals'),
    ('Charters', Icons.airplane_ticket, '/charters'),
    ('Instructors', Icons.school, '/instructors'),
    ('For Sale', Icons.sell, '/airplanes-sale'),
    ('Schools', Icons.account_balance, '/flight-schools'),
    ('Mechanics', Icons.build, '/mechanics'),
    ('Airports', Icons.place, '/airports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          context.go(_routes[i].$3); // Go to selected route
        },
        height: 60,
        destinations: [
          for (final r in _routes)
            NavigationDestination(
              icon: Icon(r.$2, size: 20),
              label: r.$1,
            ),
        ],
      ),
    );
  }
}
