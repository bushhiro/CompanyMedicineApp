import 'package:flutter/material.dart';

// Модель пациента
class Patient {
  final String surname;
  final String name;
  final String patronymic;
  final DateTime? birthDate;
  final String phone;
  final bool snilsRefused;
  final String snils;
  final String docType;
  final String gender;
  final String docSeries;
  final String docNumber;
  final String address;
  final String polis;
  final String workPlace;
  final String position;
  final String subdivision;
  final String hazard;
  final String examType;
  final String examKind;
  final String email;

  Patient({
    required this.surname,
    required this.name,
    required this.patronymic,
    required this.birthDate,
    required this.phone,
    required this.snilsRefused,
    required this.snils,
    required this.docType,
    required this.gender,
    required this.docSeries,
    required this.docNumber,
    required this.address,
    required this.polis,
    required this.workPlace,
    required this.position,
    required this.subdivision,
    required this.hazard,
    required this.examType,
    required this.examKind,
    required this.email,
  });
}

// Форма добавления пациента
class PatientForm extends StatefulWidget {
  final Function(Patient) onSave;

  const PatientForm({super.key, required this.onSave});

  @override
  State<PatientForm> createState() => _PatientFormState();
}

class _PatientFormState extends State<PatientForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController surnameCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController patronymicCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController snilsCtrl = TextEditingController();
  final TextEditingController docSeriesCtrl = TextEditingController();
  final TextEditingController docNumberCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController polisCtrl = TextEditingController();
  final TextEditingController workCtrl = TextEditingController();
  final TextEditingController positionCtrl = TextEditingController();
  final TextEditingController subdivisionCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();

  DateTime? birthDate;
  bool snilsRefused = false;

  String? docType;
  String? gender;
  String? hazard;
  String? examType;
  String? examKind;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              "Добавление пациента",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              childAspectRatio: 3.2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                TextFormField(controller: surnameCtrl, decoration: const InputDecoration(labelText: "Фамилия")),
                TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Имя")),
                TextFormField(controller: patronymicCtrl, decoration: const InputDecoration(labelText: "Отчество")),

                // Дата рождения
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => birthDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: "Дата рождения"),
                    child: Text(birthDate != null
                        ? "${birthDate!.day.toString().padLeft(2,'0')}.${birthDate!.month.toString().padLeft(2,'0')}.${birthDate!.year}"
                        : "Выбрать"),
                  ),
                ),

                TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Телефон")),

                // СНИЛС + отказ
                Column(
                  children: [
                    TextFormField(
                      controller: snilsCtrl,
                      enabled: !snilsRefused,
                      decoration: const InputDecoration(labelText: "СНИЛС"),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: snilsRefused,
                          onChanged: (v) => setState(() => snilsRefused = v ?? false),
                        ),
                        const Text("Отказ"),
                      ],
                    ),
                  ],
                ),

                // Тип документа
                DropdownButtonFormField<String>(
                  value: docType,
                  items: ["Паспорт", "Загранпаспорт", "Водительское удостоверение"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => docType = v),
                  decoration: const InputDecoration(labelText: "Тип документа"),
                ),

                // Пол
                DropdownButtonFormField<String>(
                  value: gender,
                  items: ["Мужской", "Женский"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => gender = v),
                  decoration: const InputDecoration(labelText: "Пол"),
                ),

                TextFormField(controller: docSeriesCtrl, decoration: const InputDecoration(labelText: "Серия документа")),
                TextFormField(controller: docNumberCtrl, decoration: const InputDecoration(labelText: "Номер документа")),
                TextFormField(controller: addressCtrl, decoration: const InputDecoration(labelText: "Адрес")),
                TextFormField(controller: polisCtrl, decoration: const InputDecoration(labelText: "Полис")),
                TextFormField(controller: workCtrl, decoration: const InputDecoration(labelText: "Место работы")),
                TextFormField(controller: positionCtrl, decoration: const InputDecoration(labelText: "Должность")),
                TextFormField(controller: subdivisionCtrl, decoration: const InputDecoration(labelText: "Подразделение")),

                DropdownButtonFormField<String>(
                  value: hazard,
                  items: ["Нет", "Химия", "Физика", "Биология"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => hazard = v),
                  decoration: const InputDecoration(labelText: "Пункт вредности"),
                ),

                DropdownButtonFormField<String>(
                  value: examType,
                  items: ["Предварительный", "Периодический", "Внеплановый"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => examType = v),
                  decoration: const InputDecoration(labelText: "Вид осмотра"),
                ),

                DropdownButtonFormField<String>(
                  value: examKind,
                  items: ["Общий", "Специальный", "Целевой"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => examKind = v),
                  decoration: const InputDecoration(labelText: "Тип осмотра"),
                ),

                TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Электронная почта")),
              ],
            ),

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSave(Patient(
                    surname: surnameCtrl.text,
                    name: nameCtrl.text,
                    patronymic: patronymicCtrl.text,
                    birthDate: birthDate,
                    phone: phoneCtrl.text,
                    snilsRefused: snilsRefused,
                    snils: snilsCtrl.text,
                    docType: docType ?? "",
                    gender: gender ?? "",
                    docSeries: docSeriesCtrl.text,
                    docNumber: docNumberCtrl.text,
                    address: addressCtrl.text,
                    polis: polisCtrl.text,
                    workPlace: workCtrl.text,
                    position: positionCtrl.text,
                    subdivision: subdivisionCtrl.text,
                    hazard: hazard ?? "",
                    examType: examType ?? "",
                    examKind: examKind ?? "",
                    email: emailCtrl.text,
                  ));
                  Navigator.pop(context); // закрываем диалог
                }
              },
              child: const Text("Сохранить"),
            ),
          ],
        ),
      ),
    );
  }
}