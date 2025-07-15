import 'package:flutter/material.dart';
import 'package:pilots_lounge/models/flight_school.dart';
// ← package name changed

class FlightSchoolCard extends StatelessWidget {
  final FlightSchool school;
  const FlightSchoolCard({required this.school, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        width: 240,
        constraints: const BoxConstraints(maxHeight: 100),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(school.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 2),
            Text('\$${school.price}/year', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Colors.amber),
                Text('${school.rating}', style: const TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

