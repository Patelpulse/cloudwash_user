class FooterLinkModel {
  final String label;
  final String route;

  FooterLinkModel({required this.label, required this.route});

  factory FooterLinkModel.fromJson(Map<String, dynamic> json) {
    return FooterLinkModel(
      label: json['label'] ?? '',
      route: json['route'] ?? '/',
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'route': route};
}

class FooterModel {
  final String description;
  final String phone;
  final String email;
  final String address;
  final String copyright;
  final List<FooterLinkModel> exploreLinks;
  final List<FooterLinkModel> serviceLinks;
  final List<FooterLinkModel> policyLinks;
  final Map<String, String> socialLinks;

  FooterModel({
    required this.description,
    required this.phone,
    required this.email,
    required this.address,
    required this.copyright,
    required this.exploreLinks,
    required this.serviceLinks,
    required this.policyLinks,
    required this.socialLinks,
  });

  factory FooterModel.fromJson(Map<String, dynamic> json) {
    List<FooterLinkModel> _parseLinks(dynamic value) {
      if (value is List) {
        return value
            .map((e) => FooterLinkModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    }

    return FooterModel(
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      copyright: json['copyright'] ?? '',
      exploreLinks: _parseLinks(json['exploreLinks']),
      serviceLinks: _parseLinks(json['serviceLinks']),
      policyLinks: _parseLinks(json['policyLinks']),
      socialLinks: (json['socialLinks'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value.toString())) ??
          {},
    );
  }
}
