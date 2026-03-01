import 'package:finguard/core/ui/app_colors.dart';
import 'package:finguard/features/risk/data/model/risk_trend_item.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RiskTrendCard extends StatelessWidget {
  final List<RiskTrendItem> data;
  final bool isLoading;
  final int selectedDays;
  final Function(int) onRangeChanged;
  final String trendDirection;

  const RiskTrendCard({
    super.key,
    required this.data,
    required this.isLoading,
    required this.selectedDays,
    required this.onRangeChanged,
    required this.trendDirection,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildShimmer();

    final chartData = _safeData(data);
    final isEmpty = data.isEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Risk Trend",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              isEmpty ? const SizedBox.shrink() : _trendIcon(),
            ],
          ),
          const SizedBox(height: 12),

          /// Range Selector
          Row(
            children: [
              _rangeButton(7),
              const SizedBox(width: 8),
              _rangeButton(30),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: isEmpty
                ? _buildEmptyChart()
                : LineChart(_buildChart(chartData)),
          ),
        ],
      ),
    );
  }

  Widget _rangeButton(int days) {
    final selected = selectedDays == days;

    return GestureDetector(
      onTap: () => onRangeChanged(days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "${days}D",
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _trendIcon() {
    switch (trendDirection) {
      case "UP":
        return const Icon(Icons.trending_up, color: Colors.red);
      case "DOWN":
        return const Icon(Icons.trending_down, color: Colors.green);
      default:
        return const Icon(Icons.trending_flat, color: Colors.grey);
    }
  }

  LineChartData _buildChart(List<RiskTrendItem> data) {
    final minScore = data.map((e) => e.score).reduce((a, b) => a < b ? a : b);

    final maxScore = data.map((e) => e.score).reduce((a, b) => a > b ? a : b);

    final minY = (minScore - 5).clamp(0, 100).toDouble();
    final maxY = (maxScore + 5).clamp(0, 100).toDouble();

    final interval =
        ((data.length / 4).floor() <= 0 ? 1 : (data.length / 4).floor())
            .toDouble();

    return LineChartData(
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(show: true, drawVerticalLine: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: interval,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= data.length) {
                return const SizedBox();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  data[index].date.substring(5), // MM-DD
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) {
            return spots.map((spot) {
              final item = data[spot.x.toInt()];
              return LineTooltipItem(
                "${item.date}\nScore: ${item.score}",
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: data.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.score.toDouble());
          }).toList(),
          isCurved: true,
          barWidth: 4,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF5F6D).withOpacity(0.3),
                const Color(0xFFFFC371).withOpacity(0.1),
              ],
            ),
          ),
          dotData: FlDotData(show: true),
        ),
      ],
    );
  }

  List<RiskTrendItem> _safeData(List<RiskTrendItem> list) {
    if (list.length == 1) {
      return [list.first, list.first];
    }
    return list;
  }

  Widget _buildShimmer() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Stack(
      children: [
        LineChart(
          LineChartData(
            minY: 0,
            maxY: 100,
            gridData: FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineTouchData: LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: [const FlSpot(0, 50), const FlSpot(1, 50)],
                isCurved: true,
                barWidth: 4,
                color: Colors.grey.shade300,
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              "No data yet",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
