import 'package:flutter/material.dart';
import '/services/db_services.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '/widgets/custom_app_bar.dart';
import '/widgets/custom_drawer.dart';
import '/presentation/medical_examination_lists_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBService dbService = DBService();
  late Future<List<Map<String, dynamic>>> _futureOrganizations;

  @override
  void initState() {
    super.initState();
    _futureOrganizations = dbService.getOrganizations();
  }

  void _reloadOrganizations() {
    setState(() {
      _futureOrganizations = dbService.getOrganizations();
    });
  }

  Future<void> _loadOrganizationsFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/organizations.json');
      final List<dynamic> data = json.decode(jsonString);

      // Получаем уже существующие организации из базы
      final existingOrgs = await dbService.getOrganizations();
      final existingNames = existingOrgs.map((e) => e["name"] as String).toSet();

      // Добавляем только новые записи
      for (final org in data) {
        if (!existingNames.contains(org["name"])) {
          await dbService.insertOrganization({
            "name": org["name"],
            "doctor": org["doctor"],
            "phone": org["phone"],
          });
        }
      }

      _reloadOrganizations(); // обновляем FutureBuilder

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Организации успешно загружены")),
      );
    } catch (e) {
      debugPrint("Ошибка при загрузке JSON: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка загрузки данных: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Список организаций",
        subtitle: "Организации",
        showSearchField: true,
        onSearch: (query) {
          debugPrint("Поиск: $query");
        },
      ),
      drawer: const CustomDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Старая кнопка обновления, теперь с функцией загрузки JSON
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadOrganizationsFromJson,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Обновить"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await dbService.clearOrganizations();
                      _reloadOrganizations(); // обновляем список
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("База данных очищена")),
                      );
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text("Очистить"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 14),
                      backgroundColor: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Список организаций из базы
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureOrganizations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Ошибка: ${snapshot.error}"));
                }

                final organizations = snapshot.data ?? [];
                if (organizations.isEmpty) {
                  return const Center(child: Text("Нет организаций в базе"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: organizations.length,
                  itemBuilder: (context, index) {
                    final org = organizations[index];
                    return _OrganizationCard(
                      logo: Icons.local_hospital,
                      name: org["name"] ?? "Без названия",
                      doctor: org["doctor"] ?? "-",
                      phone: org["phone"] ?? "-",
                      onOpen: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MedicalExaminationListsScreen(
                              organizationName: org["name"] ?? "",
                            ),
                          ),
                        );
                      },
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

  Future<void> loadOrganizationsFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/organizations.json');
      final List<dynamic> data = json.decode(jsonString);

      // Получаем уже существующие организации из базы
      final existingOrgs = await dbService.getOrganizations();
      final existingNames = existingOrgs.map((e) => e["name"] as String).toSet();

      // Добавляем только новые записи
      for (final org in data) {
        if (!existingNames.contains(org["name"])) {
          await dbService.insertOrganization({
            "name": org["name"],
            "doctor": org["doctor"],
            "phone": org["phone"],
          });
        }
      }

      _reloadOrganizations(); // обновляем FutureBuilder

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Организации успешно загружены")),
      );
    } catch (e) {
      debugPrint("Ошибка при загрузке JSON: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка загрузки данных: $e")),
      );
    }
  }

}

// ---------- OrganizationCard ---------- \\
class _OrganizationCard extends StatelessWidget {
  final IconData logo;
  final String name;
  final String doctor;
  final String phone;
  final VoidCallback onOpen;

  const _OrganizationCard({
    required this.logo,
    required this.name,
    required this.doctor,
    required this.phone,
    required this.onOpen,
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
                  onPressed: onOpen,
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
