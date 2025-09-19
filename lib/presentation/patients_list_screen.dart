import 'package:flutter/material.dart';
import '/widgets/custom_patient_card.dart';
import '/widgets/custom_app_bar.dart';

class PatientsListScreen extends StatefulWidget {
  final String listTitle;
  final String organizationName;

  const PatientsListScreen({
    super.key,
    required this.listTitle,
    required this.organizationName,
  });

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  bool showCompleted = false;
  bool showWithDebts = false;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // Заглушка списка пациентов
    final patients = [
      {
        "fullName": "Иванов Иван Иванович",
        "position": "Главный специалист",
        "workplace": "Комитет по социальной защите населения Ленинградской области",
        "birthDate": "12.03.1980",
        "age": 45,
        "specialistsDone": 0,
        "specialistsTotal": 6,
        "testsDone": 3,
        "testsTotal": 4,
      },
      {
        "fullName": "Петрова Мария Сергеевна",
        "position": "Врач-терапевт",
        "workplace": "Медицинский центр «Здоровье»",
        "birthDate": "05.07.1985",
        "age": 40,
        "specialistsDone": 2,
        "specialistsTotal": 5,
        "testsDone": 1,
        "testsTotal": 3,
      },
      {
        "fullName": "Сидоров Алексей Петрович",
        "position": "Старший специалист",
        "workplace": "Городская больница №7",
        "birthDate": "20.11.1978",
        "age": 46,
        "specialistsDone": 1,
        "specialistsTotal": 4,
        "testsDone": 2,
        "testsTotal": 2,
      },
      {
        "fullName": "Иванов Иван Иванович",
        "position": "Главный специалист",
        "workplace": "Комитет по социальной защите населения Ленинградской области",
        "birthDate": "12.03.1980",
        "age": 45,
        "specialistsDone": 0,
        "specialistsTotal": 6,
        "testsDone": 3,
        "testsTotal": 4,
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.listTitle,
        subtitle: widget.organizationName,
        showBackButton: true,
        showDownloadAll: true,
        onBack: () => Navigator.pop(context),
        onDownloadAll: () {
          debugPrint("Добавить нового пациента");
        },
      ),
      body: Column(
        children: [
          // Ряд фильтров и поиска
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Поиск пациента...",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Checkbox(
                        value: showCompleted,
                        onChanged: (value) {
                          setState(() {
                            showCompleted = value ?? false;
                          });
                        },
                      ),
                      const Flexible(child: Text("Показать завершенные")),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Checkbox(
                        value: showWithDebts,
                        onChanged: (value) {
                          setState(() {
                            showWithDebts = value ?? false;
                          });
                        },
                      ),
                      const Flexible(child: Text("Показать с долгами")),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final p = patients[index];
                return PatientCard(
                  fullName: p["fullName"] as String,
                  position: p["position"] as String,
                  workplace: p["workplace"] as String,
                  birthDate: p["birthDate"] as String,
                  age: p["age"] as int,
                  specialistsDone: p["specialistsDone"] as int,
                  specialistsTotal: p["specialistsTotal"] as int,
                  testsDone: p["testsDone"] as int,
                  testsTotal: p["testsTotal"] as int,
                  onContact: () {
                    debugPrint("Контактные данные ${p["fullName"]}");
                  },
                  onExamine: () {
                    debugPrint("Осмотреть ${p["fullName"]}");
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
