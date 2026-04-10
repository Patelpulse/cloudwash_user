class WhyChooseUsModel {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final bool isActive;

  WhyChooseUsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
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

  factory WhyChooseUsModel.fromJson(Map<String, dynamic> json) {
    return WhyChooseUsModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      isActive: _parseBool(json['isActive'], fallback: true),
    );
  }
}
