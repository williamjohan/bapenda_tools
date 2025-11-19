import 'package:flutter/material.dart';

class OnboardingContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const OnboardingContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(data["icon"], size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                Text(
                  data["title"],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data["subtitle"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
