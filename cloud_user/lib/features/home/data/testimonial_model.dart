class TestimonialModel {
  final String id;
  final String name;
  final String role;
  final String message;
  final double rating;
  final String imageUrl;
  final bool isActive;

  TestimonialModel({
    required this.id,
    required this.name,
    required this.role,
    required this.message,
    required this.rating,
    required this.imageUrl,
    required this.isActive,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    final role = (json['role'] ?? json['designation'] ?? 'Customer')
        .toString()
        .trim();
    final ratingValue = json['rating'];
    final rating = ratingValue is num
        ? ratingValue.toDouble()
        : double.tryParse(ratingValue?.toString() ?? '') ?? 5.0;

    final isActiveValue = json['isActive'];
    final isActive = isActiveValue is bool
        ? isActiveValue
        : isActiveValue is num
            ? isActiveValue != 0
            : isActiveValue is String
                ? (() {
                    final normalized = isActiveValue.trim().toLowerCase();
                    if (normalized == 'true' || normalized == '1') return true;
                    if (normalized == 'false' || normalized == '0') {
                      return false;
                    }
                    return true;
                  })()
                : true;

    return TestimonialModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      role: role.isNotEmpty ? role : 'Customer',
      message: json['message'] ?? '',
      rating: rating,
      imageUrl: (json['imageUrl'] ?? '').toString().trim(),
      isActive: isActive,
    );
  }
}
