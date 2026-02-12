import 'package:flutter/material.dart';
import '../../data/model/risk_detail_response.dart';

class SignalSummaryCard extends StatelessWidget {
  final RiskSignalSummary signal;

  const SignalSummaryCard({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;

    switch (signal.severity) {
      case "HIGH":
        badgeColor = Colors.red;
        break;
      case "MEDIUM":
        badgeColor = Colors.orange;
        break;
      default:
        badgeColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              signal.severity,
              style: TextStyle(
                color: badgeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signal.signalType,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "Detected ${signal.occurrences} times",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}