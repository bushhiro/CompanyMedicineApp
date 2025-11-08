
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:work_app/data/repositories/analysis_repository.dart';
import 'package:work_app/data/repositories/manual_repository.dart';
import 'package:work_app/data/repositories/patient_repository.dart';
import '../../data/models/patient_group.dart';
import '../../data/network/network_service.dart';
import '../../data/repositories/patient_group_impl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/action_buttons.dart';
import '../../widgets/custom_app_bar.dart';
import 'patients_list_screen.dart';

class PatientGroupsScreen extends StatefulWidget {
  final String organizationId;
  final String organizationName;

  const PatientGroupsScreen({
    super.key,
    required this.organizationId,
    required this.organizationName,
  });



  @override
  State<PatientGroupsScreen> createState() => _PatientGroupsScreenState();
}

class _PatientGroupsScreenState extends State<PatientGroupsScreen> {
  late final PatientGroupRepository _repository;
  final PatientRepository _patientRepository = PatientRepository(
    remote: PatientRepositoryRemote(baseUrl: 'http://192.168.29.112:65322/api/v1'),
    networkService: NetworkService(),
  );
  final ManualRepository _manualRepository = ManualRepository(
      remoteService: ManualRemoteService(baseUrl: 'http://192.168.29.112:65322/api/v1'));

  final AnalysisRepository _analysisRepository = AnalysisRepository(
      remoteService: AnalysisRemoteService(baseUrl: 'http://192.168.29.112:65322/api/v1'));

  List<PatientGroupShortResponse> _allGroups = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = PatientGroupRepository(
      remoteService: PatientGroupImpl(baseUrl: 'http://192.168.29.112:65322/api/v1'),
    );
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final groups = await _repository.getGroups(widget.organizationId);
      if (mounted) {
        setState(() {
          _allGroups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _allGroups = [];
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: CustomAppBar(
        title: "Списки на прохождение",
        subtitle: "Всего списков: ${_allGroups.length}",
        showBackButton: true,
        showDrawerButton: false,
      ),
      body: Column(
        children: [
          ActionButtons(
            reloadOrganizations: _loadGroups,
            showRefresh: true,
            refreshLabel: "Обновить списки",
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text("Ошибка: $_error"))
                : _allGroups.isEmpty
                ? const Center(child: Text("Нет списков"))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _allGroups.length,
              itemBuilder: (context, index) {
                final group = _allGroups[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      border: Border.all(color: AppColors.borderColor, width: 2),
                    ),
                    child: SizedBox(
                      height: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(group.code,
                                      style: const TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      softWrap: true),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Дата создания: ${_formatDate(group.createdAt)}",
                                    style: const TextStyle(fontSize: 14, color: AppColors.hintColor),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Организация: ${group.organizationTitle}",
                                    style: const TextStyle(fontSize: 14, color: AppColors.hintColor),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            ActionButtons(
                              showOpen: true,
                              buttonSize: const Size(150, 60),
                              onOpen: () async {
                                await _repository.localDao.insertGroup(group);

                                // Проверяем, есть ли справочники в локальной базе
                                final localManuals = await _manualRepository.localDao.getAllManuals();

                                if (localManuals.isEmpty) {
                                  try {
                                    // Если базы нет, пробуем загрузить с сервера и сохранить в БД
                                    final remoteManuals = await _manualRepository.remoteService.fetchManuals();
                                    await _manualRepository.insertManualsToDB(remoteManuals);
                                  } catch (e) {
                                    // Если интернета нет или ошибка — просто логируем
                                    print("Не удалось загрузить manuals с сервера: $e");
                                  }
                                }

                                final localAnalyses = await _analysisRepository.localDao.getAllAnalyses();
                                if (localAnalyses.isEmpty) {
                                  try {
                                    final remoteAnalyses = await _analysisRepository.remoteService.fetchAnalyses();
                                    await _analysisRepository.insertAnalysesToDB(remoteAnalyses);
                                  } catch (e) {
                                    print("Не удалось загрузить analyses с сервера: $e");
                                  }
                                }


                                // Загрузка пациентов группы (онлайн/оффлайн) через репозиторий
                                await _patientRepository.fetchAndSavePatientsByGroup(group.id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PatientsListScreen(
                                      listTitle: group.code,
                                      organizationName: group.organizationTitle,
                                      groupId: group.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}