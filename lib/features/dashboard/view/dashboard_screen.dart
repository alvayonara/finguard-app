import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import 'onboarding_dashboard.dart';
import 'active_dashboard.dart';

class DashboardScreen extends StatefulWidget {
  final String userUid;
  
  const DashboardScreen({super.key, required this.userUid});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<DashboardViewmodel>().loadDashboard(widget.userUid));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewmodel>();

    if (vm.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.error != null) {
      return Scaffold(
        body: Center(child: Text("Error: ${vm.error}")),
      );
    }

    final data = vm.dashboardData;

    if (data == null) {
      return const Scaffold(
        body: Center(child: Text("No data")),
      );
    }

    if (data.state == "ONBOARDING") {
      return OnboardingDashboard(data: data);
    }

    return ActiveDashboard(data: data);
  }
}