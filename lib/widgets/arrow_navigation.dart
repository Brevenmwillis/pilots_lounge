import 'package:flutter/material.dart';

class ArrowNavigation extends StatelessWidget {
  final String title;
  final int itemCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool showArrows;

  const ArrowNavigation({
    super.key,
    required this.title,
    required this.itemCount,
    this.onPrevious,
    this.onNext,
    this.showArrows = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            _getIconForTitle(title),
            color: _getColorForTitle(title),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title ($itemCount)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (showArrows && itemCount > 1) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: onPrevious,
              tooltip: 'Previous $title',
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 20),
              onPressed: onNext,
              tooltip: 'Next $title',
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'airports':
        return Icons.place;
      case 'aircraft':
      case 'rentals':
      case 'charters':
      case 'airplanes':
        return Icons.flight;
      case 'instructors':
      case 'cfis':
        return Icons.school;
      case 'mechanics':
        return Icons.build;
      case 'flight schools':
        return Icons.account_balance;
      case 'students':
        return Icons.person;
      default:
        return Icons.list;
    }
  }

  Color _getColorForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'airports':
        return Colors.indigo;
      case 'aircraft':
      case 'rentals':
      case 'charters':
      case 'airplanes':
        return Colors.blue;
      case 'instructors':
      case 'cfis':
        return Colors.orange;
      case 'mechanics':
        return Colors.red;
      case 'flight schools':
        return Colors.teal;
      case 'students':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 