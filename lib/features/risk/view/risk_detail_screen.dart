import 'package:finguard_app/core/utils/insight_resolver.dart';
import 'package:finguard_app/features/risk/data/model/risk_detail_response.dart';
import 'package:finguard_app/features/risk/viewmodel/risk_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RiskDetailScreen extends StatefulWidget {
  const RiskDetailScreen({super.key});

  @override
  State<RiskDetailScreen> createState() => _RiskDetailScreenState();
}

class _RiskDetailScreenState extends State<RiskDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<RiskDetailViewmodel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RiskDetailViewmodel>();

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.data == null) {
      return const Scaffold(body: Center(child: Text("No Risk Data")));
    }
    final data = vm.data!;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // white icons
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            /// Full width gradient behind status bar
            Container(
              height: 320,
              decoration: BoxDecoration(gradient: _gradient(data.currentLevel)),
            ),

            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                children: [
                  _buildPremiumHeader(context, data),
                  const SizedBox(height: 28),
                  _buildSeverityBreakdown(data),
                  const SizedBox(height: 28),
                  _buildActiveSignalSummaries(data),
                  const SizedBox(height: 28),
                  _buildHistoryTimeline(data),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // PREMIUM HEADER
  // =========================================================

  Widget _buildPremiumHeader(BuildContext context, RiskDetailResponse data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _gradient(data.currentLevel),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          _scoreRing(data.score),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Risk Overview",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  data.currentLevel,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  InsightResolver.resolveInsight(context, data.topInsightKey),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 6),
                if (data.lastDetectedAt != null)
                  Text(
                    "Last detected ${data.lastDetectedAt}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreRing(int score) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// Background subtle ring
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 6,
              ),
            ),
          ),

          /// Progress ring
          SizedBox(
            width: 110,
            height: 110,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 6,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),

          /// Inner spacing circle (gives breathing space)
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),

          /// Score text
          Text(
            "$score",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SEVERITY BREAKDOWN (FROM SUMMARIES)
  // =========================================================

  Widget _buildSeverityBreakdown(RiskDetailResponse data) {
    int high = 0;
    int medium = 0;
    int low = 0;

    for (var s in data.activeSignalSummaries) {
      if (s.severity == "HIGH") high += s.occurrences;
      if (s.severity == "MEDIUM") medium += s.occurrences;
      if (s.severity == "LOW") low += s.occurrences;
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Severity Breakdown",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _severityRow("HIGH", high, Colors.red),
          _severityRow("MEDIUM", medium, Colors.orange),
          _severityRow("LOW", low, Colors.green),
        ],
      ),
    );
  }

  Widget _severityRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              "$count",
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ACTIVE SIGNAL SUMMARIES (GROUPED)
  // =========================================================

  Widget _buildActiveSignalSummaries(RiskDetailResponse data) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Active Signals",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...data.activeSignalSummaries.map(
            (s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  _severityDot(s.severity),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.signalType,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    "${s.occurrences}x",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _severityDot(String severity) {
    Color color = Colors.grey;
    if (severity == "HIGH") color = Colors.red;
    if (severity == "MEDIUM") color = Colors.orange;
    if (severity == "LOW") color = Colors.green;

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // =========================================================
  // LEVEL HISTORY
  // =========================================================

  Widget _buildHistoryTimeline(RiskDetailResponse data) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Level History",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...data.recentLevelChanges.map(
            (e) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.timeline),
              title: Text("${e.oldLevel} → ${e.newLevel}"),
              subtitle: Text(e.occurredAt),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  LinearGradient _gradient(String level) {
    switch (level) {
      case "HIGH":
        return const LinearGradient(
          colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
        );
      case "MEDIUM":
        return const LinearGradient(
          colors: [Color(0xFFFFB347), Color(0xFFFFCC33)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
        );
    }
  }
}
