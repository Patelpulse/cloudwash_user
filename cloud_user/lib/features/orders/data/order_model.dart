class OrderModel {
  final String id;
  final String orderNumber;
  final String otp;
  final UserInfo user;
  final AddressInfo address;
  final List<ServiceItem> services;
  final List<AddonItem> addons;
  final PriceSummary priceSummary;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final DateTime? scheduledDate;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.otp,
    required this.user,
    required this.address,
    required this.services,
    required this.addons,
    required this.priceSummary,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    this.scheduledDate,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['orderId'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      otp: json['otp'] ?? '',
      user: UserInfo.fromJson(json['user'] ?? {}),
      address: AddressInfo.fromJson(json['address'] ?? {}),
      services:
          (json['services'] as List?)
              ?.map((e) => ServiceItem.fromJson(e))
              .toList() ??
          [],
      addons:
          (json['addons'] as List?)
              ?.map((e) => AddonItem.fromJson(e))
              .toList() ??
          [],
      priceSummary: PriceSummary.fromJson(json['priceSummary'] ?? {}),
      paymentMethod: json['paymentMethod'] ?? 'Cash',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      status: json['status'] ?? 'pending',
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
      cancellationReason: json['cancellationReason'],
      notes: json['notes'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderNumber': orderNumber,
      'otp': otp,
      'user': user.toJson(),
      'address': address.toJson(),
      'services': services.map((e) => e.toJson()).toList(),
      'addons': addons.map((e) => e.toJson()).toList(),
      'priceSummary': priceSummary.toJson(),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'status': status,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? otp,
    UserInfo? user,
    AddressInfo? address,
    List<ServiceItem>? services,
    List<AddonItem>? addons,
    PriceSummary? priceSummary,
    String? paymentMethod,
    String? paymentStatus,
    String? status,
    DateTime? scheduledDate,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      otp: otp ?? this.otp,
      user: user ?? this.user,
      address: address ?? this.address,
      services: services ?? this.services,
      addons: addons ?? this.addons,
      priceSummary: priceSummary ?? this.priceSummary,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserInfo {
  final String name;
  final String email;
  final String phone;

  UserInfo({required this.name, required this.email, required this.phone});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'phone': phone};
  }
}

class AddressInfo {
  final String? label;
  final String? name;
  final String? phone;
  final String? houseNumber;
  final String? street;
  final String? landmark;
  final String? city;
  final String? pincode;
  final String? fullAddress;

  AddressInfo({
    this.label,
    this.name,
    this.phone,
    this.houseNumber,
    this.street,
    this.landmark,
    this.city,
    this.pincode,
    this.fullAddress,
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      label: json['label'],
      name: json['name'],
      phone: json['phone'],
      houseNumber: json['houseNumber'],
      street: json['street'],
      landmark: json['landmark'],
      city: json['city'],
      pincode: json['pincode'],
      fullAddress: json['fullAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'name': name,
      'phone': phone,
      'houseNumber': houseNumber,
      'street': street,
      'landmark': landmark,
      'city': city,
      'pincode': pincode,
      'fullAddress': fullAddress,
    };
  }
}

class ServiceItem {
  final String? serviceId;
  final String name;
  final String? categoryName;
  final String? subCategoryName;
  final double price;
  final int quantity;
  final double total;

  ServiceItem({
    this.serviceId,
    required this.name,
    this.categoryName,
    this.subCategoryName,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      serviceId: json['serviceId'],
      name: json['name'] ?? '',
      categoryName: json['categoryName'],
      subCategoryName: json['subCategoryName'],
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'name': name,
      'categoryName': categoryName,
      'subCategoryName': subCategoryName,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }
}

class AddonItem {
  final String? addonId;
  final String name;
  final double price;

  AddonItem({this.addonId, required this.name, required this.price});

  factory AddonItem.fromJson(Map<String, dynamic> json) {
    return AddonItem(
      addonId: json['addonId'],
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'addonId': addonId, 'name': name, 'price': price};
  }
}

class PriceSummary {
  final double subtotal;
  final double tax;
  final double deliveryCharge;
  final double discount;
  final double total;

  PriceSummary({
    required this.subtotal,
    required this.tax,
    required this.deliveryCharge,
    required this.discount,
    required this.total,
  });

  factory PriceSummary.fromJson(Map<String, dynamic> json) {
    return PriceSummary(
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      deliveryCharge: (json['deliveryCharge'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'tax': tax,
      'deliveryCharge': deliveryCharge,
      'discount': discount,
      'total': total,
    };
  }
}
