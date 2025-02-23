// data/static_lands.dart
import 'package:the_boost/features/auth/presentation/models/land_model.dart';

class StaticLandsData {
  static List<Land> getLands() {
    return [
      Land(
        id: '1',
        name: 'Terrain Agricole à Mornag',
        description: 'Grand terrain agricole fertile, idéal pour l\'agriculture biologique. Système d\'irrigation moderne installé. Accès facile depuis la route principale.',
        location: 'Mornag, Ben Arous',
        type: LandType.AGRICULTURAL,
        status: LandStatus.AVAILABLE,
        price: 180000,
        surface: 5000,
        imageUrl: 'assets/1.jpg',
        createdAt: DateTime.now(),
      ),
      Land(
        id: '2',
        name: 'Terrain Constructible Vue Mer',
        description: 'Magnifique terrain avec vue panoramique sur la mer. Permis de construire R+3 disponible. Quartier résidentiel calme et sécurisé.',
        location: 'Gammarth, Tunis',
        type: LandType.RESIDENTIAL,
        status: LandStatus.AVAILABLE,
        price: 550000,
        surface: 400,
        imageUrl: 'assets/2.jpg',
        createdAt: DateTime.now(),
      ),
      Land(
        id: '3',
        name: 'Zone Industrielle Bir El Kassaa',
        description: 'Terrain industriel viabilisé dans la zone industrielle de Bir El Kassaa. Tous les réseaux disponibles. Idéal pour entrepôt ou usine.',
        location: 'Bir El Kassaa, Ben Arous',
        type: LandType.INDUSTRIAL,
        status: LandStatus.PENDING,
        price: 850000,
        surface: 2000,
        imageUrl: 'assets/3.jpg',
        createdAt: DateTime.now(),
      ),
      Land(
        id: '4',
        name: 'Local Commercial Centre Ville',
        description: 'Emplacement stratégique en plein centre-ville. Fort potentiel commercial. Façade sur avenue principale.',
        location: 'Centre Ville, Tunis',
        type: LandType.COMMERCIAL,
        status: LandStatus.AVAILABLE,
        price: 750000,
        surface: 300,
        imageUrl: 'assets/4.jpg',
        createdAt: DateTime.now(),
      ),
      Land(
        id: '5',
        name: 'Oliveraie à Zaghouan',
        description: 'Belle oliveraie avec plus de 500 oliviers centenaires. Source d\'eau naturelle. Maison de ferme incluse.',
        location: 'Zaghouan',
        type: LandType.AGRICULTURAL,
        status: LandStatus.AVAILABLE,
        price: 450000,
        surface: 10000,
        imageUrl: 'assets/5.jpg',
        createdAt: DateTime.now(),
      ),
      Land(
        id: '6',
        name: 'Terrain Résidentiel Les Berges du Lac',
        description: 'Terrain viabilisé dans quartier haut standing. Vue sur lac. Toutes commodités à proximité.',
        location: 'Les Berges du Lac, Tunis',
        type: LandType.RESIDENTIAL,
        status: LandStatus.SOLD,
        price: 1200000,
        surface: 600,
        imageUrl: 'assets/6.jpg',
        createdAt: DateTime.now(),
      ),
      Land(
        id: '7',
        name: 'Zone Commerciale La Soukra',
        description: 'Terrain commercial sur artère principale. Fort passage. Idéal pour projet commercial ou showroom.',
        location: 'La Soukra, Ariana',
        type: LandType.COMMERCIAL,
        status: LandStatus.AVAILABLE,
        price: 680000,
        surface: 800,
        imageUrl: 'assets/7.jpg',
        createdAt: DateTime.now(),
      ),
    ];
  }
}