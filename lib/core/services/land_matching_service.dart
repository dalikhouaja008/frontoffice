// lib/core/services/land_matching_service.dart
import 'dart:async';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/land_service.dart';
import 'package:the_boost/core/services/notification_service.dart';
import 'package:the_boost/features/auth/data/models/land_model.dart';
import 'package:the_boost/features/auth/domain/entities/notification.dart';
import 'package:the_boost/features/auth/domain/entities/user.dart';
import 'package:the_boost/features/auth/domain/entities/user_preferences.dart';
import 'package:the_boost/features/auth/domain/use_cases/preferences/get_preferences_usecase.dart';

class LandMatchingService {
  final NotificationService _notificationService;
  final LandService _landService;

  // For storing the last check timestamp per user
  final Map<String, DateTime> _lastCheckTimes = {};

  // Singleton instance
  static final LandMatchingService _instance = LandMatchingService._internal();

  factory LandMatchingService() => _instance;

  LandMatchingService._internal()
      : _notificationService = getIt<NotificationService>(),
        _landService = getIt<LandService>();

  /// Check if there are any lands that match the user's preferences
  Future<List<Land>> findMatchingLands(User user) async {
    try {
      // Get user preferences
      final GetPreferencesUseCase getPreferencesUseCase =
          getIt<GetPreferencesUseCase>();
      final preferences = await getPreferencesUseCase.execute();

      if (preferences == null || !preferences.notificationsEnabled) {
        print('[${DateTime.now()}] LandMatchingService: ℹ️ No preferences or notifications disabled'
            '\n└─ User: ${user.username}');
        return [];
      }

      // Fetch lands dynamically from the backend
      final List<Land> lands = await _landService.fetchLands();
      final DateTime lastCheckTime = _lastCheckTimes[user.id] ?? DateTime(2000); // Default to old date
      _lastCheckTimes[user.id] = DateTime.now(); // Update last check time

      // Filter lands that match preferences and were created after the last check
      final List<Land> matchingLands = lands.where((land) {
        // Check if land was created after last check (simulate new lands)
        final bool isNew = land.createdAt.isAfter(lastCheckTime);

        // If not new, skip matching check
        if (!isNew) return false;

        // Check if land matches user preferences
        return _landMatchesPreferences(land, preferences);
      }).toList();

      print('[${DateTime.now()}] LandMatchingService: ✅ Found ${matchingLands.length} matching lands'
          '\n└─ User: ${user.username}');

      // Create notifications for matching lands
      for (final Land land in matchingLands) {
        final UserNotification notification = UserNotification.landMatch(land);
        await _notificationService.addNotification(notification);

        print('[${DateTime.now()}] LandMatchingService: 🔔 Created notification'
            '\n└─ User: ${user.username}'
            '\n└─ Land: ${land.title}');
      }

      return matchingLands;
    } catch (e) {
      print('[${DateTime.now()}] LandMatchingService: ❌ Error finding matching lands'
          '\n└─ User: ${user.username}'
          '\n└─ Error: $e');
      rethrow; // Re-throw for UI handling
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
        (preferences.maxPrice != double.infinity &&
            land.price > preferences.maxPrice)) {
      return false;
    }

    // Check location (simple substring match)
    if (preferences.preferredLocations.isNotEmpty) {
      bool locationMatch = false;
      for (final String location in preferences.preferredLocations) {
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

    // Perform an initial check
    findMatchingLands(user);

    // Set up a timer for periodic checks
    Timer.periodic(period, (_) {
      findMatchingLands(user);
    });
  }
}