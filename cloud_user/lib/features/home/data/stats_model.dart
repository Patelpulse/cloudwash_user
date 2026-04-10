class StatsModel {
  final String id;
  final String happyClients;
  final String totalBranches;
  final String totalCities;
  final String totalOrders;
  final bool isActive;

  StatsModel({
    required this.id,
    required this.happyClients,
    required this.totalBranches,
    required this.totalCities,
    required this.totalOrders,
    required this.isActive,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      id: (json['_id'] ?? '').toString(),
      happyClients: (json['happyClients'] ?? '').toString(),
      totalBranches: (json['totalBranches'] ?? '').toString(),
      totalCities: (json['totalCities'] ?? '').toString(),
      totalOrders: (json['totalOrders'] ?? '').toString(),
      isActive: _parseBool(json['isActive'], fallback: true),
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
