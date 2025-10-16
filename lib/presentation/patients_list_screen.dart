import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/patient.dart';
import '../widgets/custom_patient_card.dart';

class PatientsListScreen extends StatefulWidget {
  final String listTitle;
  final String organizationName;
  final int groupId; // <-- теперь передаём ID группы

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

  @override
  void initState() {
    super.initState();
    _futurePatients = _fetchPatients();
  }

  /// Получаем пациентов по ID группы
  Future<List<PatientResponse>> _fetchPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('JWT токен не найден. Авторизуйтесь заново.');

    final url = Uri.parse('http://10.0.2.2:8081/api/v1/patients/${widget.groupId}');
    print("Запрос к API: $url");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> patientsJson = jsonData['data'];

      return patientsJson
          .map((item) => PatientResponse.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Ошибка при получении пациентов: ${response.statusCode}\n${response.body}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Пациенты группы ${widget.listTitle}"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: FutureBuilder<List<PatientResponse>>(
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

          final patients = snapshot.data ?? [];
          if (patients.isEmpty) {
            return const Center(child: Text("Нет пациентов в этой группе"));
          }

          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return CustomPatientCard(
                patient: patient,
                onContact: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Контактные данные"),
                      content: Text(
                        "Телефон: ${patient.contactInfo.phone}\n"
                            "Email: ${patient.contactInfo.email}\n"
                            "Адрес: ${patient.contactInfo.address}",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Закрыть"),
                        ),
                      ],
                    ),
                  );
                },
                onExamine: () {
                  debugPrint("Открыт осмотр для: ${patient.fullName}");
                },
              );
            },
          );
        },
      ),
    );
  }
}