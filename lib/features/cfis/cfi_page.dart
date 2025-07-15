import 'package:flutter/material.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';

class CfiPage extends StatelessWidget {
  const CfiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 2,
      child: Center(
        child: Text('Certified Flight Instructors (CFIs)'),
      ),
    );
  }
}
