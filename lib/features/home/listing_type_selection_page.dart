import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';

class ListingTypeSelectionPage extends StatelessWidget {
  const ListingTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What type of listing would you like to create?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose the category that best describes your listing',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _ListingTypeCard(
                    title: 'Aircraft Rental',
                    subtitle: 'Rent out your aircraft',
                    icon: Icons.airplanemode_active,
                    color: Colors.blue,
                    onTap: () => context.go('/create-listing/rental'),
                  ),
                  _ListingTypeCard(
                    title: 'Charter Service',
                    subtitle: 'Offer charter flights',
                    icon: Icons.flight_takeoff,
                    color: Colors.green,
                    onTap: () => context.go('/create-listing/charter'),
                  ),
                  _ListingTypeCard(
                    title: 'Instructor',
                    subtitle: 'Offer flight instruction',
                    icon: Icons.school,
                    color: Colors.orange,
                    onTap: () => context.go('/create-listing/instructor'),
                  ),
                  _ListingTypeCard(
                    title: 'Mechanic',
                    subtitle: 'Offer maintenance services',
                    icon: Icons.build,
                    color: Colors.purple,
                    onTap: () => context.go('/create-listing/mechanic'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ListingTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 