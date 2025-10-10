import 'package:flutter/material.dart';
import '../../data/models/patient_group.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';

class DownloadedListsScreen extends StatelessWidget {
  const DownloadedListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final downloadedLists = DownloadedGroupsService().groups;

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Скачанные списки",
        showSearchField: true,
      ),
      drawer: const CustomDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: downloadedLists.length,
        itemBuilder: (context, index) {
          final group = downloadedLists[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    group.code,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Дата создания: ${group.createdAt.day.toString().padLeft(2,'0')}.${group.createdAt.month.toString().padLeft(2,'0')}.${group.createdAt.year}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Организация: ${group.organizationTitle}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      debugPrint("Выгрузить ${group.code} в 1С");
                    },
                    icon: const Icon(Icons.upload, size: 18),
                    label: const Text("Выгрузить в 1С"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}