class PreferencesQueries {
  static const String getUserPreferences = r'''
  query GetUserPreferences {
    getUserPreferences {
      _id
      userId
      preferredLandTypes
      minPrice
      maxPrice
      preferredLocations
      maxDistanceKm
      notificationsEnabled
      lastUpdated
      createdAt
      updatedAt
    }
  }
  ''';

  static const String updateUserPreferences = r'''
  mutation UpdateUserPreferences($preferences: UserPreferencesInput!) {
    updateUserPreferences(preferences: $preferences) {
      _id
      userId
      preferredLandTypes
      minPrice
      maxPrice
      preferredLocations
      maxDistanceKm
      notificationsEnabled
      lastUpdated
      createdAt
      updatedAt
    }
  }
  ''';

  static const String getAvailableLandTypes = r'''
  query GetAvailableLandTypes {
    getAvailableLandTypes
  }
  ''';
}