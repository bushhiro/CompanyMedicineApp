import 'package:flutter/material.dart';
import '/widgets/custom_patient_card.dart';
import '/widgets/custom_app_bar.dart';
import '/widgets/custom_patient_form.dart';

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

  final List<Map<String, dynamic>> patients = [
    {
      "fullName": "Иванов Иван Иванович",
      "position": "Главный специалист",
      "workplace":
      "Комитет по социальной защите населения Ленинградской области",
      "birthDate": "12.03.1980",
      "age": 45,
      "specialistsDone": 0,
      "specialistsTotal": 6,
      "testsDone": 3,
      "testsTotal": 4,
      "specialists": [
        {"title": "Заключение врача психиатра-нарколога", "status": false},
        {"title": "Заключение врача психиатра", "status": false},
        {"title": "Заключение врача невролога", "status": true},
        {"title": "Заключение врача терапевта", "status": false},
        {"title": "ЭКГ Паспорт здоровья", "status": false},
        {"title": "Медицинское заключение комиссии", "status": true},
        {"title": "Медсестра", "status": false},
      ],
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
      "specialists": [
        {"title": "Заключение врача психиатра", "status": true},
        {"title": "Заключение врача невролога", "status": true},
        {"title": "Заключение врача терапевта", "status": false},
        {"title": "Медицинское заключение комиссии", "status": false},
        {"title": "Медсестра", "status": true},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.listTitle,
        subtitle: widget.organizationName,
        showBackButton: true,
        showDownloadAll: false,
        showAddPatient: true,
        onBack: () => Navigator.pop(context),
        onAddPatient: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => Dialog(
              insetPadding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: PatientForm(
                  onSave: (patient) {
                    setState(() {
                      patients.add({
                        "fullName":
                        "${patient.surname} ${patient.name} ${patient.patronymic}",
                        "position": patient.position,
                        "workplace": patient.workPlace,
                        "birthDate": patient.birthDate != null
                            ? "${patient.birthDate!.day.toString().padLeft(2, '0')}.${patient.birthDate!.month.toString().padLeft(2, '0')}.${patient.birthDate!.year}"
                            : "",
                        "age": patient.birthDate != null
                            ? DateTime.now().year - patient.birthDate!.year
                            : 0,
                        "specialistsDone": 0,
                        "specialistsTotal": 0,
                        "testsDone": 0,
                        "testsTotal": 0,
                        "specialists": [
                          {"title": "Медсестра", "status": false},
                        ],
                      });
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          );
        },
      ),
      body: Column(
        children: [
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
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 400,
                left: 12,
                right: 12,
              ),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final p = patients[index];

                final specialists =
                List<Map<String, dynamic>>.from(p["specialists"]);
                final doctors =
                specialists.where((s) => s["title"] != "Медсестра").toList();
                final nurse =
                specialists.where((s) => s["title"] == "Медсестра").toList();

                return PatientCard(
                  fullName: p["fullName"] as String,
                  position: p["position"] as String,
                  workplace: p["workplace"] as String,
                  birthDate: p["birthDate"] as String,
                  age: p["age"] as int,
                  specialistsDone: p["specialistsDone"] as int,
                  specialistsTotal: doctors.length,
                  testsDone: p["testsDone"] as int,
                  testsTotal: p["testsTotal"] as int,
                  specialists: doctors,
                  onContact: () {
                    debugPrint("Контакты пациента: ${p["fullName"]}");
                  },
                  onExamine: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final allSpecialists = [...doctors, ...nurse];

                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text("Осмотр ${p["fullName"]}"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: allSpecialists.map((s) {
                              final bool isNurse = s["title"] == "Медсестра";
                              final status = s["status"] == true ? "Пройдено" : "Не пройдено";

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade100,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                  onPressed: () {
                                    debugPrint("Нажата кнопка: ${s["title"]}");
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(s["title"])),
                                      if (!isNurse)
                                        Text(
                                          status,
                                          style: TextStyle(
                                            color: status == "Пройдено"
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Закрыть"),
                            ),
                          ],
                        );
                      },
                    );
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