import 'package:finguard/core/ui/app_colors.dart';
import 'package:finguard/core/utils/insight_resolver.dart';
import 'package:finguard/features/risk/data/model/risk_detail_response.dart';
import 'package:finguard/features/risk/data/model/risk_insight.dart';
import 'package:finguard/features/risk/viewmodel/risk_detail_viewmodel.dart';
import 'package:finguard/features/risk/view/widget/risk_trend_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
        backgroundColor: AppColors.background,
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
                  if (data.recommendationKey.isNotEmpty)
                    _buildRecommendation(context, data.recommendationKey),
                  if (data.recommendationKey.isNotEmpty)
                    const SizedBox(height: 28),
                  _buildRiskTrend(vm),
                  const SizedBox(height: 28),
                  if (vm.insights.isNotEmpty) _buildInsights(vm.insights),
                  if (vm.insights.isNotEmpty) const SizedBox(height: 28),
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
                  InsightResolver.resolveInsight(
                    context,
                    data.topInsightKey,
                    riskLevel: data.currentLevel,
                  ),
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

  Widget _buildRecommendation(BuildContext context, String recommendationKey) {
    final recommendation = InsightResolver.resolveRecommendation(
      context,
      recommendationKey,
    );

    if (recommendation.isEmpty) return const SizedBox.shrink();

    return _card(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Recommendation",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskTrend(RiskDetailViewmodel vm) {
    return RiskTrendCard(
      data: vm.trendData,
      isLoading: false,
      selectedDays: 7,
      onRangeChanged: (days) {},
      trendDirection: vm.getTrendDirection(),
    );
  }

  Widget _buildInsights(List<RiskInsight> insights) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Insights & Alerts",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => _insightItem(insight)),
        ],
      ),
    );
  }

  Widget _insightItem(RiskInsight insight) {
    Color severityColor = Colors.grey;
    IconData severityIcon = Icons.info_outline;

    if (insight.severity == "HIGH") {
      severityColor = Colors.red;
      severityIcon = Icons.warning;
    } else if (insight.severity == "MEDIUM") {
      severityColor = Colors.orange;
      severityIcon = Icons.error_outline;
    } else if (insight.severity == "LOW") {
      severityColor = Colors.green;
      severityIcon = Icons.check_circle_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: severityColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(severityIcon, color: severityColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  InsightResolver.resolveInsight(
                    context,
                    insight.message.isNotEmpty ? insight.message : insight.type,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(insight.detectedAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          if (data.activeSignalSummaries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "No active signals",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ...data.activeSignalSummaries.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _severityDot(s.severity),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatSignalType(s.signalType),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Last detected: ${_formatTimestamp(s.lastDetectedAt)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _severityColor(s.severity).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${s.occurrences}x",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _severityColor(s.severity),
                          fontSize: 13,
                        ),
                      ),
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
          if (data.recentLevelChanges.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "No level changes yet",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ...data.recentLevelChanges.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.timeline, color: Colors.grey.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _levelBadge(e.oldLevel),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              _levelBadge(e.newLevel),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimestamp(e.occurredAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _levelBadge(String level) {
    Color color = Colors.grey;
    if (level == "HIGH") color = Colors.red;
    if (level == "MEDIUM") color = Colors.orange;
    if (level == "LOW") color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _severityColor(String severity) {
    if (severity == "HIGH") return Colors.red;
    if (severity == "MEDIUM") return Colors.orange;
    if (severity == "LOW") return Colors.green;
    return Colors.grey;
  }

  String _formatSignalType(String signalType) {
    return signalType
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inDays > 7) {
        return DateFormat('MMM dd, yyyy').format(dt);
      } else if (diff.inDays > 0) {
        return '${diff.inDays}d ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return timestamp;
    }
  }

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
