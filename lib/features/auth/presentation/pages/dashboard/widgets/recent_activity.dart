import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';

class RecentActivity extends StatefulWidget {
  const RecentActivity({super.key});

  @override
  _RecentActivityState createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {
  String selectedPeriod = "All"; // Default period selection
  double totalRevenue = 0.0; // Total revenue for the selected period

  // Sample data for monthly revenue (in €) - in a real app, this would come from your API/database
  final List<Map<String, dynamic>> monthlyRevenues = [
    {'month': '2024-01', 'revenue': 0.0},
    {'month': '2024-02', 'revenue': 0.0},
    {'month': '2024-03', 'revenue': 0.0},
    {'month': '2024-04', 'revenue': 0.0},
    {'month': '2024-05', 'revenue': 0.0},
    {'month': '2024-06', 'revenue': 0.0},
    {'month': '2024-07', 'revenue': 0.0},
    {'month': '2024-08', 'revenue': 0.0},
    {'month': '2024-09', 'revenue': 0.0},
    {'month': '2024-10', 'revenue': 0.0},
    {'month': '2024-11', 'revenue': 0.0},
    {'month': '2024-12', 'revenue': 0.0},
    {'month': '2025-01', 'revenue': 0.0},
    {'month': '2025-02', 'revenue': 0.0},
    {'month': '2025-03', 'revenue': 0.0},
    {'month': '2025-04', 'revenue': 0.0},
  ];

  @override
  void initState() {
    super.initState();
    _calculateTotalRevenue();
  }

  void _calculateTotalRevenue() {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> filteredRevenues = [];

    if (selectedPeriod == "All") {
      filteredRevenues = monthlyRevenues;
    } else {
      int monthsToShow;
      switch (selectedPeriod) {
        case "3 Months":
          monthsToShow = 3;
          break;
        case "6 Months":
          monthsToShow = 6;
          break;
        case "1 Year":
          monthsToShow = 12;
          break;
        default:
          monthsToShow = monthlyRevenues.length;
      }

      filteredRevenues = monthlyRevenues
          .asMap()
          .entries
          .where((entry) =>
              entry.key >= monthlyRevenues.length - monthsToShow)
          .map((entry) => entry.value)
          .toList();
    }

    setState(() {
      totalRevenue = filteredRevenues.fold(
          0.0, (sum, item) => sum + (item['revenue'] as double? ?? 0.0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Monthly Revenue",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                _buildPeriodChip("3 Months", selectedPeriod == "3 Months"),
                _buildPeriodChip("6 Months", selectedPeriod == "6 Months"),
                _buildPeriodChip("1 Year", selectedPeriod == "1 Year"),
                _buildPeriodChip("All", selectedPeriod == "All"),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingL),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDE8D5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                "Total for the period: ${totalRevenue.toStringAsFixed(2)} €",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _buildRevenueChart(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPeriod = label;
            _calculateTotalRevenue();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6B4A7A) : Colors.transparent,
            border: Border.all(color: const Color(0xFFDDE8D5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    List<FlSpot> spots = [];
    List<String> months = [];
    int startIndex;

    switch (selectedPeriod) {
      case "3 Months":
        startIndex = monthlyRevenues.length - 3;
        break;
      case "6 Months":
        startIndex = monthlyRevenues.length - 6;
        break;
      case "1 Year":
        startIndex = monthlyRevenues.length - 12;
        break;
      case "All":
      default:
        startIndex = 0;
        break;
    }

    startIndex = startIndex < 0 ? 0 : startIndex;

    for (int i = startIndex; i < monthlyRevenues.length; i++) {
      final revenue = monthlyRevenues[i]['revenue'] as double? ?? 0.0;
      final monthYear = monthlyRevenues[i]['month'] as String?;
      if (monthYear == null) continue; // Skip if month is null
      final parts = monthYear.split('-');
      if (parts.length != 2) continue; // Skip if format is invalid
      final month = parts[1];
      final year = parts[0].substring(2);
      spots.add(FlSpot((i - startIndex).toDouble(), revenue));
      months.add("${_getMonthAbbreviation(month)} '$year");
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < months.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      months[index],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF6B4A7A), // Purple color
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF6B4A7A).withOpacity(0.1),
            ),
          ),
        ],
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: 0,
        maxY: spots.isNotEmpty
            ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 1
            : 5,
      ),
    );
  }

  String _getMonthAbbreviation(String month) {
    switch (month) {
      case '01':
        return 'Jan';
      case '02':
        return 'Feb';
      case '03':
        return 'Mar';
      case '04':
        return 'Apr';
      case '05':
        return 'May';
      case '06':
        return 'Jun';
      case '07':
        return 'Jul';
      case '08':
        return 'Aug';
      case '09':
        return 'Sep';
      case '10':
        return 'Oct';
      case '11':
        return 'Nov';
      case '12':
        return 'Dec';
      default:
        return '';
    }
  }
}