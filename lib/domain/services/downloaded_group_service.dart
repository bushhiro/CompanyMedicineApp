import '../../data/models/patient_group.dart';

class DownloadedGroupsService {
  // Singleton
  static final DownloadedGroupsService _instance = DownloadedGroupsService._internal();

  factory DownloadedGroupsService() => _instance;

  DownloadedGroupsService._internal();

  // Список загруженных групп
  final List<PatientGroupShortResponse> _groups = [];

  // Геттер для доступа к списку
  List<PatientGroupShortResponse> get groups => List.unmodifiable(_groups);

  // Добавление новой группы (если не добавлена ранее)
  void addGroup(PatientGroupShortResponse group) {
    if (!_groups.any((g) => g.id == group.id)) {
      _groups.add(group);
    }
  }

  // Очистка списка
  void clear() {
    _groups.clear();
  }
}