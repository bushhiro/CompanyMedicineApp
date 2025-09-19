import 'package:flutter/material.dart';

class PatientCard extends StatelessWidget {
  final String fullName;
  final String position;
  final String workplace;
  final String birthDate;
  final int age;
  final int specialistsDone;
  final int specialistsTotal;
  final int testsDone;
  final int testsTotal;
  final VoidCallback onContact;
  final VoidCallback onExamine;

  const PatientCard({
    super.key,
    required this.fullName,
    required this.position,
    required this.workplace,
    required this.birthDate,
    required this.age,
    required this.specialistsDone,
    required this.specialistsTotal,
    required this.testsDone,
    required this.testsTotal,
    required this.onContact,
    required this.onExamine,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: DefaultTabController(
        length: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Вкладки
            const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "Общая информация"),
                Tab(text: "Прививки"),
                Tab(text: "ФЛГ"),
                Tab(text: "Согласие"),
              ],
            ),

            // Содержимое вкладок
            SizedBox(
              height: 260,
              child: TabBarView(
                children: [
                  _buildPatientInfoTab(),
                  Center(child: Text("Прививки")), // заглушка
                  Center(child: Text("ФЛГ")),      // заглушка
                  Center(child: Text("Согласие")), // заглушка
                ],
              ),
            ),

            const Divider(height: 1),

            // Нижние кнопки
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onContact,
                      child: const Text("Контактные данные"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onExamine,
                      child: const Text("Осмотреть"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fullName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text("основное", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(position, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 2),
          Text(workplace, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text("Дата рождения: $birthDate", style: const TextStyle(fontSize: 12)),
          Text("Возраст: $age", style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person, size: 18),
                label: Text("Специалисты $specialistsDone из $specialistsTotal"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.science, size: 18),
                label: Text("Анализы $testsDone из $testsTotal"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}