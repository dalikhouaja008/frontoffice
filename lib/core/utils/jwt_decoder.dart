import 'dart:convert';

class JwtDecoder {
  static Map<String, dynamic>? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print('[${DateTime.now()}] JwtDecoder: ❌ Invalid token format');
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(resp);

      print('[${DateTime.now()}] JwtDecoder: ✅ Token decoded successfully'
            '\n└─ Payload: $map');

      return map;
    } catch (e) {
      print('[${DateTime.now()}] JwtDecoder: ❌ Failed to decode token'
            '\n└─ Error: $e');
      return null;
    }
  }

  static bool isExpired(String token) {
    try {
      final decoded = decode(token);
      if (decoded == null) return true;

      final exp = decoded['exp'];
      if (exp == null) return true;

      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      print('[${DateTime.now()}] JwtDecoder: 🕒 Token expiry check'
            '\n└─ Expires: $expiry'
            '\n└─ Now: $now'
            '\n└─ Is expired: ${now.isAfter(expiry)}');

      return now.isAfter(expiry);
    } catch (e) {
      print('[${DateTime.now()}] JwtDecoder: ❌ Failed to check token expiry'
            '\n└─ Error: $e');
      return true;
    }
  }
}