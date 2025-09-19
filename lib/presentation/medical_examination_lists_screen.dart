import 'package:flutter/material.dart';
import '/presentation/patients_list_screen.dart';
import '/widgets/custom_app_bar.dart';

class MedicalExaminationListsScreen extends StatelessWidget {
  final String organizationName;

  const MedicalExaminationListsScreen({super.key, required this.organizationName});

  @override
  Widget build(BuildContext context) {
    // Заглушка для списков медицинских осмотров
    final List<Map<String, String>> examinationLists = [
      {"title": "Список пациентов", "date": "18.09.2025"},
      {"title": "Список анализов", "date": "15.09.2025"},
      {"title": "Список процедур", "date": "10.09.2025"},
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: "Списки на прохождение",
        subtitle: "Всего списков: ${examinationLists.length}",
        showBackButton: true,
        showDownloadAll: true,
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  debugPrint("Обновить списки для $organizationName");
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Обновить списки"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: examinationLists.length,
              itemBuilder: (context, index) {
                final list = examinationLists[index];
                return _MedicalExaminationListCard(
                  title: list["title"]!,
                  date: list["date"]!,
                  organizationName: organizationName,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalExaminationListCard extends StatelessWidget {
  final String title;
  final String date;
  final String organizationName;

  const _MedicalExaminationListCard({
    required this.title,
    required this.date,
    required this.organizationName,
  });

  @override
  Widget build(BuildContext context) {
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
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Дата создания: $date",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Организация: $organizationName",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    debugPrint("Удалить $title");
                  },
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text("Удалить"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 14),
                    backgroundColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientsListScreen(
                        listTitle: title,
                        organizationName: organizationName,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(fontSize: 14),
                ),
                child: const Text("Открыть"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}