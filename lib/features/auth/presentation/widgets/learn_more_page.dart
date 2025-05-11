import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_nav_bar.dart';

class LearnMorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use the existing AppNavBar component with the current route
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppNavBar(
          // Pass the current route to highlight the correct nav item
          currentRoute: '/learn-more',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeroBanner(),
            AboutSection(),
            MissionSection(),
            HowItWorksDetailSection(),
            TechnologySection(),
            InvestmentOptionsSection(),
            TeamSection(),
            RoadmapSection(),
            PartnersSection(),
          ],
        ),
      ),
      // Add the mobile drawer from AppNavBar if needed
      endDrawer: AppNavBar().buildMobileDrawer(context),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class HeroBanner extends StatelessWidget {
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
            "Revolutionizing Land Investment",
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
              "Discover how TheBoost is transforming the real estate market through blockchain technology and asset tokenization.",
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

class AboutSection extends StatelessWidget {
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
          SectionTitle(title: "About TheBoost"),
          SizedBox(height: 30),
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildAboutContent(context),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildAboutContent(context),
                ),
        ],
      ),
    );
  }

  List<Widget> _buildAboutContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return [
      Expanded(
        flex: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Democratizing Land Ownership",
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "TheBoost was founded in 2023 with a simple yet powerful mission: to make land investment accessible to everyone. Traditional real estate investment has long been restricted to those with significant capital, excluding millions of potential investors worldwide.",
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Through our innovative blockchain-based tokenization platform, we've eliminated the barriers to entry, allowing anyone to invest in premium land assets with as little as \$100. Our technology ensures transparent ownership records, secure transactions, and unprecedented liquidity for land investments.",
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "With TheBoost, you're not just buying land – you're participating in the future of real estate investment.",
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      if (!isMobile) SizedBox(width: 60),
      if (!isMobile)
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  "Company Image",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      if (isMobile) SizedBox(height: 30),
      if (isMobile)
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                "Company Image",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
    ];
  }
}

  List<Widget> _buildAboutContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return [
      Expanded(
        flex: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Democratizing Land Ownership",
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "TheBoost was founded in 2023 with a simple yet powerful mission: to make land investment accessible to everyone. Traditional real estate investment has long been restricted to those with significant capital, excluding millions of potential investors worldwide.",
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Through our innovative blockchain-based tokenization platform, we've eliminated the barriers to entry, allowing anyone to invest in premium land assets with as little as \$100. Our technology ensures transparent ownership records, secure transactions, and unprecedented liquidity for land investments.",
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "With TheBoost, you're not just buying land – you're participating in the future of real estate investment.",
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      if (!isMobile) SizedBox(width: 60),
      if (!isMobile)
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  "Company Image",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      if (isMobile) SizedBox(height: 30),
      if (isMobile)
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                "Company Image",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
    ];
  }


