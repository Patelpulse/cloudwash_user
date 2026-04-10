class AboutUsModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final int experienceYears;
  final String imageUrl;
  final List<String> points;
  final bool isActive;

  AboutUsModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.experienceYears,
    required this.imageUrl,
    required this.points,
    required this.isActive,
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

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim()) ?? fallback;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  factory AboutUsModel.fromJson(Map<String, dynamic> json) {
    return AboutUsModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      experienceYears: _parseInt(json['experienceYears']),
      imageUrl: json['imageUrl'] ?? '',
      points: _parseStringList(json['points']),
      isActive: _parseBool(json['isActive'], fallback: true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'experienceYears': experienceYears,
      'imageUrl': imageUrl,
      'points': points,
      'isActive': isActive,
    };
  }
}
