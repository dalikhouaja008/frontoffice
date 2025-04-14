// lib/features/auth/presentation/pages/dashboard/widgets/recent_activity.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:the_boost/core/constants/dimensions.dart';

class RecentActivity extends StatefulWidget {
  const RecentActivity({super.key});

  @override
  _RecentActivityState createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {
  String selectedPeriod = "All";
  double totalRevenue = 0.0;
  List<Map<String, dynamic>> monthlyRevenues = [];

  @override
  void initState() {
    super.initState();
    _calculateMonthlyRevenue();
    _calculateTotalRevenue();
  }

  void _calculateMonthlyRevenue() {
    monthlyRevenues.clear();
    final now = DateTime(2025, 4, 13); // Current date as per your prompt
    final startDate = DateTime(now.year - 1, now.month, now.day);

    // Hardcode 12 months of revenue data
    for (var i = 0; i < 12; i++) {
      final month = DateTime(startDate.year, startDate.month + i);
      final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      // Static revenue values that increase each month
      final revenue = 50.0 + (i * 20.0); // Starts at 50, increases by 20 each month
      monthlyRevenues.add({'month': monthKey, 'revenue': revenue});
    }
  }

  void _calculateTotalRevenue() {
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
          .where((entry) => entry.key >= monthlyRevenues.length - monthsToShow)
          .map((entry) => entry.value)
          .toList();
    }

    setState(() {
      totalRevenue = filteredRevenues.fold(0.0, (sum, item) => sum + (item['revenue'] as double));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Monthly Revenue",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
          Text(
            "Total for the period: ${totalRevenue.toStringAsFixed(2)} €",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          SizedBox(
            height: 200,
            child: _buildRevenueChart(),
          ),
        ],
      ),
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
      final revenue = monthlyRevenues[i]['revenue'] as double;
      final monthYear = monthlyRevenues[i]['month'] as String;
      final parts = monthYear.split('-');
      final month = parts[1];
      final year = parts[0].substring(2);
      spots.add(FlSpot((i - startIndex).toDouble(), revenue));
      months.add("${_getMonthAbbreviation(month)} '$year");
    }

    double maxY = spots.isNotEmpty
        ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 50
        : 1000.0;
    double minY = spots.isNotEmpty
        ? spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) - 50
        : 0.0;
    if (minY < 0) minY = 0;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()} €',
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
            color: const Color(0xFF6B4A7A),
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
        minY: minY,
        maxY: maxY,
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