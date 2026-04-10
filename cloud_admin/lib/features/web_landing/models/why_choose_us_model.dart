class WhyChooseUsModel {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WhyChooseUsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  static bool _parseBool(dynamic value, {bool fallback = true}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return fallback;
  }

  factory WhyChooseUsModel.fromJson(Map<String, dynamic> json) {
    return WhyChooseUsModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      isActive: _parseBool(json['isActive'], fallback: true),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is Map && value['seconds'] != null) {
      final seconds = value['seconds'];
      final nanoseconds = value['nanoseconds'] ?? 0;
      if (seconds is num && nanoseconds is num) {
        return DateTime.fromMillisecondsSinceEpoch(
          (seconds.toInt() * 1000) + (nanoseconds.toInt() ~/ 1000000),
        );
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      '_id': id,
      'mongoId': id,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
