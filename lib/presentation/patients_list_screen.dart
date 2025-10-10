import 'package:flutter/material.dart';
import '../widgets/custom_patient_card.dart';

class PatientsListScreen extends StatelessWidget {
  final String listTitle;
  final String organizationName;

  const PatientsListScreen({
    super.key,
    required this.listTitle,
    required this.organizationName,
  });

  @override
  Widget build(BuildContext context) {
    final patients = [
      {
        "fullName": "Иванов Иван Иванович",
        "position": "Водитель",
        "workplace": "Клиника А",
        "birthDate": "1985-06-10",
        "age": 40,
        "specialistsDone": 2,
        "specialistsTotal": 5,
        "testsDone": 1,
        "testsTotal": 3,
        "specialists": [
          {"title": "Терапевт", "status": true},
          {"title": "Хирург", "status": false},
        ],
      },
      {
        "fullName": "Петров Петр Петрович",
        "position": "Механик",
        "workplace": "Клиника А",
        "birthDate": "1990-02-15",
        "age": 35,
        "specialistsDone": 3,
        "specialistsTotal": 5,
        "testsDone": 2,
        "testsTotal": 4,
        "specialists": [
          {"title": "Терапевт", "status": true},
          {"title": "Офтальмолог", "status": true},
          {"title": "Психиатр", "status": false},
        ],
      },
      {
        "fullName": "Петров Петр Петрович",
        "position": "Механик",
        "workplace": "Клиника А",
        "birthDate": "1990-02-15",
        "age": 35,
        "specialistsDone": 3,
        "specialistsTotal": 5,
        "testsDone": 2,
        "testsTotal": 4,
        "specialists": [
          {"title": "Терапевт", "status": true},
          {"title": "Офтальмолог", "status": true},
          {"title": "Психиатр", "status": false},
        ],
      },
      {
        "fullName": "Иванов Иван Иванович",
        "position": "Водитель",
        "workplace": "Клиника А",
        "birthDate": "1985-06-10",
        "age": 40,
        "specialistsDone": 2,
        "specialistsTotal": 5,
        "testsDone": 1,
        "testsTotal": 3,
        "specialists": [
          {"title": "Терапевт", "status": true},
          {"title": "Хирург", "status": false},
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Пациенты группы $listTitle"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Добавить пациента',
            onPressed: () {
              debugPrint("Добавить пациента в группу $listTitle");
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final p = patients[index];
          return CustomPatientCard(
            fullName: p["fullName"] as String,
            position: p["position"] as String,
            workplace: p["workplace"] as String,
            birthDate: p["birthDate"] as String,
            age: p["age"] as int,
            specialistsDone: p["specialistsDone"] as int,
            specialistsTotal: p["specialistsTotal"] as int,
            testsDone: p["testsDone"] as int,
            testsTotal: p["testsTotal"] as int,
            specialists: (p["specialists"] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
            onContact: () {
              debugPrint("Контактные данные ${p["fullName"]}");
            },
            onExamine: () {
              debugPrint("Осмотр ${p["fullName"]}");
            },
          );
        },
      ),
    );
  }
}