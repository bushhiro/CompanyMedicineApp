import 'flg.dart';
import 'analysis.dart';
import 'reception.dart';
import 'vaccine.dart';

class PatientResponse {
  final int id;
  final String fullName;
  final DateTime birthDate;
  final int age;
  final bool isMale;
  final String position;
  final String division;
  final int patientGroupID;

  final String? examinationType;
  final String? examinationView;

  final HarmPointResponse harmPoint;
  final PersonalInfoResponse personalInfo;
  final ContactInfoResponse contactInfo;
  final AnalysisOrderResponse analysisOrder;
  final PatientStatisticsResponse? statistics;
  final FlgResponse? flg;

  final List<VaccineAllResponse>? vaccines;
  final List<ReceptionResponse>? receptions;
  final List<SpecializationResponse>? specializations;

  PatientResponse({
    required this.id,
    required this.fullName,
    required this.birthDate,
    required this.age,
    required this.isMale,
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
    this.flg,
    this.vaccines,
    this.receptions,
    this.specializations,
  });

  factory PatientResponse.fromJson(Map<String, dynamic> json) {
    return PatientResponse(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      age: json['age'] as int,
      isMale: json['is_male'] as bool,
      position: json['position'] as String,
      division: json['division'] as String,
      patientGroupID: json['patient_group_id'] as int,
      examinationType: json['examination_type'] as String?,
      examinationView: json['examination_view'] as String?,
      harmPoint: HarmPointResponse.fromJson(json['harm_point']),
      personalInfo: PersonalInfoResponse.fromJson(json['personal_info']),
      contactInfo: ContactInfoResponse.fromJson(json['contact_info']),
      analysisOrder: AnalysisOrderResponse.fromJson(json['analysis_order']),
      statistics: json['statistics'] != null
          ? PatientStatisticsResponse.fromJson(json['statistics'])
          : null,
      flg: json['flg'] != null ? FlgResponse.fromJson(json['flg']) : null,
      vaccines: json['vaccines'] != null
          ? (json['vaccines'] as List)
          .map((e) => VaccineAllResponse.fromJson(e))
          .toList()
          : null,
      receptions: json['receptions'] != null
          ? (json['receptions'] as List)
          .map((e) => ReceptionResponse.fromJson(e))
          .toList()
          : null,
      specializations: json['specializations'] != null
          ? (json['specializations'] as List)
          .map((e) => SpecializationResponse.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'birth_date': birthDate.toIso8601String(),
      'age': age,
      'is_male': isMale,
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
      'flg': flg?.toJson(),
      'vaccines': vaccines?.map((e) => e.toJson()).toList(),
      'receptions': receptions?.map((e) => e.toJson()).toList(),
      'specializations': specializations?.map((e) => e.toJson()).toList(),
    };
  }
}

class HarmPointResponse {
  final int id;
  final String value;

  HarmPointResponse({required this.id, required this.value});

  factory HarmPointResponse.fromJson(Map<String, dynamic> json) {
    return HarmPointResponse(id: json['id'] as int, value: json['value'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'value': value};
}

class PersonalInfoResponse {
  final int id;
  final String docNumber;
  final String docSeries;
  final String snils;
  final String oms;
  final String? documentType;

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
      id: json['id'] as int,
      docNumber: json['doc_number'] as String,
      docSeries: json['doc_series'] as String,
      snils: json['snils'] as String,
      oms: json['oms'] as String,
      documentType: json['document_type'] as String?,
    );
  }

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
      id: json['id'] as int,
      phone: json['phone'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
    );
  }

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
      id: json['id'] as int,
      totalReceptions: json['total_receptions'] as int,
      completedReceptions: json['completed_receptions'] as int,
      totalAnalysisOrders: json['total_analysis_orders'] as int,
      completedAnalysisItems: json['completed_analysis_items'] as int,
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
    return SpecializationResponse(id: json['id'] as int, title: json['title'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'title': title};
}