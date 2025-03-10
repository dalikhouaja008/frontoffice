import 'package:the_boost/features/auth/data/models/land_model.dart';

import '../models/property_model.dart';
import '../models/user_model.dart';

class MockData {
  static final List<Land> properties = [
    Land(
      id: "67cc49c20984a92a5c99917e",
      name: "Terrain à Tunis",
      description: "Beau terrain constructible",
      location: "Tunis, Lac 2",
      type: LandType.RESIDENTIAL,
      status: LandStatus.AVAILABLE,
      price: 500000.0,
      surface: 1000.0,
      imageUrl: "https://example.com/image.jpg",
      createdAt: DateTime.parse("2025-03-08T13:44:34.779Z"),
      title: "Terrain à Tunis",
    ),
    Land(
      id: "67cc4a5b0984a92a5c999182",
      name: "Terrain à Djerba",
      description: "Beau terrain",
      location: "Djerba",
      type: LandType.RESIDENTIAL,
      status: LandStatus.AVAILABLE,
      price: 300000.0,
      surface: 800.0,
      imageUrl: "https://example.com/image2.jpg",
      createdAt: DateTime.parse("2025-03-08T13:47:07.047Z"),
      title: "Terrain à Djerba",
    ),
    Land(
      id: "67cc4a5b0984a92a5c999183",
      name: "Terrain à Sousse",
      description: "Terrain idéal pour un projet touristique",
      location: "Sousse",
      type: LandType.COMMERCIAL,
      status: LandStatus.PENDING,
      price: 750000.0,
      surface: 1200.0,
      imageUrl: "https://example.com/image3.jpg",
      createdAt: DateTime.parse("2025-03-08T13:50:00.000Z"),
      title: "Terrain à Sousse",
    ),
  ];

  static final List<UserModel> users = [
    UserModel(
      id: '1',
      username: 'John Doe',
      email: 'john@example.com',
      createdAt: DateTime(2023, 1, 15), 
      role: '', 
      accessToken: '', 
      refreshToken: '', 
      updatedAt: DateTime.now(),
    ),
  ];
}