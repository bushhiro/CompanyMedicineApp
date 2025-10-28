import 'dart:convert';

class ReceptionResponse {
  final int id;
  final bool isCompleted;
  final int specializationId;
  final SpecializationResponse? specialization;
  final ReceptionTemplateResponse template;
  final Map<String, dynamic> data;

  ReceptionResponse({
    required this.id,
    required this.isCompleted,
    required this.specializationId,
    this.specialization,
    required this.template,
    required this.data,
  });

  factory ReceptionResponse.fromJson(Map<String, dynamic> json) {
    return ReceptionResponse(
      id: json['id'] as int,
      isCompleted: json['is_completed'] as bool? ?? false,
      specializationId: json['specialization_id'] as int,
      specialization: json['specialization'] != null
          ? SpecializationResponse.fromJson(json['specialization'])
          : null,
      template: ReceptionTemplateResponse.fromJson(json['template']),
      data: json['data'] != null
          ? json['data'] is Map<String, dynamic>
          ? json['data']
          : jsonDecode(json['data'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_completed': isCompleted,
      'specialization_id': specializationId,
      'specialization': specialization?.toJson(),
      'template': template.toJson(),
      'data': data,
    };
  }
}

class ReceptionTemplateResponse {
  final int id;
  final String code;
  final Map<String, dynamic> fields;

  ReceptionTemplateResponse({
    required this.id,
    required this.code,
    required this.fields,
  });

  factory ReceptionTemplateResponse.fromJson(Map<String, dynamic> json) {
    return ReceptionTemplateResponse(
      id: json['id'] as int? ?? 0,
      code: json['code']?.toString() ?? '',
      fields: _parseFields(json['fields']),
    );
  }

  static Map<String, dynamic> _parseFields(dynamic fieldsData) {
    try {
      if (fieldsData == null) return {};
      if (fieldsData is Map<String, dynamic>) return fieldsData;
      if (fieldsData is String) {
        return jsonDecode(fieldsData) as Map<String, dynamic>? ?? {};
      }
      if (fieldsData is List) {
        // Если fields приходит как список, преобразуем в Map
        return {'list_data': fieldsData};
      }
      return {};
    } catch (e) {
      print('Error parsing fields: $e');
      return {};
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'fields': fields,
    };
  }
}

class SpecializationResponse {
  final int id;
  final String title;

  SpecializationResponse({
    required this.id,
    required this.title,
  });

  factory SpecializationResponse.fromJson(Map<String, dynamic> json) {
    return SpecializationResponse(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}