class StaticPageModel {
  final String id;
  final String slug;
  final String title;
  final String subtitle;
  final String body;
  final String imageUrl;
  final bool isActive;
  final DateTime? updatedAt;

  StaticPageModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.imageUrl,
    required this.isActive,
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

  factory StaticPageModel.fromJson(Map<String, dynamic> json) {
    return StaticPageModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      body: (json['body'] ?? json['content'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      isActive: _parseBool(json['isActive'], fallback: true),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'slug': slug,
      'title': title,
      'subtitle': subtitle,
      'body': body,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
