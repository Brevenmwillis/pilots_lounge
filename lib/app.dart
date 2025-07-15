
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_page.dart';
import 'features/rentals/rentals_page.dart';
import 'features/charters/charters_page.dart';
import 'features/instructors/instructors_page.dart';
import 'features/airplanes_sale/airplanes_sale_page.dart';
import 'features/flight_schools/flight_schools_page.dart';
import 'features/mechanics/mechanics_page.dart';
import 'features/airports/airports_page.dart';
import 'features/home/profile_page.dart';
import 'features/home/create_listing_page.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/rentals', builder: (_, __) => const RentalsPage()),
    GoRoute(path: '/charters', builder: (_, __) => const ChartersPage()),
    GoRoute(path: '/instructors', builder: (_, __) => const InstructorsPage()),
    GoRoute(path: '/airplanes-sale', builder: (_, __) => const AirplanesSalePage()),
    GoRoute(path: '/flight-schools', builder: (_, __) => const FlightSchoolsPage()),
    GoRoute(path: '/mechanics', builder: (_, __) => const MechanicsPage()),
    GoRoute(path: '/airports', builder: (_, __) => const AirportsPage()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
    GoRoute(path: '/create-listing', builder: (_, __) => const CreateListingPage()),
  ],
);

class PilotsLoungeApp extends StatelessWidget {
  const PilotsLoungeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pilots Lounge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
      ),
      routerConfig: _router,
    );
  }
}
