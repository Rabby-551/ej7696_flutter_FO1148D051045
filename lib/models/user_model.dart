class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Safely extract string values
    String getStringValue(dynamic value, [String defaultValue = '']) {
      if (value == null) return defaultValue;
      if (value is String) return value;
      return value.toString();
    }
    
    // Safely parse DateTime
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      try {
        if (value is String) {
          return DateTime.parse(value);
        } else if (value is DateTime) {
          return value;
        } else if (value is int) {
          // Handle timestamp
          return DateTime.fromMillisecondsSinceEpoch(value);
        }
      } catch (e) {
        // If parsing fails, return null
        return null;
      }
      return null;
    }
    
    // Extract ID from various possible fields
    String extractId() {
      if (json['_id'] != null) {
        return getStringValue(json['_id']);
      }
      if (json['id'] != null) {
        return getStringValue(json['id']);
      }
      return '';
    }
    
    return UserModel(
      id: extractId(),
      name: getStringValue(json['name']),
      email: getStringValue(json['email']),
      phone: json['phone'] != null ? getStringValue(json['phone']) : null,
      avatar: json['avatar'] != null ? getStringValue(json['avatar']) : null,
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
