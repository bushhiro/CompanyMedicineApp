import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/patient.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/custom_patient_card.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_patient_form.dart';

class PatientsListScreen extends StatefulWidget {
  final String listTitle;
  final String organizationName;
  final int groupId;

  const PatientsListScreen({
    super.key,
    required this.listTitle,
    required this.organizationName,
    required this.groupId,
  });

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  late Future<List<PatientResponse>> _futurePatients;
  List<PatientResponse> _allPatients = [];
  String _searchQuery = "";
  bool _showCompleted = false;
  bool _showDebts = false;

  @override
  void initState() {
    super.initState();
    _futurePatients = _fetchPatients();
  }

  Future<List<PatientResponse>> _fetchPatients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('JWT токен не найден.');

      final url = Uri.parse('http://192.168.29.112:65322/api/v1/patient-groups/${widget.groupId}/patients');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // ОТЛАДОЧНЫЙ ВЫВОД ДО ПРОВЕРКИ СТАТУСА
      print('=== RAW RESPONSE ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===================');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> patientsJson = jsonData['data'];

        final patients = <PatientResponse>[];

        for (var item in patientsJson) {
          try {
            print('Processing patient: ${item['id']}');
            print('is_male: ${item['is_male']} (type: ${item['is_male']?.runtimeType})');

            final patient = PatientResponse.fromJson(item as Map<String, dynamic>);
            patients.add(patient);
          } catch (e, stackTrace) {
            print('ERROR processing patient ${item['id']}: $e');
            print('Stack trace: $stackTrace');
            print('Problematic data: $item');
            rethrow;
          }
        }

        setState(() {
          _allPatients = patients;
        });

        return _allPatients;
      } else {
        throw Exception('Ошибка при получении пациентов: ${response.statusCode}\n${response.body}');
      }
    } catch (e, stackTrace) {
      print('General error in _fetchPatients: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  List<PatientResponse> _applyFilters() {
    return _allPatients.where((p) {
      final matchesSearch = p.fullName.toLowerCase().contains(_searchQuery.toLowerCase());

      final hasReceptionDebts = p.receptions?.any((r) => !r.isCompleted) ?? false;

      final hasAnalysisDebt = p.analysisOrder.orderItems.any((a) => !a.isCompleted);
      final isDebt = hasAnalysisDebt || hasReceptionDebts;
      final showCompleted = _showCompleted ? !isDebt : false;
      final showDebts = _showDebts ? isDebt : false;

      bool passesFilter;
      if (_showCompleted && _showDebts) {
        passesFilter = showCompleted || showDebts;
      } else if (_showCompleted) {
        passesFilter = showCompleted;
      } else if (_showDebts) {
        passesFilter = showDebts;
      } else {
        passesFilter = true;
      }

      return matchesSearch && passesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: CustomAppBar(
        title: "Список пациентов",
        subtitle: "Всего пациентов: ${_allPatients.length}",
        showBackButton: true,
        showDrawerButton: true,
        showAddPatient: true,
        onAddPatient: () async {
          final newPatient = await showDialog(
            context: context,
            builder: (_) => AddPatientFormDialog(groupId: widget.groupId),
          );

          if (newPatient != null) {
            setState(() {
              _futurePatients = _fetchPatients();
            });
          }
        },
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Поле поиска
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Поиск по ФИО...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Чекбоксы
                Row(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _showCompleted,
                          onChanged: (v) => setState(() => _showCompleted = v ?? false),
                        ),
                        const Text("Показать завершенных", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _showDebts,
                          onChanged: (v) => setState(() => _showDebts = v ?? false),
                        ),
                        const Text("Показать с долгами", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<PatientResponse>>(
              future: _futurePatients,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Ошибка: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final patients = _applyFilters();
                if (patients.isEmpty) {
                  return const Center(child: Text("Пациенты не найдены"));
                }

                return ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return CustomPatientCard(
                      patient: patient,
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