import 'package:flutter/material.dart';
import '../data/model/dashboard_response.dart';

class OnboardingDashboard extends StatelessWidget {
  final DashboardResponse data;

  const OnboardingDashboard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("FinGuard")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet, size: 80),
              const SizedBox(height: 24),
              Text(
                "Welcome to FinGuard!",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                "Start by connecting your account to get personalized financial insights.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Connect Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
