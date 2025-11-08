import 'flg.dart';
import 'analysis.dart';
import 'reception.dart';
import 'vaccine.dart';

class PatientResponse {
  final int id;
  final String fullName;
  final DateTime birthDate;
  final int age;
  final String gender;
  final String position;
  final String division;
  final int patientGroupID;

  final int? examinationType;
  final int? examinationView;

  final HarmPointResponse harmPoint;
  final PersonalInfoResponse personalInfo;
  final ContactInfoResponse contactInfo;
  final AnalysisOrderResponse analysisOrder;
  final PatientStatisticsResponse? statistics;
  final List<FlgResponse> flgs;

  final List<VaccineAllResponse> vaccines;
  final List<ReceptionResponse> receptions;
  final List<SpecializationResponse> specializations;

  PatientResponse({
    required this.id,
    required this.fullName,
    required this.birthDate,
    required this.age,
    required this.gender,
    required this.position,
    required this.division,
    required this.patientGroupID,
    this.examinationType,
    this.examinationView,
    required this.harmPoint,
    required this.personalInfo,
    required this.contactInfo,
    required this.analysisOrder,
    this.statistics,
    required this.flgs,
    required this.vaccines,
    required this.receptions,
    required this.specializations,
  });

  factory PatientResponse.fromJson(Map<String, dynamic> json) {
    try {
      return PatientResponse(
        id: json['id'] as int? ?? 0,
        fullName: json['full_name']?.toString() ?? '',
        birthDate: DateTime.tryParse(json['birth_date']?.toString() ?? '') ?? DateTime(2000),
        age: json['age'] as int? ?? 0,
        gender: json['gender']?.toString() ?? 'Не указан',
        position: json['position']?.toString() ?? '',
        division: json['division']?.toString() ?? '',
        patientGroupID: json['patient_group_id'] as int? ?? 0,
        examinationType: json['examination_type'] as int?,
        examinationView: json['examination_view'] as int?,
        harmPoint: json['harm_point'] != null
            ? HarmPointResponse.fromJson(json['harm_point'])
            : HarmPointResponse.empty(),
        personalInfo: json['personal_info'] != null
            ? PersonalInfoResponse.fromJson(json['personal_info'])
            : PersonalInfoResponse.empty(),
        contactInfo: json['contact_info'] != null
            ? ContactInfoResponse.fromJson(json['contact_info'])
            : ContactInfoResponse.empty(),
        analysisOrder: json['analysis_order'] != null
            ? AnalysisOrderResponse.fromJson(json['analysis_order'])
            : AnalysisOrderResponse.empty(),
        statistics: json['statistics'] != null
            ? PatientStatisticsResponse.fromJson(json['statistics'])
            : null,
        flgs: (json['flgs'] as List?)
            ?.map((e) => FlgResponse.fromJson(e as Map<String, dynamic>))
            .toList() ??
            [],
        vaccines: (json['vaccines'] as List?)
            ?.map((e) => VaccineAllResponse.fromJson(e as Map<String, dynamic>))
            .toList() ??
            [],
        receptions: (json['receptions'] as List?)
            ?.map((e) => ReceptionResponse.fromJson(e as Map<String, dynamic>))
            .toList() ??
            [],
        specializations: (json['receptions'] as List?)
            ?.map((e) => e['specialization'] != null
            ? SpecializationResponse.fromJson(e['specialization'])
            : SpecializationResponse.empty())
            .toList() ??
            [],
      );
    } catch (e, stack) {
      print('Ошибка парсинга PatientResponse: $e\n$stack');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'birth_date': birthDate.toIso8601String(),
      'age': age,
      'gender': gender,
      'position': position,
      'division': division,
      'patient_group_id': patientGroupID,
      'examination_type': examinationType,
      'examination_view': examinationView,
      'harm_point': harmPoint.toJson(),
      'personal_info': personalInfo.toJson(),
      'contact_info': contactInfo.toJson(),
      'analysis_order': analysisOrder.toJson(),
      'statistics': statistics?.toJson(),
      'flgs': flgs.map((e) => e.toJson()).toList(),
      'vaccines': vaccines.map((e) => e.toJson()).toList(),
      'receptions': receptions.map((e) => e.toJson()).toList(),
      'specializations': specializations.map((e) => e.toJson()).toList(),
    };
  }
}

