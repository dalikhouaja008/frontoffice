import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeaturesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.landscape, color: Color(0xFF2E7D32), size: 24),
            SizedBox(width: 8),
            Text(
              'TheBoost',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {}, // Navigate to Login page
            child: Text(
              'Login',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {}, // Navigate to Sign Up page
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Get Started'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroBanner(),
            _MainFeaturesSection(),
            _TokenizationSection(),
            _SecuritySection(),
            _MarketplaceSection(),
            _AnalyticsSection(),
            _MobileAppSection(),
            _CustomerSupportSection(),
            _FeatureComparisonSection(),
            _TestimonialsSection(),
            _CallToActionSection(),
            // Use the FooterSection from the landing page
            
            // Temporary footer until we import the one from landing page
            //FooterSection(),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 60,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFE8F5E9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "TheBoost Features",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: isMobile ? 28 : 42,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: isMobile ? double.infinity : 700,
            child: Text(
              "Explore the powerful features that make TheBoost the leading platform for land tokenization and investment.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                height: 1.5,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainFeaturesSection extends StatelessWidget {
  final List<Map<String, dynamic>> features = [
    {
      'icon': Icons.token,
      'title': 'Asset Tokenization',
      'description': 'Convert land ownership into digital tokens for fractional investing and easier transfers.'
    },
    {
      'icon': Icons.swap_horiz,
      'title': 'Buy & Sell Tokens',
      'description': 'Trade land tokens easily through our intuitive platform with minimal fees.'
    },
    {
      'icon': Icons.security,
      'title': 'Blockchain Security',
      'description': 'Secure all transactions and ownership records with immutable blockchain technology.'
    },
    {
      'icon': Icons.show_chart,
      'title': 'Market Analytics',
      'description': 'Access detailed market data and trends to make informed investment decisions.'
    },
    {
      'icon': Icons.account_balance_wallet,
      'title': 'Digital Wallet',
      'description': 'Securely store and manage your land tokens in our easy-to-use digital wallet.'
    },
    {
      'icon': Icons.insights,
      'title': 'Portfolio Management',
      'description': 'Track performance and manage all your land investments from a single dashboard.'
    },
    {
      'icon': Icons.mobile_friendly,
      'title': 'Mobile Experience',
      'description': 'Access your investments anytime, anywhere with our responsive mobile application.'
    },
    {
      'icon': Icons.support_agent,
      'title': 'Expert Support',
      'description': 'Get assistance from our knowledgeable support team whenever you need help.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Key Features",
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Everything you need to invest in land assets with confidence",
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 60),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 4,
              childAspectRatio: isMobile ? 3 : 1.1,
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        feature['icon'],
                        color: Color(0xFF2E7D32),
                        size: 28,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      feature['title'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      feature['description'],
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TokenizationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      color: Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Asset Tokenization",
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Converting land assets into digital tokens for fractional ownership",
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 60),
          isMobile
              ? Column(
                  children: [
                    _buildTokenizationImage(),
                    SizedBox(height: 40),
                    _buildTokenizationDetails(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildTokenizationImage(),
                    ),
                    SizedBox(width: 60),
                    Expanded(
                      flex: 6,
                      child: _buildTokenizationDetails(),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildTokenizationImage() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          "Tokenization Illustration",
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTokenizationDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureDetail(
          title: "Legal Compliance",
          description: "Each token is backed by legal documentation ensuring your ownership rights are fully protected.",
        ),
        SizedBox(height: 30),
        _buildFeatureDetail(
          title: "Fractional Ownership",
          description: "Buy as little as \$100 worth of land through tokens representing precise ownership percentages.",
        ),
        SizedBox(height: 30),
        _buildFeatureDetail(
          title: "Seamless Transfers",
          description: "Transfer ownership instantly without the traditional paperwork and lengthy processes.",
        ),
        SizedBox(height: 30),
        _buildFeatureDetail(
          title: "Immutable Records",
          description: "All ownership records are permanently stored on the blockchain for complete transparency.",
        ),
      ],
    );
  }

  Widget _buildFeatureDetail({
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.check,
            color: Color(0xFF2E7D32),
            size: 24,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SecuritySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Industry-Leading Security",
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Your investments and data are protected by multiple layers of security",
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 60),
          isMobile
              ? Column(
                  children: [
                    _buildSecurityDetails(),
                    SizedBox(height: 40),
                    _buildSecurityImage(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildSecurityDetails(),
                    ),
                    SizedBox(width: 60),
                    Expanded(
                      flex: 6,
                      child: _buildSecurityImage(),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildSecurityImage() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          "Security Illustration",
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSecurityFeature(
          icon: Icons.verified_user,
          title: "Multi-Factor Authentication",
          description: "Secure your account with multiple verification layers including biometric authentication.",
        ),
        SizedBox(height: 30),
        _buildSecurityFeature(
          icon: Icons.enhanced_encryption,
          title: "Bank-Level Encryption",
          description: "All data and transactions are protected with AES-256 encryption, the industry standard for financial services.",
        ),
        SizedBox(height: 30),
        _buildSecurityFeature(
          icon: Icons.security,
          title: "Blockchain Security",
          description: "Immutable transaction records and distributed ledger technology eliminate single points of failure.",
        ),
        SizedBox(height: 30),
        _buildSecurityFeature(
          icon: Icons.gavel,
          title: "Legal Protection",
          description: "All investments are backed by comprehensive legal frameworks and regulatory compliance.",
        ),
      ],
    );
  }

  Widget _buildSecurityFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Color(0xFF2E7D32),
            size: 24,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MarketplaceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      color: Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Token Marketplace",
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Buy and sell land tokens with unprecedented liquidity and ease",
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 60),
          Container(
            width: double.infinity,
            height: 500,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "Marketplace Interface Mockup",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 1 : 3,
            childAspectRatio: isMobile ? 3 : 1.5,
            crossAxisSpacing: 30,
            mainAxisSpacing: 30,
            children: [
              _buildMarketplaceFeature(
                icon: Icons.speed,
                title: "Real-Time Trading",
                description: "Buy and sell tokens instantly with real-time price updates and market data.",
              ),
              _buildMarketplaceFeature(
                icon: Icons.currency_exchange,
                title: "Low Transaction Fees",
                description: "Just 2% transaction fee, significantly lower than traditional real estate commissions.",
              ),
              _buildMarketplaceFeature(
                icon: Icons.account_balance,
                title: "Multiple Payment Options",
                description: "Fund your purchases with bank transfers, credit cards, or cryptocurrencies.",
              ),
              _buildMarketplaceFeature(
                icon: Icons.history,
                title: "Transaction History",
                description: "Track all your past purchases, sales, and transfers with detailed records.",
              ),
              _buildMarketplaceFeature(
                icon: Icons.notifications_active,
                title: "Price Alerts",
                description: "Set alerts for price movements to never miss investment opportunities.",
              ),
              _buildMarketplaceFeature(
                icon: Icons.auto_graph,
                title: "Limit Orders",
                description: "Set buy and sell orders at your desired price points for automated trading.",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Color(0xFF2E7D32),
            size: 32,
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Advanced Analytics",
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Make data-driven investment decisions with comprehensive analytics tools",
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 60),
          isMobile
              ? Column(
                  children: [
                    _buildAnalyticsImage(),
                    SizedBox(height: 40),
                    _buildAnalyticsDetails(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildAnalyticsImage(),
                    ),
                    SizedBox(width: 60),
                    Expanded(
                      flex: 6,
                      child: _buildAnalyticsDetails(),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsImage() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          "Analytics Dashboard Mockup",
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Data-Driven Investment Decisions",
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Our comprehensive analytics platform provides you with all the data and insights you need to make informed investment decisions. Track market trends, analyze property performance, and identify high-potential opportunities with ease.",
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 30),
        _buildAnalyticsFunctionality(
          icon: Icons.insert_chart,
          title: "Price History Tracking",
          description: "View historical price movements and trends for any property token.",
        ),
        SizedBox(height: 20),
        _buildAnalyticsFunctionality(
          icon: Icons.compare_arrows,
          title: "Comparative Analysis",
          description: "Compare performance across different land assets and investment categories.",
        ),
        SizedBox(height: 20),
        _buildAnalyticsFunctionality(
          icon: Icons.timeline,
          title: "Market Trends",
          description: "Track broader market movements and regional development trends.",
        ),
        SizedBox(height: 20),
        _buildAnalyticsFunctionality(
          icon: Icons.assessment,
          title: "ROI Calculator",
          description: "Project potential returns based on historical data and growth models.",
        ),
      ],
    );
  }

  Widget _buildAnalyticsFunctionality({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Color(0xFF2E7D32),
          size: 24,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileAppSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      color: Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Mobile Experience",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: isMobile ? double.infinity : 700,
            child: Text(
              "Manage your land investments anytime, anywhere with our mobile app",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(height: 60),
          Container(
            height: 500,
            child: Center(
              child: Container(
                width: 300,
                height: 500,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    "Mobile App Mockup",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 60),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 1 : 4,
            childAspectRatio: isMobile ? 3 : 1.2,
            crossAxisSpacing: 30,
            mainAxisSpacing: 30,
            children: [
              _buildMobileFeature(
                icon: Icons.speed,
                title: "Instant Access",
                description: "Check your portfolio performance instantly from anywhere.",
              ),
              _buildMobileFeature(
                icon: Icons.notifications,
                title: "Real-Time Alerts",
                description: "Receive notifications for market changes and opportunities.",
              ),
              _buildMobileFeature(
                icon: Icons.touch_app,
                title: "One-Touch Trading",
                description: "Buy and sell land tokens with just a few taps.",
              ),
              _buildMobileFeature(
                icon: Icons.fingerprint,
                title: "Biometric Security",
                description: "Secure your account with fingerprint or facial recognition.",
              ),
            ],
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.apple),
                    SizedBox(width: 8),
                    Text(
                      "App Store",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.android),
                    SizedBox(width: 8),
                    Text(
                      "Google Play",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Color(0xFF2E7D32),
            size: 32,
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerSupportSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Expert Customer Support",
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Our dedicated team is here to help you every step of the way",
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 60),
          isMobile
              ? Column(
                  children: [
                    _buildSupportDetails(),
                    SizedBox(height: 40),
                    _buildSupportImage(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildSupportDetails(),
                    ),
                    SizedBox(width: 60),
                    Expanded(
                      flex: 6,
                      child: _buildSupportImage(),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildSupportImage() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          "Support Team Image",
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSupportDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "We're Here to Help",
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Our customer support team consists of experienced investment advisors and technical specialists who understand both real estate and blockchain technology. We're committed to providing you with timely, knowledgeable assistance whenever you need it.",
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 30),
        _buildSupportChannel(
          icon: Icons.chat,
          title: "Live Chat Support",
          description: "Get immediate assistance through our live chat feature, available on both web and mobile platforms.",
        ),
        SizedBox(height: 20),
        _buildSupportChannel(
          icon: Icons.email,
          title: "Email Support",
          description: "Send detailed inquiries to our support team with a guaranteed response within 24 hours.",
        ),
        SizedBox(height: 20),
        _buildSupportChannel(
          icon: Icons.phone,
          title: "Phone Consultation",
          description: "Schedule one-on-one phone consultations with our investment advisors for personalized guidance.",
        ),
        SizedBox(height: 20),
        _buildSupportChannel(
          icon: Icons.school,
          title: "Knowledge Base",
          description: "Access our comprehensive library of guides, tutorials, and FAQs for self-service support.",
        ),
      ],
    );
  }

  Widget _buildSupportChannel({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Color(0xFF2E7D32),
            size: 24,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureComparisonSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      color: Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TheBoost vs Traditional Investment",
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "See how our features compare to traditional land investment methods",
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 60),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Color(0xFFE8F5E9)),
              dataRowHeight: 70,
              headingRowHeight: 60,
              columnSpacing: 40,
              columns: [
                DataColumn(
                  label: Text(
                    'Feature',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Traditional Land Investment',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'TheBoost Platform',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
              rows: [
                _buildComparisonRow(
                  'Minimum Investment',
                  'Typically \$100,000+',
                  'As low as \$100',
                ),
                _buildComparisonRow(
                  'Transaction Speed',
                  '30-90 days',
                  'Instant',
                ),
                _buildComparisonRow(
                  'Liquidity',
                  'Low',
                  'High',
                ),
                _buildComparisonRow(
                  'Management Required',
                  'Extensive',
                  'None',
                ),
                _buildComparisonRow(
                  'Diversification',
                  'Difficult',
                  'Easy',
                ),
                _buildComparisonRow(
                  'Transaction Costs',
                  '5-6% (agent commissions)',
                  '2% (flat fee)',
                ),
                _buildComparisonRow(
                  'Paperwork',
                  'Extensive',
                  'Digital & Automated',
                ),
                _buildComparisonRow(
                  'Market Access',
                  'Local or Limited',
                  'Global',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildComparisonRow(String feature, String traditional, String theboost) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            feature,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        DataCell(
          Text(
            traditional,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
        DataCell(
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              theboost,
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TestimonialsSection extends StatelessWidget {
  final List<Map<String, String>> testimonials = [
    {
      'name': 'Sarah Johnson',
      'role': 'Small Business Owner',
      'comment': 'TheBoost made it possible for me to invest in real estate with a limited budget. The platform is intuitive and the tokenization model really works!',
    },
    {
      'name': 'Michael Chen',
      'role': 'Financial Advisor',
      'comment': 'I recommend TheBoost to all my clients looking to diversify their portfolios. The blockchain security and transparency gives everyone peace of mind.',
    },
    {
      'name': 'Emma Rodriguez',
      'role': 'First-time Investor',
      'comment': 'Never thought I could own a piece of prime real estate until I found TheBoost. Now I have investments in three different properties!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "What Our Users Say",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: isMobile ? double.infinity : 700,
            child: Text(
              "Hear from investors who are already using TheBoost to transform their investment portfolios",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: testimonials.map((testimonial) {
              return Container(
                width: isMobile ? double.infinity : 320,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.format_quote, color: Color(0xFF2E7D32), size: 32),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      testimonial['comment']!,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(Icons.person, color: Colors.grey[400]),
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              testimonial['name']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              testimonial['role']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CallToActionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF1B5E20),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            "Ready to Transform Your Investment Strategy?",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: isMobile ? 28 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          Container(
            width: isMobile ? double.infinity : 700,
            child: Text(
              "Join thousands of investors who are already building wealth through tokenized land assets. Start with as little as \$100 today.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF2E7D32),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Create Your Account",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 24),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Schedule a Demo",
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// This is a temporary footer that would be replaced by importing the one from landing page