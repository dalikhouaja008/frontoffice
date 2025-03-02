import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/utils/responsive_helper.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppDimensions.paddingL : AppDimensions.paddingXXL,
        vertical: AppDimensions.paddingXXL,
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
          SizedBox(height: AppDimensions.paddingXL),
          Divider(color: Colors.grey[800]),
          SizedBox(height: AppDimensions.paddingL),
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
                  _FooterIconButton(Icons.one_x_mobiledata),
                  _FooterIconButton(Icons.dataset_linked_rounded),
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