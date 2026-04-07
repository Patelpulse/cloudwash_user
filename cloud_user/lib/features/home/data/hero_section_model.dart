class HeroSectionModel {
  final String id;
  final String tagline;
  final String mainTitle;
  final String description;
  final String buttonText;
  final String imageUrl;
  final String logoUrl;
  final Map<String, String> logoByDevice;
  final double logoHeight;
  final String? youtubeUrl;
  final bool isActive;

  HeroSectionModel({
    required this.id,
    required this.tagline,
    required this.mainTitle,
    required this.description,
    required this.buttonText,
    required this.imageUrl,
    this.logoUrl = '',
    this.logoByDevice = const {},
    this.logoHeight = 140,
    this.youtubeUrl,
    required this.isActive,
  });

  factory HeroSectionModel.fromJson(Map<String, dynamic> json) {
    final parsedLogoByDevice = _parseLogoByDevice(json['logoByDevice']);
    final legacyLogo = (json['logoUrl'] ?? '').toString().trim();
    if (legacyLogo.isNotEmpty && !parsedLogoByDevice.containsKey('website')) {
      parsedLogoByDevice['website'] = legacyLogo;
    }
    final resolvedLogo = parsedLogoByDevice['website'] ?? legacyLogo;

    return HeroSectionModel(
      id: json['_id'] ?? '',
      tagline: json['tagline'] ?? '',
      mainTitle: json['mainTitle'] ?? '',
      description: json['description'] ?? '',
      buttonText: json['buttonText'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      logoUrl: resolvedLogo,
      logoByDevice: parsedLogoByDevice,
      logoHeight: (json['logoHeight'] ?? json['logo_height']) is num
          ? (json['logoHeight'] ?? json['logo_height']).toDouble()
          : double.tryParse(
                  '${json['logoHeight'] ?? json['logo_height'] ?? ''}') ??
              140,
      youtubeUrl: json['youtubeUrl'],
      isActive: json['isActive'] ?? true,
    );
  }

  static Map<String, String> _parseLogoByDevice(dynamic rawValue) {
    final result = <String, String>{};
    if (rawValue is! Map) return result;

    for (final entry in rawValue.entries) {
      final normalizedKey = _normalizeDeviceKey(entry.key.toString());
      final logo = entry.value?.toString().trim() ?? '';
      if (normalizedKey != null && logo.isNotEmpty) {
        result[normalizedKey] = logo;
      }
    }
    return result;
  }

  static String? _normalizeDeviceKey(String rawKey) {
    final key = rawKey.trim().toLowerCase();
    if (key == 'phone' || key == 'mobile') return 'phone';
    if (key == 'tablet' || key == 'tab') return 'tablet';
    if (key == 'website' || key == 'web' || key == 'desktop') {
      return 'website';
    }
    return null;
  }
}