// ------------------ вложенные модели ------------------

class HarmPointResponse {
  final int id;
  final String value;

  HarmPointResponse({required this.id, required this.value});

  factory HarmPointResponse.fromJson(Map<String, dynamic> json) {
    return HarmPointResponse(
      id: json['id'] as int? ?? 0,
      value: json['value']?.toString() ?? '',
    );
  }

  factory HarmPointResponse.empty() => HarmPointResponse(id: 0, value: '');

  Map<String, dynamic> toJson() => {'id': id, 'value': value};
}

class PersonalInfoResponse {
  final int id;
  final String docNumber;
  final String docSeries;
  final String snils;
  final String oms;
  final int? documentType;

  PersonalInfoResponse({
    required this.id,
    required this.docNumber,
    required this.docSeries,
    required this.snils,
    required this.oms,
    this.documentType,
  });

  factory PersonalInfoResponse.fromJson(Map<String, dynamic> json) {
    return PersonalInfoResponse(
      id: json['id'] as int? ?? 0,
      docNumber: json['doc_number']?.toString() ?? '',
      docSeries: json['doc_series']?.toString() ?? '',
      snils: json['snils']?.toString() ?? '',
      oms: json['oms']?.toString() ?? '',
      documentType: json['document_type'] as int?,
    );
  }

  factory PersonalInfoResponse.empty() => PersonalInfoResponse(
    id: 0,
    docNumber: '',
    docSeries: '',
    snils: '',
    oms: '',
    documentType: null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'doc_number': docNumber,
    'doc_series': docSeries,
    'snils': snils,
    'oms': oms,
    'document_type': documentType,
  };
}

class ContactInfoResponse {
  final int id;
  final String phone;
  final String email;
  final String address;

  ContactInfoResponse({
    required this.id,
    required this.phone,
    required this.email,
    required this.address,
  });

  factory ContactInfoResponse.fromJson(Map<String, dynamic> json) {
    return ContactInfoResponse(
      id: json['id'] as int? ?? 0,
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }

  factory ContactInfoResponse.empty() =>
      ContactInfoResponse(id: 0, phone: '', email: '', address: '');

  Map<String, dynamic> toJson() =>
      {'id': id, 'phone': phone, 'email': email, 'address': address};
}

class PatientStatisticsResponse {
  final int id;
  final int totalReceptions;
  final int completedReceptions;
  final int totalAnalysisOrders;
  final int completedAnalysisItems;

  PatientStatisticsResponse({
    required this.id,
    required this.totalReceptions,
    required this.completedReceptions,
    required this.totalAnalysisOrders,
    required this.completedAnalysisItems,
  });

  factory PatientStatisticsResponse.fromJson(Map<String, dynamic> json) {
    return PatientStatisticsResponse(
      id: json['id'] as int? ?? 0,
      totalReceptions: json['total_receptions'] as int? ?? 0,
      completedReceptions: json['completed_receptions'] as int? ?? 0,
      totalAnalysisOrders: json['total_analysis_orders'] as int? ?? 0,
      completedAnalysisItems: json['completed_analysis_items'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'total_receptions': totalReceptions,
    'completed_receptions': completedReceptions,
    'total_analysis_orders': totalAnalysisOrders,
    'completed_analysis_items': completedAnalysisItems,
  };
}

class SpecializationResponse {
  final int id;
  final String title;

  SpecializationResponse({required this.id, required this.title});

  factory SpecializationResponse.fromJson(Map<String, dynamic> json) {
    return SpecializationResponse(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
    );
  }

  factory SpecializationResponse.empty() => SpecializationResponse(id: 0, title: '');

  Map<String, dynamic> toJson() => {'id': id, 'title': title};
}