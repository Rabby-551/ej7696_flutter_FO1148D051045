import 'user_model.dart';

class AuthResponse {
  final String? accessToken;
  final String? refreshToken;
  final String? role;
  final String? userId;
  final UserModel? user;

  AuthResponse({
    this.accessToken,
    this.refreshToken,
    this.role,
    this.userId,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Handle both registration (user data at top level) and login (nested user) responses
      // The backend returns user data with accessToken at the top level
      final userData = json['user'] ?? json; // If no 'user' key, use the entire json as user data
      
      // Safely extract string fields, handling cases where they might be null or different types
      String? getStringValue(dynamic value) {
        if (value == null) return null;
        if (value is String) return value;
        return value.toString();
      }
      
      // Safely extract userId
      String? extractUserId(Map<String, dynamic> data) {
        if (data['_id'] != null) {
          return getStringValue(data['_id']);
        }
        if (data['userId'] != null) {
          return getStringValue(data['userId']);
        }
        if (data['id'] != null) {
          return getStringValue(data['id']);
        }
        return null;
      }
      
      // Parse user model safely
      UserModel? parsedUser;
      if (userData is Map<String, dynamic>) {
        try {
          parsedUser = UserModel.fromJson(userData);
        } catch (e) {
          // If user parsing fails, continue without user data
          print('Warning: Failed to parse user data: $e');
        }
      }
      
      return AuthResponse(
        accessToken: getStringValue(json['accessToken']),
        refreshToken: getStringValue(json['refreshToken']),
        role: getStringValue(json['role']),
        userId: extractUserId(json),
        user: parsedUser,
      );
    } catch (e, stackTrace) {
      print('Error parsing AuthResponse: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'role': role,
      '_id': userId,
      'user': user?.toJson(),
    };
  }
}
