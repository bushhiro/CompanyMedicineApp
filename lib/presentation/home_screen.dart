import 'package:flutter/material.dart';
import 'package:work_app/presentation/screens/patient_group_screen.dart';

import '../domain/services/db_services.dart';
import '../widgets/custom_organization_card.dart';
import '/widgets/custom_app_bar.dart';
import '/widgets/custom_drawer.dart';

class Doctor {
  final String fullName;

  Doctor({required this.fullName});

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(fullName: json['full_name']);
  }
}

class HomeScreen extends StatefulWidget {
  final String doctorName;

  const HomeScreen({super.key, required this.doctorName});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Список организаций",
        subtitle: "Врач организации: ${widget.doctorName}",
        showSearchField: true,
        onSearch: (query) => debugPrint("Поиск: $query"),
      ),
      drawer: const CustomDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureOrganizations,
        builder: (context, snapshot) {
          final organizations = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Ошибка: ${snapshot.error}"));
          }
          if (organizations.isEmpty) {
            return const Center(child: Text("Нет организаций в базе"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: organizations.length,
            itemBuilder: (context, index) {
              final org = organizations[index];
              return OrganizationCard(
                logo: Icons.local_hospital,
                name: org["name"] ?? "Без названия",
                doctor: widget.doctorName,
                phone: org["phone"] ?? "-",
                onOpen: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientGroupsScreen(
                        organizationName: org["name"] ?? "", organizationId: '1',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}