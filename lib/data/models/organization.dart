class OrganizationShortResponse {
  final int id;
  final String title;
  final ManagerResponse manager;

  OrganizationShortResponse({
    required this.id,
    required this.title,
    required this.manager,
  });

  factory OrganizationShortResponse.fromJson(Map<String, dynamic> json) {
    return OrganizationShortResponse(
      id: json['id'] as int,
      title: json['title'] as String,
      manager: ManagerResponse.fromJson(json['manager'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'manager': manager.toJson(),
    };
  }
}

class ManagerResponse {
  final String fullName;
  final String phone;

  ManagerResponse({
    required this.fullName,
    required this.phone,
  });

  factory ManagerResponse.fromJson(Map<String, dynamic> json) {
    return ManagerResponse(
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
    };
  }
}