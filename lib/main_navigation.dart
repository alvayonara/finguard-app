import 'dart:ui';
import 'package:alice/alice.dart';
import 'package:finguard_app/core/storage/local_storage.dart';
import 'package:finguard_app/features/activity/viewmodel/activity_viewmodel.dart';
import 'package:finguard_app/features/budget/view/budget_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finguard_app/features/activity/view/activity_screen.dart';
import 'package:finguard_app/features/dashboard/view/dashboard_screen.dart';
import 'package:finguard_app/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:finguard_app/features/risk/viewmodel/risk_trend_viewmodel.dart';
import 'package:provider/provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _index = 0;
  bool _isCoachmarkVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowFirstLoginCoachmark();
    });
  }

  Future<void> _maybeShowFirstLoginCoachmark() async {
    final storage = context.read<LocalStorage>();
    final shouldShow = await storage.consumeFirstLoginCoachmarkPending();
    if (!shouldShow || !mounted) return;

    setState(() => _isCoachmarkVisible = true);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildCoachmarkCard(dialogContext),
        );
      },
    );

    if (mounted) {
      setState(() => _isCoachmarkVisible = false);
    }
  }

  Widget _buildCoachmarkCard(BuildContext dialogContext) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Quick tip",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tap the + button to add your first transaction.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Got it"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileScreen() {
    final alice = context.read<Alice>();
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profile Screen'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => alice.showInspector(),
              icon: const Icon(Icons.bug_report),
              label: const Text('API Inspector'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> get _screens => [
    const DashboardScreen(),
    const ActivityScreen(),
    const BudgetScreen(),
    _buildProfileScreen(),
  ];

  static const Color primaryColor = Color(0xFF5E5CE6);
  static const Color backgroundColor = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      body: _screens[_index],
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildGlassBottomBar(),
    );
  }

  Widget _buildGlassBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        height: 74,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  _navItem(Icons.home_rounded, "Home", 0),
                  _navItem(Icons.receipt_long_rounded, "Activity", 1),
                  const SizedBox(width: 72),
                  _navItem(Icons.account_balance_wallet_rounded, "Budget", 2),
                  _navItem(Icons.person_rounded, "Profile", 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        final created = await Navigator.pushNamed(
          context,
          '/create-transaction',
        );
        if (created == true && mounted) {
          await _refreshAfterTransactionMutation();
        }
      },
      child: Container(
        height: 66,
        width: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF7A78EE), Color(0xFF5E5CE6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: _isCoachmarkVisible
              ? Border.all(color: Colors.white, width: 4)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool isActive = _index == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _index = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? primaryColor : Colors.grey.shade500,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? primaryColor : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshAfterTransactionMutation() async {
    final dashboardVM = context.read<DashboardViewmodel>();
    final previousLastDetectedAt =
        dashboardVM.dashboardData?.financialHealth?.lastDetectedAt;
    final mutationTriggeredAt = DateTime.now();

    await Future.wait([
      dashboardVM.refreshFinancialHealthWithPolling(
        previousLastDetectedAt: previousLastDetectedAt,
        mutationTriggeredAt: mutationTriggeredAt,
      ),
      context.read<RiskTrendViewmodel>().load(),
      context.read<ActivityViewmodel>().loadActivities(refresh: true),
    ]);
  }
}
