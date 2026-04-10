class HeroSectionModel {
  final String id;
  final String tagline;
  final String mainTitle;
  final String description;
  final String buttonText;
  final String titleFontFamily;
  final String bodyFontFamily;
  final double titleFontSize;
  final double descriptionFontSize;
  final String titleColor;
  final String descriptionColor;
  final String accentColor;
  final String buttonTextColor;
  final String imageUrl;
  final String logoUrl;
  final Map<String, String> logoByDevice;
  final double? logoHeight;
  final String? youtubeUrl;
  final bool isActive;

  HeroSectionModel({
    required this.id,
    required this.tagline,
    required this.mainTitle,
    required this.description,
    required this.buttonText,
    this.titleFontFamily = 'Playfair Display',
    this.bodyFontFamily = 'Inter',
    this.titleFontSize = 64,
    this.descriptionFontSize = 18,
    this.titleColor = '#1E293B',
    this.descriptionColor = '#64748B',
    this.accentColor = '#3B82F6',
    this.buttonTextColor = '#FFFFFF',
    required this.imageUrl,
    this.logoUrl = '',
    this.logoByDevice = const {},
    this.logoHeight,
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
      titleFontFamily: (json['titleFontFamily'] ?? 'Playfair Display')
          .toString()
          .trim(),
      bodyFontFamily: (json['bodyFontFamily'] ?? 'Inter').toString().trim(),
      titleFontSize: _parseDouble(json['titleFontSize']) ?? 64,
      descriptionFontSize: _parseDouble(json['descriptionFontSize']) ?? 18,
      titleColor: (json['titleColor'] ?? '#1E293B').toString().trim(),
      descriptionColor:
          (json['descriptionColor'] ?? '#64748B').toString().trim(),
      accentColor: (json['accentColor'] ?? '#3B82F6').toString().trim(),
      buttonTextColor:
          (json['buttonTextColor'] ?? '#FFFFFF').toString().trim(),
      imageUrl: json['imageUrl'] ?? '',
      logoUrl: resolvedLogo,
      logoByDevice: parsedLogoByDevice,
      logoHeight: (json['logoHeight'] ?? json['logo_height']) is num
          ? (json['logoHeight'] ?? json['logo_height']).toDouble()
          : double.tryParse(
              '${json['logoHeight'] ?? json['logo_height'] ?? ''}'),
      youtubeUrl: json['youtubeUrl'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tagline': tagline,
      'mainTitle': mainTitle,
      'description': description,
      'buttonText': buttonText,
      'titleFontFamily': titleFontFamily,
      'bodyFontFamily': bodyFontFamily,
      'titleFontSize': titleFontSize,
      'descriptionFontSize': descriptionFontSize,
      'titleColor': titleColor,
      'descriptionColor': descriptionColor,
      'accentColor': accentColor,
      'buttonTextColor': buttonTextColor,
      'imageUrl': imageUrl,
      'logoUrl': logoUrl,
      'logoByDevice': logoByDevice,
      'logoHeight': logoHeight,
      'youtubeUrl': youtubeUrl,
      'isActive': isActive,
    };
  }

  static Map<String, String> _parseLogoByDevice(dynamic rawValue) {
    final result = <String, String>{};
    if (rawValue is! Map) return result;

    for (final entry in rawValue.entries) {
      final key = _normalizeDeviceKey(entry.key.toString());
      final value = entry.value?.toString().trim() ?? '';
      if (key != null && value.isNotEmpty) {
        result[key] = value;
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

  static double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value == null) return null;
    return double.tryParse(value.toString().trim());
  }
}
