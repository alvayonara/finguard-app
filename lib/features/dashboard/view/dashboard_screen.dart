import 'package:finguard_app/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:finguard_app/features/risk/viewmodel/risk_trend_viewmodel.dart';
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
      context.read<RiskTrendViewmodel>().load();
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
          child: Text(vm.error!),
        ),
      );
    }

    final data = vm.dashboardData;

    if (data == null) {
      return const Scaffold(
        body: Center(child: Text("No data available")),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await vm.loadDashboard();
            await context.read<RiskTrendViewmodel>().load();
          },
          child: data.state == "ONBOARDING"
              ? OnboardingDashboard(data: data)
              : ActiveDashboard(data: data),
        ),
      ),
    );
  }
}