class MissionSection extends StatelessWidget {
  final List<Map<String, dynamic>> missions = [
    {
      'icon': Icons.account_balance_outlined,
      'title': 'Accessibility',
      'description': 'Make land investment accessible to everyone regardless of their financial standing.'
    },
    {
      'icon': Icons.handshake_outlined,
      'title': 'Transparency',
      'description': 'Ensure complete transparency in all transactions and ownership records through blockchain technology.'
    },
    {
      'icon': Icons.trending_up_outlined,
      'title': 'Growth',
      'description': 'Create opportunities for wealth growth through strategic land investment and portfolio diversification.'
    },
    {
      'icon': Icons.eco_outlined,
      'title': 'Sustainability',
      'description': 'Promote responsible land development and investment practices that respect environmental concerns.'
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
          SectionTitle(title: "Our Mission & Values"),
          SizedBox(height: 20),
          Text(
            "At TheBoost, we're driven by core principles that guide everything we do.",
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
              crossAxisCount: isMobile ? 1 : 2,
              childAspectRatio: isMobile ? 3 : 2,
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
            ),
            itemCount: missions.length,
            itemBuilder: (context, index) {
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
                      missions[index]['icon'],
                      color: Color(0xFF2E7D32),
                      size: 36,
                    ),
                    SizedBox(height: 16),
                    Text(
                      missions[index]['title'],
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      missions[index]['description'],
                      style: TextStyle(
                        fontSize: 15,
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

class HowItWorksDetailSection extends StatelessWidget {
  final List<Map<String, dynamic>> steps = [
    {
      'number': '01',
      'title': 'Sign Up & Verification',
      'description': 'Create an account on TheBoost and complete our verification process. This ensures all investors on our platform are properly identified, maintaining security and compliance with regulations.',
      'icon': Icons.app_registration,
    },
    {
      'number': '02',
      'title': 'Fund Your Account',
      'description': 'Add funds to your TheBoost account using various payment methods including bank transfers, credit/debit cards, and selected cryptocurrencies.',
      'icon': Icons.account_balance_wallet,
    },
    {
      'number': '03',
      'title': 'Browse Land Offerings',
      'description': 'Explore our curated selection of land investment opportunities. Each listing includes detailed property information, location analytics, historical performance data, and projected returns.',
      'icon': Icons.search,
    },
    {
      'number': '04',
      'title': 'Purchase Tokens',
      'description': 'Choose the land properties you want to invest in and purchase tokens representing fractional ownership. You can invest as little as \$100 or as much as you wish.',
      'icon': Icons.token,
    },
    {
      'number': '05',
      'title': 'Monitor Your Portfolio',
      'description': 'Track the performance of your investments through our intuitive dashboard. View real-time valuations, land appreciation data, and comprehensive portfolio analytics.',
      'icon': Icons.insert_chart,
    },
    {
      'number': '06',
      'title': 'Trade or Hold',
      'description': 'You can sell your tokens at any time on our marketplace, or hold them for long-term appreciation. Our platform ensures high liquidity compared to traditional land investments.',
      'icon': Icons.swap_horiz,
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
          SectionTitle(title: "How TheBoost Works"),
          SizedBox(height: 20),
          Text(
            "Our platform simplifies the process of investing in land through tokenization. Here's a detailed look at how it works:",
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
              return Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          steps[index]['icon'],
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${steps[index]['number']}. ${steps[index]['title']}",
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            steps[index]['description'],
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black54,
                            ),
                          ),
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
}

class TechnologySection extends StatelessWidget {
  final List<Map<String, dynamic>> technologies = [
    {
      'icon': Icons.link,
      'title': 'Blockchain Infrastructure',
      'description': 'Our platform is built on a robust blockchain network that ensures immutable record-keeping and transparent ownership tracking.',
    },
    {
      'icon': Icons.token,
      'title': 'Asset Tokenization',
      'description': 'We convert land assets into digital tokens, each representing fractional ownership with all legal protections.',
    },
    {
      'icon': Icons.security,
      'title': 'Smart Contracts',
      'description': 'Automated smart contracts handle transactions, ensuring they are executed exactly as programmed without intermediaries.',
    },
    {
      'icon': Icons.analytics,
      'title': 'Advanced Analytics',
      'description': 'Our data analysis tools provide investors with comprehensive insights into land values and market trends.',
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
          SectionTitle(title: "Our Technology"),
          SizedBox(height: 20),
          Text(
            "TheBoost leverages cutting-edge technology to make land investment seamless, secure, and accessible.",
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 50),
          isMobile
              ? Column(
                  children: _buildTechnologyContent(context),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildTechnologyContent(context),
                ),
        ],
      ),
    );
  }

  List<Widget> _buildTechnologyContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return [
      if (!isMobile)
        Expanded(
          flex: 6,
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[300],
            ),
            child: Center(
              child: Text(
                "Technology Illustration",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      if (!isMobile) SizedBox(width: 60),
      if (isMobile)
        Container(
          height: 200,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[300],
          ),
          child: Center(
            child: Text(
              "Technology Illustration",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      Expanded(
        flex: 6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: technologies.map((tech) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      tech['icon'],
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
                          tech['title'],
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          tech['description'],
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
              ),
            );
          }).toList(),
        ),
      ),
    ];
  }
}

class InvestmentOptionsSection extends StatelessWidget {
  final List<Map<String, dynamic>> investmentTypes = [
    {
      'title': 'Urban Development Land',
      'description': 'Invest in land parcels in rapidly developing urban areas with high growth potential.',
      'minInvestment': '\$100',
      'expectedReturn': '8-12% annually',
      'riskLevel': 'Medium',
      'liquidityLevel': 'High',
    },
    {
      'title': 'Agricultural Land',
      'description': 'Secure tokens representing fertile agricultural land with stable long-term appreciation.',
      'minInvestment': '\$100',
      'expectedReturn': '6-9% annually',
      'riskLevel': 'Low',
      'liquidityLevel': 'Medium-High',
    },
    {
      'title': 'Commercial Development',
      'description': 'Participate in commercial land investments with potential for significant capital gains.',
      'minInvestment': '\$250',
      'expectedReturn': '10-15% annually',
      'riskLevel': 'Medium-High',
      'liquidityLevel': 'Medium',
    },
    {
      'title': 'Eco-Conservation Land',
      'description': 'Invest in protected land that combines conservation with sustainable appreciation.',
      'minInvestment': '\$100',
      'expectedReturn': '5-8% annually',
      'riskLevel': 'Low',
      'liquidityLevel': 'Medium',
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
          SectionTitle(title: "Investment Options"),
          SizedBox(height: 20),
          Text(
            "TheBoost offers diverse land investment opportunities to suit different goals and risk profiles.",
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
              crossAxisCount: isMobile ? 1 : 2,
              childAspectRatio: isMobile ? 1 : 1.1,
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
            ),
            itemCount: investmentTypes.length,
            itemBuilder: (context, index) {
              final investment = investmentTypes[index];
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        investment['title'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      investment['description'],
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 20),
                    _buildInvestmentDetail(
                      'Minimum Investment',
                      investment['minInvestment'],
                    ),
                    SizedBox(height: 12),
                    _buildInvestmentDetail(
                      'Expected Returns',
                      investment['expectedReturn'],
                    ),
                    SizedBox(height: 12),
                    _buildInvestmentDetail(
                      'Risk Level',
                      investment['riskLevel'],
                    ),
                    SizedBox(height: 12),
                    _buildInvestmentDetail(
                      'Liquidity',
                      investment['liquidityLevel'],
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Explore Investment Opportunities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentDetail(String label, String value) {
    return Row(
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
    );
  }
}

class RoadmapSection extends StatelessWidget {
  final List<Map<String, dynamic>> milestones = [
    {
      'year': '2023',
      'quarter': 'Q4',
      'title': 'Platform Launch',
      'description': 'Official launch of TheBoost with initial land offerings and basic tokenization features.',
      'completed': true,
    },
    {
      'year': '2024',
      'quarter': 'Q1',
      'title': 'Mobile App Release',
      'description': 'Launch of mobile applications for iOS and Android, enabling on-the-go investment management.',
      'completed': true,
    },
    {
      'year': '2024',
      'quarter': 'Q2',
      'title': 'Advanced Analytics',
      'description': 'Introduction of enhanced analytics dashboard with predictive valuation models and trend analysis.',
      'completed': false,
    },
    {
      'year': '2024',
      'quarter': 'Q4',
      'title': 'Global Expansion',
      'description': 'Expansion to international markets with land offerings across multiple countries.',
      'completed': false,
    },
    {
      'year': '2025',
      'quarter': 'Q2',
      'title': 'Institutional Integration',
      'description': 'Partnership with institutional investors and integration with traditional financial platforms.',
      'completed': false,
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
          SectionTitle(title: "Our Roadmap"),
          SizedBox(height: 20),
          Text(
            "We're on a mission to revolutionize land investment. Here's our journey so far and what's ahead.",
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
            itemCount: milestones.length,
            itemBuilder: (context, index) {
              final milestone = milestones[index];
              return Container(
                margin: EdgeInsets.only(bottom: 30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: milestone['completed'] ? Color(0xFF2E7D32) : Colors.grey[400],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                        ),
                        if (index < milestones.length - 1)
                          Container(
                            width: 2,
                            height: 80,
                            color: Colors.grey[300],
                          ),
                      ],
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: milestone['completed'] ? Color(0xFFE8F5E9) : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${milestone['year']} ${milestone['quarter']}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: milestone['completed'] ? Color(0xFF2E7D32) : Colors.grey[700],
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              if (milestone['completed'])
                                Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF2E7D32),
                                  size: 18,
                                ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            milestone['title'],
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            milestone['description'],
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PartnersSection extends StatelessWidget {
  final List<String> partners = [
    'Green Valley Investments',
    'BlockChain Innovations Inc.',
    'Global Land Registry',
    'EcoTrust Properties',
    'Fintech Alliance',
    'Sustainable Development Fund',
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SectionTitle(title: "Our Partners"),
          SizedBox(height: 20),
          Text(
            "We collaborate with trusted organizations to provide secure, transparent, and valuable investment opportunities.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 50),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: partners.map((partner) {
              return Container(
                width: isMobile ? double.infinity : 300,
                height: 100,
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
                child: Center(
                  child: Text(
                    partner,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class TeamSection extends StatelessWidget {
  final List<Map<String, dynamic>> teamMembers = [
    {
      'name': 'Alexandra Chen',
      'role': 'CEO & Co-Founder',
      'bio': 'Former real estate executive with 15+ years experience in property development and investment banking.',
      'avatar': 'assets/team/avatar1.jpg',
    },
    {
      'name': 'Michael Johnson',
      'role': 'CTO & Co-Founder',
      'bio': 'Blockchain developer with expertise in smart contracts and fintech solutions.',
      'avatar': 'assets/team/avatar2.jpg',
    },
    {
      'name': 'Sarah Williams',
      'role': 'Chief Investment Officer',
      'bio': 'Land valuation expert with background in commercial real estate and portfolio management.',
      'avatar': 'assets/team/avatar3.jpg',
    },
    {
      'name': 'David Rodriguez',
      'role': 'Head of Legal & Compliance',
      'bio': 'Regulatory lawyer specialized in securities, property law, and blockchain compliance.',
      'avatar': 'assets/team/avatar4.jpg',
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
          SectionTitle(title: "Our Team"),
          SizedBox(height: 20),
          Text(
            "Meet the experts behind TheBoost who are passionate about transforming land investment.",
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
              crossAxisCount: isMobile ? 1 : 4,
              childAspectRatio: isMobile ? 3 : 0.8,
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
            ),
            itemCount: teamMembers.length,
            itemBuilder: (context, index) {
              final member = teamMembers[index];
              return Container(
                padding: EdgeInsets.all(20),
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
                child: isMobile
                    ? Row(
                        children: [
                          _buildAvatar(member),
                          SizedBox(width: 20),
                          Expanded(
                            child: _buildMemberInfo(member),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAvatar(member),
                          SizedBox(height: 20),
                          _buildMemberInfo(member),
                        ],
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> member) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(Icons.person, color: Colors.grey[400], size: 40),
      ),
    );
  }

  Widget _buildMemberInfo(Map<String, dynamic> member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          member['name'],
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6),
        Text(
          member['role'],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        Text(
          member['bio'],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}