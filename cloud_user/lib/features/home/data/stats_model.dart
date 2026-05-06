class StatsModel {
  final String id;
  final String happyClients;
  final String totalBranches;
  final String totalCities;
  final String totalOrders;
  final bool isActive;
  final String appDownloadTag;
  final String appDownloadTitle;
  final String appDownloadSubtitle;
  final String appStoreUrl;
  final String playStoreUrl;

  StatsModel({
    required this.id,
    required this.happyClients,
    required this.totalBranches,
    required this.totalCities,
    required this.totalOrders,
    required this.isActive,
    this.appDownloadTag = 'DOWNLOAD THE APP',
    this.appDownloadTitle = 'Your Personal Laundry\nManager in Your Pocket',
    this.appDownloadSubtitle = 'Book, track, and manage your laundry needs with a single tap. Join 50,000+ happy users today.',
    this.appStoreUrl = '#',
    this.playStoreUrl = '#',
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      id: (json['_id'] ?? '').toString(),
      happyClients: (json['happyClients'] ?? '').toString(),
      totalBranches: (json['totalBranches'] ?? '').toString(),
      totalCities: (json['totalCities'] ?? '').toString(),
      totalOrders: (json['totalOrders'] ?? '').toString(),
      isActive: _parseBool(json['isActive'], fallback: true),
      appDownloadTag: (json['appDownloadTag'] ?? 'DOWNLOAD THE APP').toString(),
      appDownloadTitle: (json['appDownloadTitle'] ?? 'Your Personal Laundry\nManager in Your Pocket').toString(),
      appDownloadSubtitle: (json['appDownloadSubtitle'] ?? 'Book, track, and manage your laundry needs with a single tap. Join 50,000+ happy users today.').toString(),
      appStoreUrl: (json['appStoreUrl'] ?? '#').toString(),
      playStoreUrl: (json['playStoreUrl'] ?? '#').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'happyClients': happyClients,
      'totalBranches': totalBranches,
      'totalCities': totalCities,
      'totalOrders': totalOrders,
      'isActive': isActive,
      'appDownloadTag': appDownloadTag,
      'appDownloadTitle': appDownloadTitle,
      'appDownloadSubtitle': appDownloadSubtitle,
      'appStoreUrl': appStoreUrl,
      'playStoreUrl': playStoreUrl,
    };
  }

  static bool _parseBool(dynamic value, {required bool fallback}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return fallback;
  }
}
