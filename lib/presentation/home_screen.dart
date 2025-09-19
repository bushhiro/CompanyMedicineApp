import 'package:flutter/material.dart';
import '/widgets/custom_app_bar.dart';
import '/widgets/custom_drawer.dart';
import '/presentation/medical_examination_lists_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Заглушка для данных (в реальности подтягиваешь из бэкенда)
  final List<Map<String, dynamic>> organizations = [
    {
      "logo": Icons.local_hospital,
      "name": "Клиника №1",
      "doctor": "Иванов И.И.",
      "phone": "+7 (999) 123-45-67"
    },
    {
      "logo": Icons.local_pharmacy,
      "name": "Аптека №24",
      "doctor": "Петров П.П.",
      "phone": "+7 (812) 555-12-34"
    },
    {
      "logo": Icons.local_hospital,
      "name": "Медцентр «Здоровье»",
      "doctor": "Сидорова А.А.",
      "phone": "+7 (495) 222-33-44"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Список организаций",
        subtitle: "Всего организаций: ${organizations.length}",
        showSearchField: true,
        onSearch: (query) {
          // Фильтрация списка по названию можно реализовать здесь
          debugPrint("Поиск: $query");
        },
      ),
      drawer: const CustomDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Кнопка обновления списка
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  debugPrint("Обновить список");
                  // здесь логика обновления списка из бэкенда
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Обновить"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),

          // Список организаций
          Expanded(
            child: ListView.builder(
              itemCount: organizations.length,
              itemBuilder: (context, index) {
                final org = organizations[index];
                return _OrganizationCard(
                  logo: org["logo"],
                  name: org["name"],
                  doctor: org["doctor"],
                  phone: org["phone"],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganizationCard extends StatelessWidget {
  final IconData logo;
  final String name;
  final String doctor;
  final String phone;

  const _OrganizationCard({
    required this.logo,
    required this.name,
    required this.doctor,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Верхняя часть: логотип + название + кнопка "Открыть"
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(logo, size: 40, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Переход на страницу медицинских списков
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicalExaminationListsScreen(
                          organizationName: name,
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
              ],
            ),
          ),

          // Нижняя часть: фон серый, текст врач/телефон
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Врач организации: $doctor",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                Text(
                  phone,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}