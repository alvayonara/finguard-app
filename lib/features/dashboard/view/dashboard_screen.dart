import 'package:finguard/core/storage/local_storage.dart';
import 'package:finguard/core/ui/app_colors.dart';
import 'package:alice/alice.dart';
import 'package:finguard/features/auth/view/login_screen.dart';
import 'package:finguard/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:finguard/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:finguard/features/risk/viewmodel/risk_trend_viewmodel.dart';
import 'package:flutter/foundation.dart';
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
  bool _goToIncomeSetup = false;
  bool _showLoggedOutLogin = false;
  int _onboardingStep = 0;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final storage = LocalStorage();
    final completed = await storage.isOnboardingCompleted();
    final pendingStep = await storage.getPendingOnboardingStep();
    final wasLoggedOut = await storage.wasLoggedOut();
    final accessToken = await storage.getAccessToken();
    final refreshToken = await storage.getRefreshToken();
    final userUid = await storage.getUserUid();
    final hasSession = accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty &&
        userUid != null &&
        userUid.isNotEmpty;

    if (mounted) {
      setState(() {
        _showOnboarding = !completed;
        _goToIncomeSetup = hasSession && !completed;
        _showLoggedOutLogin = wasLoggedOut && !hasSession && !completed;
        _onboardingStep = pendingStep ?? 0;
        _checking = false;
      });
    }

    if (completed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final dashboardVM = context.read<DashboardViewmodel>();
    final riskVM = context.read<RiskTrendViewmodel>();
    final authVM = context.read<AuthViewmodel>();

    await Future.wait([
      dashboardVM.loadDashboard(),
      authVM.syncPreferences(),
    ]);

    if (!mounted) return;
    await riskVM.load();
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _loadData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
                if (kDebugMode) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      try {
                        final alice = context.read<Alice>();
                        alice.showInspector();
                      } catch (_) {}
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Inspect'),
                  ),
                ],
              ],
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => _goToIncomeSetup
                ? const OnboardingFlowScreen(initialStep: 2, allowBack: false)
                : _showLoggedOutLogin
                    ? const LoginScreen()
                    : OnboardingFlowScreen(initialStep: _onboardingStep),
          ),
        );
      });

      return const DashboardShimmer();
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
