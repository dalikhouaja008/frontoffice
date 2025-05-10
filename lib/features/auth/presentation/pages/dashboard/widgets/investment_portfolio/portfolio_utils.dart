import 'package:the_boost/features/auth/domain/entities/token.dart';

class PortfolioUtils {
  static List<Map<String, dynamic>> convertTokensToSellingFormat(
    List<Token> tokens,
    String currentDate,
    String userName,
  ) {
    if (tokens.isEmpty) {
      print('[$currentDate] $userName - Empty tokens list in convertTokensToSellingFormat');
      return [];
    }
  
    // Chercher un token avec des infos de terrain (land non-null)
    Token? referenceToken;
    for (var token in tokens) {
      if (token.land != null) {
        referenceToken = token;
        break;
      }
    }
  
    final landId = tokens.first.landId;
    
    // Si aucun token n'a de terrain défini, utiliser des valeurs par défaut
    if (referenceToken == null || referenceToken.land == null) {
      print('[$currentDate] $userName - No valid land reference found for tokens with landId $landId');
      
      // Utiliser les valeurs réelles disponibles plutôt que des mocks
      final nonListedTokens = tokens.where((token) => !token.isListed).toList();
      
      return [{
        'id': 'TOK-$landId-2025',
        'name': 'Land #$landId',
        'location': 'Unknown Location',
        'totalTokens': nonListedTokens.length, // Nombre réel de tokens non listés
        'ownedTokens': nonListedTokens.length, // Nombre réel de tokens disponibles
        'marketPrice': _calculateAveragePrice(tokens), // Prix moyen réel
        'imageUrl': 'assets/placeholder.jpg', // Image par défaut
        'lastTraded': DateTime.now().toString().substring(0, 10), // Date actuelle
        'priceChange': _calculatePriceChange(tokens), // Variation de prix réelle
        'actualTokens': nonListedTokens, // Tokens réels non listés
      }];
    }
    
    final land = referenceToken.land!;
    
    // Filtrer les tokens non listés pour la vente
    final nonListedTokens = tokens.where((token) => !token.isListed).toList();
    
    // Trier les tokens par ordre de valeur (du plus élevé au plus bas)
    nonListedTokens.sort((a, b) {
      final aPrice = double.tryParse(a.currentMarketInfo.price) ?? 0.0;
      final bPrice = double.tryParse(b.currentMarketInfo.price) ?? 0.0;
      return bPrice.compareTo(aPrice);
    });
  
    // Utiliser les données réelles du terrain
    return [{
      'id': 'TOK-$landId-2025',
      'name': land.title,
      'location': land.location,
      'totalTokens': land.totalTokens,
      'ownedTokens': nonListedTokens.length,
      'marketPrice': _calculateAveragePrice(nonListedTokens),
      'imageUrl': land.imageUrl ?? 'assets/placeholder.jpg',
      'lastTraded': DateTime.now().toString().substring(0, 10),
      'priceChange': _calculatePriceChange(tokens),
      'actualTokens': nonListedTokens,
    }];
  }
  
  static double _calculateAveragePrice(List<Token> tokens) {
    if (tokens.isEmpty) return 0.0;
    double totalValue = 0.0;
    int validTokens = 0;
    
    for (var token in tokens) {
      final price = double.tryParse(token.currentMarketInfo.price) ?? 0.0;
      if (price > 0) {
        totalValue += price;
        validTokens++;
      }
    }
    
    return validTokens > 0 ? totalValue / validTokens : 0.0;
  }
  
  static String _calculatePriceChange(List<Token> tokens) {
    if (tokens.isEmpty) return "+0.0%";
    
    final token = tokens.first;
    final currentPrice = double.tryParse(token.currentMarketInfo.price) ?? 0.0;
    final originalPrice = double.tryParse(token.purchaseInfo.price) ?? 0.0;
  
    if (originalPrice <= 0) return "+0.0%";
  
    final percentChange = ((currentPrice - originalPrice) / originalPrice) * 100;
    final direction = percentChange >= 0 ? "+" : "";
    return "$direction${percentChange.toStringAsFixed(1)}%";
  }
}