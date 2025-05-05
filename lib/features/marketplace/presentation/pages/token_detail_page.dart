import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../bloc/marketplace_state.dart';
import '../widgets/purchase_dialog.dart';
import '../../domain/entities/token.dart';

class TokenDetailPage extends StatefulWidget {
  final int tokenId;
  final String buyerAddress;

  const TokenDetailPage({
    Key? key,
    required this.tokenId,
    required this.buyerAddress,
  }) : super(key: key);

  @override
  State<TokenDetailPage> createState() => _TokenDetailPageState();
}

class _TokenDetailPageState extends State<TokenDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadListingDetails();
  }

  void _loadListingDetails() {
    context.read<MarketplaceBloc>().add(
          GetListingDetailsEvent(tokenId: widget.tokenId),
        );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open $url',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Token Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: BlocBuilder<MarketplaceBloc, MarketplaceState>(
        builder: (context, state) {
          if (state is MarketplaceLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          } else if (state is ListingDetailsLoaded) {
            final token = state.token;
            final isDesktop = ResponsiveHelper.isDesktop(context);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: _buildTokenVisual(token),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 6,
                              child: _buildTokenDetails(token),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTokenVisual(token),
                            const SizedBox(height: 24),
                            _buildTokenDetails(token),
                          ],
                        ),
                  const SizedBox(height: 32),
                  _buildLandDetails(token),
                  const SizedBox(height: 32),
                  _buildInvestmentAnalysis(token),
                  const SizedBox(height: 32),
                  _buildTransactionHistory(token),
                ],
              ),
            );
          } else if (state is MarketplaceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load token details',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadListingDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      textStyle: GoogleFonts.poppins(),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Text(
              'No token data available',
              style: GoogleFonts.poppins(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTokenVisual(Token token) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.landscape,
                  size: 64,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(height: 16),
                Text(
                  'Land Token #${token.tokenNumber}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  token.land.location,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          if (token.isRecentlyListed)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Recently Listed',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          if (token.isHighlyProfitable)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'High Profit Potential',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTokenDetails(Token token) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Token Information',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Price information
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Price',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      token.formattedPrice,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Purchase Price',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      token.formattedPurchasePrice,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: token.priceChangePercentage.isPositive
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: token.priceChangePercentage.isPositive
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        token.priceChangePercentage.isPositive
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                        color: token.priceChangePercentage.isPositive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        token.priceChangePercentage.formatted,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: token.priceChangePercentage.isPositive
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),
            
            // Token details
            _buildDetailRow('Token ID', '#${token.tokenId}'),
            _buildDetailRow('Land ID', '#${token.landId}'),
            _buildDetailRow('Token Number', token.tokenNumber.toString()),
            _buildDetailRow('Listed On', token.listingDateFormatted),
            _buildDetailRow('Minted On', token.mintDateFormatted),
            _buildDetailRow('Days Since Listing', token.daysSinceListing.toString()),
            _buildDetailRow('Seller', _shortenAddress(token.seller)),
            
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PurchaseDialog(
                      token: token,
                      buyerAddress: widget.buyerAddress,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Purchase Token'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _launchUrl(token.etherscanUrl),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: AppColors.primary),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.open_in_new, size: 16),
                    SizedBox(width: 8),
                    Text('View on Etherscan'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandDetails(Token token) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Land Details',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Land information in a grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : 2,
              childAspectRatio: 3,
              children: [
                _buildGridItem('Location', token.land.location, Icons.location_on),
                _buildGridItem('Surface Area', '${token.land.surface} m²', Icons.square_foot),
                _buildGridItem('Status', token.land.status, Icons.verified),
                _buildGridItem('Registered', token.land.isRegistered ? 'Yes' : 'No', Icons.check_circle),
                _buildGridItem('Total Tokens', token.land.totalTokens.toString(), Icons.token),
                _buildGridItem('Available Tokens', token.land.availableTokens.toString(), Icons.sell),
                _buildGridItem('Price Per Token', token.land.pricePerToken, Icons.monetization_on),
                _buildGridItem('Owner', _shortenAddress(token.land.owner), Icons.person),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentAnalysis(Token token) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Analysis',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Investment metrics
            Row(
              children: [
                Expanded(
                  child: _buildInvestmentMetric(
                    'Investment Rating',
                    token.investmentRating,
                    _getInvestmentRatingColor(token.investmentRating),
                  ),
                ),
                Expanded(
                  child: _buildInvestmentMetric(
                    'Potential Score',
                    '${token.investmentPotential}/5',
                    _getPotentialColor(token.investmentPotential),
                  ),
                ),
                Expanded(
                  child: _buildInvestmentMetric(
                    'Price Increase',
                    token.priceChangePercentage.formatted,
                    token.priceChangePercentage.isPositive ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),
            
            // Investment insights
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Investment Insights',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInsightItem(
                  icon: Icons.trending_up,
                  title: 'Price Growth',
                  description: 'This token has shown a ${token.priceChangePercentage.formatted} price growth since purchase.',
                  positive: token.priceChangePercentage.isPositive,
                ),
                const SizedBox(height: 12),
                _buildInsightItem(
                  icon: Icons.history,
                  title: 'Recency',
                  description: token.isRecentlyListed 
                      ? 'Recently listed token may indicate fresh market opportunity.'
                      : 'Token has been on the market for ${token.daysSinceListing} days.',
                  positive: token.isRecentlyListed,
                ),
                const SizedBox(height: 12),
                _buildInsightItem(
                  icon: Icons.auto_graph,
                  title: 'Profit Potential',
                  description: token.isHighlyProfitable
                      ? 'Token shows high profit potential based on market trends.'
                      : 'Token shows moderate profit potential.',
                  positive: token.isHighlyProfitable,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(Token token) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction History',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Transaction timeline
            _buildTransactionItem(
              date: token.mintDateFormatted,
              title: 'Token Minted',
              description: 'Token was minted by ${_shortenAddress(token.land.owner)}',
              amount: token.formattedPurchasePrice,
              isFirst: true,
              isLast: false,
            ),
            _buildTransactionItem(
              date: token.listingDateFormatted,
              title: 'Listed for Sale',
              description: 'Token was listed for sale by ${_shortenAddress(token.seller)}',
              amount: token.formattedPrice,
              isFirst: false,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String label, String value, IconData icon) {
    return Card(
      elevation: 0,
      color: AppColors.backgroundLight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String description,
    required bool positive,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: positive ? Colors.green[100] : Colors.amber[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: positive ? AppColors.success : AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required String date,
    required String title,
    required String description,
    required String amount,
    required bool isFirst,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: AppColors.divider,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isFirst ? AppColors.textSecondary : AppColors.primary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  String _shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  Color _getInvestmentRatingColor(String rating) {
    switch (rating.toLowerCase()) {
      case 'excellent':
        return AppColors.success;
      case 'bon':
      case 'good':
        return const Color(0xFF8BC34A); // Light green
      case 'moyen':
      case 'average':
        return AppColors.warning;
      case 'faible':
      case 'poor':
        return const Color(0xFFFF9800); // Orange
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getPotentialColor(int potential) {
    if (potential >= 4) return AppColors.success;
    if (potential >= 3) return const Color(0xFF8BC34A); // Light green
    if (potential >= 2) return AppColors.warning;
    return const Color(0xFFFF9800); // Orange
  }
}