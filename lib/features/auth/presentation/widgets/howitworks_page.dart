import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_nav_bar.dart';

class HowItWorksPage extends StatelessWidget {
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Replace AppBar with AppNavBar using PreferredSize
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppNavBar(
          // Pass the current route to highlight the correct nav item
          currentRoute: '/how-it-works',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroBanner(),
            _ProcessOverviewSection(),
            _DetailedStepsSection(),
            _TechnologyExplanationSection(),
            _InvestmentLifecycleSection(),
            _SecurityMeasuresSection(),
            _ComparisonSection(),
            _DemoSection(),
            _FAQSection(),
            _GetStartedSection(),
            _FooterSection(),
          ],
        ),
      ),
      // Add the mobile drawer from AppNavBar for consistent mobile navigation
      endDrawer: AppNavBar().buildMobileDrawer(context),
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
            "How TheBoost Works",
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
              "A simple, transparent process to invest in tokenized land assets with complete security and low barriers to entry.",
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

class _ProcessOverviewSection extends StatelessWidget {
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
            "The Process at a Glance",
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "TheBoost simplifies land investment through blockchain technology and fractional ownership.",
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 50),
          isMobile
              ? Column(
                  children: [
                    _buildProcessGraphic(),
                    SizedBox(height: 40),
                    _buildProcessDescription(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildProcessGraphic(),
                    ),
                    SizedBox(width: 60),
                    Expanded(
                      flex: 6,
                      child: _buildProcessDescription(),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildProcessGraphic() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          "Process Flow Graphic",
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProcessDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProcessItem(
          icon: Icons.real_estate_agent,
          title: "1. Land Selection & Tokenization",
          description: "We carefully select premium land properties, conduct thorough due diligence, and convert ownership into digital tokens on the blockchain.",
        ),
        SizedBox(height: 24),
        _buildProcessItem(
          icon: Icons.person_add,
          title: "2. Investor Onboarding",
          description: "Create an account, complete verification, and fund your wallet to begin investing in tokenized land assets.",
        ),
        SizedBox(height: 24),
        _buildProcessItem(
          icon: Icons.currency_exchange,
          title: "3. Investment & Management",
          description: "Purchase tokens representing fractional ownership in land, then easily monitor and manage your portfolio through our platform.",
        ),
        SizedBox(height: 24),
        _buildProcessItem(
          icon: Icons.trending_up,
          title: "4. Returns & Liquidity",
          description: "Generate returns through land appreciation and potential income, with the ability to trade tokens anytime on our marketplace.",
        ),
      ],
    );
  }

  Widget _buildProcessItem({
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
                style: GoogleFonts.montserrat(
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

class _DetailedStepsSection extends StatelessWidget {
  final List<Map<String, dynamic>> steps = [
    {
      'number': '01',
      'title': 'Create Your Account',
      'description': 'Sign up on TheBoost platform by providing your email and creating a secure password. The registration process takes less than 2 minutes to complete.',
      'icon': Icons.app_registration,
      'details': [
        'Enter your email address and create a strong password',
        'Verify your email through the confirmation link',
        'Set up two-factor authentication for enhanced security',
        'Review and accept the terms of service and privacy policy'
      ],
    },
    {
      'number': '02',
      'title': 'Complete Verification',
      'description': 'To ensure security and comply with regulations, we require identity verification for all investors on our platform.',
      'icon': Icons.verified_user,
      'details': [
        'Upload a government-issued photo ID (passport, driver\'s license)',
        'Take a real-time selfie for verification',
        'Provide proof of address (utility bill, bank statement)',
        'Complete AML/KYC verification process'
      ],
    },
    {
      'number': '03',
      'title': 'Fund Your Account',
      'description': 'Add funds to your TheBoost wallet using your preferred payment method to start investing.',
      'icon': Icons.account_balance_wallet,
      'details': [
        'Connect your bank account for direct transfers',
        'Add a credit or debit card for instant funding',
        'Deposit cryptocurrency (BTC, ETH, USDC) if preferred',
        'All transactions are secured with bank-level encryption'
      ],
    },
    {
      'number': '04',
      'title': 'Browse Land Offerings',
      'description': 'Explore our curated selection of tokenized land opportunities, each with detailed information and analytics.',
      'icon': Icons.search,
      'details': [
        'View high-quality land properties across different categories',
        'Access detailed property information, location maps, and photos',
        'Review historical performance data and projected returns',
        'Use filters to find properties matching your investment criteria'
      ],
    },
    {
      'number': '05',
      'title': 'Purchase Tokens',
      'description': 'Buy tokens representing fractional ownership in the land properties you\'re interested in, starting from just \$100.',
      'icon': Icons.token,
      'details': [
        'Select the number of tokens you wish to purchase',
        'Review the investment details and confirm your purchase',
        'Receive immediate confirmation of your ownership',
        'Access your digital certificate of ownership on the blockchain'
      ],
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
      color: Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Step-by-Step Guide",
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Follow these simple steps to begin your journey with TheBoost and start building your land investment portfolio.",
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 50),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              return Container(
                margin: EdgeInsets.only(bottom: 50),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStepHeader(step),
                          SizedBox(height: 24),
                          _buildStepContent(step, isMobile),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            child: Text(
                              step['number'],
                              style: GoogleFonts.montserrat(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32).withOpacity(0.3),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStepHeader(step),
                                SizedBox(height: 24),
                                _buildStepContent(step, isMobile),
                              ],
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

  Widget _buildStepHeader(Map<String, dynamic> step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step['title'],
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Text(
          step['description'],
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(Map<String, dynamic> step, bool isMobile) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepImage(),
              SizedBox(height: 24),
              _buildStepDetails(step),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildStepImage(),
              ),
              SizedBox(width: 30),
              Expanded(
                child: _buildStepDetails(step),
              ),
            ],
          );
  }

  Widget _buildStepImage() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          "Step Image",
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepDetails(Map<String, dynamic> step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...(step['details'] as List<String>).map<Widget>((detail) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    detail,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _TechnologyExplanationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width < 768 ? 24 : 80,
        vertical: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "The Technology Behind TheBoost",
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Our platform leverages cutting-edge blockchain technology to make land investment secure, transparent, and accessible.",
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 50),
          Container(
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
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTechnologyItem(
                  icon: Icons.link,
                  title: "Blockchain Infrastructure",
                  description: "Our platform is built on a secure blockchain network that ensures transparent and immutable record-keeping for all land ownership transactions.",
                ),
                SizedBox(height: 30),
                _buildTechnologyItem(
                  icon: Icons.token,
                  title: "Asset Tokenization",
                  description: "We transform traditional land ownership into digital tokens that represent fractional ownership, making real estate investment accessible to everyone.",
                ),
                SizedBox(height: 30),
                _buildTechnologyItem(
                  icon: Icons.smart_toy,
                  title: "Smart Contracts",
                  description: "Self-executing smart contracts automate transactions and ensure that all parties fulfill their obligations without the need for intermediaries.",
                ),
                SizedBox(height: 30),
                _buildTechnologyItem(
                  icon: Icons.security,
                  title: "Advanced Security",
                  description: "We implement multiple layers of security, including encryption, multi-sig authentication, and regular audits to protect your investments and data.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnologyItem({
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
            size: 32,
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
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

class _InvestmentLifecycleSection extends StatelessWidget {
  final List<Map<String, dynamic>> stages = [
    {
      'title': 'Property Selection',
      'description':
          'Our investment team identifies and evaluates high-potential land properties based on location, growth prospects, and value.',
      'icon': Icons.real_estate_agent,
    },
    {
      'title': 'Due Diligence',
      'description':
          'We conduct thorough legal, environmental, and financial due diligence to ensure the property meets our investment criteria.',
      'icon': Icons.fact_check,
    },
    {
      'title': 'Tokenization',
      'description':
          'The property is divided into digital tokens, each representing fractional ownership with all legal protections.',
      'icon': Icons.token,
    },
    {
      'title': 'Investor Participation',
      'description':
          'Tokens are made available on our platform for investors to purchase according to their investment goals.',
      'icon': Icons.people,
    },
    {
      'title': 'Value Creation',
      'description':
          'We actively manage and monitor the property to identify opportunities for value enhancement and appreciation.',
      'icon': Icons.trending_up,
    },
    {
      'title': 'Returns & Liquidity',
      'description':
          'Investors can generate returns through property appreciation and have the flexibility to trade tokens on our marketplace.',
      'icon': Icons.attach_money,
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
      color: Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Investment Lifecycle",
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "From property acquisition to investor returns, understand the complete lifecycle of a land investment on TheBoost.",
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 50),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              childAspectRatio: isMobile ? 2.5 : 1.2,
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
            ),
            itemCount: stages.length,
            itemBuilder: (context, index) {
              final stage = stages[index];
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
                      stage['icon'],
                      color: Color(0xFF2E7D32),
                      size: 36,
                    ),
                    SizedBox(height: 16),
                    Text(
                      stage['title'],
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      stage['description'],
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

class _SecurityMeasuresSection extends StatelessWidget {
  final List<Map<String, dynamic>> securityFeatures = [
    {
      'title': 'Blockchain Security',
      'description':
          'All ownership records and transactions are stored on a secure blockchain, creating an immutable record that cannot be altered or tampered with.',
      'icon': Icons.security,
    },
    {
      'title': 'Legal Framework',
      'description':
          'Each tokenized property has a robust legal structure that ensures your digital ownership is backed by real-world legal rights and protections.',
      'icon': Icons.gavel,
    },
    {
      'title': 'Data Encryption',
      'description':
          'Your personal and financial information is protected with bank-level encryption, ensuring your data remains private and secure at all times.',
      'icon': Icons.lock,
    },
    {
      'title': 'Multi-Signature Authorization',
      'description':
          'Significant platform activities require approval from multiple authorized parties, preventing unauthorized actions and adding an extra layer of security.',
      'icon': Icons.verified_user,
    },
    {
      'title': 'Regular Audits',
      'description':
          'Our platform undergoes regular security audits by independent third parties to identify and address potential vulnerabilities before they can be exploited.',
      'icon': Icons.fact_check,
    },
    {
      'title': 'Insurance Coverage',
      'description':
          'All investments on TheBoost are covered by comprehensive insurance policies that protect against fraud, theft, and other potential risks.',
      'icon': Icons.health_and_safety,
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
            "Security & Protection",
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Your investments and personal information are protected by multiple layers of security and legal safeguards.",
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 50),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              childAspectRatio: isMobile ? 3 : 1.5,
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
            ),
            itemCount: securityFeatures.length,
            itemBuilder: (context, index) {
              final feature = securityFeatures[index];
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
                      feature['icon'],
                      color: Color(0xFF2E7D32),
                      size: 36,
                    ),
                    SizedBox(height: 16),
                    Text(
                      feature['title'],
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
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

class _ComparisonSection extends StatelessWidget {
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
            "Traditional vs Tokenized Land Investment",
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "See how TheBoost's innovative approach compares to traditional land investment methods.",
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 50),
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
                    'TheBoost Tokenized Investment',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
              rows: [
                _buildComparisonRow(
                  'Initial Investment',
                  'High (typically \$100,000+)',
                  'Low (starting at \$100)',
                ),
                _buildComparisonRow(
                  'Accessibility',
                  'Limited to wealthy investors and institutions',
                  'Available to anyone with internet access',
                ),
                _buildComparisonRow(
                  'Transaction Time',
                  '30-90 days for closing',
                  'Instant transactions',
                ),
                _buildComparisonRow(
                  'Liquidity',
                  'Low - lengthy process to sell property',
                  'High - tokens can be traded anytime',
                ),
                _buildComparisonRow(
                  'Documentation',
                  'Extensive paperwork and legal processes',
                  'Digital and automated',
                ),
                _buildComparisonRow(
                  'Management Overhead',
                  'High - property management responsibilities',
                  'None - fully managed by TheBoost',
                ),
                _buildComparisonRow(
                  'Diversification',
                  'Difficult - requires large capital for multiple properties',
                  'Easy - invest in multiple properties with small amounts',
                ),
                _buildComparisonRow(
                  'Transparency',
                  'Limited - information asymmetry',
                  'Complete - blockchain record of all transactions',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildComparisonRow(String feature, String traditional, String tokenized) {
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
              tokenized,
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

class _DemoSection extends StatelessWidget {
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
            "See TheBoost in Action",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: isMobile ? double.infinity : 700,
            child: Text(
              "Watch a quick demonstration of how easy it is to start investing in tokenized land assets on our platform.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(height: 50),
          Container(
            width: isMobile ? double.infinity : 800,
            height: isMobile ? 200 : 450,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 80,
              ),
            ),
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDemoFeature(
                icon: Icons.access_time,
                title: "3-Minute Demo",
              ),
              SizedBox(width: 30),
              _buildDemoFeature(
                icon: Icons.ondemand_video,
                title: "Platform Walkthrough",
              ),
              SizedBox(width: 30),
              _buildDemoFeature(
                icon: Icons.closed_caption,
                title: "With Captions",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoFeature({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Color(0xFF2E7D32),
          size: 20,
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _FAQSection extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      'question': 'How do I get started with TheBoost?',
      'answer': 'Getting started is simple. Create an account, complete the verification process, fund your account, and you can begin investing in tokenized land assets immediately. The entire process typically takes less than 30 minutes.'
    },
    {
      'question': 'What is the minimum investment amount?',
      'answer': 'The minimum investment on TheBoost is \$100, allowing you to purchase fractional ownership in premium land properties. This low entry point makes land investment accessible to almost everyone.'
    },
    {
      'question': 'How is my ownership legally protected?',
      'answer': 'Your ownership is protected through a robust legal framework. Each tokenized property is held by a specialized legal entity, and your tokens represent legally binding ownership shares in that entity. Additionally, all ownership records are securely stored on the blockchain, creating an immutable proof of ownership.'
    },
    {
      'question': 'Can I sell my investment at any time?',
      'answer': 'Yes, one of the key advantages of TheBoost is liquidity. You can list your tokens for sale on our marketplace at any time. Once another investor purchases them, the transaction is processed immediately and funds are transferred to your account.'
    },
    {
      'question': 'What fees does TheBoost charge?',
      'answer': 'We charge a transparent fee structure with no hidden costs. There\'s a 2% transaction fee on purchases and sales of tokens, and a small annual management fee of 0.5% for ongoing administration of the land assets. There are no subscription fees or withdrawal fees.'
    },
    {
      'question': 'How are returns generated from land investments?',
      'answer': 'Returns come from two primary sources: land value appreciation as property values increase over time, and in some cases, income generation through leasing or development activities. The specific return potential varies by property and is detailed in each investment listing.'
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
      color: Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Frequently Asked Questions",
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Find answers to common questions about using TheBoost for land investment.",
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 50),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 16),
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
                child: ExpansionTile(
                  title: Text(
                    faqs[index]['question']!,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  iconColor: Color(0xFF2E7D32),
                  collapsedIconColor: Colors.grey,
                  tilePadding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: 24,
                      ),
                      child: Text(
                        faqs[index]['answer']!,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 30),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.help_outline, color: Color(0xFF2E7D32)),
              label: Text(
                "View All FAQs",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GetStartedSection extends StatelessWidget {
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
            "Ready to Start Your Investment Journey?",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          Container(
            width: isMobile ? double.infinity : 700,
            child: Text(
              "Join thousands of investors who are already building wealth through tokenized land assets on TheBoost. Start with as little as \$100 today.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
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
                child: Text(
                  "Create Your Account",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Schedule a Demo",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeature(
                icon: Icons.verified_user,
                text: "Secure & Regulated",
              ),
              SizedBox(width: 30),
              _buildFeature(
                icon: Icons.attach_money,
                text: "Start with \$100",
              ),
              SizedBox(width: 30),
              _buildFeature(
                icon: Icons.access_time,
                text: "5-Minute Setup",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _FooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 60,
      ),
      color: Colors.grey[900],
      child: Column(
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildFooterContent(context, isMobile),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildFooterContent(context, isMobile),
                ),
          SizedBox(height: 40),
          Divider(color: Colors.grey[800]),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2025 TheBoost. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
              Row(
                children: [
                  _FooterIconButton(Icons.facebook),
                  _FooterIconButton(Icons.facebook),
                  _FooterIconButton(Icons.facebook),
                  _FooterIconButton(Icons.email),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildFooterContent(BuildContext context, bool isMobile) {
    return [
      Expanded(
        flex: 3,
        child: Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(Icons.landscape, color: Colors.white, size: 32),
                SizedBox(width: 8),
                Text(
                  'TheBoost',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: isMobile ? 300 : 280,
              child: Text(
                'TheBoost is revolutionizing land investment through blockchain technology and asset tokenization.',
                textAlign: isMobile ? TextAlign.center : TextAlign.left,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 40, height: isMobile ? 40 : 0),
      Expanded(
        flex: 2,
        child: Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            _FooterHeading('Company'),
            _FooterLink('About Us'),
            _FooterLink('Our Team'),
            _FooterLink('Careers'),
            _FooterLink('Press'),
            _FooterLink('Contact'),
          ],
        ),
      ),
      SizedBox(width: 40, height: isMobile ? 40 : 0),
      Expanded(
        flex: 2,
        child: Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            _FooterHeading('Resources'),
            _FooterLink('Blog'),
            _FooterLink('Help Center'),
            _FooterLink('Investment Guide'),
            _FooterLink('Tokenization Explained'),
            _FooterLink('API Documentation'),
          ],
        ),
      ),
      SizedBox(width: 40, height: isMobile ? 40 : 0),
      Expanded(
        flex: 2,
        child: Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            _FooterHeading('Legal'),
            _FooterLink('Terms of Service'),
            _FooterLink('Privacy Policy'),
            _FooterLink('Compliance'),
            _FooterLink('Security'),
            _FooterLink('Cookies'),
          ],
        ),
      ),
    ];
  }
}

class _FooterHeading extends StatelessWidget {
  final String title;
  
  _FooterHeading(this.title);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String title;
  
  _FooterLink(this.title);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {},
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }
}

class _FooterIconButton extends StatelessWidget {
  final IconData icon;
  
  _FooterIconButton(this.icon);
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon),
      color: Colors.grey[400],
      iconSize: 20,
    );
  }
}