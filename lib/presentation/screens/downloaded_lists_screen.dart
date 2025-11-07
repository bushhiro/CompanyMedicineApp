import 'package:flutter/material.dart';
import 'package:work_app/widgets/action_buttons.dart';
import '../../data/local/dao/patient_group_dao.dart';
import '../../data/models/patient_group.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';

class DownloadedListsScreen extends StatefulWidget {
  const DownloadedListsScreen({super.key});

  @override
  State<DownloadedListsScreen> createState() => _DownloadedListsScreenState();
}

class _DownloadedListsScreenState extends State<DownloadedListsScreen> {
  final PatientGroupDao _dao = PatientGroupDao();
  late Future<List<PatientGroupShortResponse>> _futureGroups;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    setState(() {
      _futureGroups = _dao.getAllGroups();
    });
  }

  void _deleteGroup(int id) async {
    await _dao.deleteGroup(id);
    _loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: const CustomAppBar(
        title: "Скачанные списки",
        showSearchField: true,
      ),
      drawer: const CustomDrawer(),
      body: FutureBuilder<List<PatientGroupShortResponse>>(
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
            padding: const EdgeInsets.all(8),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Card(
                color: AppColors.primaryColor,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.borderColor,
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.code,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryTextColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Дата создания: ${group.createdAt.day.toString().padLeft(2,'0')}.${group.createdAt.month.toString().padLeft(2,'0')}.${group.createdAt.year}",
                            style: const TextStyle(fontSize: 14, color: AppColors.hintColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Организация: ${group.organizationTitle}",
                            style: const TextStyle(fontSize: 14, color: AppColors.hintColor),
                          ),
                        ],
                      ),
                      ActionButtons(
                        showOpen: true,
                        openLabel: "Удалить",
                        onOpen: () => _deleteGroup(group.id),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}