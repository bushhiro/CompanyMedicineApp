import 'package:flutter/material.dart';
import '/widgets/custom_app_bar.dart';
import '/widgets/custom_drawer.dart';

class DownloadedListsScreen extends StatelessWidget {
  const DownloadedListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Заглушка для скачанных списков
    final List<Map<String, String>> downloadedLists = [
      {
        "title": "Список пациентов",
        "date": "18.09.2025",
        "organization": "Клиника №1"
      },
      {
        "title": "Список организаций",
        "date": "15.09.2025",
        "organization": "Медцентр «Здоровье»"
      },
      {
        "title": "Список анализов",
        "date": "10.09.2025",
        "organization": "Аптека №24"
      },
    ];

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Скачанные списки",
        showSearchField: true,
      ),
      drawer: const CustomDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: downloadedLists.length,
        itemBuilder: (context, index) {
          final list = downloadedLists[index];
          return _DownloadedListCard(
            title: list["title"]!,
            date: list["date"]!,
            organization: list["organization"]!,
          );
        },
      ),
    );
  }
}

class _DownloadedListCard extends StatelessWidget {
  final String title;
  final String date;
  final String organization;

  const _DownloadedListCard({
    required this.title,
    required this.date,
    required this.organization,
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
            // Верхняя строка: название и дата
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название и дата слева
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
                      const SizedBox(height: 4),
                      Text(
                        "Организация: $organization",
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Кнопка "Выгрузить в 1С" справа
                ElevatedButton.icon(
                  onPressed: () {
                    debugPrint("Выгрузить $title в 1С");
                  },
                  icon: const Icon(Icons.upload, size: 18), // иконка загрузки
                  label: const Text("Выгрузить в 1С"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Кнопка "Открыть" внизу
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  debugPrint("Открыть $title");
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