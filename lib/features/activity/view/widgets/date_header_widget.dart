import 'package:finguard_app/features/activity/data/model/activity_item.dart';
import 'package:flutter/material.dart';

class DateHeaderWidget extends StatelessWidget {
  final ActivityDateHeader header;

  const DateHeaderWidget({
    super.key,
    required this.header,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        header.label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }
}
