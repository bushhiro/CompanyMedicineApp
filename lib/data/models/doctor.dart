class DoctorResponse {
  final String fullName;
  final List<SpecializationResponse>? specializations;

  DoctorResponse({
    required this.fullName,
    this.specializations,
  });

  factory DoctorResponse.fromJson(Map<String, dynamic> json) {
    return DoctorResponse(
      fullName: json['full_name'],
      specializations: json['specializations'] != null
          ? (json['specializations'] as List)
          .map((e) => SpecializationResponse.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'specializations': specializations?.map((e) => e.toJson()).toList(),
  };
}

class DoctorLoginRequest {
  final String phone;
  final String password;

  DoctorLoginRequest({required this.phone, required this.password});

  factory DoctorLoginRequest.fromJson(Map<String, dynamic> json) {
    return DoctorLoginRequest(
      phone: json['phone'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'password': password,
  };
}

class DoctorAuthResponse {
  final int id;
  final String token;

  DoctorAuthResponse({required this.id, required this.token});

  factory DoctorAuthResponse.fromJson(Map<String, dynamic> json) {
    return DoctorAuthResponse(
      id: json['id'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'token': token,
  };
}

class DoctorInfoResponse {
  final int doctorId;
  final String fullName;
  final String specialization;

  DoctorInfoResponse({
    required this.doctorId,
    required this.fullName,
    required this.specialization,
  });

  factory DoctorInfoResponse.fromJson(Map<String, dynamic> json) {
    return DoctorInfoResponse(
      doctorId: json['doctor_id'],
      fullName: json['full_name'],
      specialization: json['specialization'],
    );
  }

  Map<String, dynamic> toJson() => {
    'doctor_id': doctorId,
    'full_name': fullName,
    'specialization': specialization,
  };
}

class CreateDoctorRequest {
  final String fullName;
  final String phone;
  final String password;
  final int specializationId;

  CreateDoctorRequest({
    required this.fullName,
    required this.phone,
    required this.password,
    required this.specializationId,
  });

  factory CreateDoctorRequest.fromJson(Map<String, dynamic> json) {
    return CreateDoctorRequest(
      fullName: json['full_name'],
      phone: json['phone'],
      password: json['password'],
      specializationId: json['specialization_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'phone': phone,
    'password': password,
    'specialization_id': specializationId,
  };
}

class UpdateDoctorRequest {
  final int id;
  final String fullName;
  final String phone;
  final int specializationId;

  UpdateDoctorRequest({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.specializationId,
  });

  factory UpdateDoctorRequest.fromJson(Map<String, dynamic> json) {
    return UpdateDoctorRequest(
      id: json['id'],
      fullName: json['full_name'],
      phone: json['phone'],
      specializationId: json['specialization_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'phone': phone,
    'specialization_id': specializationId,
  };
}

class DoctorShortResponse {
  final int id;
  final String fullName;
  final String specialization;

  DoctorShortResponse({
    required this.id,
    required this.fullName,
    required this.specialization,
  });

  factory DoctorShortResponse.fromJson(Map<String, dynamic> json) {
    return DoctorShortResponse(
      id: json['id'],
      fullName: json['full_name'],
      specialization: json['specialization'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'specialization': specialization,
  };
}

// Вспомогательная модель для специализации
class SpecializationResponse {
  final int id;
  final String title;

  SpecializationResponse({required this.id, required this.title});

  factory SpecializationResponse.fromJson(Map<String, dynamic> json) {
    return SpecializationResponse(
      id: json['id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
  };
}