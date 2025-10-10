class PatientGroupShortResponse {
  final int id;
  final DateTime createdAt;
  final String code;
  final String organizationTitle;

  PatientGroupShortResponse({
    required this.id,
    required this.createdAt,
    required this.code,
    required this.organizationTitle,
  });

  factory PatientGroupShortResponse.fromJson(Map<String, dynamic> json) {
    return PatientGroupShortResponse(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      code: json['code'] as String,
      organizationTitle: json['organization'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'code': code,
      'organization': organizationTitle,
    };
  }
}

class DownloadedGroupsService {
  static final DownloadedGroupsService _instance = DownloadedGroupsService._internal();
  factory DownloadedGroupsService() => _instance;
  DownloadedGroupsService._internal();

  final List<PatientGroupShortResponse> _groups = [];

  List<PatientGroupShortResponse> get groups => List.unmodifiable(_groups);

  void addGroup(PatientGroupShortResponse group) {
    if (!_groups.any((g) => g.id == group.id)) {
      _groups.add(group);
    }
  }

  void clear() => _groups.clear();
}