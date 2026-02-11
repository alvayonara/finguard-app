import 'package:flutter/material.dart';
import '../data/model/dashboard_response.dart';

class OnboardingDashboard extends StatelessWidget {
  final DashboardResponse data;

  const OnboardingDashboard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.auto_graph, size: 80, color: Colors.blueAccent),
        const SizedBox(height: 24),
        const Text(
          "Start Tracking Your Finances",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          "Add a few transactions to activate financial health analysis.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {},
          child: const Text("Add First Transaction"),
        ),
      ],
    );
  }
}
