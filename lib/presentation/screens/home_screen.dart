import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_app/presentation/screens/patient_group_screen.dart';

import '../../theme/app_colors.dart';
import '../../widgets/custom_organization_card.dart';
import '/widgets/custom_app_bar.dart';
import '/widgets/custom_drawer.dart';
import '../../widgets/action_buttons.dart';

class HomeScreen extends StatefulWidget {
  final String doctorName;

  const HomeScreen({super.key, required this.doctorName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _futureOrganizations;

  @override
  void initState() {
    super.initState();
    _futureOrganizations = _fetchOrganizations();
  }

  Future<List<Map<String, dynamic>>> _fetchOrganizations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('JWT токен не найден');

    final url = Uri.parse('http://10.0.2.2:8081/api/v1/organization/getAll');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final hits = jsonData['data']['hits'] as List<dynamic>;
      return hits.map((e) => Map<String, dynamic>.from(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Неавторизованный доступ. Проверьте токен');
    } else {
      throw Exception('Ошибка сервера: ${response.statusCode}\n${response.body}');
    }
  }

  void _reloadOrganizations() {
    setState(() {
      _futureOrganizations = _fetchOrganizations();
    });
  }

  void _clearOrganizations() {
    setState(() {
      _futureOrganizations = Future.value([]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureOrganizations,
      builder: (context, snapshot) {
        final organizations = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: AppColors.primaryColor,
          appBar: CustomAppBar(
            title: "Список организаций",
            subtitle: snapshot.connectionState == ConnectionState.done
                ? "Всего организаций: ${organizations.length}"
                : "Загрузка...",
            showSearchField: true,
            showDrawerButton: true,
            onSearch: (query) => debugPrint("Поиск: $query"),
          ),
          drawer: const CustomDrawer(),
          body: Column(
            children: [
              // Встраиваем ActionButtons сразу под AppBar
              ActionButtons(
                reloadOrganizations: _reloadOrganizations,
                showRefresh: true,
                refreshLabel: "Обновить список",
                onClear: _clearOrganizations,
              ),

              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : snapshot.hasError
                    ? Center(child: Text("Ошибка: ${snapshot.error}"))
                    : organizations.isEmpty
                    ? const Center(child: Text("Нет организаций"))
                    : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: organizations.length,
                  itemBuilder: (context, index) {
                    final org = organizations[index];
                    final doctor = (org["manager"] != null &&
                        org["manager"]["full_name"] != null)
                        ? org["manager"]["full_name"] as String
                        : "-";
                    final phone = (org["manager"] != null &&
                        org["manager"]["phone"] != null)
                        ? org["manager"]["phone"] as String
                        : "-";
                    return OrganizationCard(
                      logo: Icons.local_hospital,
                      name: org["title"] ?? "Без названия",
                      doctor: doctor,
                      phone: phone,
                      onOpen: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientGroupsScreen(
                              organizationName:
                              org["title"] ?? "",
                              organizationId: org["id"].toString(),
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
      },
    );
  }
}