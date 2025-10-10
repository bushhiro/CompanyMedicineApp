import 'package:flutter/material.dart';
import '../../data/models/patient_group.dart';
import '../../data/repositories/patient_group_impl.dart';
import '../../widgets/action_buttons.dart';
import '../../widgets/custom_app_bar.dart';
import '../patients_list_screen.dart';

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
  late final PatientGroupImpl _service;
  late Future<List<PatientGroupShortResponse>> _futureGroups;

  @override
  void initState() {
    super.initState();
    _service = PatientGroupImpl(baseUrl: 'http://10.0.2.2:8081/api/v1');
    _loadGroups();
  }

  void _loadGroups() {
    setState(() {
      _futureGroups = _service.getGroupsByOrganization(widget.organizationId);
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2,'0')}.${date.month.toString().padLeft(2,'0')}.${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Списки на прохождение",
        subtitle: "Организация: ${widget.organizationName}",
        showBackButton: true,
        showDrawerButton: false,
      ),
      body: Column(
        children: [
          ActionButtons(
            reloadOrganizations: _loadGroups,
            showRefresh: true,
            showClear: false,
            refreshLabel: "Обновить списки",
          ),
          Expanded(
            child: FutureBuilder<List<PatientGroupShortResponse>>(
              future: _futureGroups,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Ошибка: ${snapshot.error}"));
                }

                final groups = snapshot.data ?? [];
                if (groups.isEmpty) {
                  return const Center(child: Text("Нет списков"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        group.code,
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Дата создания: ${_formatDate(group.createdAt)}",
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Организация: ${group.organizationTitle}",
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ActionButtons(
                                showOpen: true,
                                onOpen: () {
                                  DownloadedGroupsService().addGroup(group); // добавляем глобально
                                  print("ADDEEDD");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PatientsListScreen(
                                        listTitle: group.code,
                                        organizationName: group.organizationTitle,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

