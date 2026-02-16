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
    if (mounted) {
      await context.read<DashboardViewmodel>().loadDashboard();
      await context.read<RiskTrendViewmodel>().load();
    }
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

  void _showErrorBottomSheet(BuildContext context, String errorMessage) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 32,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Connection Error",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Unable to load dashboard data. Please check your connection and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E5CE6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Retry",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorBottomSheet(context, vm.error!);
      });
      return const DashboardShimmer();
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
