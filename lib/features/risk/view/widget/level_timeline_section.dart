import 'package:flutter/material.dart';
import '../../data/model/risk_detail_response.dart';

class LevelTimelineSection extends StatelessWidget {
  final List<RiskLevelChange> changes;

  const LevelTimelineSection({super.key, required this.changes});

  @override
  Widget build(BuildContext context) {
    if (changes.isEmpty) {
      return const Text("No recent level changes");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: changes.map((change) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${change.oldLevel} → ${change.newLevel}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      change.occurredAt,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}