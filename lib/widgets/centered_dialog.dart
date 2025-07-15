import 'package:flutter/material.dart';

class CenteredDialog extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final double? maxHeight;

  const CenteredDialog({
    required this.child,
    this.maxWidth,
    this.maxHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: maxHeight ?? 600,
          maxWidth: maxWidth ?? 400,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  static void show({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
    double? maxHeight,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CenteredDialog(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }
} 
