import 'package:finguard_app/core/storage/local_storage.dart';
import 'package:finguard_app/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:finguard_app/features/risk/viewmodel/risk_trend_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _showOnboarding = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final storage = LocalStorage();
    final completed = await storage.isOnboardingCompleted();

    if (mounted) {
      setState(() {
        _showOnboarding = !completed;
        _checking = false;
      });
    }

    if (completed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    await context.read<DashboardViewmodel>().loadDashboard();
    await context.read<RiskTrendViewmodel>().load();
  }

  Future<void> _completeOnboarding() async {
    await LocalStorage().markOnboardingCompleted();

    if (mounted) {
      setState(() {
        _showOnboarding = false;
      });
    }

    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const DashboardShimmer();
    }

    if (_showOnboarding) {
      return OnboardingFlowScreen();
    }

    final vm = context.watch<DashboardViewmodel>();

    if (vm.isLoading) {
      return const DashboardShimmer();
    }

    if (vm.error != null) {
      return Scaffold(
        body: Center(child: Text(vm.error!)),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ActiveDashboard(data: vm.dashboardData!),
          ),
        ),
      ),
    );
  }
}