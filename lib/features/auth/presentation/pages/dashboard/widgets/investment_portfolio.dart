// lib/features/auth/presentation/pages/dashboard/widgets/investment_portfolio.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';

class InvestmentPortfolio extends StatelessWidget {
  final List<Land> lands;

  const InvestmentPortfolio({super.key, required this.lands});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (lands.isEmpty) {
      return const Center(
        child: Text(
          "No investments available",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    final investments = lands.asMap().entries.map((entry) {
      final land = entry.value;
      final index = entry.key;
      final investedAmount = land.totalPrice;
      final increasePercent = land.status == LandValidationStatus.VALIDATED
          ? (10 + (index * 5) % 15).toDouble()
          : 5.0;
      final currentValue = investedAmount * (1 + increasePercent / 100);
      return {
        'property': land.title,
        'location': land.location,
        'investedAmount': investedAmount,
        'currentValue': currentValue,
        'tokens': land.totalTokens,
        'changePercent': increasePercent,
      };
    }).toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppDimensions.paddingL),
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
          const Padding(
            padding: EdgeInsets.all(AppDimensions.paddingL),
            child: Text(
              "Your Investment Portfolio",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingM,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusM),
              ),
            ),
            child: isMobile
                ? Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text(
                          "Property",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Value",
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Text(
                          "Property",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Invested",
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Current Value",
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Change",
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 60),
                    ],
                  ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: investments.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final investment = investments[index];
              return isMobile
                  ? _buildMobileInvestmentRow(context, investment)
                  : _buildDesktopInvestmentRow(context, investment);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileInvestmentRow(
      BuildContext context, Map<String, dynamic> investment) {
    return InkWell(
      onTap: () {
        final land = lands.firstWhere((l) => l.title == investment['property']);
        Navigator.pushNamed(context, '/land-details', arguments: land);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investment['property'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        investment['location'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${investment['tokens']} tokens",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${investment['currentValue'].toStringAsFixed(2)} €",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${investment['investedAmount'].toStringAsFixed(2)} € invested",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_upward,
                            color: Colors.green,
                            size: 12,
                          ),
                          Text(
                            "${investment['changePercent'].toStringAsFixed(1)}%",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopInvestmentRow(
      BuildContext context, Map<String, dynamic> investment) {
    return InkWell(
      onTap: () {
        final land = lands.firstWhere((l) => l.title == investment['property']);
        Navigator.pushNamed(context, '/land-details', arguments: land);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    investment['property'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${investment['location']} • ${investment['tokens']} tokens",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                "${investment['investedAmount'].toStringAsFixed(2)} €",
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: Text(
                "${investment['currentValue'].toStringAsFixed(2)} €",
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.arrow_upward,
                    color: Colors.green,
                    size: 16,
                  ),
                  Text(
                    "${investment['changePercent'].toStringAsFixed(1)}%",
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show options menu
              },
            ),
          ],
        ),
      ),
    );
  }
}