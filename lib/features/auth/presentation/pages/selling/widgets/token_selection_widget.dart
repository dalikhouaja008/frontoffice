import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_boost/core/constants/colors.dart';

class TokenSelectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> tokens;
  final int selectedIndex;
  final Function(int) onTokenSelected;
  final NumberFormat formatter;

  const TokenSelectionWidget({
    super.key,
    required this.tokens,
    required this.selectedIndex,
    required this.onTokenSelected,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      child: tokens.isEmpty 
        ? Center(
            child: Text(
              'No tokens available for selling',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          )
        : ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: tokens.length,
            itemBuilder: (context, index) {
              final token = tokens[index];
              final isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: () => onTokenSelected(index),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 300,
                  clipBehavior: Clip.none,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Property Image
                              Container(
                                height: 140,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  image: DecorationImage(
                                    image: _getTokenImage(token),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _getTokenProperty(token, 'id', 'TOK-0000'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Token Details
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getTokenProperty(token, 'name', 'Unnamed Token'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getTokenProperty(token, 'location', 'Unknown Location'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'You Own',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              '${_getTokenProperty(token, 'ownedTokens', 0)} tokens',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Market Value',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              '\$${_safeFormat(token['marketPrice'] ?? 0.0)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  // Méthode pour récupérer les propriétés des tokens en toute sécurité
  dynamic _getTokenProperty(Map<String, dynamic> token, String key, dynamic defaultValue) {
    if (token == null) return defaultValue;
    return token.containsKey(key) ? (token[key] ?? defaultValue) : defaultValue;
  }

  // Méthode pour formater les nombres en toute sécurité
  String _safeFormat(dynamic value) {
    try {
      if (value == null) return formatter.format(0.0);
      
      if (value is String) {
        final numValue = double.tryParse(value) ?? 0.0;
        return formatter.format(numValue);
      }
      
      if (value is num) {
        return formatter.format(value);
      }
      
      return formatter.format(0.0);
    } catch (e) {
      return '0.00';
    }
  }

  // Méthode pour récupérer l'image du token en toute sécurité
  ImageProvider _getTokenImage(Map<String, dynamic>? token) {
    try {
      final imageUrl = _getTokenProperty(token!, 'imageUrl', 'assets/placeholder.jpg');
      return AssetImage(imageUrl);
    } catch (e) {
      return const AssetImage('assets/placeholder.jpg');
    }
  }
}