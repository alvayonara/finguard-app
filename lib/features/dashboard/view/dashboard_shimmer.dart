import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(height: 160, decoration: _box()),
            const SizedBox(height: 16),
            Container(height: 100, decoration: _box()),
            const SizedBox(height: 16),
            Container(height: 80, decoration: _box()),
            const SizedBox(height: 8),
            Container(height: 80, decoration: _box()),
          ],
        ),
      ),
    );
  }

  BoxDecoration _box() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
  );
}
