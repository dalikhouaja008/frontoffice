// presentation/pages/dashboard/widgets/investment_portfolio.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';


class InvestmentPortfolio extends StatelessWidget {
  // Sample data - in a real app, this would come from your API/database
  final List<Map<String, dynamic>> investments = [
    {
      'property': 'Urban Development Land - Downtown Metro',
      'location': 'Phoenix, Arizona',
      'investedAmount': 2500,
      'currentValue': 2850,
      'tokens': 50,
      'changePercent': 14.0,
    },
    {
      'property': 'Commercial District - Tech Corridor',
      'location': 'Austin, Texas',
      'investedAmount': 5000,
      'currentValue': 6250,
      'tokens': 50,
      'changePercent': 25.0,
    },
    {
      'property': 'Residential Development - Lakeside Community',
      'location': 'Nashville, Tennessee',
      'investedAmount': 3000,
      'currentValue': 3450,
      'tokens': 40,
      'changePercent': 15.0,
    },
    {
      'property': 'Agricultural Farmland - Riverside County',
      'location': 'Riverside, California',
      'investedAmount': 2000,
      'currentValue': 2150,
      'tokens': 200,
      'changePercent': 7.5,
    },
  ];

   InvestmentPortfolio({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingM,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusM),
              ),
            ),
            child: isMobile
                ? Row(
                    children: [
                      Expanded(
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Current Value",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Change",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(width: 60),
                    ],
                  ),
          ),
          
          // Table rows
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: investments.length,
            separatorBuilder: (context, index) => Divider(height: 1),
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

  Widget _buildMobileInvestmentRow(BuildContext context, Map<String, dynamic> investment) {
    return InkWell(
      onTap: () {
        // Navigate to investment details
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        investment['location'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${investment['tokens']} tokens",
                        style: TextStyle(
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
                        "\$${investment['currentValue']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "\$${investment['investedAmount']} invested",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            color: Colors.green,
                            size: 12,
                          ),
                          Text(
                            "${investment['changePercent']}%",
                            style: TextStyle(
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

  Widget _buildDesktopInvestmentRow(BuildContext context, Map<String, dynamic> investment) {
    return InkWell(
      onTap: () {
        // Navigate to investment details
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "${investment['location']} • ${investment['tokens']} tokens",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                "\$${investment['investedAmount']}",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: Text(
                "\$${investment['currentValue']}",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.arrow_upward,
                    color: Colors.green,
                    size: 16,
                  ),
                  Text(
                    "${investment['changePercent']}%",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppDimensions.paddingM),
            IconButton(
              icon: Icon(Icons.more_vert),
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