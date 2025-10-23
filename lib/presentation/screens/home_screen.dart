import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/patient_group.dart'; // здесь твоя модель Organization
import '../../theme/app_colors.dart';
import '../../widgets/custom_organization_card.dart';
import '/widgets/custom_app_bar.dart';
import '/widgets/custom_drawer.dart';
import '../../widgets/action_buttons.dart';
import '../screens/patient_group_screen.dart';

class HomeScreen extends StatefulWidget {
  final String doctorName;

  const HomeScreen({super.key, required this.doctorName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Organization>> _futureOrganizations;
  List<Organization> _allOrganizations = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _futureOrganizations = _fetchOrganizations();
  }

  Future<List<Organization>> _fetchOrganizations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('JWT токен не найден');

    final url = Uri.parse('http://192.168.29.112:65322/swagger/index.html#/');
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
      final orgs = hits.map((e) => Organization.fromJson(e)).toList();

      setState(() {
        _allOrganizations = orgs;
      });

      return _allOrganizations;
    } else if (response.statusCode == 401) {
      throw Exception('Неавторизованный доступ. Проверьте токен');
    } else {
      throw Exception('Ошибка сервера: ${response.statusCode}\n${response.body}');
    }
  }

  List<Organization> _applyFilters() {
    if (_searchQuery.isEmpty) return _allOrganizations;

    return _allOrganizations.where((org) {
      return org.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _reloadOrganizations() {
    setState(() {
      _futureOrganizations = _fetchOrganizations();
    });
  }

  void _clearOrganizations() {
    setState(() {
      _allOrganizations = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrganizations = _applyFilters();

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: CustomAppBar(
        title: "Список организаций",
        subtitle: "Всего организаций: ${filteredOrganizations.length}",
        showDrawerButton: true,
        showSearchField: true,
        onSearch: (query) => setState(() {
          _searchQuery = query;
        }),
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          ActionButtons(
            reloadOrganizations: _reloadOrganizations,
            showRefresh: true,
            refreshLabel: "Обновить список",
            onClear: _clearOrganizations,
          ),
          Expanded(
            child: FutureBuilder<List<Organization>>(
              future: _futureOrganizations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Ошибка: ${snapshot.error}"));
                }

                if (filteredOrganizations.isEmpty) {
                  return const Center(child: Text("Организации не найдены"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredOrganizations.length,
                  itemBuilder: (context, index) {
                    final org = filteredOrganizations[index];
                    final doctor = org.managerName ?? "-";
                    final phone = org.managerPhone ?? "-";

                    return OrganizationCard(
                      logo: Icons.local_hospital,
                      name: org.title,
                      doctor: doctor,
                      phone: phone,
                      onOpen: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientGroupsScreen(
                              organizationName: org.title,
                              organizationId: org.id.toString(),
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
}