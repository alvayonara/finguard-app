import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finguard_app/features/dashboard/view/dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _index = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    Placeholder(),
    Placeholder(),
    Placeholder(),
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
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.pushNamed(context, '/create-transaction');
      },
      child: Container(
        height: 66,
        width: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF7B7CFF), Color(0xFF5E5CE6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5E5CE6).withOpacity(0.45),
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
}
