import 'package:finguard/features/activity/data/model/insight_card.dart';
import 'package:finguard/core/utils/insight_resolver.dart';
import 'package:flutter/material.dart';

class InsightCardWidget extends StatelessWidget {
  final InsightCard insight;

  const InsightCardWidget({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor();
    final resolvedMessage = InsightResolver.resolveInsight(
      context,
      insight.message,
      riskLevel: insight.insightType,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: severityColor.withOpacity(0.25), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: severityColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Insight',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  resolvedMessage,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor() {
    switch (insight.insightType) {
      case 'HIGH':
        return const Color(0xFFFF5F6D);
      case 'MEDIUM':
        return const Color(0xFFFFB347);
      case 'LOW':
        return const Color(0xFF56AB2F);
      default:
        return Colors.grey;
    }
  }
}
