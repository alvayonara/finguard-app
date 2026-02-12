import 'package:finguard_app/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dashboard_shimmer.dart';
import 'onboarding_dashboard.dart';
import 'active_dashboard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DashboardViewmodel>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewmodel>();
    if (vm.isLoading) {
      return const DashboardShimmer();
    }

    if (vm.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Something went wrong",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  vm.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => vm.loadDashboard(),
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final data = vm.dashboardData;
    if (data == null) {
      return const Scaffold(body: Center(child: Text("No data available")));
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => vm.loadDashboard(),
          child: data.state == "ONBOARDING"
              ? OnboardingDashboard(data: data)
              : ActiveDashboard(data: data),
        ),
      ),
    );
  }
}
