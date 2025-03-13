// lib/core/services/land_matching_service.dart

import 'dart:async';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/notification_service.dart';
import 'package:the_boost/features/auth/data/datasources/static_lands.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/entities/notification.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';
import 'package:the_boost/features/auth/domain/use_cases/preferences/get_preferences_usecase.dart';

class LandMatchingService {
  final NotificationService _notificationService;
  
  // For storing the last check timestamp per user
  final Map<String, DateTime> _lastCheckTimes = {};
  
  // Singleton instance
  static final LandMatchingService _instance = LandMatchingService._internal();
  
  factory LandMatchingService() {
    return _instance;
  }
  
  LandMatchingService._internal() : _notificationService = getIt<NotificationService>();
  
  /// Check if there are any lands that match the user's preferences
  Future<List<Land>> findMatchingLands(User user) async {
    try {
      // Get user preferences
      final GetPreferencesUseCase getPreferencesUseCase = getIt<GetPreferencesUseCase>();
      final preferences = await getPreferencesUseCase.execute();
      
      if (preferences == null || !preferences.notificationsEnabled) {
        print('[${DateTime.now()}] LandMatchingService: ℹ️ No preferences or notifications disabled'
              '\n└─ User: ${user.username}');
        return [];
      }
      
      // Get all lands (in a real app, this would filter for new/updated lands since last check)
      final lands = StaticLandsData.getLands();
      final lastCheckTime = _lastCheckTimes[user.id] ?? DateTime(2000); // Default to old date
      _lastCheckTimes[user.id] = DateTime.now(); // Update last check time
      
      // Filter lands that match preferences and were added after last check
      final matchingLands = lands.where((land) {
        // Check if land was created after last check (simulate new lands)
        // In a real app, you'd use the actual creation/update timestamp
        final isNew = land.createdAt.isAfter(lastCheckTime);
        
        // If not new, skip matching check
        if (!isNew) return false;
        
        return _landMatchesPreferences(land, preferences);
      }).toList();
      
      print('[${DateTime.now()}] LandMatchingService: ✅ Found ${matchingLands.length} matching lands'
            '\n└─ User: ${user.username}');
      
      // Create notifications for matching lands
      for (final land in matchingLands) {
        final notification = UserNotification.landMatch(land);
        await _notificationService.addNotification(notification);
        
        print('[${DateTime.now()}] LandMatchingService: 🔔 Created notification'
              '\n└─ User: ${user.username}'
              '\n└─ Land: ${land.name}');
      }
      
      return matchingLands;
    } catch (e) {
      print('[${DateTime.now()}] LandMatchingService: ❌ Error finding matching lands'
            '\n└─ User: ${user.username}'
            '\n└─ Error: $e');
      return [];
    }
  }
  
  /// Check if a land matches the given user preferences
  bool _landMatchesPreferences(Land land, UserPreferences preferences) {
    // Check land type
    if (!preferences.preferredLandTypes.contains(land.type)) {
      return false;
    }
    
    // Check price range
    if (land.price < preferences.minPrice || 
        (preferences.maxPrice != double.infinity && land.price > preferences.maxPrice)) {
      return false;
    }
    
    // Check location (simple substring match)
    if (preferences.preferredLocations.isNotEmpty) {
      bool locationMatch = false;
      for (final location in preferences.preferredLocations) {
        if (land.location.toLowerCase().contains(location.toLowerCase())) {
          locationMatch = true;
          break;
        }
      }
      if (!locationMatch) return false;
    }
    
    return true;
  }
  
  /// Start periodic checking for matching lands
  void startPeriodicMatching(User user, {Duration period = const Duration(minutes: 30)}) {
    print('[${DateTime.now()}] LandMatchingService: 🔄 Starting periodic matching'
          '\n└─ User: ${user.username}'
          '\n└─ Period: ${period.inMinutes} minutes');
          
    // Do an initial check
    findMatchingLands(user);
    
    // Setup timer for periodic checks
    Timer.periodic(period, (_) {
      findMatchingLands(user);
    });
  }
}