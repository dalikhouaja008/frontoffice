// presentation/pages/property_details/widgets/investment_calculator.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/constants/text_styles.dart';
import 'package:the_boost/features/auth/presentation/widgets/buttons/app_button.dart';
import '../../../../domain/entities/property.dart';

class InvestmentCalculator extends StatefulWidget {
  final Property property;
  final bool isAuthenticated;

  const InvestmentCalculator({
    Key? key,
    required this.property,
    required this.isAuthenticated,
  }) : super(key: key);

  @override
  _InvestmentCalculatorState createState() => _InvestmentCalculatorState();
}

class _InvestmentCalculatorState extends State<InvestmentCalculator> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  int _tokens = 1;
  double _investmentAmount = 0;
  double _projectedAnnualReturn = 0;
  double _projectedFiveYearReturn = 0;

  @override
  void initState() {
    super.initState();
    _tokens = (widget.property.minInvestment / widget.property.tokenPrice).ceil();
    _tokenController.text = _tokens.toString();
    _updateCalculations();
    
    _tokenController.addListener(_onTokensChanged);
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onTokensChanged() {
    if (_tokenController.text.isEmpty) {
      setState(() {
        _tokens = 0;
        _investmentAmount = 0;
        _projectedAnnualReturn = 0;
        _projectedFiveYearReturn = 0;
      });
      return;
    }
    
    final newTokens = int.tryParse(_tokenController.text) ?? 0;
    if (newTokens != _tokens) {
      setState(() {
        _tokens = newTokens;
        _investmentAmount = _tokens * widget.property.tokenPrice;
        _amountController.text = _investmentAmount.toStringAsFixed(2);
        _updateCalculations();
      });
    }
  }

  void _onAmountChanged() {
    if (_amountController.text.isEmpty) {
      setState(() {
        _tokens = 0;
        _investmentAmount = 0;
        _projectedAnnualReturn = 0;
        _projectedFiveYearReturn = 0;
      });
      return;
    }
    
    final newAmount = double.tryParse(_amountController.text) ?? 0;
    if (newAmount != _investmentAmount) {
      final newTokens = (newAmount / widget.property.tokenPrice).floor();
      setState(() {
        _tokens = newTokens;
        _tokenController.text = _tokens.toString();
        _investmentAmount = _tokens * widget.property.tokenPrice;
        _updateCalculations();
      });
    }
  }

  void _updateCalculations() {
    setState(() {
      _projectedAnnualReturn = _investmentAmount * (widget.property.projectedReturn / 100);
      _projectedFiveYearReturn = _projectedAnnualReturn * 5;
    });
  }

  void _handleInvestment() {
    if (_tokens <= 0 || _investmentAmount < widget.property.minInvestment) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimum investment is \$${widget.property.minInvestment}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!widget.isAuthenticated) {
      _showLoginDialog();
      return;
    }
    
    _showPurchaseDialog();
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Required'),
        content: Text('You need to be logged in to make an investment. Would you like to login now?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/auth');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Investment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to purchase:'),
            SizedBox(height: AppDimensions.paddingM),
            _buildConfirmationDetail('Property', widget.property.title),
            _buildConfirmationDetail('Number of Tokens', '$_tokens'),
            _buildConfirmationDetail('Price per Token', '\$${widget.property.tokenPrice}'),
            _buildConfirmationDetail('Total Amount', '\$${_investmentAmount.toStringAsFixed(2)}'),
            SizedBox(height: AppDimensions.paddingM),
            Text(
              'By proceeding, you agree to the terms and conditions of this investment.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Confirm Purchase'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() {
    // In a real app, this would connect to a payment gateway
    // For now, show a success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
            SizedBox(width: AppDimensions.paddingS),
            Text('Investment Successful'),
          ],
        ),
        content: Text(
          'Congratulations! Your investment of \$${_investmentAmount.toStringAsFixed(2)} in ${widget.property.title} has been successfully processed. You can view your investment in your dashboard.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Investment Calculator",
            style: AppTextStyles.h4,
          ),
          SizedBox(height: AppDimensions.paddingM),
          
          // Number of tokens input
          Text(
            "Number of Tokens",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: AppDimensions.paddingS),
          TextFormField(
            controller: _tokenController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: "Enter number of tokens",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingM,
              ),
            ),
          ),
          SizedBox(height: AppDimensions.paddingM),
          
          // Investment amount input
          Text(
            "Investment Amount",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: AppDimensions.paddingS),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              hintText: "Enter investment amount",
              prefixText: "\$ ",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingM,
              ),
            ),
          ),
          SizedBox(height: AppDimensions.paddingM),
          
          // Token price info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Token Price:",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Text(
                "\$${widget.property.tokenPrice}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.paddingS),
          
          // Minimum investment info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Minimum Investment:",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Text(
                "\$${widget.property.minInvestment}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppDimensions.paddingM),
          Divider(),
          SizedBox(height: AppDimensions.paddingM),
          
          // Projected returns
          Text(
            "Projected Returns",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: AppDimensions.paddingM),
          
          // Annual return
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Annual Return (${widget.property.projectedReturn}%):",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Text(
                "\$${_projectedAnnualReturn.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.paddingS),
          
          // 5-year return
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "5-Year Return:",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Text(
                "\$${_projectedFiveYearReturn.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppDimensions.paddingXL),
          
          // Invest button
          AppButton(
            text: "Invest Now",
            onPressed: _handleInvestment,
            isFullWidth: true,
            type: ButtonType.primary,
          ),
          SizedBox(height: AppDimensions.paddingM),
          
          // Disclaimer
          Text(
            "Projected returns are estimates based on historical data and market analysis. Actual returns may vary. Investment involves risk.",
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}