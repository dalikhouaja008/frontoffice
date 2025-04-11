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
  final Map<String, DateTime> _lastCheckTimes = {};
  Timer? _periodicTimer;

  static final LandMatchingService _instance = LandMatchingService._internal();
  factory LandMatchingService() => _instance;

  LandMatchingService._internal()
      : _notificationService = getIt<NotificationService>(),
        _landService = getIt<LandService>();

  Future<List<Land>> findMatchingLands(User user) async {
    try {
      final preferences = await _getUserPreferences();
      if (preferences == null || !preferences.notificationsEnabled) {
        print('[${DateTime.now()}] LandMatchingService: ℹ️ No preferences or notifications disabled'
            '\n└─ User: ${user.username}');
        return [];
      }

      final lands = await _landService.fetchLands();
      final lastCheckTime = _lastCheckTimes[user.id] ?? DateTime(2000);
      _lastCheckTimes[user.id] = DateTime.now();

      final matchingLands = lands
          .where((land) =>
              land.createdAt.isAfter(lastCheckTime) && _matchesPreferences(land, preferences))
          .toList();

      await _createNotifications(user, matchingLands);
      return matchingLands;
    } catch (e) {
      print('[${DateTime.now()}] LandMatchingService: ❌ Error finding matches'
          '\n└─ User: ${user.username}'
          '\n└─ Error: $e');
      rethrow;
    }
  }

  void startPeriodicMatching(User user, {Duration period = const Duration(minutes: 30)}) {
    stopPeriodicMatching();

    print('[${DateTime.now()}] LandMatchingService: 🔄 Starting periodic matching'
        '\n└─ User: ${user.username}'
        '\n└─ Period: ${period.inMinutes} minutes');

    findMatchingLands(user);

    _periodicTimer = Timer.periodic(period, (_) => findMatchingLands(user));
  }

  void stopPeriodicMatching() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  bool _matchesPreferences(Land land, UserPreferences preferences) {
    final landPrice = land.totalPrice;
    return landPrice >= preferences.minPrice &&
        (preferences.maxPrice == double.infinity || landPrice <= preferences.maxPrice) &&
        (preferences.preferredLocations.isEmpty ||
            preferences.preferredLocations.any(
                (loc) => land.location.toLowerCase().contains(loc.toLowerCase())));
  }

  Future<UserPreferences?> _getUserPreferences() async {
    final getPreferencesUseCase = getIt<GetPreferencesUseCase>();
    return await getPreferencesUseCase.execute();
  }

  Future<void> _createNotifications(User user, List<Land> matchingLands) async {
    for (final land in matchingLands) {
      final notification = UserNotification.landMatch(land);
      await _notificationService.addNotification(notification);
      print('[${DateTime.now()}] LandMatchingService: 🔔 Notification created'
          '\n└─ User: ${user.username}'
          '\n└─ Land: ${land.title}');
    }
  }
}